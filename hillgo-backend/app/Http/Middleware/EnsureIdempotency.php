<?php

namespace App\Http\Middleware;

use App\Models\IdempotencyKey;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Backend 7.4.21 — opt-in idempotency for POST create / status-transition
 * routes (rides/orders/parcels). Clients that send an `Idempotency-Key`
 * header get the exact same response replayed for ~24h if the request is
 * retried (e.g. after a timeout where the server actually processed it);
 * clients that don't send the header are unaffected — this never changes
 * existing route paths or breaks callers that predate this middleware.
 */
class EnsureIdempotency
{
    private const TTL_HOURS = 24;

    public function handle(Request $request, Closure $next): Response
    {
        $key = $request->header('Idempotency-Key');
        if (! $key) {
            return $next($request);
        }
        if (strlen($key) > 200) {
            return response()->json(['message' => 'Idempotency-Key header is too long.'], 422);
        }

        $userId = $request->user()?->id;
        $method = $request->method();
        $path = $request->path();
        $fingerprint = hash('sha256', $request->getContent());

        // Cheap opportunistic cleanup of expired rows — never blocks the request.
        IdempotencyKey::where('expires_at', '<', now())->limit(50)->delete();

        $record = IdempotencyKey::where('user_id', $userId)
            ->where('method', $method)
            ->where('path', $path)
            ->where('key', $key)
            ->where('expires_at', '>=', now())
            ->first();

        if ($record) {
            if ($record->request_fingerprint !== $fingerprint) {
                return response()->json([
                    'message' => 'This Idempotency-Key was already used with a different request body.',
                ], 409);
            }
            if ($record->response_status !== null) {
                return response($record->response_body, $record->response_status)
                    ->header('Content-Type', 'application/json')
                    ->header('Idempotency-Replayed', 'true');
            }
            // Record exists but has no stored response yet — a duplicate arrived
            // while the first request was still in flight. Let it through rather
            // than blocking the client indefinitely; the response overwrite below
            // is a last-write-wins on the ledger row, which is acceptable for a
            // narrow race and far better than silently dropping the retry.
        } else {
            $record = IdempotencyKey::create([
                'user_id' => $userId,
                'method' => $method,
                'path' => $path,
                'key' => $key,
                'request_fingerprint' => $fingerprint,
                'expires_at' => now()->addHours(self::TTL_HOURS),
            ]);
        }

        $response = $next($request);

        $record->update([
            'response_status' => $response->getStatusCode(),
            'response_body' => $response->getContent(),
        ]);

        return $response;
    }
}

<?php

/**
 * Dual-bot real-time ride test.
 *
 * Bot A (customer) books a ride.
 * Bot B (rider) goes online, polls for THAT ride's offer, accepts it.
 * Writes a timeline JSON for tracking.
 *
 * Usage: php scripts/ride_bots.php
 */

declare(strict_types=1);

$base = getenv('HILLGO_API_BASE') ?: 'http://127.0.0.1:8000/api';
$password = getenv('SEED_DEMO_PASSWORD') ?: 'HillGoDemo@2026!';
$outPath = __DIR__ . '/../storage/app/ride_bots_last_run.json';

$timeline = [];
$t0 = microtime(true);

function elapsed(): float
{
    global $t0;

    return round((microtime(true) - $t0) * 1000);
}

function logStep(string $bot, string $step, array $data = [], string $status = 'ok'): void
{
    global $timeline;
    $entry = [
        'ms' => elapsed(),
        'bot' => $bot,
        'step' => $step,
        'status' => $status,
        'data' => $data,
        'at' => date('c'),
    ];
    $timeline[] = $entry;
    echo sprintf(
        "[%5dms] %-8s %-28s %s %s\n",
        $entry['ms'],
        strtoupper($bot),
        $step,
        $status,
        $data === [] ? '' : json_encode($data, JSON_UNESCAPED_SLASHES)
    );
}

function httpJson(string $method, string $url, ?array $body = null, ?string $token = null): array
{
    $ch = curl_init($url);
    $headers = ['Accept: application/json', 'Content-Type: application/json'];
    if ($token) {
        $headers[] = 'Authorization: Bearer '.$token;
    }
    curl_setopt_array($ch, [
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => $headers,
        CURLOPT_TIMEOUT => 20,
    ]);
    if ($body !== null) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($body));
    }
    $raw = curl_exec($ch);
    $code = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $err = curl_error($ch);
    if ($raw === false) {
        throw new RuntimeException("HTTP error: {$err}");
    }
    $json = json_decode($raw, true);
    if (! is_array($json)) {
        throw new RuntimeException("Invalid JSON (HTTP {$code}): {$raw}");
    }
    if ($code >= 400) {
        $msg = $json['message'] ?? ($json['error'] ?? "HTTP {$code}");
        throw new RuntimeException(is_string($msg) ? $msg : json_encode($msg));
    }

    return $json;
}

function saveResult(string $path, array $payload): void
{
    $dir = dirname($path);
    if (! is_dir($dir)) {
        mkdir($dir, 0777, true);
    }
    file_put_contents($path, json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
}

/** Cancel leftover open trips/rides so this run starts clean. */
function resetDemoState(string $customerToken, string $riderToken, string $base): void
{
    // Cancel rider active trip if any.
    $active = httpJson('GET', "{$base}/rider/trips/active", null, $riderToken);
    if (! empty($active['trip']['id'])) {
        $tripId = $active['trip']['id'];
        httpJson('POST', "{$base}/rider/trips/{$tripId}/status", ['status' => 'cancelled'], $riderToken);
        logStep('rider', 'clear_active_trip', ['trip_id' => $tripId]);
    }

    // Decline any current offer so it does not block the new booking.
    $current = httpJson('GET', "{$base}/rider/offers/current", null, $riderToken);
    if (! empty($current['offer']['id'])) {
        $offerId = $current['offer']['id'];
        try {
            httpJson('POST', "{$base}/rider/offers/{$offerId}/decline", null, $riderToken);
            logStep('rider', 'decline_stale_offer', ['trip_id' => $offerId]);
        } catch (Throwable $e) {
            logStep('rider', 'decline_stale_offer', ['trip_id' => $offerId, 'note' => $e->getMessage()], 'warn');
        }
    }

    // Cancel customer searching rides.
    $rides = httpJson('GET', "{$base}/customer/rides", null, $customerToken);
    foreach ($rides['data'] ?? [] as $ride) {
        if (($ride['status'] ?? '') === 'searching') {
            try {
                httpJson('POST', "{$base}/customer/rides/{$ride['id']}/cancel", [
                    'reason' => 'Cleared by ride_bots.php before test',
                ], $customerToken);
                logStep('customer', 'cancel_stale_ride', ['ride_id' => $ride['id'], 'code' => $ride['code'] ?? null]);
            } catch (Throwable $e) {
                logStep('customer', 'cancel_stale_ride', ['ride_id' => $ride['id'], 'note' => $e->getMessage()], 'warn');
            }
        }
    }
}

try {
    logStep('system', 'start', ['base' => $base]);

    $riderLogin = httpJson('POST', "{$base}/rider/auth/login", [
        'email' => 'rider@demo.hillgo.app',
        'password' => $password,
    ]);
    $riderToken = $riderLogin['token'];
    $riderName = $riderLogin['user']['name'] ?? 'Demo Rider';
    logStep('rider', 'login', ['name' => $riderName, 'id' => $riderLogin['user']['id'] ?? null]);

    $customerLogin = httpJson('POST', "{$base}/customer/auth/login", [
        'email' => 'customer@demo.hillgo.app',
        'password' => $password,
    ]);
    $customerToken = $customerLogin['token'];
    $customerName = $customerLogin['user']['name'] ?? 'Demo Customer';
    logStep('customer', 'login', ['name' => $customerName, 'id' => $customerLogin['user']['id'] ?? null]);

    resetDemoState($customerToken, $riderToken, $base);

    $presence = httpJson('POST', "{$base}/rider/presence", ['online' => true], $riderToken);
    logStep('rider', 'go_online', ['online' => $presence['online'] ?? true]);

    $quote = httpJson('POST', "{$base}/customer/rides/quote", [
        'distance_km' => 4.2,
        'duration_min' => 12,
        'vehicle_type' => 'bike',
    ], $customerToken);
    logStep('customer', 'quote', ['fare' => $quote['fare'] ?? null]);

    $pickupMarker = 'BOT-PICKUP-'.substr((string) time(), -6);
    $bookedAt = elapsed();
    $ride = httpJson('POST', "{$base}/customer/rides", [
        'vehicle_type' => 'bike',
        'pickup' => "{$pickupMarker} Gulshan 1, Dhaka",
        'drop' => 'Banani 11, Dhaka',
        'pickup_lat' => 23.7808875,
        'pickup_lng' => 90.4169271,
        'drop_lat' => 23.7937,
        'drop_lng' => 90.4066,
        'distance_km' => 4.2,
        'duration_min' => 12,
        'payment_method' => 'cash',
    ], $customerToken);
    $rideId = (int) $ride['id'];
    logStep('customer', 'book_ride', [
        'ride_id' => $rideId,
        'code' => $ride['code'],
        'status' => $ride['status'],
        'fare' => $ride['fare'],
        'pickup' => $ride['pickup'],
    ]);

    // Bot B polls until the offer for THIS ride appears.
    $offer = null;
    $offerSeenAt = null;
    $deadline = microtime(true) + 45;
    while (microtime(true) < $deadline) {
        $current = httpJson('GET', "{$base}/rider/offers/current", null, $riderToken);
        $candidate = $current['offer'] ?? null;
        if (is_array($candidate)) {
            $refId = (int) ($candidate['ref_id'] ?? 0);
            $pickup = (string) ($candidate['pickup_name'] ?? '');
            $matches = ($candidate['type'] ?? '') === 'ride'
                && ($refId === $rideId || str_contains($pickup, $pickupMarker));

            if ($matches) {
                $offer = $candidate;
                $offerSeenAt = elapsed();
                logStep('rider', 'offer_seen', [
                    'trip_id' => $offer['id'],
                    'ref_id' => $offer['ref_id'] ?? null,
                    'code' => $offer['code'] ?? null,
                    'earning' => $offer['earning'] ?? null,
                    'expires_in' => $offer['expires_in_seconds'] ?? null,
                    'latency_ms_from_book' => $offerSeenAt - $bookedAt,
                ]);
                break;
            }

            // Wrong/stale offer — decline so the correct one can surface.
            try {
                httpJson('POST', "{$base}/rider/offers/{$candidate['id']}/decline", null, $riderToken);
                logStep('rider', 'decline_unrelated_offer', [
                    'trip_id' => $candidate['id'],
                    'ref_id' => $candidate['ref_id'] ?? null,
                ]);
            } catch (Throwable $e) {
                logStep('rider', 'decline_unrelated_offer', [
                    'trip_id' => $candidate['id'],
                    'note' => $e->getMessage(),
                ], 'warn');
            }
        }
        usleep(300_000);
    }

    if (! $offer) {
        throw new RuntimeException("Rider never received offer for ride #{$rideId} within 45s");
    }

    $accepted = httpJson('POST', "{$base}/rider/offers/{$offer['id']}/accept", null, $riderToken);
    $acceptedAt = elapsed();
    logStep('rider', 'accept_offer', [
        'trip_id' => $accepted['id'] ?? $offer['id'],
        'status' => $accepted['status'] ?? null,
        'latency_ms_from_book' => $acceptedAt - $bookedAt,
    ]);

    // Bot A polls until driver is assigned (same as customer searching screen).
    $assigned = null;
    $customerSeenAt = null;
    $deadline = microtime(true) + 20;
    while (microtime(true) < $deadline) {
        $fresh = httpJson('GET', "{$base}/customer/rides/{$rideId}", null, $customerToken);
        if (($fresh['status'] ?? '') !== 'searching' && ! empty($fresh['driver'])) {
            $assigned = $fresh;
            $customerSeenAt = elapsed();
            logStep('customer', 'driver_assigned', [
                'status' => $fresh['status'],
                'driver' => $fresh['driver']['name'] ?? null,
                'latency_ms_from_book' => $customerSeenAt - $bookedAt,
                'latency_ms_from_accept' => $customerSeenAt - $acceptedAt,
            ]);
            break;
        }
        usleep(250_000);
    }

    if (! $assigned) {
        throw new RuntimeException('Customer never saw driver assignment');
    }

    $result = [
        'ok' => true,
        'started_at' => date('c', (int) $t0),
        'total_ms' => elapsed(),
        'book_to_offer_ms' => ($offerSeenAt ?? 0) - $bookedAt,
        'book_to_accept_ms' => $acceptedAt - $bookedAt,
        'book_to_customer_see_ms' => ($customerSeenAt ?? elapsed()) - $bookedAt,
        'accept_to_customer_see_ms' => ($customerSeenAt ?? elapsed()) - $acceptedAt,
        'ride' => [
            'id' => $rideId,
            'code' => $ride['code'],
            'fare' => $ride['fare'],
            'status' => $assigned['status'],
            'driver' => $assigned['driver']['name'] ?? null,
            'pickup' => $ride['pickup'],
            'drop' => $ride['drop'],
        ],
        'trip' => [
            'id' => $accepted['id'] ?? $offer['id'],
            'code' => $accepted['code'] ?? ($offer['code'] ?? null),
            'status' => $accepted['status'] ?? null,
            'earning' => $accepted['earning'] ?? ($offer['earning'] ?? null),
            'ref_id' => $offer['ref_id'] ?? $rideId,
        ],
        'timeline' => $timeline,
    ];

    // Free the rider again so manual UI testing is not blocked by this bot run.
    $tripId = $accepted['id'] ?? $offer['id'];
    try {
        httpJson('POST', "{$base}/rider/trips/{$tripId}/status", ['status' => 'cancelled'], $riderToken);
        logStep('rider', 'release_after_test', ['trip_id' => $tripId]);
        httpJson('POST', "{$base}/customer/rides/{$rideId}/cancel", [
            'reason' => 'Released after ride_bots.php verification',
        ], $customerToken);
        logStep('customer', 'release_after_test', ['ride_id' => $rideId]);
    } catch (Throwable $e) {
        logStep('system', 'release_after_test', ['note' => $e->getMessage()], 'warn');
    }

    saveResult($outPath, $result);
    logStep('system', 'done', [
        'total_ms' => $result['total_ms'],
        'book_to_offer_ms' => $result['book_to_offer_ms'],
        'book_to_accept_ms' => $result['book_to_accept_ms'],
        'book_to_customer_see_ms' => $result['book_to_customer_see_ms'],
    ]);
    echo "\nPASS — {$ride['code']} accepted by {$riderName} · book→accept {$result['book_to_accept_ms']}ms · customer saw driver in {$result['book_to_customer_see_ms']}ms\n";
    exit(0);
} catch (Throwable $e) {
    $result = [
        'ok' => false,
        'error' => $e->getMessage(),
        'total_ms' => elapsed(),
        'timeline' => $timeline,
    ];
    saveResult($outPath, $result);
    logStep('system', 'failed', ['error' => $e->getMessage()], 'error');
    fwrite(STDERR, "\nFAIL — {$e->getMessage()}\n");
    exit(1);
}

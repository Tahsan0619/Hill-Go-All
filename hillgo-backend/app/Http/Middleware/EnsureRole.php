<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureRole
{
    /**
     * Usage: ->middleware('role:admin') or 'role:customer'.
     * 'admin' matches both super_admin and admin. Role is always read
     * from the DB user row, never from the token string.
     */
    public function handle(Request $request, Closure $next, string $role): Response
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $allowed = $role === 'admin'
            ? in_array($user->role, ['super_admin', 'admin'], true)
            : $user->role === $role;

        if (! $allowed) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        if ($user->status === 'suspended' && ! $user->isAdmin()) {
            return response()->json(['message' => 'Account suspended. Contact support.'], 403);
        }

        return $next($request);
    }
}

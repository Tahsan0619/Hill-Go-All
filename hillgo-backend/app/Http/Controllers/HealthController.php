<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

/**
 * Backend 7.4.24 — unauthenticated liveness/readiness probe.
 * Registered both as GET /api/health (routes/api.php, what the Admin Panel
 * polls) and GET /health (routes/web.php, no /api prefix) for infra checks
 * that hit the bare host.
 */
class HealthController extends Controller
{
    public function check(): JsonResponse
    {
        $dbOk = true;
        try {
            DB::select('select 1');
        } catch (\Throwable) {
            $dbOk = false;
        }

        return response()->json([
            'status' => $dbOk ? 'ok' : 'fail',
            'db' => $dbOk ? 'ok' : 'fail',
        ], $dbOk ? 200 : 503);
    }
}

<?php

use App\Http\Controllers\HealthController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Backend 7.4.24 — health check without the /api prefix, for infra probes
// that hit the bare host. Same JSON contract as GET /api/health.
Route::get('/health', [HealthController::class, 'check']);

<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Never allow debug/stack traces in production even if misconfigured.
        if ($this->app->environment('production') && config('app.debug')) {
            config(['app.debug' => false]);
        }

        // Buckets are keyed per endpoint (path) so e.g. contact-form spam
        // can never exhaust the login limiter for the same IP.
        $byEndpoint = fn (Request $request) => $request->path() . '|' . ($request->user()?->id ?? $request->ip());

        RateLimiter::for('public-read', fn (Request $r) => Limit::perMinute(60)->by($byEndpoint($r)));
        RateLimiter::for('public-write', fn (Request $r) => Limit::perMinute(10)->by($byEndpoint($r)));
        RateLimiter::for('auth', fn (Request $r) => Limit::perMinute(10)->by($byEndpoint($r)));
        RateLimiter::for('otp', fn (Request $r) => Limit::perMinute(5)->by($byEndpoint($r)));
        RateLimiter::for('otp-verify', fn (Request $r) => Limit::perMinute(15)->by($byEndpoint($r)));
    }
}

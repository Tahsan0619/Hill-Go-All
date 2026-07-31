<?php

namespace App\Jobs;

use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

/**
 * OTP delivery channel. Local/dev: write to log (never returned by API).
 * Production: swap the body for an SMS provider call — still never log the plaintext code.
 */
class DeliverOtp implements ShouldQueue
{
    use Queueable;

    public function __construct(
        public string $phone,
        public string $role,
        public string $purpose,
        public string $code,
    ) {}

    public function handle(): void
    {
        if (app()->environment(['local', 'testing'])) {
            Log::info("OTP for {$this->role} {$this->phone} ({$this->purpose}): {$this->code}");

            return;
        }

        // Production: integrate SMS provider here. Do not log the plaintext OTP.
        Log::info('OTP queued for delivery', [
            'role' => $this->role,
            'phone_last4' => substr($this->phone, -4),
            'purpose' => $this->purpose,
        ]);
    }
}

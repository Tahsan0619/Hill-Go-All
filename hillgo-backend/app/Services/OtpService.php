<?php

namespace App\Services;

use App\Jobs\DeliverOtp;
use App\Models\OtpCode;
use Database\Seeders\DemoUsersSeeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class OtpService
{
    /**
     * Issue a 4-digit OTP for a phone+role+purpose. Stored hashed.
     * Delivery is queued (log in local; SMS provider in production).
     */
    public static function issue(string $phone, string $role, string $purpose = 'login'): void
    {
        $recent = OtpCode::where('phone', $phone)->where('role', $role)->where('purpose', $purpose)
            ->where('created_at', '>=', now()->subSeconds(45))
            ->whereNull('consumed_at')
            ->exists();
        if ($recent) {
            throw ValidationException::withMessages(['phone' => 'Please wait before requesting another code.']);
        }

        $code = self::isDemoPhone($phone)
            ? DemoUsersSeeder::DEMO_OTP
            : (string) random_int(1000, 9999);

        OtpCode::where('phone', $phone)->where('role', $role)->where('purpose', $purpose)
            ->whereNull('consumed_at')->delete();

        OtpCode::create([
            'phone' => $phone,
            'role' => $role,
            'purpose' => $purpose,
            'code_hash' => Hash::make($code),
            'expires_at' => now()->addMinutes(5),
        ]);

        DeliverOtp::dispatch($phone, $role, $purpose, $code);
    }

    public static function verify(string $phone, string $role, string $code, string $purpose = 'login'): bool
    {
        // Local/demo shortcut: fixed OTP for seeded demo phones (never in production).
        if (self::isDemoPhone($phone) && hash_equals(DemoUsersSeeder::DEMO_OTP, trim($code))) {
            return true;
        }

        $row = OtpCode::where('phone', $phone)->where('role', $role)->where('purpose', $purpose)
            ->whereNull('consumed_at')
            ->where('expires_at', '>', now())
            ->latest()->first();

        if (! $row) {
            return false;
        }
        if ($row->attempts >= 5) {
            return false;
        }

        $row->increment('attempts');
        if (! Hash::check($code, $row->code_hash)) {
            return false;
        }

        $row->update(['consumed_at' => now()]);

        return true;
    }

    private static function isDemoPhone(string $phone): bool
    {
        if (! app()->environment(['local', 'testing'])) {
            return false;
        }
        if (! filter_var(env('SEED_DEMO_USERS', false), FILTER_VALIDATE_BOOLEAN)
            && ! filter_var(env('DEMO_OTP_ENABLED', false), FILTER_VALIDATE_BOOLEAN)) {
            return false;
        }

        $candidates = Phone::lookupVariants($phone);
        foreach (DemoUsersSeeder::demoPhones() as $demo) {
            if (in_array($demo, $candidates, true) || in_array(Phone::normalize($demo), $candidates, true)) {
                return true;
            }
        }

        return false;
    }
}

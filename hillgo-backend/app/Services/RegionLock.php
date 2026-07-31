<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Validation\ValidationException;

class RegionLock
{
    /** Ensure the user's district is open for the given allow flag. */
    public static function check(User $user, string $flag): void
    {
        $district = $user->district;
        if (! $district) {
            return; // No district on record — allow; registration enforced it.
        }
        if ($district->status !== 'open' || ! $district->{$flag}) {
            throw ValidationException::withMessages([
                'district' => "This service is currently unavailable in {$district->name}.",
            ]);
        }
    }
}

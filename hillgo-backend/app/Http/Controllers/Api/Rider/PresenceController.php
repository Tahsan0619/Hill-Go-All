<?php

namespace App\Http\Controllers\Api\Rider;

use App\Http\Controllers\Controller;
use App\Services\Dispatch;
use App\Services\RegionLock;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class PresenceController extends Controller
{
    public function presence(Request $request)
    {
        $data = $request->validate(['online' => ['required', 'boolean']]);
        $user = $request->user();
        $profile = $user->riderProfile;

        if ($data['online']) {
            if ($user->status !== 'active') {
                throw ValidationException::withMessages(['online' => 'Your account is not active yet.']);
            }
            if ($profile->kyc_status !== 'verified') {
                throw ValidationException::withMessages(['online' => 'Complete KYC verification before going online.']);
            }
            RegionLock::check($user, 'allow_rider');
            $profile->update(['online' => true, 'online_since' => now()]);
            // Pick up any ride/food/parcel offers waiting without a rider.
            Dispatch::claimPendingFor($user->fresh(['riderProfile']));
        } else {
            if ($profile->online && $profile->online_since) {
                $profile->online_seconds_today += $profile->online_since->diffInSeconds(now());
            }
            $profile->update(['online' => false, 'online_since' => null, 'online_seconds_today' => $profile->online_seconds_today]);
        }

        return response()->json(['online' => (bool) $profile->fresh()->online]);
    }

    public function location(Request $request)
    {
        $data = $request->validate([
            'lat' => ['required', 'numeric', 'between:-90,90'],
            'lng' => ['required', 'numeric', 'between:-180,180'],
        ]);

        $request->user()->riderProfile->update([
            'lat' => $data['lat'],
            'lng' => $data['lng'],
            'last_location_at' => now(),
        ]);

        return response()->json(['message' => 'OK']);
    }
}

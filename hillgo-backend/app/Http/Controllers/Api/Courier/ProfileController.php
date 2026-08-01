<?php

namespace App\Http\Controllers\Api\Courier;

use App\Http\Controllers\Controller;
use App\Models\CourierDocument;
use App\Services\Notifier;
use App\Services\RegionLock;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class ProfileController extends Controller
{
    public const REQUIRED_DOCS = [
        'license' => 'Driving License',
        'nid' => 'NID',
        'registration' => 'Vehicle Registration',
    ];

    public function presence(Request $request)
    {
        $data = $request->validate(['online' => ['required', 'boolean']]);
        $user = $request->user();
        $profile = $user->courierProfile;

        if ($data['online']) {
            if ($user->status !== 'active') {
                throw ValidationException::withMessages(['online' => 'Your account is not active yet.']);
            }
            if (! $profile->verified) {
                throw ValidationException::withMessages(['online' => 'Complete KYC verification before going online.']);
            }
            RegionLock::check($user, 'allow_courier');
        }

        $profile->update(['online' => $data['online']]);
        return response()->json(['online' => (bool) $profile->fresh()->online]);
    }

    public function location(Request $request)
    {
        $data = $request->validate([
            'lat' => ['required', 'numeric', 'between:-90,90'],
            'lng' => ['required', 'numeric', 'between:-180,180'],
        ]);
        $request->user()->courierProfile->update([
            'lat' => $data['lat'], 'lng' => $data['lng'], 'last_location_at' => now(),
        ]);
        return response()->json(['message' => 'OK']);
    }

    public function updateVehicle(Request $request)
    {
        $data = $request->validate([
            'vehicle_type' => ['sometimes', 'in:Motorbike,Bicycle,Van'],
            'vehicle_name' => ['sometimes', 'nullable', 'string', 'max:120'],
            'plate' => ['sometimes', 'nullable', 'string', 'max:64'],
        ]);
        $request->user()->courierProfile->update($data);
        return response()->json($request->user()->courierProfile->fresh()->only(['vehicle_type', 'vehicle_name', 'plate']));
    }

    public function updateBank(Request $request)
    {
        $data = $request->validate([
            'bank_last4' => ['required', 'string', 'size:4'],
        ]);
        // Changing bank details resets verification (admin re-verifies).
        $request->user()->courierProfile->update(['bank_last4' => $data['bank_last4'], 'bank_verified' => false]);
        Notifier::admins('Courier bank details changed', "{$request->user()->name} updated bank details — re-verify.", 'kyc');
        return response()->json(['message' => 'Saved. Pending re-verification.']);
    }

    public function documents(Request $request)
    {
        $profile = $request->user()->courierProfile;
        $existing = $profile->documents->keyBy('doc_key');

        return response()->json(collect(self::REQUIRED_DOCS)->map(fn ($title, $key) => [
            'id' => $key,
            'title' => $title,
            'status' => $existing[$key]->status ?? 'pending',
            'uploaded' => isset($existing[$key]) && $existing[$key]->file_path,
            'expires_at' => $existing[$key]->expires_at?->toDateString() ?? null,
        ])->values());
    }

    public function upload(Request $request, string $docKey)
    {
        abort_unless(array_key_exists($docKey, self::REQUIRED_DOCS), 404);
        $request->validate([
            'file' => ['required', 'file', 'mimes:jpg,jpeg,png,webp,pdf', 'max:8192'],
            'expires_at' => ['nullable', 'date', 'after:today'],
        ]);

        $profile = $request->user()->courierProfile;
        $existing = CourierDocument::where('courier_profile_id', $profile->id)->where('doc_key', $docKey)->first();
        $path = \App\Support\StoredFiles::replacePrivate($existing?->file_path, $request->file('file'), 'kyc/courier/' . $request->user()->id);

        CourierDocument::updateOrCreate(
            ['courier_profile_id' => $profile->id, 'doc_key' => $docKey],
            ['title' => self::REQUIRED_DOCS[$docKey], 'status' => 'uploaded', 'file_path' => $path, 'expires_at' => $request->input('expires_at')]
        );

        // Submit for review automatically when all docs are in.
        $uploaded = $profile->documents()->whereNotNull('file_path')->count();
        if ($uploaded >= count(self::REQUIRED_DOCS) && $profile->kyc_status !== 'verified') {
            $profile->kyc_status = 'uploaded';
            $profile->kyc_submitted_at = now();
            $profile->save();
            Notifier::admins('Courier KYC submitted', "{$request->user()->name} uploaded all documents.", 'kyc', ['courier_profile_id' => $profile->id]);
        }

        return response()->json(['message' => 'Uploaded.', 'doc' => $docKey, 'status' => 'uploaded']);
    }

    public function settings(Request $request)
    {
        $data = $request->validate([
            'notify_assignments' => ['sometimes', 'boolean'],
            'notify_payouts' => ['sometimes', 'boolean'],
            'language' => ['sometimes', 'in:en,bn'],
        ]);
        $user = $request->user();
        if (isset($data['language'])) {
            $user->update(['language' => $data['language']]);
        }
        $user->prefs = array_merge($user->prefs ?? [], collect($data)->except('language')->all());
        $user->save();
        return response()->json(['message' => 'Saved.', 'prefs' => $user->prefs]);
    }
}

<?php

namespace App\Http\Controllers\Api\Rider;

use App\Http\Controllers\Controller;
use App\Models\RiderDocument;
use App\Services\Notifier;
use Illuminate\Http\Request;

class OnboardingController extends Controller
{
    public const REQUIRED_DOCS = [
        'id_proof' => "Driver's License or Token",
        'nid' => 'National ID (NID)',
        'registration' => 'Vehicle Registration',
        'photo' => 'Rider Photo',
    ];

    public function personal(Request $request)
    {
        $data = $request->validate([
            'legal_name' => ['required', 'string', 'max:150'],
            'home_address' => ['required', 'string', 'max:300'],
            'district_id' => ['required', 'string', 'exists:districts,id'],
            'dob' => ['required', 'date', 'before:-18 years'],
            'nid' => ['required', 'string', 'max:32'],
        ]);

        $request->user()->update(['district_id' => $data['district_id']]);
        $request->user()->riderProfile->update(collect($data)->except('district_id')->all());

        return response()->json(['message' => 'Personal info saved.']);
    }

    public function vehicle(Request $request)
    {
        $data = $request->validate([
            'vehicle_type' => ['required', 'in:bike,car,xl'],
            'vehicle_make' => ['required', 'string', 'max:64'],
            'vehicle_model' => ['required', 'string', 'max:64'],
            'vehicle_year' => ['required', 'string', 'max:8'],
            'plate' => ['required', 'string', 'max:64'],
        ]);
        $request->user()->riderProfile->update($data);
        return response()->json(['message' => 'Vehicle saved.', 'vehicle' => $data]);
    }

    public function documents(Request $request)
    {
        $profile = $request->user()->riderProfile;
        $existing = $profile->documents->keyBy('doc_key');

        $docs = collect(self::REQUIRED_DOCS)->map(fn ($title, $key) => [
            'id' => $key,
            'title' => $title,
            'status' => $existing[$key]->status ?? 'pending',
            'token_number' => $existing[$key]->token_number ?? null,
            'uploaded' => isset($existing[$key]) && ($existing[$key]->file_path || $existing[$key]->token_number),
            'allows_token_alternative' => $key === 'id_proof',
        ])->values();

        return response()->json(['documents' => $docs, 'kyc_status' => $profile->kyc_status]);
    }

    public function upload(Request $request, string $docKey)
    {
        abort_unless(array_key_exists($docKey, self::REQUIRED_DOCS), 404);
        $request->validate([
            'file' => ['required', 'file', 'mimes:jpg,jpeg,png,webp,pdf', 'max:8192'],
        ]);

        // Private disk — served to admins only via authenticated route.
        $path = $request->file('file')->store('kyc/rider/' . $request->user()->id, 'local');

        $profile = $request->user()->riderProfile;
        RiderDocument::updateOrCreate(
            ['rider_profile_id' => $profile->id, 'doc_key' => $docKey],
            ['title' => self::REQUIRED_DOCS[$docKey], 'status' => 'uploaded', 'file_path' => $path]
        );

        $this->refreshKycStatus($request);
        return response()->json(['message' => 'Uploaded.', 'doc' => $docKey, 'status' => 'uploaded']);
    }

    /** License token alternative for id_proof. */
    public function idProofToken(Request $request)
    {
        $data = $request->validate([
            'token_number' => ['required', 'string', 'max:64'],
            'photo' => ['nullable', 'file', 'mimes:jpg,jpeg,png,webp', 'max:8192'],
        ]);

        $path = $request->hasFile('photo')
            ? $request->file('photo')->store('kyc/rider/' . $request->user()->id, 'local')
            : null;

        $profile = $request->user()->riderProfile;
        RiderDocument::updateOrCreate(
            ['rider_profile_id' => $profile->id, 'doc_key' => 'id_proof'],
            ['title' => self::REQUIRED_DOCS['id_proof'], 'status' => 'uploaded', 'token_number' => $data['token_number'], 'file_path' => $path]
        );

        $this->refreshKycStatus($request);
        return response()->json(['message' => 'Token saved.', 'status' => 'uploaded']);
    }

    public function status(Request $request)
    {
        $profile = $request->user()->riderProfile;
        $docs = $profile->documents;
        $uploadedCount = $docs->filter(fn ($d) => $d->file_path || $d->token_number)->count();

        return response()->json([
            'kyc_status' => $profile->kyc_status,
            'account_status' => $request->user()->status,
            'documents_uploaded' => $uploadedCount,
            'documents_required' => count(self::REQUIRED_DOCS),
            'submitted_at' => $profile->kyc_submitted_at?->toIso8601String(),
            'can_go_online' => $profile->kyc_status === 'verified' && $request->user()->status === 'active',
        ]);
    }

    public function complete(Request $request)
    {
        $profile = $request->user()->riderProfile;
        $uploaded = $profile->documents->filter(fn ($d) => $d->file_path || $d->token_number)->pluck('doc_key');
        $missing = collect(array_keys(self::REQUIRED_DOCS))->diff($uploaded);

        if ($missing->isNotEmpty()) {
            return response()->json([
                'message' => 'Missing documents: ' . $missing->implode(', '),
            ], 422);
        }

        $profile->update(['kyc_submitted_at' => now()]);
        $profile->kyc_status = 'uploaded';
        $profile->save();
        Notifier::admins('Rider KYC submitted', "{$request->user()->name} completed document upload.", 'kyc', ['rider_profile_id' => $profile->id]);

        return response()->json(['message' => 'Submitted for review.', 'kyc_status' => 'uploaded']);
    }

    private function refreshKycStatus(Request $request): void
    {
        $profile = $request->user()->riderProfile;
        if (in_array($profile->kyc_status, ['pending', 'action_required'], true)) {
            $profile->kyc_status = 'pending';
            $profile->save();
        }
    }
}

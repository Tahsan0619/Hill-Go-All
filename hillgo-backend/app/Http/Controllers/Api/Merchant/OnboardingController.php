<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use App\Models\District;
use App\Models\MerchantOnboarding;
use App\Services\Notifier;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class OnboardingController extends Controller
{
    public const CATEGORIES = [
        'Restaurant & Cafe', 'Grocery & Market', 'Bakery', 'Electronics',
        'Fashion & Apparel', 'Home & Lifestyle', 'Health & Beauty', 'Other',
    ];

    public function submit(Request $request)
    {
        $data = $request->validate([
            'business_name' => ['required', 'string', 'max:190'],
            'description' => ['nullable', 'string', 'max:2000'],
            'category' => ['required', 'in:' . implode(',', self::CATEGORIES)],
            'subcategories' => ['nullable', 'array'],
            'contact_name' => ['required', 'string', 'max:120'],
            'phone' => ['required', 'string', 'max:32'],
            'email' => ['required', 'email', 'max:190'],
            'address' => ['required', 'string', 'max:300'],
            'city' => ['required', 'string', 'max:120'],
            'zip' => ['nullable', 'string', 'max:16'],
            'district_id' => ['nullable', 'string', 'exists:districts,id'],
            'logo' => ['nullable', 'file', 'mimes:jpg,jpeg,png,webp', 'max:4096'],
            'storefront' => ['nullable', 'file', 'mimes:jpg,jpeg,png,webp', 'max:8192'],
            'trade_license' => ['nullable', 'file', 'mimes:jpg,jpeg,png,webp,pdf', 'max:8192'],
            'nid' => ['nullable', 'file', 'mimes:jpg,jpeg,png,webp,pdf', 'max:8192'],
        ]);

        // Region Lock: resolve district from explicit id or city name.
        $district = ! empty($data['district_id'])
            ? District::find($data['district_id'])
            : District::whereRaw('LOWER(name) = ?', [mb_strtolower(trim($data['city']))])->first();

        if (! $district) {
            throw ValidationException::withMessages(['city' => 'Could not match your city to a Bangladesh district.']);
        }
        if ($district->status !== 'open' || ! $district->allow_merchant) {
            throw ValidationException::withMessages(['city' => "Merchant onboarding is not open in {$district->name} yet."]);
        }

        $userId = $request->user()->id;
        $docs = [];
        foreach (['trade_license' => 'Trade License', 'nid' => 'NID'] as $field => $label) {
            if ($request->hasFile($field)) {
                $docs[] = [
                    'name' => $label,
                    'path' => \App\Support\StoredFiles::putPrivate($request->file($field), "kyc/merchant/{$userId}"),
                    'disk' => 'local',
                ];
            }
        }
        // Branding on public disk; storefront also copied to private for admin review.
        $logoPath = $request->hasFile('logo')
            ? \App\Support\StoredFiles::putPublic($request->file('logo'), "stores/{$userId}")
            : null;
        $storefrontPath = null;
        if ($request->hasFile('storefront')) {
            $privateKey = \App\Support\StoredFiles::putPrivate($request->file('storefront'), "kyc/merchant/{$userId}");
            $bytes = \Illuminate\Support\Facades\Storage::disk('local')->get($privateKey);
            $ext = pathinfo($privateKey, PATHINFO_EXTENSION) ?: 'jpg';
            $publicKey = "stores/{$userId}/".\Illuminate\Support\Str::random(40).'.'.$ext;
            \Illuminate\Support\Facades\Storage::disk('public')->put($publicKey, $bytes);
            $storefrontPath = '/storage/'.$publicKey;
            $docs[] = ['name' => 'Storefront Photo', 'path' => $privateKey, 'disk' => 'local'];
        }

        $onboarding = MerchantOnboarding::create([
            'user_id' => $userId,
            'business_name' => $data['business_name'],
            'description' => $data['description'] ?? null,
            'owner' => $data['contact_name'],
            'category' => $data['category'],
            'subcategories' => $data['subcategories'] ?? [],
            'phone' => $data['phone'],
            'email' => $data['email'],
            'address' => $data['address'],
            'city' => $data['city'],
            'district_id' => $district->id,
            'zip' => $data['zip'] ?? null,
            'docs' => $docs,
            'logo_path' => $logoPath,
            'storefront_path' => $storefrontPath,
            'status' => 'pending',
        ]);

        $request->user()->update(['district_id' => $district->id]);
        Notifier::admins('New merchant onboarding', "{$onboarding->business_name} ({$district->name})", 'onboarding', ['onboarding_id' => $onboarding->id]);

        return response()->json(['message' => 'Submitted for review.', 'id' => $onboarding->id, 'status' => 'pending'], 201);
    }

    public function status(Request $request)
    {
        $onboarding = MerchantOnboarding::where('user_id', $request->user()->id)->latest()->first();
        $store = $request->user()->store;

        return response()->json([
            'submitted' => (bool) $onboarding,
            'status' => $onboarding?->status,
            'store_active' => $store?->status === 'active',
            'store_id' => $store?->id,
            'submitted_at' => $onboarding?->created_at?->toIso8601String(),
        ]);
    }
}

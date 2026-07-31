<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use App\Models\Store;
use App\Services\RegionLock;
use App\Support\Media;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class StoreController extends Controller
{
    public function show(Request $request)
    {
        return response()->json($this->shape($this->store($request)));
    }

    public function update(Request $request)
    {
        $store = $this->store($request);
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:190'],
            'description' => ['sometimes', 'nullable', 'string', 'max:2000'],
            'specialties' => ['sometimes', 'nullable', 'string', 'max:300'],
            'bio' => ['sometimes', 'nullable', 'string', 'max:2000'],
            'address' => ['sometimes', 'string', 'max:300'],
            'lat' => ['sometimes', 'nullable', 'numeric', 'between:-90,90'],
            'lng' => ['sometimes', 'nullable', 'numeric', 'between:-180,180'],
            'hours' => ['sometimes', 'array'],
            'eta_label' => ['sometimes', 'nullable', 'string', 'max:32'],
            'free_delivery' => ['sometimes', 'boolean'],
        ]);
        $store->update($data);
        $store->update(['profile_strength' => $this->strength($store->fresh())]);
        return response()->json($this->shape($store->fresh()));
    }

    public function setStatus(Request $request)
    {
        $store = $this->store($request);
        $data = $request->validate([
            'is_open' => ['sometimes', 'boolean'],
            'accepting_orders' => ['sometimes', 'boolean'],
        ]);

        if (($data['accepting_orders'] ?? false) || ($data['is_open'] ?? false)) {
            if ($store->status !== 'active') {
                throw ValidationException::withMessages(['store' => 'Store must be approved by HillGo before opening.']);
            }
            RegionLock::check($request->user(), 'allow_merchant');
        }

        $store->update($data);
        return response()->json($store->fresh()->only(['is_open', 'accepting_orders']));
    }

    public function branding(Request $request)
    {
        $store = $this->store($request);
        $request->validate([
            'banner' => ['nullable', 'file', 'mimes:jpg,jpeg,png,webp', 'max:8192'],
            'logo' => ['nullable', 'file', 'mimes:jpg,jpeg,png,webp', 'max:4096'],
        ]);

        $patch = [];
        foreach (['banner', 'logo'] as $field) {
            if ($request->hasFile($field)) {
                $patch[$field] = '/storage/' . $request->file($field)->store("stores/{$store->id}", 'public');
            }
        }
        $store->update($patch);
        $fresh = $store->fresh();

        return response()->json([
            'banner' => Media::url($fresh->banner),
            'logo' => Media::url($fresh->logo),
        ]);
    }

    private function store(Request $request): Store
    {
        $store = $request->user()->store;
        abort_unless($store, 404, 'No store yet. Complete onboarding first.');
        return $store;
    }

    private function strength(Store $s): int
    {
        $checks = [
            $s->name, $s->description, $s->address, $s->logo, $s->banner,
            $s->hours, $s->specialties, $s->lat,
        ];
        return (int) round(collect($checks)->filter()->count() / count($checks) * 100);
    }

    private function shape(Store $s): array
    {
        return [
            'id' => $s->id,
            'code' => $s->code,
            'name' => $s->name,
            'description' => $s->description,
            'specialties' => $s->specialties,
            'bio' => $s->bio,
            'category' => $s->category,
            'subcategories' => $s->subcategories,
            'address' => $s->address,
            'city' => $s->city,
            'lat' => $s->lat, 'lng' => $s->lng,
            'is_open' => (bool) $s->is_open,
            'accepting_orders' => (bool) $s->accepting_orders,
            'status' => $s->status,
            'rating' => (float) $s->rating,
            'rating_count' => (int) $s->rating_count,
            'hours' => $s->hours,
            'banner' => Media::url($s->banner),
            'logo' => Media::url($s->logo),
            'profile_strength' => (int) $s->profile_strength,
            'balance' => (float) $s->balance,
            'eta_label' => $s->eta_label,
            'free_delivery' => (bool) $s->free_delivery,
        ];
    }
}

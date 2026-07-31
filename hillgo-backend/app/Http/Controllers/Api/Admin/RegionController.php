<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\District;
use App\Models\Division;
use App\Services\Audit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class RegionController extends Controller
{
    public function divisions()
    {
        $divisions = Division::withCount([
            'districts as total',
            'districts as open' => fn ($q) => $q->where('status', 'open'),
        ])->get()->map(function ($d) {
            $closed = $d->total - $d->open;
            return [
                'id' => $d->id,
                'name' => $d->name,
                'zone' => $d->zone,
                'total' => $d->total,
                'open' => $d->open,
                'closed' => $closed,
                'status' => $d->open === 0 ? 'closed' : ($closed === 0 ? 'open' : 'partial'),
            ];
        });

        return response()->json($divisions);
    }

    public function districts(string $divisionId)
    {
        return response()->json(
            District::with('division')->where('division_id', $divisionId)->orderBy('name')->get()->map(fn ($d) => $this->shape($d))
        );
    }

    public function show(string $id)
    {
        return response()->json($this->shape(District::with('division')->findOrFail($id)));
    }

    public function update(Request $request, string $id)
    {
        $district = District::findOrFail($id);
        $data = $request->validate([
            'status' => ['sometimes', 'in:open,closed'],
            'allowCustomer' => ['sometimes', 'boolean'],
            'allowRider' => ['sometimes', 'boolean'],
            'allowMerchant' => ['sometimes', 'boolean'],
            'allowCourier' => ['sometimes', 'boolean'],
            'note' => ['sometimes', 'nullable', 'string', 'max:500'],
        ]);

        $patch = [];
        foreach (['status' => 'status', 'allowCustomer' => 'allow_customer', 'allowRider' => 'allow_rider',
            'allowMerchant' => 'allow_merchant', 'allowCourier' => 'allow_courier', 'note' => 'note'] as $in => $col) {
            if (array_key_exists($in, $data)) {
                $patch[$col] = $data[$in] ?? '';
            }
        }
        $patch['updated_by'] = $request->user()->name;
        $patch['updated_by_user_id'] = $request->user()->id;

        // Business rules: closing forces all allow flags off; opening stamps opened_at.
        if (($patch['status'] ?? $district->status) === 'closed') {
            $patch += ['allow_customer' => false, 'allow_rider' => false, 'allow_merchant' => false, 'allow_courier' => false];
        }
        if (($patch['status'] ?? null) === 'open' && ! $district->opened_at) {
            $patch['opened_at'] = now();
        }

        $district->update($patch);
        Cache::forget('public.districts.v1');
        Audit::log("{$district->name} ({$district->division->name}) → {$district->status}", $request->user()->name, 'region');

        return response()->json($this->shape($district->fresh()));
    }

    public function bulkStatus(Request $request, string $divisionId)
    {
        $data = $request->validate(['status' => ['required', 'in:open,closed']]);
        $open = $data['status'] === 'open';

        District::where('division_id', $divisionId)->get()->each(function (District $d) use ($open, $request) {
            $d->update([
                'status' => $open ? 'open' : 'closed',
                'opened_at' => $open ? ($d->opened_at ?? now()) : $d->opened_at,
                'allow_customer' => $open,
                'allow_rider' => $open,
                'allow_merchant' => $open,
                'allow_courier' => $open,
                'updated_by' => $request->user()->name,
                'updated_by_user_id' => $request->user()->id,
            ]);
        });

        Cache::forget('public.districts.v1');
        $division = Division::findOrFail($divisionId);
        Audit::log("{$division->name}: all districts {$data['status']}", $request->user()->name, 'region');

        return response()->json(['message' => 'Updated.']);
    }

    private function shape(District $d): array
    {
        return [
            'id' => $d->id,
            'divisionId' => $d->division_id,
            'divisionName' => $d->division->name,
            'name' => $d->name,
            'status' => $d->status,
            'openedAt' => $d->opened_at?->toIso8601String(),
            'allowCustomer' => (bool) $d->allow_customer,
            'allowRider' => (bool) $d->allow_rider,
            'allowMerchant' => (bool) $d->allow_merchant,
            'allowCourier' => (bool) $d->allow_courier,
            'note' => $d->note,
            'updatedAt' => $d->updated_at?->toIso8601String(),
            'updatedBy' => $d->updated_by,
        ];
    }
}

<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\CourierProfile;
use App\Models\CourierWithdrawal;
use App\Models\Incentive;
use App\Models\Parcel;
use App\Models\User;
use App\Services\Audit;
use App\Services\Codes;
use App\Services\Dispatch;
use App\Services\Notifier;
use App\Services\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CourierController extends Controller
{
    public function agents(Request $request)
    {
        $rows = User::where('role', 'courier_agent')->with(['courierProfile', 'district'])
            ->when($request->query('q'), function ($query, $q) {
                $query->where(fn ($w) => $w->where('name', 'like', "%$q%")->orWhere('phone', 'like', "%$q%")
                    ->orWhereHas('courierProfile', fn ($p) => $p->where('code', 'like', "%$q%")));
            })
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($query) => $query->where('status', $request->query('status')))
            ->latest()->paginate(50);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($u) => $this->agentShape($u)),
            'total' => $rows->total(),
        ]);
    }

    public function updateAgent(Request $request, int $id)
    {
        $u = User::where('role', 'courier_agent')->findOrFail($id);
        $data = $request->validate(['status' => ['sometimes', 'in:active,suspended,onboarding']]);

        if (isset($data['status'])) {
            $u->status = $data['status'];
            $u->save();
            if ($data['status'] === 'suspended') {
                $u->courierProfile?->update(['online' => false]);
                Notifier::user($u, 'Account suspended', 'Your courier account was suspended.', 'account');
            }
        }

        Audit::log("Courier {$u->name} updated", $request->user()->name, 'role');
        return response()->json($this->agentShape($u->fresh(['courierProfile', 'district'])));
    }

    // —— KYC ——

    public function kycIndex(Request $request)
    {
        $rows = CourierProfile::with(['user', 'documents'])
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($q) => $q->where('kyc_status', $request->query('status')))
            ->orderByDesc('kyc_submitted_at')->paginate(50);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($p) => [
                'id' => $p->id,
                'agentId' => $p->user_id,
                'agentName' => $p->user?->name,
                'docs' => $p->documents->map(fn ($d) => [
                    'key' => $d->doc_key, 'title' => $d->title, 'status' => $d->status,
                    'expiresAt' => $d->expires_at?->toDateString(),
                    'fileUrl' => $d->file_path ? route('admin.courier.doc', ['document' => $d->id]) : null,
                ]),
                'status' => $p->kyc_status,
                'bankVerified' => (bool) $p->bank_verified,
                'submitted' => $p->kyc_submitted_at?->toDateString(),
            ]),
            'total' => $rows->total(),
        ]);
    }

    public function kycStatus(Request $request, int $id)
    {
        $data = $request->validate([
            'status' => ['required', 'in:pending,action_required,uploaded,verified,rejected'],
            'bankVerified' => ['sometimes', 'boolean'],
        ]);
        $profile = CourierProfile::with('user')->findOrFail($id);

        $profile->kyc_status = $data['status'];
        if (array_key_exists('bankVerified', $data)) {
            $profile->bank_verified = $data['bankVerified'];
        }
        if ($data['status'] === 'verified') {
            $profile->verified = true;
            $profile->documents()->update(['status' => 'verified']);
            if ($profile->user->status === 'onboarding') {
                $profile->user->status = 'active';
                $profile->user->save();
            }
            Notifier::user($profile->user, 'KYC approved', 'You are verified and can now receive parcel assignments.', 'kyc');
        }
        $profile->save();

        Audit::log("Courier KYC {$profile->user->name}: {$data['status']}", $request->user()->name, 'kyc');
        return response()->json(['id' => $profile->id, 'status' => $profile->kyc_status, 'bankVerified' => (bool) $profile->bank_verified]);
    }

    public function document(\App\Models\CourierDocument $document)
    {
        abort_unless($document->file_path, 404);
        $full = \App\Support\StoredFiles::absolute($document->file_path, 'local');
        abort_unless($full, 404);
        return response()->file($full);
    }

    /** Delivery proof photos/signatures — admin-only, served off the private disk. */
    public function proofFile(\App\Models\ParcelProof $proof)
    {
        abort_unless($proof->file_path, 404);
        $full = \App\Support\StoredFiles::absolute($proof->file_path, 'local');
        abort_unless($full, 404);
        return response()->file($full);
    }

    // —— Parcels ——

    public function parcels(Request $request)
    {
        $rows = Parcel::with(['courier', 'otpLogs'])
            ->where('fulfillment_channel', 'courier')
            ->when($request->query('q'), function ($query, $q) {
                $query->where(fn ($w) => $w->where('code', 'like', "%$q%")
                    ->orWhere('pickup_address', 'like', "%$q%")->orWhere('drop_address', 'like', "%$q%")
                    ->orWhereHas('courier', fn ($c) => $c->where('name', 'like', "%$q%")));
            })
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($query) => $query->where('status', $request->query('status')))
            ->latest()->paginate(50);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($p) => [
                'id' => $p->id,
                'code' => $p->code,
                'priority' => $p->priority,
                'agentId' => $p->courier_id,
                'agent' => $p->courier?->name ?? '—',
                'pickup' => $p->pickup_address,
                'drop' => $p->drop_address,
                'weightKg' => (float) $p->weight_kg,
                'distanceKm' => (float) $p->distance_km,
                'earnings' => (float) $p->earnings,
                'surge' => (float) $p->surge_bonus,
                'status' => $p->status,
                'date' => $p->created_at->toDateString(),
                'otpLog' => $p->otpLogs->map(fn ($l) => [
                    'stage' => $l->stage, 'success' => (bool) $l->success, 'at' => $l->created_at->toIso8601String(),
                ]),
            ]),
            'total' => $rows->total(),
        ]);
    }

    public function reassignParcel(Request $request, int $id)
    {
        $parcel = Parcel::findOrFail($id);
        $data = $request->validate(['agentId' => ['nullable', 'integer', 'exists:users,id']]);

        if (! empty($data['agentId'])) {
            $agent = User::where('role', 'courier_agent')->where('status', 'active')->findOrFail($data['agentId']);
            $parcel->update(['courier_id' => $agent->id, 'status' => 'assigned', 'fail_reason' => null]);
            Notifier::user($agent, 'Parcel assigned', "Parcel {$parcel->code} was assigned to you.", 'parcel_assigned', ['parcel_id' => $parcel->id]);
        } else {
            $ok = Dispatch::assignParcelToCourier($parcel);
            if (! $ok) {
                return response()->json(['message' => 'No online verified agent available; parcel left unassigned.', 'status' => $parcel->status], 200);
            }
        }

        Audit::log("Parcel {$parcel->code} reassigned", $request->user()->name);
        return response()->json(['id' => $parcel->id, 'status' => $parcel->fresh()->status]);
    }

    // —— Withdrawals ——

    public function withdrawals(Request $request)
    {
        $rows = CourierWithdrawal::with('courier')
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($q) => $q->where('status', $request->query('status')))
            ->latest()->paginate(50);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($w) => [
                'id' => $w->id,
                'code' => $w->code,
                'agentId' => $w->courier_id,
                'agent' => $w->courier?->name,
                'amount' => (float) $w->amount,
                'method' => $w->method,
                'bankLast4' => $w->bank_last4,
                'status' => $w->status,
                'date' => $w->created_at->toDateString(),
            ]),
            'total' => $rows->total(),
        ]);
    }

    public function withdrawalStatus(Request $request, int $id)
    {
        $data = $request->validate(['status' => ['required', 'in:pending,approved,rejected,paid']]);
        $w = CourierWithdrawal::with('courier')->findOrFail($id);

        DB::transaction(function () use ($w, $data) {
            // Settlement debits the agent balance once, on first approval/payment
            // (ledger-backed; throws if the balance can't cover it).
            if (in_array($data['status'], ['approved', 'paid'], true) && ! in_array($w->status, ['approved', 'paid'], true)) {
                Wallet::adjustCourier($w->courier_id, -(float) $w->amount,
                    "Withdrawal {$w->code} ({$w->method})", 'withdrawal', $w->id);
            }
            $w->update(['status' => $data['status']]);
        });

        Audit::log("Withdrawal {$w->courier?->name}: {$data['status']} ৳{$w->amount}", $request->user()->name, 'payout');
        Notifier::user($w->courier_id, 'Withdrawal ' . $data['status'], "Your withdrawal of ৳{$w->amount} is {$data['status']}.", 'payout');

        return response()->json(['id' => $w->id, 'status' => $w->status]);
    }

    // —— Incentives ——

    public function incentives()
    {
        return response()->json(
            Incentive::latest()->limit(100)->get()->map(fn ($i) => $this->incentiveShape($i))
        );
    }

    public function createIncentive(Request $request)
    {
        $data = $request->validate([
            'title' => ['required', 'string', 'max:150'],
            'description' => ['nullable', 'string', 'max:500'],
            'multiplier' => ['nullable', 'numeric', 'min:1', 'max:10'],
            'district' => ['nullable', 'string', 'max:100'],
            'goalDeliveries' => ['nullable', 'integer', 'min:0'],
            'bonusTk' => ['nullable', 'numeric', 'min:0'],
            'validUntil' => ['nullable', 'date'],
            'active' => ['nullable', 'boolean'],
        ]);

        $incentive = Incentive::create([
            'code' => Codes::make('INC'),
            'title' => $data['title'],
            'description' => $data['description'] ?? '',
            'multiplier' => (float) ($data['multiplier'] ?? 1),
            'district' => $data['district'] ?? '',
            'goal_deliveries' => (int) ($data['goalDeliveries'] ?? 0),
            'bonus_tk' => (float) ($data['bonusTk'] ?? 0),
            'valid_until' => $data['validUntil'] ?? null,
            'active' => (bool) ($data['active'] ?? false),
        ]);

        Audit::log("Incentive created: {$incentive->title}", $request->user()->name);
        return response()->json($this->incentiveShape($incentive), 201);
    }

    public function toggleIncentive(Request $request, int $id)
    {
        $data = $request->validate(['active' => ['required', 'boolean']]);
        $incentive = Incentive::findOrFail($id);
        $incentive->update(['active' => $data['active']]);
        return response()->json($this->incentiveShape($incentive));
    }

    private function agentShape(User $u): array
    {
        $p = $u->courierProfile;
        return [
            'id' => $u->id,
            'code' => $p?->code,
            'name' => $u->name,
            'phone' => $u->phone,
            'vehicle' => $p?->vehicle_type,
            'plate' => $p?->plate ?? 'N/A',
            'rating' => (float) ($p?->rating ?? 0),
            'deliveries' => (int) ($p?->deliveries_count ?? 0),
            'verified' => (bool) ($p?->verified ?? false),
            'bankVerified' => (bool) ($p?->bank_verified ?? false),
            'bankLast4' => $p?->bank_last4,
            'district' => $u->district?->name,
            'status' => $u->status,
            'online' => (bool) ($p?->online ?? false),
            'balance' => (float) ($p?->balance ?? 0),
        ];
    }

    private function incentiveShape(Incentive $i): array
    {
        return [
            'id' => $i->id,
            'code' => $i->code,
            'title' => $i->title,
            'description' => $i->description,
            'multiplier' => (float) $i->multiplier,
            'district' => $i->district,
            'goalDeliveries' => (int) $i->goal_deliveries,
            'bonusTk' => (float) $i->bonus_tk,
            'validUntil' => $i->valid_until?->toDateString(),
            'active' => (bool) $i->active,
            'status' => $i->active ? 'active' : 'scheduled',
        ];
    }
}

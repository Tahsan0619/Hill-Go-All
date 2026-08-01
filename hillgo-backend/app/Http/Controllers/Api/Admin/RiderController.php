<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\RiderPayout;
use App\Models\RiderProfile;
use App\Models\Trip;
use App\Models\User;
use App\Services\Audit;
use App\Services\Codes;
use App\Services\Notifier;
use App\Services\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RiderController extends Controller
{
    public function index(Request $request)
    {
        $rows = User::where('role', 'rider')->with(['riderProfile', 'district'])
            ->when($request->query('q'), function ($query, $q) {
                $query->where(fn ($w) => $w->where('name', 'like', "%$q%")
                    ->orWhere('phone', 'like', "%$q%")
                    ->orWhereHas('riderProfile', fn ($p) => $p->where('code', 'like', "%$q%")->orWhere('plate', 'like', "%$q%")));
            })
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($query) => $query->where('status', $request->query('status')))
            ->latest()->paginate(min((int) $request->query('per_page', 50), 100));

        $ids = collect($rows->items())->pluck('id');
        $todayStats = Trip::whereIn('rider_id', $ids)->where('status', 'completed')
            ->whereDate('completed_at', today())
            ->selectRaw('rider_id, COUNT(*) as trips_today, COALESCE(SUM(earning),0) as today_earnings')
            ->groupBy('rider_id')
            ->get()
            ->keyBy('rider_id');

        return response()->json([
            'data' => collect($rows->items())->map(fn ($u) => $this->shape($u, $todayStats->get($u->id))),
            'total' => $rows->total(),
        ]);
    }

    public function update(Request $request, int $id)
    {
        $u = User::where('role', 'rider')->findOrFail($id);
        $data = $request->validate([
            'status' => ['sometimes', 'in:active,suspended,onboarding'],
            'name' => ['sometimes', 'string', 'max:120'],
        ]);

        if (isset($data['status'])) {
            $u->status = $data['status'];
            if ($data['status'] === 'suspended') {
                // Force offline + expire any pending offer
                $u->riderProfile?->update(['online' => false]);
                Trip::where('rider_id', $u->id)->where('status', 'requested')->get()
                    ->each(fn (Trip $t) => \App\Services\Dispatch::requeue($t));
                Notifier::user($u, 'Account suspended', 'Your rider account was suspended by HillGo operations.', 'account');
            }
        }
        if (isset($data['name'])) {
            $u->name = $data['name'];
        }
        $u->save();

        Audit::log("Rider {$u->name} → " . ($data['status'] ?? 'updated'), $request->user()->name, 'role');
        return response()->json($this->shape($u->fresh(['riderProfile', 'district'])));
    }

    // —— KYC queue ——

    public function kycIndex(Request $request)
    {
        $rows = RiderProfile::with(['user', 'documents'])
            ->whereHas('user', fn ($q) => $q->where('role', 'rider'))
            ->when($request->query('tab') === 'priority', fn ($q) => $q->where('kyc_priority', true))
            ->when($request->query('tab') === 'flagged', fn ($q) => $q->where('kyc_flagged', true))
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($q) => $q->where('kyc_status', $request->query('status')))
            ->orderByDesc('kyc_submitted_at')->paginate(50);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($p) => [
                'id' => $p->id,
                'riderId' => $p->user_id,
                'riderName' => $p->user?->name,
                'docs' => $p->documents->map(fn ($d) => [
                    'key' => $d->doc_key, 'title' => $d->title, 'status' => $d->status,
                    'tokenNumber' => $d->token_number,
                    'fileUrl' => $d->file_path ? route('admin.rider.doc', ['document' => $d->id]) : null,
                ]),
                'status' => $p->kyc_status,
                'priority' => (bool) $p->kyc_priority,
                'flagged' => (bool) $p->kyc_flagged,
                'submitted' => $p->kyc_submitted_at?->toDateString(),
            ]),
            'total' => $rows->total(),
        ]);
    }

    public function kycStatus(Request $request, int $id)
    {
        $data = $request->validate(['status' => ['required', 'in:pending,action_required,uploaded,verified,rejected']]);
        $profile = RiderProfile::with('user')->findOrFail($id);
        $profile->kyc_status = $data['status'];
        $profile->save();

        if ($data['status'] === 'verified') {
            $profile->documents()->update(['status' => 'verified']);
            if ($profile->user->status === 'onboarding') {
                $profile->user->status = 'active';
                $profile->user->save();
            }
            Notifier::user($profile->user, 'KYC approved', 'Your documents are verified. You can now go online and accept jobs.', 'kyc');
        } elseif ($data['status'] === 'action_required') {
            Notifier::user($profile->user, 'KYC action required', 'Some documents need to be re-uploaded. Open the Documents screen.', 'kyc');
        }

        Audit::log("Rider KYC {$profile->user->name}: {$data['status']}", $request->user()->name, 'kyc');
        return response()->json(['id' => $profile->id, 'status' => $profile->kyc_status]);
    }

    public function kycBulk(Request $request)
    {
        $data = $request->validate([
            'ids' => ['required', 'array'],
            'ids.*' => ['integer'],
            'status' => ['required', 'in:pending,action_required,uploaded,verified,rejected'],
        ]);
        foreach (RiderProfile::with('user')->whereIn('id', $data['ids'])->get() as $profile) {
            if ($profile->kyc_status === 'verified') {
                continue;
            }
            $request2 = new Request(['status' => $data['status']]);
            $request2->setUserResolver(fn () => $request->user());
            $this->kycStatus($request2, $profile->id);
        }
        Audit::log("Bulk rider KYC → {$data['status']} (" . count($data['ids']) . ')', $request->user()->name, 'kyc');
        return response()->json(['message' => 'Done.']);
    }

    public function document(\App\Models\RiderDocument $document)
    {
        abort_unless($document->file_path, 404);
        $full = \App\Support\StoredFiles::absolute($document->file_path, 'local');
        abort_unless($full, 404);
        return response()->file($full);
    }

    // —— Trips ——

    public function trips(Request $request)
    {
        $rows = Trip::with('rider')
            ->when($request->query('type') && $request->query('type') !== 'all',
                fn ($q) => $q->where('type', $request->query('type')))
            ->when($request->query('q'), function ($query, $q) {
                $query->where(fn ($w) => $w->where('code', 'like', "%$q%")
                    ->orWhere('pickup_name', 'like', "%$q%")->orWhere('drop_name', 'like', "%$q%")
                    ->orWhereHas('rider', fn ($r) => $r->where('name', 'like', "%$q%")));
            })
            ->latest()->paginate(min((int) $request->query('per_page', 50), 200));

        return response()->json([
            'data' => collect($rows->items())->map(fn ($t) => [
                'id' => $t->id,
                'code' => $t->code,
                'type' => $t->type,
                'riderId' => $t->rider_id,
                'rider' => $t->rider?->name ?? '—',
                'route' => trim(($t->pickup_name ?? '?') . ' → ' . ($t->drop_name ?? '?')),
                'km' => (float) $t->distance_km,
                'earning' => (float) $t->earning,
                'payment' => $t->payment_method,
                'surge' => (float) $t->surge,
                'status' => $t->status,
                'cod' => (float) $t->cod_amount,
                'date' => $t->created_at->toDateString(),
            ]),
            'total' => $rows->total(),
        ]);
    }

    // —— Payouts ——

    public function createPayout(Request $request)
    {
        $data = $request->validate([
            'riderId' => ['required', 'integer', 'exists:users,id'],
            'amount' => ['required', 'numeric', 'min:1'],
            'method' => ['required', 'in:bKash,Nagad,Bank'],
            'periodFrom' => ['nullable', 'date'],
            'periodTo' => ['nullable', 'date'],
            'ref' => ['nullable', 'string', 'max:100'],
            'tips' => ['nullable', 'numeric', 'min:0'],
            'surge' => ['nullable', 'numeric', 'min:0'],
            'deductions' => ['nullable', 'numeric', 'min:0'],
            'note' => ['nullable', 'string', 'max:300'],
        ]);

        $rider = User::where('role', 'rider')->findOrFail($data['riderId']);

        $payout = DB::transaction(function () use ($data, $rider) {
            $net = (float) $data['amount'];
            $payout = RiderPayout::create([
                'code' => Codes::make('HG-PY'),
                'rider_id' => $rider->id,
                'amount' => $net,
                'method' => $data['method'],
                'period_from' => $data['periodFrom'] ?? null,
                'period_to' => $data['periodTo'] ?? null,
                'ref' => $data['ref'] ?? '',
                'tips' => (float) ($data['tips'] ?? 0),
                'surge' => (float) ($data['surge'] ?? 0),
                'deductions' => (float) ($data['deductions'] ?? 0),
                'note' => $data['note'] ?? '',
                'status' => 'paid',
                'source' => 'admin_salary',
                'paid_at' => now(),
            ]);

            // Debit through the ledger; throws if the balance can't cover it
            // (a payout must never be marked paid without the matching debit).
            Wallet::adjustRider($rider->id, -$net, "Payout {$payout->code} ({$payout->method})", 'payout', $payout->id);

            return $payout;
        });

        Audit::log("Salary paid {$rider->name}: ৳{$payout->amount} via {$payout->method}", $request->user()->name, 'payout');
        Notifier::user($rider, 'Payout paid', "৳{$payout->amount} was paid via {$payout->method}.", 'payout');

        return response()->json($this->payoutShape($payout->load('rider')), 201);
    }

    public function payouts(Request $request)
    {
        $rows = RiderPayout::with('rider')
            ->when($request->query('method') && $request->query('method') !== 'all',
                fn ($q) => $q->where('method', $request->query('method')))
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($q) => $q->where('status', $request->query('status')))
            ->when($request->query('q'), function ($query, $q) {
                $query->where(fn ($w) => $w->where('code', 'like', "%$q%")->orWhere('ref', 'like', "%$q%")
                    ->orWhereHas('rider', fn ($r) => $r->where('name', 'like', "%$q%")));
            })
            ->latest()->paginate(50);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($p) => $this->payoutShape($p)),
            'total' => $rows->total(),
        ]);
    }

    public function payoutStatus(Request $request, int $id)
    {
        $data = $request->validate(['status' => ['required', 'in:pending,processing,paid,rejected']]);
        $payout = RiderPayout::with('rider')->findOrFail($id);

        DB::transaction(function () use ($payout, $data) {
            if ($data['status'] === 'paid' && $payout->status !== 'paid' && $payout->source === 'cash_out') {
                // Ledger-backed debit; throws if the balance can't cover it.
                Wallet::adjustRider($payout->rider_id, -(float) $payout->amount,
                    "Payout {$payout->code} ({$payout->method})", 'payout', $payout->id);
                $payout->paid_at = now();
            }
            $payout->status = $data['status'];
            $payout->save();
        });

        Audit::log("Rider payout {$payout->rider?->name}: {$data['status']} ৳{$payout->amount}", $request->user()->name, 'payout');
        Notifier::user($payout->rider_id, 'Payout ' . $data['status'], "Your cash-out of ৳{$payout->amount} is {$data['status']}.", 'payout');

        return response()->json($this->payoutShape($payout->fresh('rider')));
    }

    // —— Live map ——

    public function mapPoints()
    {
        $riders = RiderProfile::with(['user.district'])
            ->where('online', true)
            ->whereHas('user', fn ($q) => $q->where('status', 'active'))
            ->whereNotNull('lat')
            ->orderByDesc('last_location_at')
            ->limit(500)
            ->get()
            ->map(fn ($p) => [
                'id' => $p->user_id,
                'code' => $p->code,
                'name' => $p->user?->name,
                'vehicle' => $p->vehicle_type,
                'district' => $p->user?->district?->name,
                'lat' => (float) $p->lat,
                'lng' => (float) $p->lng,
                'lastSeen' => $p->last_location_at?->toIso8601String(),
            ]);

        return response()->json($riders);
    }

    private function shape(User $u, $today = null): array
    {
        $p = $u->riderProfile;

        return [
            'id' => $u->id,
            'code' => $p?->code,
            'name' => $u->name,
            'phone' => $u->phone,
            'vehicle' => $p?->vehicle_type,
            'plate' => $p?->plate,
            'rating' => (float) ($p?->rating ?? 0),
            'online' => (bool) ($p?->online ?? false),
            'district' => $u->district?->name,
            'status' => $u->status,
            'balance' => (float) ($p?->balance ?? 0),
            'todayEarnings' => (float) ($today->today_earnings ?? 0),
            'tripsToday' => (int) ($today->trips_today ?? 0),
        ];
    }

    private function payoutShape(RiderPayout $p): array
    {
        return [
            'id' => $p->id,
            'code' => $p->code,
            'riderId' => $p->rider_id,
            'rider' => $p->rider?->name,
            'amount' => (float) $p->amount,
            'method' => $p->method,
            'periodFrom' => $p->period_from?->toDateString(),
            'periodTo' => $p->period_to?->toDateString(),
            'ref' => $p->ref,
            'tips' => (float) $p->tips,
            'surge' => (float) $p->surge,
            'deductions' => (float) $p->deductions,
            'note' => $p->note,
            'status' => $p->status,
            'source' => $p->source,
            'paidAt' => $p->paid_at?->toIso8601String(),
        ];
    }
}

<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Parcel;
use App\Models\Ride;
use App\Models\SosAlert;
use App\Models\User;
use App\Models\WalletTransaction;
use App\Services\Audit;
use App\Services\Notifier;
use App\Services\Wallet;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    public function index(Request $request)
    {
        $rows = User::where('role', 'customer')->with(['customerProfile', 'district'])
            ->when($request->query('q'), function ($query, $q) {
                $query->where(fn ($w) => $w
                    ->where('name', 'like', "%$q%")
                    ->orWhere('phone', 'like', "%$q%")
                    ->orWhere('email', 'like', "%$q%")
                    ->orWhereHas('customerProfile', fn ($p) => $p->where('code', 'like', "%$q%")));
            })
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($query) => $query->where('status', $request->query('status')))
            ->latest()->paginate(min((int) $request->query('per_page', 50), 200));

        return response()->json([
            'data' => collect($rows->items())->map(fn ($u) => $this->shape($u)),
            'total' => $rows->total(),
            'current_page' => $rows->currentPage(),
            'last_page' => $rows->lastPage(),
        ]);
    }

    public function show(int $id)
    {
        $u = User::where('role', 'customer')->with(['customerProfile', 'district', 'addresses', 'paymentMethods'])->findOrFail($id);
        $shape = $this->shape($u);
        $shape['addressesCount'] = $u->addresses->count();
        $shape['paymentMethodsCount'] = $u->paymentMethods->count();
        $shape['lastRide'] = Ride::where('customer_id', $u->id)->latest()->first()?->only(['code', 'pickup', 'drop', 'fare', 'status']);
        $shape['transactions'] = WalletTransaction::where('user_id', $u->id)->latest()->limit(20)->get();
        return response()->json($shape);
    }

    public function update(Request $request, int $id)
    {
        $u = User::where('role', 'customer')->findOrFail($id);
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:120'],
            'status' => ['sometimes', 'in:active,suspended'],
            'tier' => ['sometimes', 'string', 'max:32'],
            'district_id' => ['sometimes', 'nullable', 'string', 'exists:districts,id'],
        ]);

        if (isset($data['status'])) {
            $u->status = $data['status'];
        }
        $u->fill(collect($data)->only(['name', 'district_id'])->all())->save();

        if (isset($data['tier'])) {
            $u->customerProfile?->update(['tier' => $data['tier']]);
        }

        Audit::log("Customer {$u->name} updated" . (isset($data['status']) ? " → {$data['status']}" : ''), $request->user()->name, 'role');
        if (($data['status'] ?? null) === 'suspended') {
            Notifier::user($u, 'Account suspended', 'Your HillGo account has been suspended. Contact support.', 'account');
        }

        return response()->json($this->shape($u->fresh(['customerProfile', 'district'])));
    }

    public function adjustWallet(Request $request, int $id)
    {
        $u = User::where('role', 'customer')->findOrFail($id);
        $data = $request->validate([
            'delta' => ['required', 'numeric', 'not_in:0'],
            'note' => ['nullable', 'string', 'max:300'],
        ]);

        $tx = Wallet::adjust($u, (float) $data['delta'],
            $data['delta'] > 0 ? 'Admin wallet credit' : 'Admin wallet debit',
            'admin_adjust', null, $data['note'] ?? '');

        Audit::log(sprintf('Wallet %s: %s%s ৳%s', $u->name, $data['delta'] >= 0 ? '+' : '−', abs($data['delta']), $data['note'] ? " ({$data['note']})" : ''), $request->user()->name, 'wallet');
        Notifier::user($u, 'Wallet updated', sprintf('৳%s was %s your Hill Wallet.', abs($data['delta']), $data['delta'] >= 0 ? 'added to' : 'deducted from'), 'wallet');

        return response()->json($this->shape($u->fresh(['customerProfile', 'district'])) + ['transaction' => $tx]);
    }

    public function walletTransactions(Request $request, int $id)
    {
        User::where('role', 'customer')->findOrFail($id);
        return response()->json(WalletTransaction::where('user_id', $id)->latest()->paginate(50));
    }

    // —— Related ops lists ——

    public function rides(Request $request)
    {
        $rows = Ride::with(['customer', 'rider'])
            ->when($request->query('q'), function ($query, $q) {
                $query->where(fn ($w) => $w->where('code', 'like', "%$q%")
                    ->orWhere('pickup', 'like', "%$q%")->orWhere('drop', 'like', "%$q%")
                    ->orWhereHas('customer', fn ($c) => $c->where('name', 'like', "%$q%"))
                    ->orWhereHas('rider', fn ($r) => $r->where('name', 'like', "%$q%")));
            })
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($query) => $query->where('status', $request->query('status')))
            ->latest()->paginate(min((int) $request->query('per_page', 50), 200));

        return response()->json([
            'data' => collect($rows->items())->map(fn ($r) => [
                'id' => $r->id,
                'code' => $r->code,
                'customerId' => $r->customer_id,
                'customer' => $r->customer?->name,
                'rider' => $r->rider?->name ?? '—',
                'pickup' => $r->pickup,
                'drop' => $r->drop,
                'fare' => (float) $r->fare,
                'status' => $r->status,
                'date' => $r->created_at->toDateString(),
                'distanceKm' => (float) $r->distance_km,
            ]),
            'total' => $rows->total(),
        ]);
    }

    public function foodOrders(Request $request)
    {
        return $this->orders($request, 'food');
    }

    public function marketplaceOrders(Request $request)
    {
        return $this->orders($request, 'marketplace');
    }

    private function orders(Request $request, string $channel)
    {
        $rows = Order::where('channel', $channel)->with(['store', 'customer', 'items', 'district'])
            ->when($request->query('q'), function ($query, $q) {
                $query->where(fn ($w) => $w->where('code', 'like', "%$q%")
                    ->orWhereHas('store', fn ($s) => $s->where('name', 'like', "%$q%"))
                    ->orWhereHas('customer', fn ($c) => $c->where('name', 'like', "%$q%")));
            })
            ->when($request->query('status') && $request->query('status') !== 'all', function ($query) use ($request, $channel) {
                $status = $request->query('status');
                if ($channel === 'food') {
                    // Admin food list filters by customer-facing status
                    $map = ['placed' => ['new_order'], 'preparing' => ['preparing'], 'on_the_way' => ['ready', 'on_the_way'], 'delivered' => ['delivered'], 'cancelled' => ['rejected', 'cancelled']];
                    $query->whereIn('status', $map[$status] ?? [$status]);
                } else {
                    $query->where('status', $status);
                }
            })
            ->latest()->paginate(min((int) $request->query('per_page', 50), 100));

        return response()->json([
            'data' => collect($rows->items())->map(fn ($o) => [
                'id' => $o->id,
                'code' => $o->code,
                'restaurant' => $o->store?->name,
                'store' => $o->store?->name,
                'customer' => $o->customer?->name,
                'total' => (float) $o->total,
                'deliveryFee' => (float) $o->delivery_fee,
                'status' => $channel === 'food' ? $o->customerStatus() : $o->status,
                'merchantStatus' => $o->status,
                'priority' => $o->priority,
                'date' => $o->created_at->toDateString(),
                'district' => $o->district?->name,
                'items' => $o->items->map->only(['name', 'qty', 'price', 'notes']),
            ]),
            'total' => $rows->total(),
        ]);
    }

    public function parcels(Request $request)
    {
        $rows = Parcel::with('customer')
            ->when($request->query('q'), function ($query, $q) {
                $query->where(fn ($w) => $w->where('code', 'like', "%$q%")
                    ->orWhere('type', 'like', "%$q%")
                    ->orWhereHas('customer', fn ($c) => $c->where('name', 'like', "%$q%")));
            })
            ->when($request->query('status') && $request->query('status') !== 'all', function ($query) use ($request) {
                $status = $request->query('status');
                $status === 'booked'
                    ? $query->whereIn('status', ['booked', 'assigned'])
                    : $query->where('status', $status);
            })
            ->latest()->paginate(min((int) $request->query('per_page', 50), 200));

        return response()->json([
            'data' => collect($rows->items())->map(fn ($p) => [
                'id' => $p->id,
                'code' => $p->code,
                'type' => $p->type,
                'pickup' => $p->pickup_address,
                'destination' => $p->drop_address,
                'weightKg' => (float) $p->weight_kg,
                'distanceKm' => (float) $p->distance_km,
                'fare' => (float) $p->fare,
                'status' => in_array($p->status, ['booked', 'assigned'], true) ? 'booked' : $p->status,
                'customer' => $p->customer?->name,
                'channel' => $p->fulfillment_channel,
                'date' => $p->created_at->toDateString(),
            ]),
            'total' => $rows->total(),
        ]);
    }

    // —— SOS queue ——

    public function sosAlerts(Request $request)
    {
        $rows = SosAlert::with('user')
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($q) => $q->where('status', strtolower($request->query('status'))))
            ->latest()->paginate(50);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($a) => [
                'id' => $a->id,
                'customer' => $a->user?->name,
                'customerId' => $a->user_id,
                'phone' => $a->user?->phone,
                'type' => $a->type,
                'location' => $a->location_label,
                'lat' => $a->lat,
                'lng' => $a->lng,
                'status' => ucfirst($a->status),
                'createdAt' => $a->created_at->toIso8601String(),
                'resolvedAt' => $a->resolved_at?->toIso8601String(),
            ]),
            'total' => $rows->total(),
        ]);
    }

    public function resolveSos(Request $request, int $id)
    {
        $alert = SosAlert::findOrFail($id);
        $alert->update([
            'status' => 'resolved',
            'resolved_at' => now(),
            'resolved_by' => $request->user()->name,
            'resolved_by_user_id' => $request->user()->id,
        ]);
        Audit::log("SOS #{$alert->id} resolved", $request->user()->name);
        Notifier::user($alert->user_id, 'SOS resolved', 'Your emergency alert has been marked resolved by our team.', 'sos');
        return response()->json(['message' => 'Resolved.']);
    }

    private function shape(User $u): array
    {
        $p = $u->customerProfile;
        return [
            'id' => $u->id,
            'code' => $p?->code,
            'name' => $u->name,
            'phone' => $u->phone,
            'email' => $u->email,
            'district' => $u->district?->name,
            'districtId' => $u->district_id,
            'status' => $u->status,
            'tier' => $p?->tier ?? 'Bronze',
            'wallet' => (float) ($p?->wallet_balance ?? 0),
            'loyaltyPoints' => (int) ($p?->loyalty_points ?? 0),
            'orders' => (int) ($p?->orders_count ?? 0),
            'rating' => (float) ($p?->rating ?? 0),
            'joined' => $u->created_at->toDateString(),
        ];
    }
}

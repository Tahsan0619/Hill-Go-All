<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\MerchantOnboarding;
use App\Models\MerchantPayout;
use App\Models\Order;
use App\Models\Product;
use App\Models\Store;
use App\Services\Audit;
use App\Services\Codes;
use App\Services\Notifier;
use App\Services\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MerchantController extends Controller
{
    public function index(Request $request)
    {
        $rows = Store::with('district')
            ->when($request->query('q'), function ($query, $q) {
                $query->where(fn ($w) => $w->where('name', 'like', "%$q%")
                    ->orWhere('owner_name', 'like', "%$q%")->orWhere('category', 'like', "%$q%")
                    ->orWhere('code', 'like', "%$q%"));
            })
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($query) => $query->where('status', $request->query('status')))
            ->latest()->paginate(min((int) $request->query('per_page', 50), 100));

        $ids = collect($rows->items())->pluck('id');
        $gmv = Order::whereIn('store_id', $ids)
            ->whereDate('created_at', today())
            ->whereNotIn('status', ['rejected', 'cancelled'])
            ->selectRaw('store_id, COALESCE(SUM(total),0) as gmv_today')
            ->groupBy('store_id')
            ->get()
            ->keyBy('store_id');

        return response()->json([
            'data' => collect($rows->items())->map(fn ($s) => $this->shape($s, (float) ($gmv->get($s->id)?->gmv_today ?? 0))),
            'total' => $rows->total(),
        ]);
    }

    public function show(int $id)
    {
        $s = Store::with(['district', 'owner'])->findOrFail($id);
        return response()->json($this->shape($s) + [
            'description' => $s->description,
            'address' => $s->address,
            'hours' => $s->hours,
            'banner' => $s->banner,
            'logo' => $s->logo,
            'profileStrength' => $s->profile_strength,
            'ownerEmail' => $s->owner?->email,
            'ownerPhone' => $s->owner?->phone,
        ]);
    }

    public function update(Request $request, int $id)
    {
        $store = Store::findOrFail($id);
        $data = $request->validate([
            'status' => ['sometimes', 'in:active,pending,onboarding,suspended'],
            'isOpen' => ['sometimes', 'boolean'],
            'acceptingOrders' => ['sometimes', 'boolean'],
        ]);

        $patch = [];
        if (array_key_exists('status', $data)) {
            $store->status = $data['status'];
            if ($data['status'] === 'suspended') {
                $patch['is_open'] = false;
                $patch['accepting_orders'] = false;
                Notifier::user($store->user_id, 'Store suspended', 'Your store was suspended by HillGo operations.', 'store');
            }
        }
        if (array_key_exists('isOpen', $data)) {
            $patch['is_open'] = $data['isOpen'];
        }
        if (array_key_exists('acceptingOrders', $data)) {
            $patch['accepting_orders'] = $data['acceptingOrders'];
        }
        if ($patch !== []) {
            $store->fill($patch);
        }
        $store->save();

        Audit::log("Merchant {$store->name} updated", $request->user()->name);
        return response()->json($this->shape($store->fresh('district')));
    }

    // —— Onboarding queue ——

    public function onboarding(Request $request)
    {
        $rows = MerchantOnboarding::with('district')
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($q) => $q->where('status', $request->query('status')))
            ->latest()->paginate(50);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($o) => [
                'id' => $o->id,
                'merchantId' => $o->store_id,
                'businessName' => $o->business_name,
                'owner' => $o->owner,
                'category' => $o->category,
                'subcategories' => $o->subcategories,
                'phone' => $o->phone,
                'email' => $o->email,
                'address' => $o->address,
                'city' => $o->city,
                'district' => $o->district?->name,
                'zip' => $o->zip,
                'docs' => collect($o->docs ?? [])->pluck('name'),
                'docFiles' => collect($o->docs ?? [])->values()->map(fn ($doc, $i) => [
                    'name' => $doc['name'] ?? "Document {$i}",
                    'fileUrl' => isset($doc['path']) ? route('admin.merchant.onboarding.doc', ['id' => $o->id, 'index' => $i]) : null,
                ]),
                'status' => $o->status,
                'submitted' => $o->created_at->toDateString(),
            ]),
            'total' => $rows->total(),
        ]);
    }

    /** Onboarding KYC documents (trade license, NID) — admin-only, private disk. */
    public function onboardingDoc(int $id, int $index)
    {
        $onb = MerchantOnboarding::findOrFail($id);
        $doc = collect($onb->docs ?? [])->values()->get($index);
        abort_unless($doc && ! empty($doc['path']), 404);
        $disk = $doc['disk'] ?? 'local';
        $full = \App\Support\StoredFiles::absolute($doc['path'], $disk);
        abort_unless($full, 404);
        return response()->file($full);
    }

    public function onboardingStatus(Request $request, int $id)
    {
        $data = $request->validate(['status' => ['required', 'in:pending,changes_requested,approved,rejected']]);
        $onb = MerchantOnboarding::findOrFail($id);
        $onb->update(['status' => $data['status']]);

        if ($data['status'] === 'approved') {
            $store = $onb->store_id ? Store::find($onb->store_id) : null;
            if (! $store) {
                $store = Store::create([
                    'code' => Codes::make('HG-MRT'),
                    'user_id' => $onb->user_id,
                    'name' => $onb->business_name,
                    'owner_name' => $onb->owner,
                    'category' => $onb->category,
                    'subcategories' => $onb->subcategories,
                    'description' => $onb->description,
                    'address' => $onb->address,
                    'city' => $onb->city,
                    'district_id' => $onb->district_id,
                    'zip' => $onb->zip,
                    'logo' => \App\Support\StoredFiles::asPublicDbPath($onb->logo_path),
                    'banner' => \App\Support\StoredFiles::asPublicDbPath($onb->storefront_path),
                    'is_open' => true,
                    'accepting_orders' => true,
                    'hours' => self::defaultHours(),
                ]);
                $store->status = 'active';
                $store->save();
                $onb->update(['store_id' => $store->id]);
            } else {
                $store->status = 'active';
                $store->is_open = true;
                $store->accepting_orders = true;
                $store->save();
            }
            if ($onb->user_id) {
                $owner = \App\Models\User::find($onb->user_id);
                if ($owner && $owner->status !== 'active') {
                    $owner->status = 'active';
                    $owner->save();
                }
            }
            Notifier::user($onb->user_id, 'Onboarding approved', 'Your store is live. You can now accept orders.', 'onboarding');
        } elseif (in_array($data['status'], ['changes_requested', 'rejected'], true)) {
            Notifier::user($onb->user_id, 'Onboarding ' . str_replace('_', ' ', $data['status']),
                $data['status'] === 'rejected' ? 'Your application was rejected. Contact support for details.' : 'Please update your application details/documents.', 'onboarding');
        }

        Audit::log("Onboarding {$onb->business_name}: {$data['status']}", $request->user()->name, 'kyc');
        return response()->json(['id' => $onb->id, 'status' => $onb->status, 'merchantId' => $onb->store_id]);
    }

    // —— Orders ——

    public function orders(Request $request)
    {
        $rows = Order::with(['store', 'customer', 'items'])
            ->when($request->query('tab') === 'active', fn ($q) => $q->whereIn('status', ['new_order', 'preparing', 'ready']))
            ->when($request->query('tab') === 'scheduled', fn ($q) => $q->where('priority', 'scheduled'))
            ->when($request->query('tab') === 'completed', fn ($q) => $q->whereIn('status', ['delivered', 'rejected']))
            ->when($request->query('q'), function ($query, $q) {
                $query->where(fn ($w) => $w->where('code', 'like', "%$q%")
                    ->orWhereHas('store', fn ($s) => $s->where('name', 'like', "%$q%"))
                    ->orWhereHas('customer', fn ($c) => $c->where('name', 'like', "%$q%")));
            })
            ->latest()->paginate(min((int) $request->query('per_page', 50), 200));

        return response()->json([
            'data' => collect($rows->items())->map(fn ($o) => [
                'id' => $o->id,
                'code' => $o->code,
                'store' => $o->store?->name,
                'customer' => $o->customer?->name,
                'priority' => $o->priority,
                'status' => $o->status,
                'channel' => $o->channel,
                'subtotal' => (float) $o->subtotal,
                'serviceFee' => (float) $o->service_fee,
                'tax' => (float) $o->tax,
                'total' => (float) $o->total,
                'date' => $o->created_at->toDateString(),
                'items' => $o->items->map->only(['name', 'qty', 'price', 'notes']),
            ]),
            'total' => $rows->total(),
        ]);
    }

    // —— Payouts ——

    public function payouts(Request $request)
    {
        $rows = MerchantPayout::with('store')
            ->when($request->query('status') && $request->query('status') !== 'all',
                fn ($q) => $q->where('status', $request->query('status')))
            ->latest()->paginate(50);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($p) => [
                'id' => $p->id,
                'code' => $p->code,
                'storeId' => $p->store_id,
                'store' => $p->store?->name,
                'amount' => (float) $p->amount,
                'method' => $p->method,
                'status' => $p->status,
                'earlyRequest' => (bool) $p->early_request,
                'fee' => (float) $p->fee,
                'date' => $p->created_at->toDateString(),
            ]),
            'total' => $rows->total(),
        ]);
    }

    public function payoutStatus(Request $request, int $id)
    {
        $data = $request->validate(['status' => ['required', 'in:pending,processing,completed,rejected']]);
        $payout = MerchantPayout::with('store')->findOrFail($id);

        DB::transaction(function () use ($payout, $data) {
            // Completing a payout debits the store balance exactly once
            // (ledger-backed; throws if the balance can't cover it).
            if ($data['status'] === 'completed' && $payout->status !== 'completed') {
                Wallet::adjustStore($payout->store_id, -(float) $payout->amount,
                    "Payout {$payout->code} ({$payout->method})", 'merchant_payout', $payout->id,
                    $payout->fee > 0 ? "Early payout fee ৳{$payout->fee}" : '');
            }
            $payout->update(['status' => $data['status']]);
        });

        Audit::log("Merchant payout {$payout->store?->name}: {$data['status']} ৳{$payout->amount}", $request->user()->name, 'payout');
        Notifier::user($payout->store?->user_id, 'Payout ' . $data['status'], "Payout of ৳{$payout->amount} is now {$data['status']}.", 'payout');

        return response()->json(['id' => $payout->id, 'status' => $payout->status]);
    }

    // —— Catalog oversight ——

    public function catalog(Request $request)
    {
        $rows = Product::with(['store', 'category'])
            ->when($request->query('q'), fn ($query, $q) => $query->where('name', 'like', "%$q%"))
            ->when($request->query('filter') === 'low_stock', fn ($q) => $q->where('track_stock', true)->whereColumn('stock', '<=', 'low_stock_alert'))
            ->when($request->query('filter') === 'hidden', function ($q) {
                $q->where(fn ($w) => $w->where('status', 'hidden')->orWhereHas('category', fn ($c) => $c->where('is_visible', false)));
            })
            ->latest()->paginate(min((int) $request->query('per_page', 50), 200));

        return response()->json([
            'data' => collect($rows->items())->map(fn ($p) => [
                'id' => $p->id,
                'name' => $p->name,
                'store' => $p->store?->name,
                'storeId' => $p->store_id,
                'category' => $p->category?->name ?? $p->marketplace_category,
                'price' => (float) $p->price,
                'stock' => $p->stock,
                'lowStock' => $p->track_stock && $p->stock <= $p->low_stock_alert,
                'status' => $p->status,
                'categoryVisible' => $p->category?->is_visible ?? true,
            ]),
            'total' => $rows->total(),
        ]);
    }

    public function toggleProduct(Request $request, int $id)
    {
        $data = $request->validate(['status' => ['required', 'in:active,hidden']]);
        $product = Product::findOrFail($id);
        $product->update(['status' => $data['status']]);
        Audit::log("Product {$product->name} force-{$data['status']}", $request->user()->name);
        return response()->json(['id' => $product->id, 'status' => $product->status]);
    }

    public static function defaultHours(): array
    {
        $hours = [];
        foreach (['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'] as $day) {
            $hours[$day] = ['open' => '09:00', 'close' => '22:00', 'isClosed' => false];
        }
        return $hours;
    }

    private function shape(Store $s, ?float $gmvToday = null): array
    {
        return [
            'id' => $s->id,
            'code' => $s->code,
            'name' => $s->name,
            'owner' => $s->owner_name,
            'category' => $s->category,
            'district' => $s->district?->name,
            'isOpen' => (bool) $s->is_open,
            'acceptingOrders' => (bool) $s->accepting_orders,
            'status' => $s->status,
            'rating' => (float) $s->rating,
            'gmvToday' => $gmvToday ?? (float) Order::where('store_id', $s->id)
                ->whereDate('created_at', today())
                ->whereNotIn('status', ['rejected', 'cancelled'])
                ->sum('total'),
        ];
    }
}

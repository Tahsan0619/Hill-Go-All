<?php

namespace App\Http\Controllers\Api\Customer;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Product;
use App\Models\Promo;
use App\Models\Store;
use App\Services\Codes;
use App\Services\Notifier;
use App\Services\PricingService;
use App\Services\RegionLock;
use App\Services\Wallet;
use App\Support\Media;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class FoodController extends Controller
{
    private const FOOD_CATEGORIES = ['Restaurant & Cafe', 'Bakery'];

    public function restaurants(Request $request)
    {
        $rows = Store::whereIn('category', self::FOOD_CATEGORIES)
            ->where('status', 'active')
            ->when($request->query('q'), fn ($query, $q) => $query->where('name', 'like', "%$q%"))
            ->when($request->query('cuisine') && $request->query('cuisine') !== 'All',
                fn ($q) => $q->whereJsonContains('subcategories', $request->query('cuisine')))
            ->orderByDesc('rating')
            ->paginate(30);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($s) => $this->restaurantShape($s)),
            'total' => $rows->total(),
        ]);
    }

    public function restaurant(int $id)
    {
        $store = Store::whereIn('category', self::FOOD_CATEGORIES)->where('status', 'active')->findOrFail($id);
        $menu = $store->categories()->where('is_visible', true)->orderBy('sort_order')
            ->with(['products' => fn ($q) => $q->where('status', 'active')])
            ->get()
            ->map(fn ($cat) => [
                'name' => $cat->name,
                'items' => $cat->products->map(fn ($p) => [
                    'id' => $p->id,
                    'name' => $p->name,
                    'description' => $p->description,
                    'price' => (float) $p->price,
                    'image' => Media::url(($p->images ?? [])[0] ?? null),
                ]),
            ]);

        return response()->json($this->restaurantShape($store) + ['menu' => $menu]);
    }

    public function checkout(Request $request)
    {
        RegionLock::check($request->user(), 'allow_customer');

        $data = $request->validate([
            'store_id' => ['required', 'integer', 'exists:stores,id'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'integer', 'exists:products,id'],
            'items.*.qty' => ['required', 'integer', 'min:1', 'max:50'],
            'items.*.notes' => ['nullable', 'string', 'max:200'],
            'delivery_address' => ['required', 'string', 'max:300'],
            'payment_method' => ['required', 'in:cash,wallet,card'],
            'customer_note' => ['nullable', 'string', 'max:300'],
            'promo_code' => ['nullable', 'string', 'max:32'],
        ]);

        $store = Store::findOrFail($data['store_id']);
        if ($store->status !== 'active' || ! $store->accepting_orders) {
            throw ValidationException::withMessages(['store_id' => 'This restaurant is not accepting orders right now.']);
        }

        $order = DB::transaction(function () use ($data, $store, $request) {
            // Server-side money math from DB product prices.
            $subtotal = 0;
            $lines = [];
            foreach ($data['items'] as $line) {
                $product = Product::where('store_id', $store->id)->where('status', 'active')->findOrFail($line['product_id']);
                $subtotal += $product->price * $line['qty'];
                $lines[] = ['product' => $product, 'qty' => $line['qty'], 'notes' => $line['notes'] ?? null];
            }

            $pricing = PricingService::get('customer');
            $deliveryFee = (float) ($pricing['foodDeliveryFee'] ?? 30);
            if ($store->free_delivery && $subtotal >= (float) ($pricing['freeDeliveryThreshold'] ?? 300)) {
                $deliveryFee = 0;
            }

            $discount = 0;
            if (! empty($data['promo_code'])) {
                $promo = Promo::where('code', $data['promo_code'])->where('active', true)
                    ->where(fn ($q) => $q->whereNull('expires_at')->orWhere('expires_at', '>=', today()))
                    ->first();
                if (! $promo || ($promo->usage_limit && $promo->used_count >= $promo->usage_limit)) {
                    throw ValidationException::withMessages(['promo_code' => 'This promo code is not valid.']);
                }
                if ($subtotal < $promo->min_order_tk) {
                    throw ValidationException::withMessages(['promo_code' => "Minimum order ৳{$promo->min_order_tk} for this promo."]);
                }
                $discount = match ($promo->type) {
                    'free_delivery' => $deliveryFee,
                    'amount_off' => min((float) $promo->value, $subtotal),
                    'ride_percent', 'wallet_cashback' => 0,
                    default => 0,
                };
                $promo->increment('used_count');
            }

            $total = round($subtotal + $deliveryFee - $discount, 2);

            $order = Order::create([
                'code' => Codes::make('ORD'),
                'store_id' => $store->id,
                'customer_id' => $request->user()->id,
                'channel' => 'food',
                'status' => 'new_order',
                'subtotal' => $subtotal,
                'delivery_fee' => $deliveryFee,
                'discount' => $discount,
                'total' => $total,
                'payment_method' => $data['payment_method'],
                'delivery_address' => $data['delivery_address'],
                'customer_note' => $data['customer_note'] ?? null,
                'promo_code' => $data['promo_code'] ?? null,
                'district_id' => $request->user()->district_id,
            ]);

            foreach ($lines as $line) {
                $order->items()->create([
                    'product_id' => $line['product']->id,
                    'name' => $line['product']->name,
                    'qty' => $line['qty'],
                    'price' => $line['product']->price,
                    'notes' => $line['notes'],
                ]);
                if ($line['product']->track_stock) {
                    $line['product']->decrement('stock', $line['qty']);
                }
            }

            if ($data['payment_method'] === 'wallet') {
                Wallet::adjust($request->user(), -$total, "Food order {$order->code}", 'food', $order->id);
            }

            $request->user()->customerProfile?->increment('orders_count');
            return $order;
        });

        Notifier::user($store->user_id, 'New order', "Order {$order->code} — ৳{$order->total}", 'new_order', ['order_id' => $order->id]);
        Notifier::user($request->user(), 'Order placed', "Your order {$order->code} was sent to {$store->name}.", 'food', ['order_id' => $order->id]);

        return response()->json($this->orderShape($order->fresh(['items', 'store'])), 201);
    }

    public function orders(Request $request)
    {
        $rows = Order::where('customer_id', $request->user()->id)->where('channel', 'food')
            ->with(['items', 'store'])->latest()->paginate(30);
        return response()->json([
            'data' => collect($rows->items())->map(fn ($o) => $this->orderShape($o)),
            'total' => $rows->total(),
        ]);
    }

    public function order(Request $request, Order $order)
    {
        abort_unless($order->customer_id === $request->user()->id, 403);
        return response()->json($this->orderShape($order->load(['items', 'store'])));
    }

    private function restaurantShape(Store $s): array
    {
        return [
            'id' => $s->id,
            'name' => $s->name,
            'cuisine' => collect($s->subcategories ?? [])->first() ?? $s->category,
            'cuisines' => $s->subcategories ?? [],
            'rating' => (float) $s->rating,
            'eta' => $s->eta_label ?? '30-45 min',
            'fee' => (float) (PricingService::get('customer')['foodDeliveryFee'] ?? 30),
            'image' => Media::url($s->banner ?? $s->logo),
            'free_delivery' => (bool) $s->free_delivery,
            'is_open' => (bool) $s->is_open,
            'accepting_orders' => (bool) $s->accepting_orders,
        ];
    }

    private function orderShape(Order $o): array
    {
        return [
            'id' => $o->id,
            'code' => $o->code,
            'restaurant' => $o->store?->name,
            'status' => $o->customerStatus(),
            'subtotal' => (float) $o->subtotal,
            'delivery_fee' => (float) $o->delivery_fee,
            'discount' => (float) $o->discount,
            'total' => (float) $o->total,
            'payment_method' => $o->payment_method,
            'delivery_address' => $o->delivery_address,
            'created_at' => $o->created_at->toIso8601String(),
            'items' => $o->items->map->only(['name', 'qty', 'price', 'notes']),
        ];
    }
}

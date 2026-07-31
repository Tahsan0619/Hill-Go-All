<?php

namespace App\Http\Controllers\Api\Customer;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Product;
use App\Services\Codes;
use App\Services\Notifier;
use App\Services\PricingService;
use App\Services\RegionLock;
use App\Services\Wallet;
use App\Support\Media;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MarketplaceController extends Controller
{
    public const CATEGORIES = ['Electronics', 'Fashion', 'Home', 'Beauty', 'Groceries', 'Sports'];

    public function categories()
    {
        $counts = Product::where('status', 'active')->whereNotNull('marketplace_category')
            ->selectRaw('marketplace_category, COUNT(*) as total')
            ->groupBy('marketplace_category')->pluck('total', 'marketplace_category');

        return response()->json(collect(self::CATEGORIES)->map(fn ($c) => [
            'name' => $c,
            'count' => (int) ($counts[$c] ?? 0),
        ]));
    }

    public function products(Request $request)
    {
        $rows = Product::with('store')
            ->where('status', 'active')->whereNotNull('marketplace_category')
            ->whereHas('store', fn ($q) => $q->where('status', 'active'))
            ->when($request->query('category') && $request->query('category') !== 'All',
                fn ($q) => $q->where('marketplace_category', $request->query('category')))
            ->when($request->query('q'), fn ($query, $q) => $query->where('name', 'like', "%$q%"))
            ->latest()->paginate(30);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($p) => $this->shape($p)),
            'total' => $rows->total(),
        ]);
    }

    public function product(int $id)
    {
        $p = Product::with('store')->where('status', 'active')->findOrFail($id);
        return response()->json($this->shape($p) + ['description' => $p->description]);
    }

    public function checkout(Request $request)
    {
        RegionLock::check($request->user(), 'allow_customer');

        $data = $request->validate([
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'integer', 'exists:products,id'],
            'items.*.qty' => ['required', 'integer', 'min:1', 'max:50'],
            'delivery_address' => ['required', 'string', 'max:300'],
            'payment_method' => ['required', 'in:cash,wallet,card'],
        ]);

        // Group items per store — one merchant order per store.
        $products = Product::with('store')->whereIn('id', collect($data['items'])->pluck('product_id'))->get()->keyBy('id');
        $byStore = collect($data['items'])->groupBy(fn ($line) => $products[$line['product_id']]->store_id);

        $orders = DB::transaction(function () use ($byStore, $products, $data, $request) {
            $deliveryFee = (float) (PricingService::get('customer')['marketplaceDelivery'] ?? 40);
            $created = [];

            foreach ($byStore as $storeId => $lines) {
                $subtotal = 0;
                foreach ($lines as $line) {
                    $subtotal += $products[$line['product_id']]->price * $line['qty'];
                }
                $total = round($subtotal + $deliveryFee, 2);

                $order = Order::create([
                    'code' => Codes::make('HG'),
                    'store_id' => $storeId,
                    'customer_id' => $request->user()->id,
                    'channel' => 'marketplace',
                    'status' => 'new_order',
                    'subtotal' => $subtotal,
                    'delivery_fee' => $deliveryFee,
                    'total' => $total,
                    'payment_method' => $data['payment_method'],
                    'delivery_address' => $data['delivery_address'],
                    'district_id' => $request->user()->district_id,
                ]);

                foreach ($lines as $line) {
                    $product = $products[$line['product_id']];
                    $order->items()->create([
                        'product_id' => $product->id,
                        'name' => $product->name,
                        'qty' => $line['qty'],
                        'price' => $product->price,
                    ]);
                    if ($product->track_stock) {
                        $product->decrement('stock', $line['qty']);
                    }
                }

                if ($data['payment_method'] === 'wallet') {
                    Wallet::adjust($request->user(), -$total, "Marketplace order {$order->code}", 'order', $order->id);
                }

                Notifier::user($products[$lines[0]['product_id']]->store->user_id, 'New marketplace order',
                    "Order {$order->code} — ৳{$order->total}", 'new_order', ['order_id' => $order->id]);
                $created[] = $order;
            }

            $request->user()->customerProfile?->increment('orders_count');
            return $created;
        });

        Notifier::user($request->user(), 'Order placed', 'Your marketplace order was placed.', 'marketplace');

        return response()->json([
            'orders' => collect($orders)->map(fn ($o) => [
                'id' => $o->id, 'code' => $o->code, 'total' => (float) $o->total, 'status' => 'placed',
            ]),
        ], 201);
    }

    public function orders(Request $request)
    {
        $rows = Order::where('customer_id', $request->user()->id)->where('channel', 'marketplace')
            ->with(['items', 'store'])->latest()->paginate(30);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($o) => [
                'id' => $o->id,
                'code' => $o->code,
                'store' => $o->store?->name,
                'status' => $o->customerStatus(),
                'total' => (float) $o->total,
                'created_at' => $o->created_at->toIso8601String(),
                'items' => $o->items->map->only(['name', 'qty', 'price']),
            ]),
            'total' => $rows->total(),
        ]);
    }

    private function shape(Product $p): array
    {
        return [
            'id' => $p->id,
            'name' => $p->name,
            'category' => $p->marketplace_category,
            'price' => (float) $p->price,
            'rating' => (float) $p->rating,
            'image' => Media::url(($p->images ?? [])[0] ?? null),
            'store' => $p->store?->name,
            'in_stock' => ! $p->track_stock || $p->stock > 0,
        ];
    }
}

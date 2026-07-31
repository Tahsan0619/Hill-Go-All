<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Services\Dispatch;
use App\Services\Notifier;
use App\Services\PricingService;
use App\Services\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $store = $this->store($request);
        $status = $request->query('status');

        $rows = Order::where('store_id', $store->id)->with(['items', 'customer.customerProfile'])
            ->when($status === 'new', fn ($q) => $q->where('status', 'new_order'))
            ->when(in_array($status, ['preparing', 'ready'], true), fn ($q) => $q->where('status', $status))
            ->when($status === 'delivered', fn ($q) => $q->whereIn('status', ['delivered', 'on_the_way']))
            ->when($request->query('priority') && $request->query('priority') !== 'all',
                fn ($q) => $q->where('priority', $request->query('priority')))
            ->when($request->query('q'), function ($query, $q) {
                $query->where(fn ($w) => $w->where('code', 'like', "%$q%")
                    ->orWhereHas('customer', fn ($c) => $c->where('name', 'like', "%$q%")));
            })
            ->when($request->query('from'), fn ($q, $from) => $q->whereDate('created_at', '>=', $from))
            ->when($request->query('to'), fn ($q, $to) => $q->whereDate('created_at', '<=', $to))
            ->latest()->paginate(30);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($o) => $this->shape($o)),
            'total' => $rows->total(),
        ]);
    }

    public function show(Request $request, Order $order)
    {
        $this->authorizeOrder($request, $order);
        return response()->json($this->shape($order->load(['items', 'customer.customerProfile'])));
    }

    public function accept(Request $request, Order $order)
    {
        return $this->transition($request, $order, 'new_order', 'preparing', function (Order $o) {
            Notifier::user($o->customer_id, 'Order accepted', "{$o->store?->name} is preparing your order.", 'food', ['order_id' => $o->id]);
        });
    }

    public function ready(Request $request, Order $order)
    {
        return $this->transition($request, $order, 'preparing', 'ready', function (Order $o) {
            // Dispatch a rider food job as soon as the kitchen marks ready.
            Dispatch::offerFoodJob($o);
            Notifier::user($o->customer_id, 'Order ready', 'Your order is packed — assigning a rider now.', 'food', ['order_id' => $o->id]);
        });
    }

    public function deliver(Request $request, Order $order)
    {
        $this->authorizeOrder($request, $order);

        DB::transaction(function () use ($order) {
            // Lock + re-check: the rider completing the trip must not also credit.
            $locked = Order::whereKey($order->id)->lockForUpdate()->first();
            abort_unless(in_array($locked->status, ['ready', 'on_the_way'], true), 422, 'Order is not out for delivery.');
            $locked->update(['status' => 'delivered', 'delivered_at' => now()]);

            $pricing = PricingService::get('merchant');
            $commission = round($locked->subtotal * ((float) ($pricing['platformCommissionPct'] ?? 15)) / 100, 2);
            Wallet::adjustStore($locked->store_id, round($locked->subtotal - $commission, 2),
                "Order {$locked->code} settled", 'order', $locked->id, "Net of ৳{$commission} commission");
        });

        Notifier::user($order->customer_id, 'Order delivered', 'Your order was delivered. Enjoy!', 'food', ['order_id' => $order->id]);
        return response()->json($this->shape($order->fresh(['items', 'customer'])));
    }

    public function reject(Request $request, Order $order)
    {
        $this->authorizeOrder($request, $order);
        abort_unless(in_array($order->status, ['new_order', 'preparing'], true), 422, 'Order can no longer be rejected.');

        $data = $request->validate(['reason' => ['nullable', 'string', 'max:300']]);

        // Status flip + refund are one atomic unit.
        DB::transaction(function () use ($order, $data) {
            $locked = Order::whereKey($order->id)->lockForUpdate()->first();
            abort_unless(in_array($locked->status, ['new_order', 'preparing'], true), 422, 'Order can no longer be rejected.');
            $locked->update(['status' => 'rejected']);

            // Refund wallet payments in full.
            if ($locked->payment_method === 'wallet' && $locked->customer) {
                Wallet::adjust($locked->customer, (float) $locked->total, "Refund order {$locked->code}", 'order', $locked->id, $data['reason'] ?? 'Order rejected');
            }
        });

        Notifier::user($order->customer_id, 'Order rejected',
            $data['reason'] ?? "{$order->store?->name} could not take your order. Any payment was refunded.", 'food', ['order_id' => $order->id]);

        return response()->json($this->shape($order->fresh(['items', 'customer'])));
    }

    private function transition(Request $request, Order $order, string $from, string $to, callable $after)
    {
        $this->authorizeOrder($request, $order);
        abort_unless($order->status === $from, 422, "Order must be '{$from}' to do this.");
        $order->update(['status' => $to]);
        $after($order->fresh('store'));
        return response()->json($this->shape($order->fresh(['items', 'customer'])));
    }

    private function authorizeOrder(Request $request, Order $order): void
    {
        abort_unless($order->store_id === $request->user()->store?->id, 403);
    }

    private function store(Request $request)
    {
        $store = $request->user()->store;
        abort_unless($store, 404, 'No store yet. Complete onboarding first.');
        return $store;
    }

    private function shape(Order $o): array
    {
        return [
            'id' => $o->id,
            'code' => $o->code,
            'channel' => $o->channel,
            'status' => $o->status === 'new_order' ? 'new_order' : $o->status,
            'priority' => $o->priority,
            'scheduled_for' => $o->scheduled_for?->toIso8601String(),
            'customer_name' => $o->customer?->name,
            'customer_phone' => $o->customer?->phone,
            'customer_rating' => (float) ($o->customer?->customerProfile?->rating ?? 0),
            'customer_order_count' => (int) ($o->customer?->customerProfile?->orders_count ?? 0),
            'customer_note' => $o->customer_note,
            'items' => $o->items->map->only(['name', 'qty', 'price', 'notes']),
            'subtotal' => (float) $o->subtotal,
            'service_fee' => (float) $o->service_fee,
            'tax' => (float) $o->tax,
            'delivery_fee' => (float) $o->delivery_fee,
            'discount' => (float) $o->discount,
            'total' => (float) $o->total,
            'payment_method' => $o->payment_method,
            'delivery_address' => $o->delivery_address,
            'created_at' => $o->created_at->toIso8601String(),
            'delivered_at' => $o->delivered_at?->toIso8601String(),
            'rating' => $o->rating,
        ];
    }
}

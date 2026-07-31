<?php

namespace App\Http\Controllers\Api\Rider;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Parcel;
use App\Models\Ride;
use App\Models\Trip;
use App\Services\Dispatch;
use App\Services\Notifier;
use App\Services\PricingService;
use App\Services\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TripController extends Controller
{
    /** Status machine per job type (§27). */
    private const FLOW = [
        'ride' => ['accepted', 'arriving', 'arrived', 'in_progress', 'completed'],
        'food' => ['accepted', 'picked_up', 'completed'],
        'parcel' => ['accepted', 'picked_up', 'in_transit', 'completed'],
    ];

    public function currentOffer(Request $request)
    {
        Dispatch::sweepExpired();
        // Claim rides booked while this rider was offline / no one was online.
        Dispatch::claimPendingFor($request->user());

        $trip = Trip::with('customer.customerProfile')
            ->where('rider_id', $request->user()->id)
            ->where('status', 'requested')
            ->where('offer_expires_at', '>', now())
            // Prefer the newest booking so stale requeues don't steal the slot.
            ->latest('id')->first();

        return response()->json(['offer' => $trip ? $this->offerShape($trip) : null]);
    }

    public function accept(Request $request, Trip $trip)
    {
        abort_unless($trip->rider_id === $request->user()->id, 403);

        $expired = false;
        $result = DB::transaction(function () use ($request, $trip, &$expired) {
            // Re-read under lock so two concurrent accepts can't both win.
            $locked = Trip::whereKey($trip->id)->lockForUpdate()->first();

            abort_unless($locked->rider_id === $request->user()->id && $locked->status === 'requested',
                422, 'Offer is no longer available.');
            if ($locked->offer_expires_at && $locked->offer_expires_at->isPast()) {
                $expired = true;
                return $locked;
            }

            // One active job per rider, enforced at accept time.
            $busy = Trip::where('rider_id', $request->user()->id)
                ->whereIn('status', ['accepted', 'arriving', 'arrived', 'in_progress', 'picked_up', 'in_transit'])
                ->lockForUpdate()
                ->exists();
            abort_if($busy, 422, 'You already have an active job. Complete it before accepting another.');

            $locked->update(['status' => 'accepted', 'accepted_at' => now()]);
            return $locked;
        });

        if ($expired) {
            Dispatch::requeue($result);
            return response()->json(['message' => 'Offer expired.'], 422);
        }

        $this->syncRefOnAccept($result, $request);

        return response()->json($this->tripShape($result->fresh()));
    }

    public function decline(Request $request, Trip $trip)
    {
        // Idempotent: stale/expired offers should not hard-fail the rider app.
        if ($trip->rider_id !== $request->user()->id || $trip->status !== 'requested') {
            return response()->json(['message' => 'Offer is no longer available.']);
        }

        Dispatch::requeue($trip);
        return response()->json(['message' => 'Declined.']);
    }

    public function active(Request $request)
    {
        $trip = Trip::where('rider_id', $request->user()->id)
            ->whereIn('status', ['accepted', 'arriving', 'arrived', 'in_progress', 'picked_up', 'in_transit'])
            ->latest('accepted_at')->first();

        return response()->json(['trip' => $trip ? $this->tripShape($trip) : null]);
    }

    /** Advance to the next status in the machine for this job type. */
    public function advance(Request $request, Trip $trip)
    {
        abort_unless($trip->rider_id === $request->user()->id, 403);

        $flow = self::FLOW[$trip->type];
        $idx = array_search($trip->status, $flow, true);
        abort_if($idx === false || $idx === count($flow) - 1, 422, 'Trip cannot advance from its current status.');

        $next = $flow[$idx + 1];
        $trip->update(['status' => $next, 'completed_at' => $next === 'completed' ? now() : null]);

        $this->syncRefStatus($trip, $next);
        if ($next === 'completed') {
            $this->settleCompletion($trip, $request);
        }

        return response()->json($this->tripShape($trip->fresh()));
    }

    public function setStatus(Request $request, Trip $trip)
    {
        abort_unless($trip->rider_id === $request->user()->id, 403);
        $data = $request->validate(['status' => ['required', 'in:cancelled']]);

        abort_if(in_array($trip->status, ['completed', 'cancelled'], true), 422, 'Trip already finished.');
        $trip->update(['status' => 'cancelled']);
        $this->syncRefStatus($trip, 'cancelled');

        return response()->json($this->tripShape($trip->fresh()));
    }

    public function index(Request $request)
    {
        $filter = $request->query('filter', 'all');
        $rows = Trip::where('rider_id', $request->user()->id)
            ->whereNotIn('status', ['requested', 'expired', 'declined'])
            ->when($filter === 'completed', fn ($q) => $q->where('status', 'completed'))
            ->when($filter === 'cancelled', fn ($q) => $q->where('status', 'cancelled'))
            ->when($filter === 'cod', fn ($q) => $q->where('payment_method', 'cash'))
            ->when(in_array($filter, ['ride', 'food', 'parcel'], true), fn ($q) => $q->where('type', $filter))
            ->when($request->query('q'), function ($query, $q) {
                $query->where(fn ($w) => $w->where('code', 'like', "%$q%")
                    ->orWhere('pickup_name', 'like', "%$q%")->orWhere('drop_name', 'like', "%$q%"));
            })
            ->latest()->paginate(30);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($t) => $this->tripShape($t)),
            'total' => $rows->total(),
        ]);
    }

    public function show(Request $request, Trip $trip)
    {
        abort_unless($trip->rider_id === $request->user()->id, 403);
        return response()->json($this->tripShape($trip));
    }

    // —— Cross-surface sync ——

    private function syncRefOnAccept(Trip $trip, Request $request): void
    {
        $rider = $request->user();
        if ($trip->ref_type === 'rides') {
            Ride::where('id', $trip->ref_id)->update(['rider_id' => $rider->id, 'status' => 'assigned']);
            Notifier::user($trip->customer_id, 'Driver assigned', "{$rider->name} is on the way.", 'ride', ['ride_id' => $trip->ref_id]);
        } elseif ($trip->ref_type === 'parcels') {
            Parcel::where('id', $trip->ref_id)->update(['rider_id' => $rider->id]);
            Notifier::user($trip->customer_id, 'Parcel pickup on the way', "{$rider->name} will collect your parcel.", 'parcel', ['parcel_id' => $trip->ref_id]);
        } elseif ($trip->ref_type === 'orders') {
            Notifier::user($trip->customer_id, 'Rider assigned', "{$rider->name} will deliver your order.", 'food', ['order_id' => $trip->ref_id]);
        }
    }

    private function syncRefStatus(Trip $trip, string $status): void
    {
        if ($trip->ref_type === 'rides') {
            $map = ['arriving' => 'assigned', 'arrived' => 'assigned', 'in_progress' => 'in_progress', 'completed' => 'completed', 'cancelled' => 'searching'];
            if (isset($map[$status])) {
                $ride = Ride::find($trip->ref_id);
                if ($ride && ! in_array($ride->status, ['completed', 'cancelled'], true)) {
                    $ride->update([
                        'status' => $map[$status],
                        'completed_at' => $status === 'completed' ? now() : null,
                        'rider_id' => $status === 'cancelled' ? null : $ride->rider_id,
                    ]);
                    if ($status === 'completed') {
                        Notifier::user($ride->customer_id, 'Ride completed', "Fare ৳{$ride->fare}. Thanks for riding with HillGo!", 'ride', ['ride_id' => $ride->id]);
                    } elseif ($status === 'cancelled') {
                        Dispatch::offerRide($ride); // requeue for another driver
                    }
                }
            }
        } elseif ($trip->ref_type === 'orders') {
            if ($status === 'picked_up') {
                $order = Order::find($trip->ref_id);
                if ($order) {
                    $order->update(['status' => 'on_the_way']);
                    Notifier::user($order->customer_id, 'Order on the way', 'Your food is heading to you now.', 'food', ['order_id' => $order->id]);
                }
            } elseif ($status === 'completed') {
                // Lock + status guard: merchant "deliver" and rider completion
                // must never both mark delivered / credit the store.
                $order = DB::transaction(function () use ($trip) {
                    $locked = Order::whereKey($trip->ref_id)->lockForUpdate()->first();
                    if (! $locked || $locked->status === 'delivered' || in_array($locked->status, ['rejected', 'cancelled'], true)) {
                        return null;
                    }
                    $locked->update(['status' => 'delivered', 'delivered_at' => now()]);
                    $this->creditMerchant($locked);
                    return $locked;
                });
                if ($order) {
                    Notifier::user($order->customer_id, 'Order delivered', 'Enjoy your meal! Rate your experience.', 'food', ['order_id' => $order->id]);
                    Notifier::user($order->store?->user_id, 'Order delivered', "Order {$order->code} was delivered.", 'order', ['order_id' => $order->id]);
                }
            }
        } elseif ($trip->ref_type === 'parcels') {
            $map = ['picked_up' => 'picked_up', 'in_transit' => 'in_transit', 'completed' => 'delivered'];
            if (isset($map[$status])) {
                $parcel = Parcel::find($trip->ref_id);
                if ($parcel) {
                    $parcel->update([
                        'status' => $map[$status],
                        'picked_up_at' => $status === 'picked_up' ? now() : $parcel->picked_up_at,
                        'delivered_at' => $status === 'completed' ? now() : null,
                    ]);
                    Notifier::user($parcel->customer_id, 'Parcel ' . str_replace('_', ' ', $map[$status]),
                        "Tracking {$parcel->code}", 'parcel', ['parcel_id' => $parcel->id]);
                }
            }
        }
    }

    private function settleCompletion(Trip $trip, Request $request): void
    {
        $pricing = PricingService::get('rider');
        $commissionPct = (float) ($pricing['platformCommissionPct'] ?? 15);
        $net = round(($trip->earning * (1 - $commissionPct / 100)) + $trip->tip, 2);

        Wallet::adjustRider($request->user()->id, $net, "Trip {$trip->code} earnings", 'trip', $trip->id,
            "Net of {$commissionPct}% commission" . ($trip->tip > 0 ? " + ৳{$trip->tip} tip" : ''));

        Notifier::user($request->user(), 'Trip completed', "৳{$trip->earning} earned (net credited to balance).", 'earning', ['trip_id' => $trip->id]);

        // Loyalty: customers earn points on completed jobs.
        if ($trip->customer_id) {
            \App\Models\CustomerProfile::where('user_id', $trip->customer_id)->increment('loyalty_points', max(1, (int) round($trip->earning / 10)));
        }
    }

    // —— Shapes ——

    private function offerShape(Trip $t): array
    {
        return $this->tripShape($t) + [
            'expires_in_seconds' => max(0, (int) now()->diffInSeconds($t->offer_expires_at, false)),
            'customer' => $t->customer ? [
                'name' => $t->customer->name,
                'phone' => $t->customer->phone,
                'rating' => (float) ($t->customer->customerProfile?->rating ?? 0),
                'tier' => $t->customer->customerProfile?->tier,
            ] : null,
        ];
    }

    private function tripShape(Trip $t): array
    {
        return [
            'id' => $t->id,
            'code' => $t->code,
            'type' => $t->type,
            'status' => $t->status,
            'ref_type' => $t->ref_type,
            'ref_id' => $t->ref_id,
            'pickup_name' => $t->pickup_name,
            'pickup_address' => $t->pickup_address,
            'pickup_lat' => $t->pickup_lat !== null ? (float) $t->pickup_lat : null,
            'pickup_lng' => $t->pickup_lng !== null ? (float) $t->pickup_lng : null,
            'drop_name' => $t->drop_name,
            'drop_address' => $t->drop_address,
            'drop_lat' => $t->drop_lat !== null ? (float) $t->drop_lat : null,
            'drop_lng' => $t->drop_lng !== null ? (float) $t->drop_lng : null,
            'distance_km' => (float) $t->distance_km,
            'duration_min' => $t->duration_min,
            'earning' => (float) $t->earning,
            'tip' => (float) $t->tip,
            'payment_method' => $t->payment_method,
            'cod_amount' => (float) $t->cod_amount,
            'surge' => (float) $t->surge,
            'vehicle_required' => $t->vehicle_required,
            'weight_kg' => $t->weight_kg !== null ? (float) $t->weight_kg : null,
            'package_label' => $t->package_label,
            'created_at' => $t->created_at->toIso8601String(),
            'completed_at' => $t->completed_at?->toIso8601String(),
        ];
    }

    private function creditMerchant(Order $order): void
    {
        $pricing = PricingService::get('merchant');
        $commission = round($order->subtotal * ((float) ($pricing['platformCommissionPct'] ?? 15)) / 100, 2);
        Wallet::adjustStore($order->store_id, round($order->subtotal - $commission, 2),
            "Order {$order->code} settled", 'order', $order->id, "Net of ৳{$commission} commission");
    }
}

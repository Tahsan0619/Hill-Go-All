<?php

namespace App\Http\Controllers\Api\Customer;

use App\Http\Controllers\Controller;
use App\Models\Ride;
use App\Models\RiderProfile;
use App\Models\Trip;
use App\Services\Codes;
use App\Services\Dispatch;
use App\Services\Notifier;
use App\Services\PricingService;
use App\Services\RegionLock;
use App\Services\Wallet;
use App\Support\Geo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RideController extends Controller
{
    public function quote(Request $request)
    {
        $data = $request->validate([
            'distance_km' => ['required', 'numeric', 'min:0.1', 'max:500'],
            'duration_min' => ['required', 'numeric', 'min:0', 'max:1000'],
            'vehicle_type' => ['required', 'in:bike,car,xl'],
        ]);

        return response()->json(PricingService::rideFare(
            (float) $data['distance_km'], (float) $data['duration_min'], $data['vehicle_type']
        ));
    }

    public function store(Request $request)
    {
        RegionLock::check($request->user(), 'allow_customer');

        $data = $request->validate([
            'vehicle_type' => ['required', 'in:bike,car,xl'],
            'pickup' => ['required', 'string', 'max:300'],
            'drop' => ['required', 'string', 'max:300'],
            'pickup_lat' => ['nullable', 'numeric'], 'pickup_lng' => ['nullable', 'numeric'],
            'drop_lat' => ['nullable', 'numeric'], 'drop_lng' => ['nullable', 'numeric'],
            'distance_km' => ['required', 'numeric', 'min:0.1', 'max:500'],
            'duration_min' => ['required', 'numeric', 'min:0', 'max:1000'],
            'payment_method' => ['required', 'in:cash,wallet,card,bkash,nagad'],
        ]);

        // One active ride per customer (prevents double-booking).
        $hasActive = Ride::where('customer_id', $request->user()->id)
            ->whereIn('status', ['searching', 'assigned', 'in_progress'])
            ->exists();
        abort_if($hasActive, 422, 'You already have an active ride. Complete or cancel it first.');

        // Server recomputes distance when coords exist; never trusts client km blindly.
        $distanceKm = Geo::trustedDistanceKm(
            (float) $data['distance_km'],
            isset($data['pickup_lat']) ? (float) $data['pickup_lat'] : null,
            isset($data['pickup_lng']) ? (float) $data['pickup_lng'] : null,
            isset($data['drop_lat']) ? (float) $data['drop_lat'] : null,
            isset($data['drop_lng']) ? (float) $data['drop_lng'] : null,
        );

        // Server recalculates fare — client totals never trusted.
        $fare = PricingService::rideFare($distanceKm, (float) $data['duration_min'], $data['vehicle_type']);

        // Ride creation and any wallet debit are one atomic unit.
        $ride = DB::transaction(function () use ($request, $data, $fare, $distanceKm) {
            $ride = Ride::create([
                'code' => Codes::make('RID'),
                'customer_id' => $request->user()->id,
                'vehicle_type' => $data['vehicle_type'],
                'pickup' => $data['pickup'],
                'drop' => $data['drop'],
                'pickup_lat' => $data['pickup_lat'] ?? null,
                'pickup_lng' => $data['pickup_lng'] ?? null,
                'drop_lat' => $data['drop_lat'] ?? null,
                'drop_lng' => $data['drop_lng'] ?? null,
                'distance_km' => $distanceKm,
                'duration_min' => (int) $data['duration_min'],
                'fare' => $fare['fare'],
                'surge' => 1,
                'status' => 'searching',
                'payment_method' => $data['payment_method'],
                'district_id' => $request->user()->district_id,
            ]);

            if ($data['payment_method'] === 'wallet') {
                Wallet::adjust($request->user(), -(float) $fare['fare'], "Ride {$ride->code}", 'ride', $ride->id);
            }

            return $ride;
        });

        Dispatch::offerRide($ride);
        Notifier::user($request->user(), 'Finding your driver', "Ride {$ride->code} — searching nearby {$data['vehicle_type']} drivers.", 'ride', ['ride_id' => $ride->id]);

        return response()->json($this->shape($ride), 201);
    }

    public function index(Request $request)
    {
        $rows = Ride::where('customer_id', $request->user()->id)->latest()->paginate(30);
        return response()->json([
            'data' => collect($rows->items())->map(fn ($r) => $this->shape($r)),
            'total' => $rows->total(),
        ]);
    }

    public function show(Request $request, Ride $ride)
    {
        abort_unless($ride->customer_id === $request->user()->id, 403);
        Dispatch::sweepExpired();
        return response()->json($this->shape($ride->fresh()));
    }

    public function cancel(Request $request, Ride $ride)
    {
        abort_unless($ride->customer_id === $request->user()->id, 403);
        abort_if(in_array($ride->status, ['completed', 'cancelled'], true), 422, 'Ride already finished.');

        $data = $request->validate(['reason' => ['nullable', 'string', 'max:300']]);

        DB::transaction(function () use ($request, $ride, $data) {
            $ride->update(['status' => 'cancelled', 'cancel_reason' => $data['reason'] ?? 'Cancelled by customer']);

            // Refund wallet rides — only if a debit exists and no refund was issued yet
            // (idempotent; also skips legacy rides that were never debited).
            if ($ride->payment_method === 'wallet') {
                $debited = \App\Models\WalletTransaction::where('ref_type', 'ride')->where('ref_id', $ride->id)
                    ->where('user_id', $request->user()->id)->where('direction', 'debit')->exists();
                $refunded = \App\Models\WalletTransaction::where('ref_type', 'ride')->where('ref_id', $ride->id)
                    ->where('user_id', $request->user()->id)->where('direction', 'credit')->exists();
                if ($debited && ! $refunded) {
                    Wallet::adjust($request->user(), (float) $ride->fare, "Refund ride {$ride->code}", 'ride', $ride->id);
                }
            }
        });

        $openTrips = Trip::where('ref_type', 'rides')->where('ref_id', $ride->id)
            ->whereNotIn('status', ['completed', 'cancelled'])
            ->get();
        $tripIds = $openTrips->pluck('id')->all();
        Trip::whereIn('id', $tripIds)->update(['status' => 'cancelled']);

        if ($ride->rider_id) {
            Notifier::user(
                $ride->rider_id,
                'Ride cancelled',
                "Ride {$ride->code} was cancelled by the customer.",
                'ride',
                [
                    'ride_id' => $ride->id,
                    'trip_id' => $tripIds[0] ?? null,
                    'reason' => $ride->cancel_reason,
                ],
            );
        }

        return response()->json($this->shape($ride->fresh()));
    }

    public function rate(Request $request, Ride $ride)
    {
        abort_unless($ride->customer_id === $request->user()->id, 403);
        abort_unless($ride->status === 'completed', 422, 'Only completed rides can be rated.');

        $data = $request->validate([
            'rating' => ['required', 'integer', 'between:1,5'],
            'comment' => ['nullable', 'string', 'max:500'],
        ]);
        $ride->update(['rating' => $data['rating'], 'rating_comment' => $data['comment'] ?? null]);

        // Update the rider's aggregate rating.
        if ($ride->rider_id) {
            $profile = RiderProfile::where('user_id', $ride->rider_id)->first();
            if ($profile) {
                $count = $profile->rating_count + 1;
                $newRating = round((($profile->rating * $profile->rating_count) + $data['rating']) / $count, 2);
                $profile->update(['rating' => $newRating, 'rating_count' => $count]);
            }
        }

        return response()->json($this->shape($ride->fresh()));
    }

    private function shape(Ride $r): array
    {
        $r->loadMissing('rider.riderProfile');
        return [
            'id' => $r->id,
            'code' => $r->code,
            'vehicle_type' => $r->vehicle_type,
            'pickup' => $r->pickup,
            'drop' => $r->drop,
            'pickup_lat' => $r->pickup_lat, 'pickup_lng' => $r->pickup_lng,
            'drop_lat' => $r->drop_lat, 'drop_lng' => $r->drop_lng,
            'distance_km' => (float) $r->distance_km,
            'duration_min' => $r->duration_min,
            'fare' => (float) $r->fare,
            'status' => $r->status,
            'payment_method' => $r->payment_method,
            'rating' => $r->rating,
            'created_at' => $r->created_at->toIso8601String(),
            'driver' => $r->rider ? [
                'name' => $r->rider->name,
                'phone' => $r->rider->phone,
                'rating' => (float) ($r->rider->riderProfile?->rating ?? 0),
                'vehicle' => $r->rider->riderProfile?->vehicle_type,
                'plate' => $r->rider->riderProfile?->plate,
                'lat' => $r->rider->riderProfile?->lat,
                'lng' => $r->rider->riderProfile?->lng,
            ] : null,
        ];
    }
}

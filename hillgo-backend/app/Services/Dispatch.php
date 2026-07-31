<?php

namespace App\Services;

use App\Models\Order;
use App\Models\Parcel;
use App\Models\Ride;
use App\Models\RiderProfile;
use App\Models\Trip;
use App\Models\User;

class Dispatch
{
    private const OFFER_SECONDS = 60;

    /** Offer a customer ride to the next eligible online rider. */
    public static function offerRide(Ride $ride): ?Trip
    {
        $rider = self::nextRider('ride', $ride->vehicle_type, $ride->district_id, []);
        return self::createOffer('ride', $ride->customer_id, 'rides', $ride->id, [
            'pickup_name' => $ride->pickup,
            'pickup_address' => $ride->pickup,
            'pickup_lat' => $ride->pickup_lat,
            'pickup_lng' => $ride->pickup_lng,
            'drop_name' => $ride->drop,
            'drop_address' => $ride->drop,
            'drop_lat' => $ride->drop_lat,
            'drop_lng' => $ride->drop_lng,
            'distance_km' => $ride->distance_km,
            'duration_min' => $ride->duration_min,
            'earning' => PricingService::riderEarning('ride', $ride->distance_km, $ride->duration_min, 0, $ride->vehicle_type, (float) ($ride->surge ?? 1)),
            'payment_method' => $ride->payment_method === 'cash' ? 'cash' : 'digital',
            'surge' => (float) ($ride->surge ?? 1),
            'vehicle_required' => $ride->vehicle_type,
        ], $rider);
    }

    /** Offer a food delivery job when merchant marks the order ready. */
    public static function offerFoodJob(Order $order): ?Trip
    {
        $rider = self::nextRider('food', null, $order->district_id, []);
        $isCash = $order->payment_method === 'cash';
        return self::createOffer('food', $order->customer_id, 'orders', $order->id, [
            'pickup_name' => $order->store?->name,
            'pickup_address' => $order->store?->address,
            'pickup_lat' => $order->store?->lat,
            'pickup_lng' => $order->store?->lng,
            'drop_name' => 'Customer',
            'drop_address' => $order->delivery_address,
            'distance_km' => 0,
            'earning' => PricingService::riderEarning('food', 0),
            'payment_method' => $isCash ? 'cash' : 'digital',
            'cod_amount' => $isCash ? (float) $order->total : 0,
        ], $rider);
    }

    /** Offer a customer parcel to a rider (fulfillment_channel=rider). */
    public static function offerParcelJob(Parcel $parcel): ?Trip
    {
        $rider = self::nextRider('parcel', null, $parcel->district_id, []);
        return self::createOffer('parcel', $parcel->customer_id, 'parcels', $parcel->id, [
            'pickup_name' => $parcel->pickup_address,
            'pickup_address' => $parcel->pickup_address,
            'pickup_lat' => $parcel->pickup_lat,
            'pickup_lng' => $parcel->pickup_lng,
            'drop_name' => $parcel->drop_address,
            'drop_address' => $parcel->drop_address,
            'drop_lat' => $parcel->drop_lat,
            'drop_lng' => $parcel->drop_lng,
            'distance_km' => $parcel->distance_km,
            'earning' => PricingService::riderEarning('parcel', (float) $parcel->distance_km, 0, (float) $parcel->weight_kg),
            'payment_method' => $parcel->payment_method === 'cash' ? 'cash' : 'digital',
            'weight_kg' => $parcel->weight_kg,
            'package_label' => $parcel->type,
        ], $rider);
    }

    /** Assign a customer parcel to an online, verified courier agent. */
    public static function assignParcelToCourier(Parcel $parcel): bool
    {
        $agent = User::where('role', 'courier_agent')->where('status', 'active')
            ->whereHas('courierProfile', fn ($q) => $q->where('online', true)->where('verified', true))
            ->when($parcel->district_id, function ($q) use ($parcel) {
                $q->where(fn ($w) => $w->where('district_id', $parcel->district_id)->orWhereNull('district_id'));
            })
            ->withCount(['courierProfile'])
            ->inRandomOrder()
            ->first();

        if (! $agent) {
            return false;
        }

        $parcel->update([
            'courier_id' => $agent->id,
            'status' => 'assigned',
            'earnings' => PricingService::courierEarning((float) $parcel->distance_km, (float) $parcel->weight_kg, $parcel->priority, (float) $parcel->surge_bonus),
        ]);

        Notifier::user($agent, 'New parcel assigned', "Parcel {$parcel->code}: {$parcel->pickup_address} → {$parcel->drop_address}", 'parcel_assigned', ['parcel_id' => $parcel->id]);
        return true;
    }

    /** Requeue an expired/declined offer to the next eligible rider. */
    public static function requeue(Trip $trip, bool $allowRetrySkipped = false): ?Trip
    {
        $declined = $trip->declined_rider_ids ?? [];
        if ($trip->rider_id) {
            $declined[] = $trip->rider_id;
        }
        $declined = array_values(array_unique(array_map('intval', $declined)));

        $rider = self::nextRider($trip->type, $trip->vehicle_required, null, $declined);

        // After an expiry (or orphan recovery), if every eligible rider was already
        // skipped, start a fresh round so a solo rider can see the job again.
        if (! $rider && $allowRetrySkipped && $declined !== []) {
            $declined = [];
            $rider = self::nextRider($trip->type, $trip->vehicle_required, null, []);
        }

        if (! $rider) {
            $trip->update(['rider_id' => null, 'status' => 'requested', 'declined_rider_ids' => $declined, 'offered_at' => null, 'offer_expires_at' => null]);
            return null;
        }
        $trip->update([
            'rider_id' => $rider->id,
            'status' => 'requested',
            'declined_rider_ids' => $declined,
            'offered_at' => now(),
            'offer_expires_at' => now()->addSeconds(self::OFFER_SECONDS),
        ]);
        Notifier::user($rider, 'New job offer', ucfirst($trip->type) . " job ৳{$trip->earning}", 'offer', ['trip_id' => $trip->id]);
        return $trip;
    }

    /** Sweep expired offers and requeue them. Called opportunistically. */
    public static function sweepExpired(): void
    {
        Trip::where('status', 'requested')
            ->whereNotNull('offer_expires_at')
            ->where('offer_expires_at', '<', now())
            ->orderBy('offer_expires_at')
            ->limit(50)
            ->get()
            ->each(fn (Trip $t) => self::requeue($t, true));

        // Orphans: booked while no eligible rider was online (rider_id null, no expiry).
        Trip::where('status', 'requested')
            ->whereNull('rider_id')
            ->orderBy('created_at')
            ->limit(50)
            ->get()
            ->each(fn (Trip $t) => self::requeue($t, true));
    }

    /**
     * Assign the oldest matching unassigned offer to this rider.
     * Fixes the gap where a ride was booked before the rider went online.
     */
    public static function claimPendingFor(User $rider): ?Trip
    {
        $profile = $rider->riderProfile;
        if (! $profile || ! $profile->online || $profile->kyc_status !== 'verified' || $rider->status !== 'active') {
            return null;
        }

        $hasOpen = Trip::where('rider_id', $rider->id)
            ->where(function ($q) {
                $q->whereIn('status', ['accepted', 'arriving', 'arrived', 'in_progress', 'picked_up', 'in_transit'])
                    ->orWhere(function ($w) {
                        $w->where('status', 'requested')->where('offer_expires_at', '>', now());
                    });
            })
            ->exists();
        if ($hasOpen) {
            return null;
        }

        $candidates = Trip::where('status', 'requested')
            ->whereNull('rider_id')
            ->where(function ($q) use ($profile) {
                $q->whereNull('vehicle_required')
                    ->orWhere('vehicle_required', $profile->vehicle_type);
            })
            ->orderBy('created_at')
            ->limit(20)
            ->get();

        $trip = $candidates->first(function (Trip $t) use ($rider) {
            $declined = $t->declined_rider_ids ?? [];

            return ! in_array($rider->id, $declined, false)
                && ! in_array((string) $rider->id, array_map('strval', $declined), true);
        });

        if (! $trip) {
            return null;
        }

        $trip->update([
            'rider_id' => $rider->id,
            'offered_at' => now(),
            'offer_expires_at' => now()->addSeconds(self::OFFER_SECONDS),
        ]);

        Notifier::user($rider, 'New job offer', ucfirst($trip->type)." job ৳{$trip->earning}", 'offer', ['trip_id' => $trip->id]);

        return $trip->fresh();
    }

    private static function nextRider(string $type, ?string $vehicleType, ?string $districtId, array $exclude): ?User
    {
        $busyRiderIds = Trip::whereIn('status', ['accepted', 'arriving', 'arrived', 'in_progress', 'picked_up', 'in_transit'])
            ->whereNotNull('rider_id')->pluck('rider_id');

        return User::where('role', 'rider')->where('status', 'active')
            ->whereHas('riderProfile', function ($q) use ($vehicleType) {
                $q->where('online', true)->where('kyc_status', 'verified');
                if ($vehicleType) {
                    $q->where('vehicle_type', $vehicleType);
                }
            })
            ->whereNotIn('id', $busyRiderIds)
            ->whereNotIn('id', $exclude)
            ->when($districtId, function ($q) use ($districtId) {
                $q->where(fn ($w) => $w->where('district_id', $districtId)->orWhereNull('district_id'));
            })
            ->inRandomOrder()
            ->first();
    }

    private static function createOffer(string $type, ?int $customerId, string $refType, int $refId, array $attrs, ?User $rider): ?Trip
    {
        $trip = Trip::create(array_merge([
            'code' => 'HG-' . strtoupper(uniqid()),
            'type' => $type,
            'customer_id' => $customerId,
            'ref_type' => $refType,
            'ref_id' => $refId,
            'status' => 'requested',
            'rider_id' => $rider?->id,
            'offered_at' => $rider ? now() : null,
            'offer_expires_at' => $rider ? now()->addSeconds(self::OFFER_SECONDS) : null,
            'declined_rider_ids' => [],
        ], $attrs));

        if ($rider) {
            Notifier::user($rider, 'New job offer', ucfirst($type) . " job ৳{$trip->earning}", 'offer', ['trip_id' => $trip->id]);
        }
        return $trip;
    }
}

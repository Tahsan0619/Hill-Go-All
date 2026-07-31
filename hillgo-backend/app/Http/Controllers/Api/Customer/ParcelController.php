<?php

namespace App\Http\Controllers\Api\Customer;

use App\Http\Controllers\Controller;
use App\Models\Parcel;
use App\Services\Codes;
use App\Services\Dispatch;
use App\Services\Notifier;
use App\Services\PricingService;
use App\Services\RegionLock;
use App\Services\Wallet;
use App\Support\Geo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class ParcelController extends Controller
{
    public function quote(Request $request)
    {
        $data = $request->validate([
            'distance_km' => ['required', 'numeric', 'min:0.1', 'max:1000'],
            'weight_kg' => ['required', 'numeric', 'min:0.1', 'max:500'],
            'priority' => ['nullable', 'in:standard,express,priority'],
        ]);
        return response()->json(PricingService::parcelFare(
            (float) $data['distance_km'], (float) $data['weight_kg'], $data['priority'] ?? 'standard'
        ));
    }

    public function store(Request $request)
    {
        RegionLock::check($request->user(), 'allow_customer');

        $data = $request->validate([
            'type' => ['required', 'in:Document,Box,Fragile'],
            'priority' => ['nullable', 'in:standard,express,priority'],
            'pickup_address' => ['required', 'string', 'max:300'],
            'sender_name' => ['required', 'string', 'max:120'],
            'sender_phone' => ['required', 'string', 'max:32'],
            'receiver_name' => ['required', 'string', 'max:120'],
            'receiver_phone' => ['required', 'string', 'max:32'],
            'drop_address' => ['required', 'string', 'max:300'],
            'pickup_lat' => ['nullable', 'numeric'], 'pickup_lng' => ['nullable', 'numeric'],
            'drop_lat' => ['nullable', 'numeric'], 'drop_lng' => ['nullable', 'numeric'],
            'weight_kg' => ['required', 'numeric', 'min:0.1', 'max:500'],
            'distance_km' => ['required', 'numeric', 'min:0.1', 'max:1000'],
            'payment_method' => ['required', 'in:cash,wallet'],
            'notes' => ['nullable', 'string', 'max:300'],
            'fragile' => ['nullable', 'boolean'],
        ]);

        $priority = $data['priority'] ?? 'standard';
        $distanceKm = Geo::trustedDistanceKm(
            (float) $data['distance_km'],
            isset($data['pickup_lat']) ? (float) $data['pickup_lat'] : null,
            isset($data['pickup_lng']) ? (float) $data['pickup_lng'] : null,
            isset($data['drop_lat']) ? (float) $data['drop_lat'] : null,
            isset($data['drop_lng']) ? (float) $data['drop_lng'] : null,
        );
        $weightKg = min(500.0, max(0.1, (float) $data['weight_kg']));
        $fareBreakdown = PricingService::parcelFare($distanceKm, $weightKg, $priority);

        // Server-generated OTPs; hashed at rest, plain codes only in customer notifications.
        $pickupOtp = (string) random_int(1000, 9999);
        $deliveryOtp = (string) random_int(1000, 9999);

        // Parcel creation and any wallet debit are one atomic unit.
        $parcel = DB::transaction(function () use ($request, $data, $priority, $fareBreakdown, $pickupOtp, $deliveryOtp, $distanceKm, $weightKg) {
            $parcel = Parcel::create([
            'code' => Codes::make('HG'),
            'customer_id' => $request->user()->id,
            'type' => $data['type'],
            'priority' => $priority,
            'fulfillment_channel' => 'courier',
            'sender_name' => $data['sender_name'],
            'sender_phone' => $data['sender_phone'],
            'pickup_address' => $data['pickup_address'],
            'pickup_lat' => $data['pickup_lat'] ?? null,
            'pickup_lng' => $data['pickup_lng'] ?? null,
            'receiver_name' => $data['receiver_name'],
            'receiver_phone' => $data['receiver_phone'],
            'drop_address' => $data['drop_address'],
            'drop_lat' => $data['drop_lat'] ?? null,
            'drop_lng' => $data['drop_lng'] ?? null,
            'weight_kg' => $weightKg,
            'distance_km' => $distanceKm,
            'fare' => $fareBreakdown['fare'],
            'status' => 'booked',
            'pickup_otp_hash' => Hash::make($pickupOtp),
            'delivery_otp_hash' => Hash::make($deliveryOtp),
            'fragile' => (bool) ($data['fragile'] ?? $data['type'] === 'Fragile'),
            'notes' => $data['notes'] ?? null,
            'payment_method' => $data['payment_method'],
            'district_id' => $request->user()->district_id,
            ]);

            if ($data['payment_method'] === 'wallet') {
                Wallet::adjust($request->user(), -(float) $fareBreakdown['fare'], "Parcel {$parcel->code}", 'parcel', $parcel->id);
            }

            return $parcel;
        });

        // Try to assign an online courier; falls back to rider dispatch.
        $assigned = Dispatch::assignParcelToCourier($parcel);
        if (! $assigned) {
            $parcel->update(['fulfillment_channel' => 'rider']);
            Dispatch::offerParcelJob($parcel);
        }

        Notifier::user($request->user(), 'Parcel booked',
            "Tracking {$parcel->code}. Pickup OTP: {$pickupOtp} · Delivery OTP: {$deliveryOtp} (share with the receiver).",
            'parcel', ['parcel_id' => $parcel->id, 'pickup_otp' => $pickupOtp, 'delivery_otp' => $deliveryOtp]);

        // Load courier so the customer app can show the assigned agent immediately.
        return response()->json($this->shape($parcel->fresh()->load('courier')) + [
            'pickup_otp' => $pickupOtp,
            'delivery_otp' => $deliveryOtp,
        ], 201);
    }

    public function index(Request $request)
    {
        $rows = Parcel::where('customer_id', $request->user()->id)
            ->with('courier')
            ->latest()
            ->paginate(30);
        return response()->json([
            'data' => collect($rows->items())->map(fn ($p) => $this->shape($p)),
            'total' => $rows->total(),
        ]);
    }

    public function show(Request $request, Parcel $parcel)
    {
        abort_unless($parcel->customer_id === $request->user()->id, 403);
        return response()->json($this->shape($parcel->load('courier')));
    }

    public function cancel(Request $request, Parcel $parcel)
    {
        abort_unless($parcel->customer_id === $request->user()->id, 403);
        abort_unless(in_array($parcel->status, ['booked', 'assigned'], true), 422, 'Parcel already in progress.');

        // Status flip + refund are one atomic unit.
        DB::transaction(function () use ($request, $parcel) {
            $locked = Parcel::whereKey($parcel->id)->lockForUpdate()->first();
            abort_unless(in_array($locked->status, ['booked', 'assigned'], true), 422, 'Parcel already in progress.');
            $locked->update(['status' => 'cancelled']);
            if ($locked->payment_method === 'wallet') {
                Wallet::adjust($request->user(), (float) $locked->fare, "Refund parcel {$locked->code}", 'parcel', $locked->id);
            }
        });
        if ($parcel->courier_id) {
            Notifier::user($parcel->courier_id, 'Parcel cancelled', "Parcel {$parcel->code} was cancelled.", 'parcel');
        }
        return response()->json($this->shape($parcel->fresh()));
    }

    private function shape(Parcel $p): array
    {
        return [
            'id' => $p->id,
            'code' => $p->code,
            'type' => $p->type,
            'priority' => $p->priority,
            'status' => in_array($p->status, ['booked', 'assigned'], true) ? 'booked' : $p->status,
            'pickup_address' => $p->pickup_address,
            'drop_address' => $p->drop_address,
            'receiver_name' => $p->receiver_name,
            'weight_kg' => (float) $p->weight_kg,
            'distance_km' => (float) $p->distance_km,
            'fare' => (float) $p->fare,
            'payment_method' => $p->payment_method,
            'created_at' => $p->created_at->toIso8601String(),
            'picked_up_at' => $p->picked_up_at?->toIso8601String(),
            'delivered_at' => $p->delivered_at?->toIso8601String(),
            'agent' => $p->relationLoaded('courier') && $p->courier ? [
                'name' => $p->courier->name, 'phone' => $p->courier->phone,
            ] : null,
        ];
    }
}

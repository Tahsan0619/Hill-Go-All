<?php

namespace App\Http\Controllers\Api\Customer;

use App\Http\Controllers\Controller;
use App\Models\RentalBooking;
use App\Models\RentalVehicle;
use App\Services\Codes;
use App\Services\Notifier;
use App\Services\PricingService;
use App\Services\RegionLock;
use Illuminate\Http\Request;

class RentalController extends Controller
{
    public function index(Request $request)
    {
        $rows = RentalVehicle::where('active', true)
            ->when($request->query('category') && $request->query('category') !== 'All',
                fn ($q) => $q->where('category', $request->query('category')))
            ->when($request->query('q'), fn ($query, $q) => $query->where('name', 'like', "%$q%"))
            ->orderByDesc('rating')->paginate(30);

        return response()->json(['data' => $rows->items(), 'total' => $rows->total()]);
    }

    public function show(int $id)
    {
        return response()->json(RentalVehicle::where('active', true)->findOrFail($id));
    }

    public function book(Request $request)
    {
        RegionLock::check($request->user(), 'allow_customer');

        $data = $request->validate([
            'vehicle_id' => ['required', 'integer', 'exists:rental_vehicles,id'],
            'pickup_location' => ['required', 'string', 'max:300'],
            'dropoff_location' => ['required', 'string', 'max:300'],
            'start_date' => ['required', 'date', 'after_or_equal:today'],
            'end_date' => ['required', 'date', 'after_or_equal:start_date'],
            'with_driver' => ['nullable', 'boolean'],
            'renter_name' => ['required', 'string', 'max:120'],
            'renter_phone' => ['required', 'string', 'max:32'],
        ]);

        $vehicle = RentalVehicle::where('active', true)->findOrFail($data['vehicle_id']);
        $days = max(1, \Carbon\Carbon::parse($data['start_date'])->diffInDays(\Carbon\Carbon::parse($data['end_date'])) + 1);

        $pricing = PricingService::get('customer');
        $vehicleTotal = round($vehicle->price_per_day * $days, 2);
        $driverFee = ($data['with_driver'] ?? false) ? round((float) ($pricing['rentalDriverPerDay'] ?? 1500) * $days, 2) : 0;
        $insuranceFee = round((float) ($pricing['rentalInsurancePerDay'] ?? 300) * $days, 2);

        $booking = RentalBooking::create([
            'code' => Codes::make('RB'),
            'vehicle_id' => $vehicle->id,
            'customer_id' => $request->user()->id,
            'pickup_location' => $data['pickup_location'],
            'dropoff_location' => $data['dropoff_location'],
            'start_date' => $data['start_date'],
            'end_date' => $data['end_date'],
            'days' => $days,
            'with_driver' => (bool) ($data['with_driver'] ?? false),
            'renter_name' => $data['renter_name'],
            'renter_phone' => $data['renter_phone'],
            'vehicle_total' => $vehicleTotal,
            'driver_fee' => $driverFee,
            'insurance_fee' => $insuranceFee,
            'total' => round($vehicleTotal + $driverFee + $insuranceFee, 2),
            'status' => 'upcoming',
        ]);

        Notifier::user($request->user(), 'Rental booked', "{$vehicle->name}, {$days} day(s) — ৳{$booking->total}", 'rental', ['booking_id' => $booking->id]);
        Notifier::admins('New rental booking', "{$vehicle->name} — {$booking->code}", 'rental');

        return response()->json($booking->load('vehicle'), 201);
    }

    public function bookings(Request $request)
    {
        return response()->json(
            RentalBooking::where('customer_id', $request->user()->id)->with('vehicle')->latest()->paginate(30)
        );
    }

    public function cancelBooking(Request $request, RentalBooking $booking)
    {
        abort_unless($booking->customer_id === $request->user()->id, 403);
        abort_unless($booking->status === 'upcoming', 422, 'Only upcoming bookings can be cancelled.');
        $booking->update(['status' => 'cancelled']);
        return response()->json($booking->fresh());
    }
}

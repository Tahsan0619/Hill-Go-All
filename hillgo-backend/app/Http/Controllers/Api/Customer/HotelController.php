<?php

namespace App\Http\Controllers\Api\Customer;

use App\Http\Controllers\Controller;
use App\Models\Hotel;
use App\Models\HotelBooking;
use App\Services\Codes;
use App\Services\Notifier;
use App\Services\PricingService;
use App\Services\RegionLock;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class HotelController extends Controller
{
    public function index(Request $request)
    {
        $rows = Hotel::where('active', true)
            ->when($request->query('location') && $request->query('location') !== 'All',
                fn ($q) => $q->where('location', 'like', '%' . $request->query('location') . '%'))
            ->when($request->query('q'), fn ($query, $q) => $query->where('name', 'like', "%$q%"))
            ->orderByDesc('rating')->paginate(30);

        return response()->json(['data' => $rows->items(), 'total' => $rows->total()]);
    }

    public function show(int $id)
    {
        return response()->json(Hotel::where('active', true)->findOrFail($id));
    }

    public function book(Request $request)
    {
        RegionLock::check($request->user(), 'allow_customer');

        $data = $request->validate([
            'hotel_id' => ['required', 'integer', 'exists:hotels,id'],
            'check_in' => ['required', 'date', 'after_or_equal:today'],
            'check_out' => ['required', 'date', 'after:check_in'],
            'guests' => ['required', 'integer', 'min:1', 'max:20'],
            'rooms' => ['required', 'integer', 'min:1', 'max:10'],
            'guest_name' => ['required', 'string', 'max:120'],
            'guest_phone' => ['required', 'string', 'max:32'],
        ]);

        $hotel = Hotel::where('active', true)->findOrFail($data['hotel_id']);
        $nights = \Carbon\Carbon::parse($data['check_in'])->diffInDays(\Carbon\Carbon::parse($data['check_out']));
        if ($nights < 1) {
            throw ValidationException::withMessages(['check_out' => 'Stay must be at least one night.']);
        }

        $roomTotal = round($hotel->price_per_night * $nights * $data['rooms'], 2);
        $feePct = (float) (PricingService::get('customer')['hotelServiceFeePct'] ?? 5);
        $serviceFee = round($roomTotal * $feePct / 100, 2);

        $booking = HotelBooking::create([
            'code' => Codes::make('HB'),
            'hotel_id' => $hotel->id,
            'customer_id' => $request->user()->id,
            'check_in' => $data['check_in'],
            'check_out' => $data['check_out'],
            'nights' => $nights,
            'guests' => $data['guests'],
            'rooms' => $data['rooms'],
            'guest_name' => $data['guest_name'],
            'guest_phone' => $data['guest_phone'],
            'room_total' => $roomTotal,
            'service_fee' => $serviceFee,
            'total' => round($roomTotal + $serviceFee, 2),
            'status' => 'upcoming',
        ]);

        Notifier::user($request->user(), 'Hotel booked', "{$hotel->name}, {$nights} night(s) — ৳{$booking->total}", 'hotel', ['booking_id' => $booking->id]);
        Notifier::admins('New hotel booking', "{$hotel->name} — {$booking->code}", 'hotel');

        return response()->json($booking->load('hotel'), 201);
    }

    public function bookings(Request $request)
    {
        return response()->json(
            HotelBooking::where('customer_id', $request->user()->id)->with('hotel')->latest()->paginate(30)
        );
    }

    public function cancelBooking(Request $request, HotelBooking $booking)
    {
        abort_unless($booking->customer_id === $request->user()->id, 403);
        abort_unless($booking->status === 'upcoming', 422, 'Only upcoming bookings can be cancelled.');
        $booking->update(['status' => 'cancelled']);
        return response()->json($booking->fresh());
    }
}

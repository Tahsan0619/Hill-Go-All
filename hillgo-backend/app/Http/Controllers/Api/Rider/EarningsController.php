<?php

namespace App\Http\Controllers\Api\Rider;

use App\Http\Controllers\Controller;
use App\Models\RiderPayout;
use App\Models\Trip;
use App\Services\Codes;
use App\Services\Notifier;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class EarningsController extends Controller
{
    public function summary(Request $request)
    {
        $riderId = $request->user()->id;
        $profile = $request->user()->riderProfile;

        $todayTrips = Trip::where('rider_id', $riderId)->where('status', 'completed')->whereDate('completed_at', today());
        $todayTotal = (float) (clone $todayTrips)->sum('earning');
        $yesterdayTotal = (float) Trip::where('rider_id', $riderId)->where('status', 'completed')
            ->whereDate('completed_at', today()->subDay())->sum('earning');

        $thisWeek = (float) Trip::where('rider_id', $riderId)->where('status', 'completed')
            ->whereBetween('completed_at', [now()->startOfWeek(), now()])->sum('earning');
        $lastWeek = (float) Trip::where('rider_id', $riderId)->where('status', 'completed')
            ->whereBetween('completed_at', [now()->subWeek()->startOfWeek(), now()->subWeek()->endOfWeek()])->sum('earning');

        $dailyTotals = collect(range(6, 0))->map(function ($daysAgo) use ($riderId) {
            $day = today()->subDays($daysAgo);
            return [
                'date' => $day->toDateString(),
                'total' => (float) Trip::where('rider_id', $riderId)->where('status', 'completed')
                    ->whereDate('completed_at', $day)->sum('earning'),
            ];
        });

        $onlineSeconds = (int) $profile->online_seconds_today
            + ($profile->online && $profile->online_since ? $profile->online_since->diffInSeconds(now()) : 0);

        return response()->json([
            'today_total' => $todayTotal,
            'today_trips' => (clone $todayTrips)->count(),
            'online_duration_seconds' => $onlineSeconds,
            'today_trend_percent' => $yesterdayTotal > 0 ? round(($todayTotal - $yesterdayTotal) / $yesterdayTotal * 100, 1) : 0,
            'current_balance' => (float) $profile->balance,
            'week_trend_percent' => $lastWeek > 0 ? round(($thisWeek - $lastWeek) / $lastWeek * 100, 1) : 0,
            'base_fare' => (float) (clone $todayTrips)->where('surge', '<=', 1)->sum('earning'),
            'tips' => (float) (clone $todayTrips)->sum('tip'),
            'surge_bonuses' => (float) (clone $todayTrips)->where('surge', '>', 1)->sum('earning'),
            'daily_totals' => $dailyTotals,
        ]);
    }

    public function payouts(Request $request)
    {
        $rows = RiderPayout::where('rider_id', $request->user()->id)->latest()->paginate(30);
        return response()->json([
            'data' => collect($rows->items())->map(fn ($p) => [
                'id' => $p->id, 'code' => $p->code, 'amount' => (float) $p->amount,
                'method' => $p->method, 'status' => $p->status, 'source' => $p->source,
                'ref' => $p->ref, 'paid_at' => $p->paid_at?->toIso8601String(),
                'created_at' => $p->created_at->toIso8601String(),
            ]),
            'total' => $rows->total(),
        ]);
    }

    public function cashOut(Request $request)
    {
        $data = $request->validate([
            'amount' => ['required', 'numeric', 'min:100'],
            'method' => ['required', 'in:bKash,Nagad,Bank'],
        ]);

        $payout = DB::transaction(function () use ($request, $data) {
            $profile = $request->user()->riderProfile()->lockForUpdate()->first();
            $pendingRequests = (float) RiderPayout::where('rider_id', $request->user()->id)
                ->where('source', 'cash_out')->whereIn('status', ['pending', 'processing'])->sum('amount');
            if ($data['amount'] > $profile->balance - $pendingRequests) {
                throw ValidationException::withMessages(['amount' => 'Amount exceeds your available balance.']);
            }
            // Balance is settled when Admin marks the payout paid.
            return RiderPayout::create([
                'code' => Codes::make('HG-PY'),
                'rider_id' => $request->user()->id,
                'amount' => (float) $data['amount'],
                'method' => $data['method'],
                'status' => 'pending',
                'source' => 'cash_out',
            ]);
        });

        Notifier::admins('Rider cash-out request', "{$request->user()->name}: ৳{$payout->amount} via {$payout->method}", 'payout', ['payout_id' => $payout->id]);
        Notifier::user($request->user(), 'Cash-out requested', "৳{$payout->amount} request submitted for review.", 'payout');

        return response()->json([
            'id' => $payout->id, 'code' => $payout->code, 'amount' => (float) $payout->amount,
            'method' => $payout->method, 'status' => $payout->status,
        ], 201);
    }

    public function updateVehicle(Request $request)
    {
        $data = $request->validate([
            'vehicle_type' => ['sometimes', 'in:bike,car,xl'],
            'vehicle_make' => ['sometimes', 'string', 'max:64'],
            'vehicle_model' => ['sometimes', 'string', 'max:64'],
            'vehicle_year' => ['sometimes', 'string', 'max:8'],
            'plate' => ['sometimes', 'string', 'max:64'],
            'payout_method' => ['sometimes', 'in:bKash,Nagad,Bank'],
        ]);
        $request->user()->riderProfile->update($data);
        return response()->json($request->user()->riderProfile->fresh()->only([
            'vehicle_type', 'vehicle_make', 'vehicle_model', 'vehicle_year', 'plate', 'payout_method',
        ]));
    }
}

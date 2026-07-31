<?php

namespace App\Http\Controllers\Api\Courier;

use App\Http\Controllers\Controller;
use App\Models\CourierWithdrawal;
use App\Models\Incentive;
use App\Models\IncentiveEnrollment;
use App\Models\Parcel;
use App\Services\Codes;
use App\Services\Notifier;
use App\Services\PricingService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class EarningsController extends Controller
{
    public function dashboard(Request $request)
    {
        $userId = $request->user()->id;
        $delivered = Parcel::where('courier_id', $userId)->where('status', 'delivered');

        $todayEarnings = (float) (clone $delivered)->whereDate('delivered_at', today())->sum(DB::raw('earnings + surge_bonus'));
        $yesterday = (float) (clone $delivered)->whereDate('delivered_at', today()->subDay())->sum(DB::raw('earnings + surge_bonus'));

        $trend = collect(range(6, 0))->map(fn ($d) => [
            'date' => today()->subDays($d)->toDateString(),
            'total' => (float) (clone $delivered)->whereDate('delivered_at', today()->subDays($d))->sum(DB::raw('earnings + surge_bonus')),
        ]);

        $pricing = PricingService::get('courier');

        return response()->json([
            'today_earnings' => $todayEarnings,
            'distance_km' => (float) (clone $delivered)->whereDate('delivered_at', today())->sum('distance_km'),
            'deliveries_today' => (clone $delivered)->whereDate('delivered_at', today())->count(),
            'bonus_multiplier' => (float) ($pricing['topPerformerMultiplier'] ?? 1.2),
            'earnings_trend' => $trend,
            'trend_percent' => $yesterday > 0 ? round(($todayEarnings - $yesterday) / $yesterday * 100, 1) : 0,
            'balance' => (float) $request->user()->courierProfile->balance,
        ]);
    }

    public function weekly(Request $request)
    {
        $userId = $request->user()->id;
        $delivered = Parcel::where('courier_id', $userId)->where('status', 'delivered');

        $thisWeek = (clone $delivered)->whereBetween('delivered_at', [now()->startOfWeek(), now()]);
        $lastWeekTotal = (float) (clone $delivered)->whereBetween('delivered_at', [
            now()->subWeek()->startOfWeek(), now()->subWeek()->endOfWeek(),
        ])->sum(DB::raw('earnings + surge_bonus'));

        $total = (float) (clone $thisWeek)->sum(DB::raw('earnings + surge_bonus'));
        $count = (clone $thisWeek)->count();

        $daily = collect(range(0, 6))->map(function ($offset) use ($delivered) {
            $day = now()->startOfWeek()->addDays($offset);
            $dayRows = (clone $delivered)->whereDate('delivered_at', $day);
            return [
                'date' => $day->toDateString(),
                'total' => (float) (clone $dayRows)->sum(DB::raw('earnings + surge_bonus')),
                'base_pay' => (float) (clone $dayRows)->sum('earnings'),
                'surges' => (float) (clone $dayRows)->sum('surge_bonus'),
                'deliveries' => (clone $dayRows)->count(),
            ];
        });

        $goal = (int) (PricingService::get('courier')['weeklyGoalDeliveries'] ?? 50);

        return response()->json([
            'total' => $total,
            'percent_change' => $lastWeekTotal > 0 ? round(($total - $lastWeekTotal) / $lastWeekTotal * 100, 1) : 0,
            'total_deliveries' => $count,
            'avg_per_delivery' => $count > 0 ? round($total / $count, 2) : 0,
            'daily' => $daily,
            'weekly_goal' => $goal,
            'weekly_goal_percent' => $goal > 0 ? min(100, round($count / $goal * 100)) : 0,
        ]);
    }

    public function payoutSummary(Request $request)
    {
        $profile = $request->user()->courierProfile;
        $transactions = CourierWithdrawal::where('courier_id', $request->user()->id)->latest()->limit(20)->get();

        return response()->json([
            'balance' => (float) $profile->balance,
            'next_payout_date' => now()->next('friday')->toDateString(),
            'total_processed' => (float) CourierWithdrawal::where('courier_id', $request->user()->id)
                ->whereIn('status', ['approved', 'paid'])->sum('amount'),
            'bank_last_four' => $profile->bank_last4,
            'is_verified' => (bool) $profile->bank_verified,
            'deliveries_completed' => (int) $profile->deliveries_count,
            'withdrawal_min' => (float) (PricingService::get('courier')['withdrawalMin'] ?? 500),
            'transactions' => $transactions,
        ]);
    }

    public function withdraw(Request $request)
    {
        $profile = $request->user()->courierProfile;
        $min = (float) (PricingService::get('courier')['withdrawalMin'] ?? 500);

        $data = $request->validate([
            'amount' => ['required', 'numeric', 'min:1'],
            'method' => ['required', 'in:bKash,Nagad,Bank'],
        ]);

        if (! $profile->bank_verified) {
            throw ValidationException::withMessages(['method' => 'Bank verification is required before withdrawing.']);
        }
        if ($data['amount'] < $min) {
            throw ValidationException::withMessages(['amount' => "Minimum withdrawal is ৳{$min}."]);
        }

        // Balance check under row lock, accounting for already-pending requests.
        $withdrawal = DB::transaction(function () use ($request, $data, $profile) {
            $locked = $request->user()->courierProfile()->lockForUpdate()->first();
            $pendingRequests = (float) CourierWithdrawal::where('courier_id', $request->user()->id)
                ->where('status', 'pending')->sum('amount');
            if ($data['amount'] > $locked->balance - $pendingRequests) {
                throw ValidationException::withMessages(['amount' => 'Amount exceeds available balance.']);
            }

            return CourierWithdrawal::create([
                'code' => Codes::make('WD'),
                'courier_id' => $request->user()->id,
                'amount' => (float) $data['amount'],
                'method' => $data['method'],
                'bank_last4' => $profile->bank_last4,
                'status' => 'pending',
            ]);
        });

        Notifier::admins('Courier withdrawal request', "{$request->user()->name}: ৳{$withdrawal->amount} via {$withdrawal->method}", 'payout', ['withdrawal_id' => $withdrawal->id]);
        Notifier::user($request->user(), 'Withdrawal requested', "৳{$withdrawal->amount} request submitted.", 'payout');

        return response()->json($withdrawal, 201);
    }

    // —— Incentives ——

    public function incentives(Request $request)
    {
        $district = $request->user()->district?->name;
        $enrolled = IncentiveEnrollment::where('courier_id', $request->user()->id)->pluck('progress', 'incentive_id');

        $rows = Incentive::where('active', true)
            ->where(fn ($q) => $q->whereNull('valid_until')->orWhere('valid_until', '>=', today()))
            ->where(fn ($q) => $q->where('district', '')->orWhere('district', $district ?? ''))
            ->latest()->get()
            ->map(fn ($i) => [
                'id' => $i->id,
                'title' => $i->title,
                'description' => $i->description,
                'multiplier' => (float) $i->multiplier,
                'district' => $i->district,
                'goal_deliveries' => (int) $i->goal_deliveries,
                'bonus_tk' => (float) $i->bonus_tk,
                'valid_until' => $i->valid_until?->toDateString(),
                'is_active' => (bool) $i->active,
                'accepted' => $enrolled->has($i->id),
                'progress' => (int) ($enrolled[$i->id] ?? 0),
            ]);

        return response()->json($rows);
    }

    public function acceptIncentive(Request $request, int $id)
    {
        $district = $request->user()->district?->name;
        $incentive = Incentive::where('active', true)
            ->where(fn ($q) => $q->whereNull('valid_until')->orWhere('valid_until', '>=', today()))
            ->where(fn ($q) => $q->where('district', '')->orWhere('district', $district ?? ''))
            ->findOrFail($id);

        $enrollment = IncentiveEnrollment::firstOrCreate([
            'incentive_id' => $incentive->id,
            'courier_id' => $request->user()->id,
        ]);

        Notifier::user($request->user(), 'Incentive accepted', "{$incentive->title} — deliver {$incentive->goal_deliveries} to earn ৳{$incentive->bonus_tk}.", 'incentive');
        return response()->json(['message' => 'Accepted.', 'enrollment_id' => $enrollment->id], 201);
    }
}

<?php

namespace App\Http\Controllers\Api\Merchant;

use App\Http\Controllers\Controller;
use App\Models\MerchantPayout;
use App\Models\Order;
use App\Models\Review;
use App\Services\Codes;
use App\Services\Notifier;
use App\Services\PricingService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class PayoutController extends Controller
{
    public function revenue(Request $request)
    {
        $store = $this->store($request);
        $delivered = Order::where('store_id', $store->id)->where('status', 'delivered');

        $today = (clone $delivered)->whereDate('delivered_at', today());
        $thisMonth = (float) (clone $delivered)->whereMonth('delivered_at', now()->month)->sum('total');
        $lastMonth = (float) (clone $delivered)->whereMonth('delivered_at', now()->subMonth()->month)
            ->whereYear('delivered_at', now()->subMonth()->year)->sum('total');

        $daily = collect(range(6, 0))->map(fn ($d) => [
            'date' => today()->subDays($d)->toDateString(),
            'total' => (float) (clone $delivered)->whereDate('delivered_at', today()->subDays($d))->sum('total'),
        ]);
        $weekly = collect(range(3, 0))->map(fn ($w) => [
            'week_start' => now()->subWeeks($w)->startOfWeek()->toDateString(),
            'total' => (float) (clone $delivered)->whereBetween('delivered_at', [
                now()->subWeeks($w)->startOfWeek(), now()->subWeeks($w)->endOfWeek(),
            ])->sum('total'),
        ]);
        $monthly = collect(range(5, 0))->map(fn ($m) => [
            'month' => now()->subMonths($m)->format('Y-m'),
            'total' => (float) (clone $delivered)->whereMonth('delivered_at', now()->subMonths($m)->month)
                ->whereYear('delivered_at', now()->subMonths($m)->year)->sum('total'),
        ]);

        $lastPayout = MerchantPayout::where('store_id', $store->id)->where('status', 'completed')->latest()->first();
        $cycle = PricingService::get('merchant')['settlementCycle'] ?? 'weekly';

        return response()->json([
            'total_revenue' => (float) (clone $delivered)->sum('total'),
            'pending_payout' => (float) $store->balance,
            'orders_count' => (clone $delivered)->count(),
            'growth_percent' => $lastMonth > 0 ? round(($thisMonth - $lastMonth) / $lastMonth * 100, 1) : 0,
            'next_payout_date' => $cycle === 'weekly' ? now()->next('friday')->toDateString() : now()->endOfMonth()->toDateString(),
            'total_withdrawn' => (float) MerchantPayout::where('store_id', $store->id)->where('status', 'completed')->sum('amount'),
            'last_payout_date' => $lastPayout?->created_at?->toDateString(),
            'today_sales' => (float) (clone $today)->sum('total'),
            'today_orders' => (clone $today)->count(),
            'rating' => (float) $store->rating,
            'review_count' => Review::where('store_id', $store->id)->count(),
            'trend' => ['daily' => $daily, 'weekly' => $weekly, 'monthly' => $monthly],
        ]);
    }

    public function payouts(Request $request)
    {
        $store = $this->store($request);
        return response()->json(
            MerchantPayout::where('store_id', $store->id)->latest()->paginate(30)
        );
    }

    public function earlyRequest(Request $request)
    {
        $store = $this->store($request);
        $pricing = PricingService::get('merchant');
        $min = (float) ($pricing['minPayoutAmount'] ?? 1000);
        $feePct = (float) ($pricing['earlyPayoutFeePct'] ?? 2);

        $data = $request->validate([
            'amount' => ['required', 'numeric', 'min:1'],
            'method' => ['required', 'in:Bank,bKash,Nagad'],
        ]);

        if ($data['amount'] < $min) {
            throw ValidationException::withMessages(['amount' => "Minimum payout is ৳{$min}."]);
        }

        $fee = round($data['amount'] * $feePct / 100, 2);
        // Balance check under row lock so concurrent requests can't both pass.
        $payout = DB::transaction(function () use ($store, $data, $fee) {
            $locked = \App\Models\Store::whereKey($store->id)->lockForUpdate()->first();
            $pendingRequests = (float) MerchantPayout::where('store_id', $store->id)
                ->whereIn('status', ['pending', 'processing'])->sum('amount');
            if ($data['amount'] > $locked->balance - $pendingRequests) {
                throw ValidationException::withMessages(['amount' => 'Amount exceeds pending balance.']);
            }

            return MerchantPayout::create([
                'code' => Codes::make('PAY'),
                'store_id' => $store->id,
                'amount' => (float) $data['amount'],
                'method' => $data['method'],
                'status' => 'pending',
                'early_request' => true,
                'fee' => $fee,
            ]);
        });

        Notifier::admins('Early payout request', "{$store->name}: ৳{$payout->amount} ({$payout->method}, fee ৳{$fee})", 'payout', ['payout_id' => $payout->id]);
        return response()->json($payout, 201);
    }

    /** Ledger: order credits + payout debits. */
    public function transactions(Request $request)
    {
        $store = $this->store($request);

        $orders = Order::where('store_id', $store->id)->where('status', 'delivered')
            ->latest('delivered_at')->limit(50)->get()
            ->map(fn ($o) => [
                'type' => 'credit', 'title' => "Order {$o->code}", 'amount' => (float) $o->subtotal,
                'at' => $o->delivered_at?->toIso8601String(),
            ]);
        $payouts = MerchantPayout::where('store_id', $store->id)->whereIn('status', ['processing', 'completed'])
            ->latest()->limit(50)->get()
            ->map(fn ($p) => [
                'type' => 'debit', 'title' => "Payout {$p->code}", 'amount' => (float) $p->amount,
                'at' => $p->created_at->toIso8601String(),
            ]);

        return response()->json($orders->concat($payouts)->sortByDesc('at')->values());
    }

    // —— Reviews ——

    public function reviews(Request $request)
    {
        $store = $this->store($request);
        $rows = Review::where('store_id', $store->id)->where('hidden', false)->with('customer')
            ->when($request->query('filter') === 'unreplied', fn ($q) => $q->whereNull('reply'))
            ->when($request->query('filter') === 'positive', fn ($q) => $q->where('rating', '>=', 4))
            ->latest()->paginate(30);

        return response()->json([
            'data' => collect($rows->items())->map(fn ($r) => [
                'id' => $r->id,
                'customer_name' => $r->customer?->name,
                'avatar' => $r->customer?->avatar,
                'rating' => $r->rating,
                'comment' => $r->comment,
                'created_at' => $r->created_at->toIso8601String(),
                'verified' => (bool) $r->verified,
                'reply' => $r->reply,
                'replied_at' => $r->replied_at?->toIso8601String(),
                'images' => $r->images ?? [],
            ]),
            'total' => $rows->total(),
        ]);
    }

    public function reply(Request $request, Review $review)
    {
        abort_unless($review->store_id === $request->user()->store?->id, 403);
        $data = $request->validate(['reply' => ['required', 'string', 'max:1000']]);
        $review->update(['reply' => $data['reply'], 'replied_at' => now()]);
        Notifier::user($review->customer_id, 'Merchant replied to your review', $data['reply'], 'review');
        return response()->json($review->fresh());
    }

    public function settings(Request $request)
    {
        $data = $request->validate([
            'notify_new_orders' => ['sometimes', 'boolean'],
            'notify_payouts' => ['sometimes', 'boolean'],
            'notify_reviews' => ['sometimes', 'boolean'],
            'language' => ['sometimes', 'in:en,bn'],
        ]);

        $user = $request->user();
        if (isset($data['language'])) {
            $user->update(['language' => $data['language']]);
        }
        $user->prefs = array_merge($user->prefs ?? [], collect($data)->except('language')->all());
        $user->save();

        return response()->json(['message' => 'Saved.', 'prefs' => $user->prefs, 'language' => $user->language]);
    }

    private function store(Request $request)
    {
        $store = $request->user()->store;
        abort_unless($store, 404, 'No store yet. Complete onboarding first.');
        return $store;
    }
}

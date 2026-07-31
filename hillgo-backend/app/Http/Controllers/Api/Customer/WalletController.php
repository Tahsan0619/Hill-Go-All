<?php

namespace App\Http\Controllers\Api\Customer;

use App\Http\Controllers\Controller;
use App\Models\LoyaltyRedemption;
use App\Models\LoyaltyReward;
use App\Models\LoyaltyTier;
use App\Models\Promo;
use App\Services\Notifier;
use App\Services\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class WalletController extends Controller
{
    public function summary(Request $request)
    {
        $profile = $request->user()->customerProfile;
        $tiers = LoyaltyTier::orderBy('sort')->get();
        $points = (int) ($profile?->loyalty_points ?? 0);
        $currentTier = $tiers->where('threshold', '<=', $points)->last();
        $nextTier = $tiers->where('threshold', '>', $points)->first();

        return response()->json([
            'balance' => (float) ($profile?->wallet_balance ?? 0),
            'loyalty_points' => $points,
            'tier' => $currentTier?->name ?? 'Bronze',
            'next_tier' => $nextTier?->only(['name', 'threshold']),
            'tiers' => $tiers,
        ]);
    }

    public function transactions(Request $request)
    {
        return response()->json(
            $request->user()->walletTransactions()->latest()->paginate(30)
        );
    }

    /**
     * Top-up request. Without a live payment gateway this records a wallet
     * credit through the ledger only when a gateway reference is supplied by
     * the payment provider callback; direct client credits are not allowed.
     */
    public function topUp(Request $request)
    {
        $data = $request->validate([
            'amount' => ['required', 'numeric', 'min:10', 'max:50000'],
            'method' => ['required', 'in:bkash,nagad,card'],
        ]);

        // Payment gateway integration point: for now create an admin-approval request.
        Notifier::admins('Wallet top-up request', "{$request->user()->name} requested ৳{$data['amount']} via {$data['method']}.", 'wallet_topup', [
            'user_id' => $request->user()->id, 'amount' => $data['amount'], 'method' => $data['method'],
        ]);

        return response()->json([
            'message' => 'Top-up request submitted. Balance updates after payment confirmation.',
            'status' => 'pending',
        ], 202);
    }

    // —— Loyalty ——

    public function rewards()
    {
        return response()->json(LoyaltyReward::where('active', true)->get());
    }

    public function redeem(Request $request, int $rewardId)
    {
        $reward = LoyaltyReward::where('active', true)->findOrFail($rewardId);

        $redemption = DB::transaction(function () use ($request, $reward) {
            $profile = $request->user()->customerProfile()->lockForUpdate()->first();
            if (! $profile || $profile->loyalty_points < $reward->points) {
                throw ValidationException::withMessages(['points' => 'Not enough loyalty points.']);
            }
            $profile->decrement('loyalty_points', $reward->points);
            return LoyaltyRedemption::create([
                'user_id' => $request->user()->id,
                'reward_id' => $reward->id,
                'points' => $reward->points,
            ]);
        });

        Notifier::user($request->user(), 'Reward redeemed', "{$reward->title} — {$reward->points} points used.", 'loyalty');
        return response()->json(['message' => 'Redeemed.', 'redemption' => $redemption], 201);
    }

    // —— Promos ——

    public function promos(Request $request)
    {
        return response()->json(
            Promo::where('active', true)
                ->where(fn ($q) => $q->whereNull('expires_at')->orWhere('expires_at', '>=', today()))
                ->where(fn ($q) => $q->whereNull('usage_limit')->orWhereColumn('used_count', '<', 'usage_limit'))
                ->latest()->get()
                ->map(fn ($p) => $p->only(['id', 'title', 'description', 'code', 'type', 'value', 'min_order_tk', 'expires_at']))
        );
    }
}

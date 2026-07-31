<?php

namespace App\Services;

use App\Models\CourierProfile;
use App\Models\CustomerProfile;
use App\Models\RiderProfile;
use App\Models\Store;
use App\Models\User;
use App\Models\WalletTransaction;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

/**
 * Single authoritative money-mutation path. Every balance change — customer
 * wallet, rider balance, courier balance, store balance — goes through here:
 * row lock + balance update + wallet_transactions ledger row + audit log.
 * Cached profile balances must never be written anywhere else.
 */
class Wallet
{
    /**
     * Atomically credit/debit a customer wallet and write the ledger row.
     * All money math is server-side; negative balance is rejected.
     */
    public static function adjust(User $user, float $delta, string $title, string $refType = 'admin_adjust', ?int $refId = null, string $note = ''): WalletTransaction
    {
        return DB::transaction(function () use ($user, $delta, $title, $refType, $refId, $note) {
            $profile = CustomerProfile::where('user_id', $user->id)->lockForUpdate()->first();
            if (! $profile) {
                throw ValidationException::withMessages(['wallet' => 'No wallet for this user.']);
            }
            $before = (float) $profile->wallet_balance;
            $newBalance = round($before + $delta, 2);
            if ($newBalance < 0) {
                throw ValidationException::withMessages(['wallet' => 'Insufficient wallet balance.']);
            }
            // balance is intentionally not mass-assignable
            $profile->wallet_balance = $newBalance;
            $profile->save();

            $tx = self::ledger($user->id, $delta, $newBalance, $title, $refType, $refId, $note);
            self::audit('customer', $user->id, $delta, $before, $newBalance, $title, $refType, $refId);

            return $tx;
        });
    }

    /** Atomically credit/debit a rider's earnings balance (with ledger row). */
    public static function adjustRider(int $riderUserId, float $delta, string $title, string $refType, ?int $refId = null, string $note = ''): WalletTransaction
    {
        return DB::transaction(function () use ($riderUserId, $delta, $title, $refType, $refId, $note) {
            $profile = RiderProfile::where('user_id', $riderUserId)->lockForUpdate()->first();
            if (! $profile) {
                throw ValidationException::withMessages(['balance' => 'No rider profile for this user.']);
            }
            $before = (float) $profile->balance;
            $newBalance = round($before + $delta, 2);
            if ($newBalance < 0) {
                throw ValidationException::withMessages(['balance' => 'Rider balance is below the requested amount.']);
            }
            $profile->balance = $newBalance;
            $profile->save();

            $tx = self::ledger($riderUserId, $delta, $newBalance, $title, $refType, $refId, $note);
            self::audit('rider', $riderUserId, $delta, $before, $newBalance, $title, $refType, $refId);

            return $tx;
        });
    }

    /** Atomically credit/debit a courier agent's balance (with ledger row). */
    public static function adjustCourier(int $courierUserId, float $delta, string $title, string $refType, ?int $refId = null, string $note = ''): WalletTransaction
    {
        return DB::transaction(function () use ($courierUserId, $delta, $title, $refType, $refId, $note) {
            $profile = CourierProfile::where('user_id', $courierUserId)->lockForUpdate()->first();
            if (! $profile) {
                throw ValidationException::withMessages(['balance' => 'No courier profile for this user.']);
            }
            $before = (float) $profile->balance;
            $newBalance = round($before + $delta, 2);
            if ($newBalance < 0) {
                throw ValidationException::withMessages(['balance' => 'Agent balance is below the requested amount.']);
            }
            $profile->balance = $newBalance;
            $profile->save();

            $tx = self::ledger($courierUserId, $delta, $newBalance, $title, $refType, $refId, $note);
            self::audit('courier', $courierUserId, $delta, $before, $newBalance, $title, $refType, $refId);

            return $tx;
        });
    }

    /** Atomically credit/debit a store balance (ledger row on the owner user). */
    public static function adjustStore(int $storeId, float $delta, string $title, string $refType, ?int $refId = null, string $note = ''): ?WalletTransaction
    {
        return DB::transaction(function () use ($storeId, $delta, $title, $refType, $refId, $note) {
            $store = Store::whereKey($storeId)->lockForUpdate()->first();
            if (! $store) {
                throw ValidationException::withMessages(['balance' => 'Store not found.']);
            }
            $before = (float) $store->balance;
            $newBalance = round($before + $delta, 2);
            if ($newBalance < 0) {
                throw ValidationException::withMessages(['balance' => 'Store balance is below the requested amount.']);
            }
            $store->balance = $newBalance;
            $store->save();

            self::audit('store', $store->user_id ?? $storeId, $delta, $before, $newBalance, $title, $refType, $refId);

            return $store->user_id
                ? self::ledger($store->user_id, $delta, $newBalance, $title, $refType, $refId, $note)
                : null;
        });
    }

    private static function ledger(int $userId, float $delta, float $balanceAfter, string $title, string $refType, ?int $refId, string $note): WalletTransaction
    {
        return WalletTransaction::create([
            'user_id' => $userId,
            'title' => $title,
            'amount' => abs($delta),
            'direction' => $delta >= 0 ? 'credit' : 'debit',
            'ref_type' => $refType,
            'ref_id' => $refId,
            'note' => $note,
            'balance_after' => $balanceAfter,
        ]);
    }

    private static function audit(string $subject, int $subjectId, float $delta, float $before, float $after, string $title, string $refType, ?int $refId): void
    {
        $sign = $delta >= 0 ? '+' : '−';
        Audit::log(
            sprintf('%s#%d %s৳%.2f (%s→%s) %s [%s%s]',
                $subject, $subjectId, $sign, abs($delta),
                number_format($before, 2), number_format($after, 2),
                $title, $refType, $refId !== null ? ":$refId" : ''
            ),
            null,
            'wallet'
        );
    }
}

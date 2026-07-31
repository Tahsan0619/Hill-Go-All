<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Security & compliance fixes:
 *  1. Soft deletes on identity, commercial and financial-history entities.
 *  2. Financial / order-history FKs changed from CASCADE to RESTRICT so a user
 *     or store row can never take its money trail down with it.
 *  3. NID columns widened to text and existing plaintext values encrypted
 *     (models use the `encrypted` cast from now on).
 *  4. Audit attribution: real user-id FKs next to the free-text `by` columns.
 *  5. otp_codes.expires_at index for cheap cleanup of expired codes.
 */
return new class extends Migration
{
    private const SOFT_DELETE_TABLES = [
        'users', 'stores', 'rides', 'orders', 'parcels', 'trips', 'products',
        'hotels', 'rental_vehicles', 'loyalty_rewards',
    ];

    /** table => [column => referenced table] for cascade -> restrict swaps. */
    private const RESTRICT_FKS = [
        'wallet_transactions' => ['user_id' => 'users'],
        'rider_payouts' => ['rider_id' => 'users'],
        'courier_withdrawals' => ['courier_id' => 'users'],
        'merchant_payouts' => ['store_id' => 'stores'],
        'orders' => ['customer_id' => 'users', 'store_id' => 'stores'],
        'rides' => ['customer_id' => 'users'],
        'hotel_bookings' => ['hotel_id' => 'hotels', 'customer_id' => 'users'],
        'rental_bookings' => ['vehicle_id' => 'rental_vehicles', 'customer_id' => 'users'],
        'loyalty_redemptions' => ['user_id' => 'users', 'reward_id' => 'loyalty_rewards'],
    ];

    public function up(): void
    {
        foreach (self::SOFT_DELETE_TABLES as $tableName) {
            Schema::table($tableName, function (Blueprint $table) {
                $table->softDeletes();
            });
        }

        foreach (self::RESTRICT_FKS as $tableName => $columns) {
            Schema::table($tableName, function (Blueprint $table) use ($columns) {
                foreach ($columns as $column => $references) {
                    $table->dropForeign([$column]);
                    $table->foreign($column)->references('id')->on($references)->restrictOnDelete();
                }
            });
        }

        // —— NID: widen to text, then encrypt existing plaintext values ——
        Schema::table('rider_profiles', fn (Blueprint $table) => $table->text('nid')->nullable()->change());
        Schema::table('courier_profiles', fn (Blueprint $table) => $table->text('nid')->nullable()->change());

        foreach (['rider_profiles', 'courier_profiles'] as $tableName) {
            foreach (DB::table($tableName)->whereNotNull('nid')->get(['id', 'nid']) as $row) {
                if ($row->nid === '' || str_starts_with($row->nid, 'eyJ')) {
                    continue; // empty or already-encrypted payload
                }
                DB::table($tableName)->where('id', $row->id)
                    ->update(['nid' => Crypt::encryptString($row->nid)]);
            }
        }

        // —— Audit attribution FKs (text columns kept for display) ——
        Schema::table('activity_logs', function (Blueprint $table) {
            $table->foreignId('by_user_id')->nullable()->after('by')->constrained('users')->nullOnDelete();
        });
        Schema::table('pricing_audits', function (Blueprint $table) {
            $table->foreignId('by_user_id')->nullable()->after('by')->constrained('users')->nullOnDelete();
        });
        Schema::table('sos_alerts', function (Blueprint $table) {
            $table->foreignId('resolved_by_user_id')->nullable()->after('resolved_by')->constrained('users')->nullOnDelete();
        });
        Schema::table('districts', function (Blueprint $table) {
            $table->foreignId('updated_by_user_id')->nullable()->after('updated_by')->constrained('users')->nullOnDelete();
        });

        // Best-effort backfill: map historical admin display names to user ids.
        $admins = DB::table('users')->whereIn('role', ['super_admin', 'admin'])->pluck('id', 'name');
        foreach ($admins as $name => $id) {
            DB::table('activity_logs')->where('by', $name)->whereNull('by_user_id')->update(['by_user_id' => $id]);
            DB::table('pricing_audits')->where('by', $name)->whereNull('by_user_id')->update(['by_user_id' => $id]);
            DB::table('sos_alerts')->where('resolved_by', $name)->whereNull('resolved_by_user_id')->update(['resolved_by_user_id' => $id]);
            DB::table('districts')->where('updated_by', $name)->whereNull('updated_by_user_id')->update(['updated_by_user_id' => $id]);
        }

        Schema::table('otp_codes', function (Blueprint $table) {
            $table->index('expires_at');
        });
    }

    public function down(): void
    {
        Schema::table('otp_codes', fn (Blueprint $table) => $table->dropIndex(['expires_at']));

        Schema::table('districts', function (Blueprint $table) {
            $table->dropForeign(['updated_by_user_id']);
            $table->dropColumn('updated_by_user_id');
        });
        Schema::table('sos_alerts', function (Blueprint $table) {
            $table->dropForeign(['resolved_by_user_id']);
            $table->dropColumn('resolved_by_user_id');
        });
        Schema::table('pricing_audits', function (Blueprint $table) {
            $table->dropForeign(['by_user_id']);
            $table->dropColumn('by_user_id');
        });
        Schema::table('activity_logs', function (Blueprint $table) {
            $table->dropForeign(['by_user_id']);
            $table->dropColumn('by_user_id');
        });

        foreach (['rider_profiles', 'courier_profiles'] as $tableName) {
            foreach (DB::table($tableName)->whereNotNull('nid')->get(['id', 'nid']) as $row) {
                if (str_starts_with($row->nid, 'eyJ')) {
                    try {
                        DB::table($tableName)->where('id', $row->id)
                            ->update(['nid' => Crypt::decryptString($row->nid)]);
                    } catch (\Throwable) {
                        // leave undecryptable values as-is
                    }
                }
            }
        }
        Schema::table('rider_profiles', fn (Blueprint $table) => $table->string('nid')->nullable()->change());
        Schema::table('courier_profiles', fn (Blueprint $table) => $table->string('nid')->nullable()->change());

        foreach (self::RESTRICT_FKS as $tableName => $columns) {
            Schema::table($tableName, function (Blueprint $table) use ($columns) {
                foreach ($columns as $column => $references) {
                    $table->dropForeign([$column]);
                    $table->foreign($column)->references('id')->on($references)->cascadeOnDelete();
                }
            });
        }

        foreach (self::SOFT_DELETE_TABLES as $tableName) {
            Schema::table($tableName, fn (Blueprint $table) => $table->dropSoftDeletes());
        }
    }
};

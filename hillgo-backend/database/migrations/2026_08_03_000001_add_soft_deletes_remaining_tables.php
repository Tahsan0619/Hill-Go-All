<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Remediation 7.1.1 follow-up: the 2026_08_01_000001 pass covered
 * users/stores/rides/orders/parcels/trips/products/hotels/rental_vehicles/
 * loyalty_rewards, but left these hard-delete-only:
 *  - hotel_bookings, rental_bookings (named explicitly in the checklist)
 *  - loyalty_tiers, loyalty_redemptions (covered by the "loyalty_*" wildcard
 *    in the same checklist item; loyalty_rewards already had it)
 */
return new class extends Migration
{
    private const TABLES = ['hotel_bookings', 'rental_bookings', 'loyalty_tiers', 'loyalty_redemptions'];

    public function up(): void
    {
        foreach (self::TABLES as $table) {
            Schema::table($table, fn (Blueprint $t) => $t->softDeletes());
        }
    }

    public function down(): void
    {
        foreach (self::TABLES as $table) {
            Schema::table($table, fn (Blueprint $t) => $t->dropSoftDeletes());
        }
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/** Hot-path indexes for dispatch, KYC queues, dashboards, and payouts. */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('courier_profiles', function (Blueprint $table) {
            $table->index(['online', 'verified'], 'courier_profiles_online_verified_index');
            $table->index('kyc_status');
        });

        Schema::table('rider_profiles', function (Blueprint $table) {
            $table->index(['kyc_status', 'kyc_submitted_at'], 'rider_profiles_kyc_queue_index');
        });

        Schema::table('trips', function (Blueprint $table) {
            $table->index(['rider_id', 'status', 'completed_at'], 'trips_rider_status_completed_index');
            $table->index(['status', 'completed_at'], 'trips_status_completed_index');
        });

        Schema::table('orders', function (Blueprint $table) {
            $table->index(['channel', 'created_at'], 'orders_channel_created_index');
            $table->index(['status', 'created_at'], 'orders_status_created_index');
        });

        Schema::table('rider_payouts', function (Blueprint $table) {
            $table->index(['rider_id', 'status'], 'rider_payouts_rider_status_index');
            $table->index('status');
        });

        Schema::table('merchant_payouts', function (Blueprint $table) {
            $table->index(['store_id', 'status'], 'merchant_payouts_store_status_index');
            $table->index('status');
        });

        Schema::table('courier_withdrawals', function (Blueprint $table) {
            $table->index(['courier_id', 'status'], 'courier_withdrawals_courier_status_index');
            $table->index('status');
        });

        Schema::table('rides', function (Blueprint $table) {
            $table->index(['customer_id', 'status'], 'rides_customer_status_index');
        });

        Schema::table('wallet_transactions', function (Blueprint $table) {
            $table->index(['ref_type', 'ref_id'], 'wallet_transactions_ref_index');
        });
    }

    public function down(): void
    {
        Schema::table('wallet_transactions', fn (Blueprint $t) => $t->dropIndex('wallet_transactions_ref_index'));
        Schema::table('rides', fn (Blueprint $t) => $t->dropIndex('rides_customer_status_index'));
        Schema::table('courier_withdrawals', function (Blueprint $t) {
            $t->dropIndex('courier_withdrawals_courier_status_index');
            $t->dropIndex(['status']);
        });
        Schema::table('merchant_payouts', function (Blueprint $t) {
            $t->dropIndex('merchant_payouts_store_status_index');
            $t->dropIndex(['status']);
        });
        Schema::table('rider_payouts', function (Blueprint $t) {
            $t->dropIndex('rider_payouts_rider_status_index');
            $t->dropIndex(['status']);
        });
        Schema::table('orders', function (Blueprint $t) {
            $t->dropIndex('orders_channel_created_index');
            $t->dropIndex('orders_status_created_index');
        });
        Schema::table('trips', function (Blueprint $t) {
            $t->dropIndex('trips_rider_status_completed_index');
            $t->dropIndex('trips_status_completed_index');
        });
        Schema::table('rider_profiles', fn (Blueprint $t) => $t->dropIndex('rider_profiles_kyc_queue_index'));
        Schema::table('courier_profiles', function (Blueprint $t) {
            $t->dropIndex('courier_profiles_online_verified_index');
            $t->dropIndex(['kyc_status']);
        });
    }
};

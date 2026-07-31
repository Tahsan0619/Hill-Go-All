<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('customer_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->string('code')->unique(); // HG-#####
            $table->string('tier')->default('Bronze');
            $table->decimal('wallet_balance', 12, 2)->default(0);
            $table->unsignedInteger('loyalty_points')->default(0);
            $table->unsignedInteger('orders_count')->default(0);
            $table->decimal('rating', 3, 2)->default(0);
            $table->timestamps();
        });

        Schema::create('addresses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('label');
            $table->string('address');
            $table->decimal('lat', 10, 7)->nullable();
            $table->decimal('lng', 10, 7)->nullable();
            $table->boolean('is_default')->default(false);
            $table->timestamps();
        });

        Schema::create('payment_methods', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('type'); // wallet|card|bkash|nagad
            $table->string('label');
            $table->json('details')->nullable(); // masked info only
            $table->boolean('is_default')->default(false);
            $table->timestamps();
        });

        Schema::create('wallet_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->decimal('amount', 12, 2);
            $table->enum('direction', ['credit', 'debit']);
            $table->string('ref_type')->nullable(); // ride|food|parcel|topup|admin_adjust|payout|order
            $table->unsignedBigInteger('ref_id')->nullable();
            $table->string('note')->default('');
            $table->decimal('balance_after', 12, 2)->nullable();
            $table->timestamps();
            $table->index(['user_id', 'created_at']);
        });

        Schema::create('loyalty_tiers', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();
            $table->unsignedInteger('threshold');
            $table->unsignedSmallInteger('sort')->default(0);
            $table->timestamps();
        });

        Schema::create('loyalty_rewards', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('description')->default('');
            $table->unsignedInteger('points');
            $table->string('type')->default('voucher');
            $table->boolean('active')->default(true);
            $table->timestamps();
        });

        Schema::create('loyalty_redemptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('reward_id')->constrained('loyalty_rewards')->cascadeOnDelete();
            $table->unsignedInteger('points');
            $table->timestamps();
        });

        Schema::create('promos', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('description')->default('');
            $table->string('code')->unique();
            $table->string('type'); // ride_percent|free_delivery|wallet_cashback|amount_off
            $table->decimal('value', 10, 2)->default(0); // pct or tk depending on type
            $table->decimal('min_order_tk', 10, 2)->default(0);
            $table->date('expires_at')->nullable();
            $table->boolean('active')->default(true);
            $table->unsignedInteger('usage_limit')->nullable();
            $table->unsignedInteger('used_count')->default(0);
            $table->timestamps();
        });

        Schema::create('sos_contacts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('name');
            $table->string('phone');
            $table->string('relation')->default('');
            $table->timestamps();
        });

        Schema::create('sos_alerts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('type'); // sos|police|ambulance|location_share|ride_sos
            $table->string('location_label')->default('');
            $table->decimal('lat', 10, 7)->nullable();
            $table->decimal('lng', 10, 7)->nullable();
            $table->enum('status', ['active', 'resolved'])->default('active');
            $table->timestamp('resolved_at')->nullable();
            $table->string('resolved_by')->nullable();
            $table->timestamps();
            $table->index(['status', 'created_at']);
        });

        Schema::create('support_tickets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('role', 32)->default('customer');
            $table->string('subject');
            $table->text('message');
            $table->enum('status', ['open', 'answered', 'closed'])->default('open');
            $table->text('reply')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        foreach (['support_tickets', 'sos_alerts', 'sos_contacts', 'promos', 'loyalty_redemptions',
            'loyalty_rewards', 'loyalty_tiers', 'wallet_transactions', 'payment_methods',
            'addresses', 'customer_profiles'] as $t) {
            Schema::dropIfExists($t);
        }
    }
};

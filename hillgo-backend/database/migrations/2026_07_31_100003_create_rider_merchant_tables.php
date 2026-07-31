<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rider_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->string('code')->unique(); // HG-RD-####
            $table->enum('vehicle_type', ['bike', 'car', 'xl'])->nullable();
            $table->string('vehicle_make')->nullable();
            $table->string('vehicle_model')->nullable();
            $table->string('vehicle_year', 8)->nullable();
            $table->string('plate')->nullable();
            $table->string('vehicle_photo')->nullable();
            $table->decimal('rating', 3, 2)->default(0);
            $table->unsignedInteger('rating_count')->default(0);
            $table->boolean('online')->default(false);
            $table->decimal('lat', 10, 7)->nullable();
            $table->decimal('lng', 10, 7)->nullable();
            $table->timestamp('last_location_at')->nullable();
            $table->timestamp('online_since')->nullable();
            $table->unsignedInteger('online_seconds_today')->default(0);
            $table->decimal('balance', 12, 2)->default(0);
            $table->string('payout_method')->default('bKash'); // bKash|Nagad|Bank
            $table->enum('kyc_status', ['pending', 'action_required', 'uploaded', 'verified', 'rejected'])->default('pending');
            $table->boolean('kyc_priority')->default(false);
            $table->boolean('kyc_flagged')->default(false);
            $table->timestamp('kyc_submitted_at')->nullable();
            $table->string('legal_name')->nullable();
            $table->string('home_address')->nullable();
            $table->date('dob')->nullable();
            $table->string('nid')->nullable();
            $table->timestamps();
            $table->index(['online', 'vehicle_type']);
        });

        Schema::create('rider_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('rider_profile_id')->constrained('rider_profiles')->cascadeOnDelete();
            $table->string('doc_key'); // id_proof|nid|registration|photo
            $table->string('title');
            $table->enum('status', ['pending', 'action_required', 'uploaded', 'verified'])->default('pending');
            $table->string('file_path')->nullable(); // private disk
            $table->string('token_number')->nullable(); // license token alternative
            $table->string('note')->default('');
            $table->timestamps();
            $table->unique(['rider_profile_id', 'doc_key']);
        });

        // Merchant stores
        Schema::create('stores', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique(); // HG-MRT-#####
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete(); // owner account
            $table->string('name');
            $table->string('owner_name')->nullable();
            $table->string('category')->nullable();
            $table->json('subcategories')->nullable();
            $table->text('description')->nullable();
            $table->string('specialties')->nullable();
            $table->text('bio')->nullable();
            $table->string('address')->nullable();
            $table->string('city')->nullable();
            $table->string('district_id')->nullable();
            $table->foreign('district_id')->references('id')->on('districts')->nullOnDelete();
            $table->string('zip', 16)->nullable();
            $table->decimal('lat', 10, 7)->nullable();
            $table->decimal('lng', 10, 7)->nullable();
            $table->boolean('is_open')->default(false);
            $table->boolean('accepting_orders')->default(false);
            $table->enum('status', ['active', 'pending', 'onboarding', 'suspended'])->default('onboarding');
            $table->decimal('rating', 3, 2)->default(0);
            $table->unsignedInteger('rating_count')->default(0);
            $table->json('hours')->nullable();
            $table->string('banner')->nullable();
            $table->string('logo')->nullable();
            $table->unsignedTinyInteger('profile_strength')->default(0);
            $table->decimal('balance', 12, 2)->default(0);
            $table->boolean('free_delivery')->default(false);
            $table->string('eta_label')->nullable(); // e.g. 30-40 min
            $table->timestamps();
            $table->index(['status', 'category']);
        });

        Schema::create('merchant_onboardings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('store_id')->nullable()->constrained('stores')->nullOnDelete();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('business_name');
            $table->text('description')->nullable();
            $table->string('owner');
            $table->string('category');
            $table->json('subcategories')->nullable();
            $table->string('phone');
            $table->string('email');
            $table->string('address');
            $table->string('city');
            $table->string('district_id')->nullable();
            $table->foreign('district_id')->references('id')->on('districts')->nullOnDelete();
            $table->string('zip', 16)->nullable();
            $table->json('docs')->nullable(); // [{name, path}]
            $table->string('logo_path')->nullable();
            $table->string('storefront_path')->nullable();
            $table->enum('status', ['pending', 'changes_requested', 'approved', 'rejected'])->default('pending');
            $table->timestamps();
        });

        Schema::create('product_categories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('store_id')->constrained('stores')->cascadeOnDelete();
            $table->string('name');
            $table->string('icon')->nullable();
            $table->string('color', 16)->nullable();
            $table->boolean('is_visible')->default(true);
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('store_id')->constrained('stores')->cascadeOnDelete();
            $table->foreignId('category_id')->nullable()->constrained('product_categories')->nullOnDelete();
            $table->string('name');
            $table->text('description')->nullable();
            $table->decimal('price', 12, 2);
            $table->string('sku')->nullable();
            $table->integer('stock')->default(0);
            $table->integer('low_stock_alert')->default(5);
            $table->boolean('track_stock')->default(false);
            $table->json('images')->nullable();
            $table->enum('status', ['active', 'hidden'])->default('active');
            $table->string('marketplace_category')->nullable(); // Electronics|Fashion|Home|Beauty|Groceries|Sports
            $table->decimal('rating', 3, 2)->default(0);
            $table->timestamps();
            $table->index(['store_id', 'status']);
            $table->index('marketplace_category');
        });

        // Unified orders (food kitchen + marketplace) — merchant status machine
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique(); // ORD-#### / HG-#####
            $table->foreignId('store_id')->constrained('stores')->cascadeOnDelete();
            $table->foreignId('customer_id')->constrained('users')->cascadeOnDelete();
            $table->enum('channel', ['food', 'marketplace'])->default('food');
            $table->enum('priority', ['standard', 'express', 'priority', 'scheduled'])->default('standard');
            $table->timestamp('scheduled_for')->nullable();
            $table->enum('status', ['new_order', 'preparing', 'ready', 'on_the_way', 'delivered', 'rejected', 'cancelled'])->default('new_order');
            $table->decimal('subtotal', 12, 2)->default(0);
            $table->decimal('service_fee', 12, 2)->default(0);
            $table->decimal('tax', 12, 2)->default(0);
            $table->decimal('delivery_fee', 12, 2)->default(0);
            $table->decimal('discount', 12, 2)->default(0);
            $table->decimal('total', 12, 2)->default(0);
            $table->string('payment_method')->default('cash'); // cash|wallet|card|bkash|nagad
            $table->string('delivery_address')->nullable();
            $table->string('customer_note')->nullable();
            $table->string('promo_code')->nullable();
            $table->timestamp('delivered_at')->nullable();
            $table->unsignedTinyInteger('rating')->nullable();
            $table->string('district_id')->nullable();
            $table->foreign('district_id')->references('id')->on('districts')->nullOnDelete();
            $table->timestamps();
            $table->index(['store_id', 'status']);
            $table->index(['customer_id', 'channel']);
        });

        Schema::create('order_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->foreignId('product_id')->nullable()->constrained('products')->nullOnDelete();
            $table->string('name');
            $table->unsignedInteger('qty');
            $table->decimal('price', 12, 2);
            $table->string('notes')->nullable();
            $table->timestamps();
        });

        Schema::create('merchant_payouts', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique(); // PAY-#####-BD
            $table->foreignId('store_id')->constrained('stores')->cascadeOnDelete();
            $table->decimal('amount', 12, 2);
            $table->string('method')->default('Bank');
            $table->enum('status', ['pending', 'processing', 'completed', 'rejected'])->default('pending');
            $table->boolean('early_request')->default(false);
            $table->decimal('fee', 12, 2)->default(0);
            $table->timestamps();
        });

        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('store_id')->constrained('stores')->cascadeOnDelete();
            $table->foreignId('customer_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('order_id')->nullable()->constrained('orders')->nullOnDelete();
            $table->unsignedTinyInteger('rating');
            $table->text('comment')->nullable();
            $table->boolean('verified')->default(true);
            $table->text('reply')->nullable();
            $table->timestamp('replied_at')->nullable();
            $table->json('images')->nullable();
            $table->boolean('hidden')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        foreach (['reviews', 'merchant_payouts', 'order_items', 'orders', 'products',
            'product_categories', 'merchant_onboardings', 'stores', 'rider_documents', 'rider_profiles'] as $t) {
            Schema::dropIfExists($t);
        }
    }
};

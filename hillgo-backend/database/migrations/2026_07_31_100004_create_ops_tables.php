<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rides', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique(); // RID-####
            $table->foreignId('customer_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('rider_id')->nullable()->constrained('users')->nullOnDelete();
            $table->enum('vehicle_type', ['bike', 'car', 'xl'])->default('bike');
            $table->string('pickup');
            $table->string('drop');
            $table->decimal('pickup_lat', 10, 7)->nullable();
            $table->decimal('pickup_lng', 10, 7)->nullable();
            $table->decimal('drop_lat', 10, 7)->nullable();
            $table->decimal('drop_lng', 10, 7)->nullable();
            $table->decimal('distance_km', 8, 2)->default(0);
            $table->unsignedInteger('duration_min')->default(0);
            $table->decimal('fare', 12, 2)->default(0);
            $table->decimal('surge', 4, 2)->default(1);
            $table->enum('status', ['searching', 'assigned', 'in_progress', 'completed', 'cancelled'])->default('searching');
            $table->string('payment_method')->default('cash');
            $table->unsignedTinyInteger('rating')->nullable();
            $table->string('rating_comment')->nullable();
            $table->string('cancel_reason')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->string('district_id')->nullable();
            $table->foreign('district_id')->references('id')->on('districts')->nullOnDelete();
            $table->timestamps();
            $table->index(['status', 'created_at']);
            $table->index('customer_id');
        });

        // Unified parcels: customer-booked, fulfilled by courier agent or rider
        Schema::create('parcels', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique(); // HG-##### tracking code (public track)
            $table->foreignId('customer_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('type')->default('Box'); // Document|Box|Fragile|...
            $table->enum('priority', ['standard', 'express', 'priority'])->default('standard');
            $table->enum('fulfillment_channel', ['courier', 'rider'])->default('courier');
            $table->foreignId('courier_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('rider_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('sender_name')->nullable();
            $table->string('sender_phone')->nullable();
            $table->string('pickup_address');
            $table->decimal('pickup_lat', 10, 7)->nullable();
            $table->decimal('pickup_lng', 10, 7)->nullable();
            $table->string('receiver_name')->nullable();
            $table->string('receiver_phone')->nullable();
            $table->string('drop_address');
            $table->decimal('drop_lat', 10, 7)->nullable();
            $table->decimal('drop_lng', 10, 7)->nullable();
            $table->decimal('weight_kg', 8, 2)->default(0.5);
            $table->decimal('distance_km', 8, 2)->default(0);
            $table->decimal('fare', 12, 2)->default(0); // customer pays
            $table->decimal('earnings', 12, 2)->default(0); // agent/rider earns
            $table->decimal('surge_bonus', 12, 2)->default(0);
            $table->enum('status', ['booked', 'assigned', 'picked_up', 'in_transit', 'delivered', 'failed', 'cancelled'])->default('booked');
            $table->string('pickup_otp_hash')->nullable();
            $table->string('delivery_otp_hash')->nullable();
            $table->string('fail_reason')->nullable();
            $table->boolean('fragile')->default(false);
            $table->string('notes')->nullable();
            $table->string('payment_method')->default('cash');
            $table->timestamp('picked_up_at')->nullable();
            $table->timestamp('delivered_at')->nullable();
            $table->string('district_id')->nullable();
            $table->foreign('district_id')->references('id')->on('districts')->nullOnDelete();
            $table->timestamps();
            $table->index(['status', 'created_at']);
            $table->index('courier_id');
        });

        Schema::create('parcel_otp_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parcel_id')->constrained('parcels')->cascadeOnDelete();
            $table->enum('stage', ['pickup', 'delivery']);
            $table->boolean('success');
            $table->foreignId('by_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
        });

        Schema::create('parcel_proofs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parcel_id')->constrained('parcels')->cascadeOnDelete();
            $table->enum('type', ['photo', 'signature']);
            $table->string('file_path');
            $table->timestamps();
        });

        // Rider dispatch jobs (offers + trips)
        Schema::create('trips', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique(); // HG-#####
            $table->enum('type', ['ride', 'food', 'parcel']);
            $table->foreignId('rider_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('customer_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('ref_type')->nullable(); // rides|orders|parcels
            $table->unsignedBigInteger('ref_id')->nullable();
            $table->string('pickup_name')->nullable();
            $table->string('pickup_address')->nullable();
            $table->decimal('pickup_lat', 10, 7)->nullable();
            $table->decimal('pickup_lng', 10, 7)->nullable();
            $table->string('drop_name')->nullable();
            $table->string('drop_address')->nullable();
            $table->decimal('drop_lat', 10, 7)->nullable();
            $table->decimal('drop_lng', 10, 7)->nullable();
            $table->decimal('distance_km', 8, 2)->default(0);
            $table->unsignedInteger('duration_min')->default(0);
            $table->decimal('earning', 12, 2)->default(0);
            $table->decimal('tip', 12, 2)->default(0);
            $table->enum('payment_method', ['cash', 'digital'])->default('digital');
            $table->decimal('cod_amount', 12, 2)->default(0);
            $table->decimal('surge', 4, 2)->default(1);
            $table->enum('vehicle_required', ['bike', 'car', 'xl'])->nullable();
            $table->decimal('weight_kg', 8, 2)->nullable();
            $table->string('package_label')->nullable();
            $table->enum('status', [
                'requested', 'accepted', 'arriving', 'arrived', 'in_progress',
                'picked_up', 'in_transit', 'completed', 'cancelled', 'expired', 'declined',
            ])->default('requested');
            $table->timestamp('offered_at')->nullable();
            $table->timestamp('offer_expires_at')->nullable();
            $table->json('declined_rider_ids')->nullable();
            $table->timestamp('accepted_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
            $table->index(['rider_id', 'status']);
            $table->index(['status', 'offer_expires_at']);
        });

        Schema::create('rider_payouts', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique(); // HG-PY-####
            $table->foreignId('rider_id')->constrained('users')->cascadeOnDelete();
            $table->decimal('amount', 12, 2);
            $table->string('method')->default('bKash');
            $table->date('period_from')->nullable();
            $table->date('period_to')->nullable();
            $table->string('ref')->default('');
            $table->decimal('tips', 12, 2)->default(0);
            $table->decimal('surge', 12, 2)->default(0);
            $table->decimal('deductions', 12, 2)->default(0);
            $table->string('note')->default('');
            $table->enum('status', ['pending', 'processing', 'paid', 'rejected'])->default('pending');
            $table->enum('source', ['admin_salary', 'cash_out'])->default('admin_salary');
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();
        });

        // Courier
        Schema::create('courier_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->string('code')->unique(); // CG-#####
            $table->string('vehicle_type')->default('Motorbike'); // Motorbike|Bicycle|Van
            $table->string('vehicle_name')->nullable();
            $table->string('plate')->nullable();
            $table->decimal('rating', 3, 2)->default(0);
            $table->unsignedInteger('deliveries_count')->default(0);
            $table->boolean('verified')->default(false);
            $table->boolean('bank_verified')->default(false);
            $table->string('bank_last4', 8)->nullable();
            $table->boolean('online')->default(false);
            $table->decimal('lat', 10, 7)->nullable();
            $table->decimal('lng', 10, 7)->nullable();
            $table->timestamp('last_location_at')->nullable();
            $table->decimal('balance', 12, 2)->default(0);
            $table->string('nid')->nullable();
            $table->enum('kyc_status', ['pending', 'action_required', 'uploaded', 'verified', 'rejected'])->default('pending');
            $table->timestamp('kyc_submitted_at')->nullable();
            $table->timestamps();
        });

        Schema::create('courier_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('courier_profile_id')->constrained('courier_profiles')->cascadeOnDelete();
            $table->string('doc_key'); // license|nid|registration
            $table->string('title');
            $table->enum('status', ['pending', 'action_required', 'uploaded', 'verified'])->default('pending');
            $table->string('file_path')->nullable();
            $table->date('expires_at')->nullable();
            $table->timestamps();
            $table->unique(['courier_profile_id', 'doc_key']);
        });

        Schema::create('courier_withdrawals', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique(); // WD-####
            $table->foreignId('courier_id')->constrained('users')->cascadeOnDelete();
            $table->decimal('amount', 12, 2);
            $table->string('method')->default('bKash');
            $table->string('bank_last4', 8)->nullable();
            $table->enum('status', ['pending', 'approved', 'rejected', 'paid'])->default('pending');
            $table->timestamps();
        });

        Schema::create('incentives', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique(); // INC-##
            $table->string('title');
            $table->string('description')->default('');
            $table->decimal('multiplier', 4, 2)->default(1);
            $table->string('district')->default('');
            $table->unsignedInteger('goal_deliveries')->default(0);
            $table->decimal('bonus_tk', 12, 2)->default(0);
            $table->date('valid_until')->nullable();
            $table->boolean('active')->default(false);
            $table->timestamps();
        });

        Schema::create('incentive_enrollments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('incentive_id')->constrained('incentives')->cascadeOnDelete();
            $table->foreignId('courier_id')->constrained('users')->cascadeOnDelete();
            $table->unsignedInteger('progress')->default(0);
            $table->boolean('completed')->default(false);
            $table->timestamps();
            $table->unique(['incentive_id', 'courier_id']);
        });

        // Hotels & rentals
        Schema::create('hotels', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('location');
            $table->decimal('rating', 3, 2)->default(0);
            $table->unsignedTinyInteger('stars')->default(3);
            $table->decimal('price_per_night', 12, 2);
            $table->json('amenities')->nullable();
            $table->text('description')->nullable();
            $table->string('image')->nullable();
            $table->unsignedInteger('reviews_count')->default(0);
            $table->boolean('active')->default(true);
            $table->timestamps();
        });

        Schema::create('hotel_bookings', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique();
            $table->foreignId('hotel_id')->constrained('hotels')->cascadeOnDelete();
            $table->foreignId('customer_id')->constrained('users')->cascadeOnDelete();
            $table->date('check_in');
            $table->date('check_out');
            $table->unsignedSmallInteger('nights');
            $table->unsignedSmallInteger('guests')->default(1);
            $table->unsignedSmallInteger('rooms')->default(1);
            $table->string('guest_name');
            $table->string('guest_phone');
            $table->decimal('room_total', 12, 2);
            $table->decimal('service_fee', 12, 2);
            $table->decimal('total', 12, 2);
            $table->enum('status', ['upcoming', 'completed', 'cancelled'])->default('upcoming');
            $table->timestamps();
        });

        Schema::create('rental_vehicles', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('category'); // Car|SUV|Bike|Scooter|Van
            $table->decimal('price_per_day', 12, 2);
            $table->unsignedTinyInteger('seats')->default(4);
            $table->string('transmission')->default('Manual');
            $table->string('fuel')->default('Petrol');
            $table->decimal('rating', 3, 2)->default(0);
            $table->text('description')->nullable();
            $table->string('image')->nullable();
            $table->json('features')->nullable();
            $table->boolean('active')->default(true);
            $table->timestamps();
        });

        Schema::create('rental_bookings', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique();
            $table->foreignId('vehicle_id')->constrained('rental_vehicles')->cascadeOnDelete();
            $table->foreignId('customer_id')->constrained('users')->cascadeOnDelete();
            $table->string('pickup_location');
            $table->string('dropoff_location');
            $table->date('start_date');
            $table->date('end_date');
            $table->unsignedSmallInteger('days');
            $table->boolean('with_driver')->default(false);
            $table->string('renter_name');
            $table->string('renter_phone');
            $table->decimal('vehicle_total', 12, 2);
            $table->decimal('driver_fee', 12, 2)->default(0);
            $table->decimal('insurance_fee', 12, 2)->default(0);
            $table->decimal('total', 12, 2);
            $table->enum('status', ['upcoming', 'completed', 'cancelled'])->default('upcoming');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        foreach (['rental_bookings', 'rental_vehicles', 'hotel_bookings', 'hotels',
            'incentive_enrollments', 'incentives', 'courier_withdrawals', 'courier_documents',
            'courier_profiles', 'rider_payouts', 'trips', 'parcel_proofs', 'parcel_otp_logs',
            'parcels', 'rides'] as $t) {
            Schema::dropIfExists($t);
        }
    }
};

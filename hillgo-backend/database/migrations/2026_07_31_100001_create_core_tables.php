<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Region Lock master
        Schema::create('divisions', function (Blueprint $table) {
            $table->string('id')->primary(); // slug e.g. dhaka
            $table->string('name');
            $table->string('zone')->nullable();
            $table->timestamps();
        });

        Schema::create('districts', function (Blueprint $table) {
            $table->string('id')->primary(); // slug e.g. dhaka__dhaka
            $table->string('division_id');
            $table->foreign('division_id')->references('id')->on('divisions')->cascadeOnDelete();
            $table->string('name');
            $table->enum('status', ['open', 'closed'])->default('closed');
            $table->timestamp('opened_at')->nullable();
            $table->boolean('allow_customer')->default(false);
            $table->boolean('allow_rider')->default(false);
            $table->boolean('allow_merchant')->default(false);
            $table->boolean('allow_courier')->default(false);
            $table->string('note')->default('');
            $table->string('updated_by')->nullable();
            $table->timestamps();
            $table->index(['division_id', 'status']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->enum('role', ['super_admin', 'admin', 'customer', 'rider', 'merchant', 'courier_agent'])
                ->default('customer')->after('id');
            $table->string('phone')->nullable()->unique()->after('email');
            $table->enum('status', ['active', 'suspended', 'onboarding', 'pending'])->default('active')->after('password');
            $table->string('district_id')->nullable()->after('status');
            $table->foreign('district_id')->references('id')->on('districts')->nullOnDelete();
            $table->string('avatar')->nullable();
            $table->string('language', 16)->default('en');
            $table->index(['role', 'status']);
        });

        // Key-value org settings
        Schema::create('app_settings', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();
            $table->json('value')->nullable();
            $table->timestamps();
        });

        // Append-only admin activity log
        Schema::create('activity_logs', function (Blueprint $table) {
            $table->id();
            $table->string('text');
            $table->string('by')->default('System');
            $table->string('category')->nullable(); // wallet|payout|kyc|pricing|region|role|...
            $table->timestamps();
            $table->index('created_at');
        });

        // Role-agnostic notification inbox
        Schema::create('app_notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->cascadeOnDelete();
            $table->string('role', 32); // recipient role; user_id null = broadcast to role (admin)
            $table->string('title');
            $table->text('body')->nullable();
            $table->string('type', 48)->default('general');
            $table->json('data')->nullable();
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
            $table->index(['user_id', 'read_at']);
            $table->index(['role', 'created_at']);
        });

        // Pricing per panel + audit
        Schema::create('pricing_settings', function (Blueprint $table) {
            $table->id();
            $table->string('panel')->unique(); // customer|rider|merchant|courier
            $table->json('values');
            $table->timestamps();
        });

        Schema::create('pricing_audits', function (Blueprint $table) {
            $table->id();
            $table->string('panel');
            $table->string('field');
            $table->string('old_value')->nullable();
            $table->string('new_value')->nullable();
            $table->string('by');
            $table->timestamps();
            $table->index(['panel', 'created_at']);
        });

        // Server-side OTPs (hashed at rest)
        Schema::create('otp_codes', function (Blueprint $table) {
            $table->id();
            $table->string('phone');
            $table->string('role', 32);
            $table->string('purpose', 32)->default('login'); // login|register|reset
            $table->string('code_hash');
            $table->unsignedTinyInteger('attempts')->default(0);
            $table->timestamp('expires_at');
            $table->timestamp('consumed_at')->nullable();
            $table->timestamps();
            $table->index(['phone', 'role', 'purpose']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('otp_codes');
        Schema::dropIfExists('pricing_audits');
        Schema::dropIfExists('pricing_settings');
        Schema::dropIfExists('app_notifications');
        Schema::dropIfExists('activity_logs');
        Schema::dropIfExists('app_settings');
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['district_id']);
            $table->dropColumn(['role', 'phone', 'status', 'district_id', 'avatar', 'language']);
        });
        Schema::dropIfExists('districts');
        Schema::dropIfExists('divisions');
    }
};

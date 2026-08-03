<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Backend 7.4.21 — Idempotency-Key support for POST create / status-transition
 * endpoints on rides/orders/parcels. A client-supplied key is scoped to the
 * caller + route so replays return the original response instead of
 * re-running the mutation (e.g. a retried "accept order" after a lost
 * response never double-charges a wallet or double-dispatches a rider).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('idempotency_keys', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->cascadeOnDelete();
            $table->string('method', 8);
            $table->string('path', 300);
            $table->string('key', 200);
            $table->string('request_fingerprint', 64);
            $table->unsignedSmallInteger('response_status')->nullable();
            $table->longText('response_body')->nullable();
            $table->timestamp('expires_at');
            $table->timestamps();
            $table->unique(['user_id', 'method', 'path', 'key'], 'idempotency_keys_scope_unique');
            $table->index('expires_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('idempotency_keys');
    }
};

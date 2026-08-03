<?php

namespace Tests\Feature;

use App\Models\Ride;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/** Backend 7.4.21 — Idempotency-Key middleware on ride/order/parcel routes. */
class IdempotencyMiddlewareTest extends TestCase
{
    use RefreshDatabase;

    private function customerToken(): string
    {
        $user = User::factory()->create();
        $user->role = 'customer';
        $user->save();

        return $user->createToken('customer')->plainTextToken;
    }

    public function test_repeated_request_with_same_key_replays_the_original_response(): void
    {
        $token = $this->customerToken();
        $payload = [
            'vehicle_type' => 'bike', 'pickup' => 'A', 'drop' => 'B',
            'distance_km' => 5, 'duration_min' => 10, 'payment_method' => 'cash',
        ];

        $first = $this->withHeader('Authorization', "Bearer {$token}")
            ->withHeader('Idempotency-Key', 'ride-key-1')
            ->postJson('/api/customer/rides', $payload);
        $first->assertStatus(201);

        // Without idempotency this would 422 ("already have an active ride");
        // the middleware must short-circuit and replay the first response instead.
        $second = $this->withHeader('Authorization', "Bearer {$token}")
            ->withHeader('Idempotency-Key', 'ride-key-1')
            ->postJson('/api/customer/rides', $payload);

        $second->assertStatus(201)->assertHeader('Idempotency-Replayed', 'true');
        $this->assertSame($first->json('code'), $second->json('code'));
        $this->assertSame(1, Ride::count(), 'Replay must not create a second ride.');
    }

    public function test_same_key_with_a_different_payload_is_rejected(): void
    {
        $token = $this->customerToken();
        $base = [
            'vehicle_type' => 'bike', 'pickup' => 'A', 'drop' => 'B',
            'distance_km' => 5, 'duration_min' => 10, 'payment_method' => 'cash',
        ];

        $this->withHeader('Authorization', "Bearer {$token}")
            ->withHeader('Idempotency-Key', 'ride-key-2')
            ->postJson('/api/customer/rides', $base)
            ->assertStatus(201);

        $this->withHeader('Authorization', "Bearer {$token}")
            ->withHeader('Idempotency-Key', 'ride-key-2')
            ->postJson('/api/customer/rides', array_merge($base, ['pickup' => 'Different pickup']))
            ->assertStatus(409);
    }

    public function test_requests_without_the_header_are_unaffected(): void
    {
        $token = $this->customerToken();
        $payload = [
            'vehicle_type' => 'bike', 'pickup' => 'A', 'drop' => 'B',
            'distance_km' => 5, 'duration_min' => 10, 'payment_method' => 'cash',
        ];

        $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/customer/rides', $payload)
            ->assertStatus(201)
            ->assertHeaderMissing('Idempotency-Replayed');
    }
}

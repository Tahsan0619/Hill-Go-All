<?php

namespace Tests\Feature;

use App\Models\District;
use App\Models\Division;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Tests\TestCase;

/** Backend 7.4.23 — GET /admin/regions/districts (batched, all divisions). */
class RegionBatchedDistrictsTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Cache::flush();
    }

    public function test_admin_can_fetch_every_district_in_a_single_call(): void
    {
        $admin = User::factory()->create();
        $admin->role = 'super_admin';
        $admin->save();
        $token = $admin->createToken('admin')->plainTextToken;

        Division::create(['id' => 'dhaka', 'name' => 'Dhaka', 'zone' => 'Central']);
        Division::create(['id' => 'khulna', 'name' => 'Khulna', 'zone' => 'Southwest']);
        District::create(['id' => 'dhaka__t1', 'division_id' => 'dhaka', 'name' => 'T1', 'status' => 'open']);
        District::create(['id' => 'khulna__t2', 'division_id' => 'khulna', 'name' => 'T2', 'status' => 'closed']);

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->getJson('/api/admin/regions/districts');

        $response->assertStatus(200);
        $ids = collect($response->json())->pluck('id');
        $this->assertTrue($ids->contains('dhaka__t1'));
        $this->assertTrue($ids->contains('khulna__t2'));

        $row = collect($response->json())->firstWhere('id', 'dhaka__t1');
        $this->assertSame('dhaka', $row['divisionId']);
    }

    public function test_non_admin_cannot_access_the_batched_endpoint(): void
    {
        $customer = User::factory()->create();
        $customer->role = 'customer';
        $customer->save();
        $token = $customer->createToken('customer')->plainTextToken;

        $this->withHeader('Authorization', "Bearer {$token}")
            ->getJson('/api/admin/regions/districts')
            ->assertStatus(403);
    }
}

<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/** Backend 7.4.24 — GET /api/health and GET /health. */
class HealthEndpointTest extends TestCase
{
    use RefreshDatabase;

    public function test_api_health_reports_ok_with_db_check(): void
    {
        $this->getJson('/api/health')
            ->assertStatus(200)
            ->assertJson(['status' => 'ok', 'db' => 'ok']);
    }

    public function test_health_is_also_reachable_without_the_api_prefix(): void
    {
        $this->getJson('/health')
            ->assertStatus(200)
            ->assertJson(['status' => 'ok', 'db' => 'ok']);
    }

    public function test_health_does_not_require_authentication(): void
    {
        // No Authorization header at all — must not 401/redirect.
        $this->getJson('/api/health')->assertStatus(200);
    }
}

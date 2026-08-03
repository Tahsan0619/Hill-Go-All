<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;
use Laravel\Sanctum\PersonalAccessToken;
use Tests\TestCase;

/** Backend 7.4.22 — POST /{role}/auth/refresh rotates the Sanctum token. */
class AuthRefreshTest extends TestCase
{
    use RefreshDatabase;

    public function test_refresh_issues_a_new_token_and_revokes_the_old_one(): void
    {
        $user = User::factory()->create();
        $user->role = 'customer';
        $user->save();

        $oldToken = $user->createToken('customer')->plainTextToken;
        $oldTokenId = (int) explode('|', $oldToken)[0];

        $response = $this->withHeader('Authorization', "Bearer {$oldToken}")
            ->postJson('/api/customer/auth/refresh');

        $response->assertStatus(200)->assertJsonStructure(['token', 'user' => ['id', 'role']]);
        $newToken = $response->json('token');
        $newTokenId = (int) explode('|', $newToken)[0];

        $this->assertNotSame($oldToken, $newToken);
        $this->assertNull(PersonalAccessToken::find($oldTokenId), 'Old token row must be deleted after refresh.');
        $this->assertNotNull(PersonalAccessToken::find($newTokenId), 'New token row must exist after refresh.');

        // Sanctum's RequestGuard memoizes the resolved user for the guard
        // instance's lifetime, so a fresh guard is needed between calls that
        // authenticate with different tokens in the same test process —
        // in real (non-test) requests every request gets its own guard.
        Auth::forgetGuards();
        $this->withHeader('Authorization', "Bearer {$newToken}")
            ->getJson('/api/customer/me')
            ->assertStatus(200);

        Auth::forgetGuards();
        $this->withHeader('Authorization', "Bearer {$oldToken}")
            ->getJson('/api/customer/me')
            ->assertStatus(401);
    }

    public function test_refresh_is_mirrored_across_role_groups(): void
    {
        $admin = User::factory()->create();
        $admin->role = 'super_admin';
        $admin->save();
        $token = $admin->createToken('admin')->plainTextToken;

        $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/admin/auth/refresh')
            ->assertStatus(200)
            ->assertJsonStructure(['token', 'user']);
    }
}

<?php
/**
 * Live end-to-end verification of HillGo API after the security/compliance fixes.
 * Relies on actual HTTP responses only — no mocks.
 *
 * Usage: php scripts/e2e_security_verify.php
 */

$base = getenv('HILLGO_API') ?: 'http://127.0.0.1:8000/api';
$pass = true;
$results = [];

function req(string $method, string $path, ?array $body = null, ?string $token = null): array
{
    global $base;
    $ch = curl_init($base . $path);
    $headers = ['Accept: application/json', 'Content-Type: application/json'];
    if ($token) {
        $headers[] = "Authorization: Bearer {$token}";
    }
    curl_setopt_array($ch, [
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => $headers,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_POSTFIELDS => $body !== null ? json_encode($body) : null,
    ]);
    $raw = curl_exec($ch);
    $code = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $err = curl_error($ch);
    curl_close($ch);
    $json = json_decode($raw ?: 'null', true);
    return ['code' => $code, 'body' => $json, 'raw' => $raw, 'err' => $err];
}

function check(string $label, bool $ok, string $detail = ''): void
{
    global $pass, $results;
    $results[] = [$ok ? 'PASS' : 'FAIL', $label, $detail];
    if (! $ok) {
        $pass = false;
    }
}

function login(string $role, string $emailOrPhone, string $password, bool $useEmail = true): ?string
{
    $payload = $useEmail
        ? ['email' => $emailOrPhone, 'password' => $password]
        : ['phone' => $emailOrPhone, 'password' => $password];
    // Admin uses email, others may use phone/email depending on AuthController.
    $r = req('POST', "/{$role}/auth/login", $payload);
    if ($r['code'] !== 200 || empty($r['body']['token'])) {
        // Try phone-based if email failed for non-admin.
        if ($useEmail && $role !== 'admin') {
            return null;
        }
        return null;
    }
    return $r['body']['token'];
}

echo "=== HillGo E2E Security Verification ===\n";
echo "API: {$base}\n\n";

// ------------------------------------------------------------------
// 0. Public endpoints
// ------------------------------------------------------------------
$r = req('GET', '/public/districts');
check('Public districts', $r['code'] === 200 && is_array($r['body']) && count($r['body']) > 0, "HTTP {$r['code']} count=" . (is_array($r['body']) ? count($r['body']) : 0));

$r = req('GET', '/public/availability?city=Dhaka');
check('Public availability', $r['code'] === 200, "HTTP {$r['code']}");

$r = req('GET', '/public/content/home');
check('Public home content', $r['code'] === 200, "HTTP {$r['code']}");

// ------------------------------------------------------------------
// 1. Auth for all roles
// ------------------------------------------------------------------
$adminTok = null;
$r = req('POST', '/admin/auth/login', ['email' => 'admin@hillgo.app', 'password' => 'HillGo@2026!']);
check('Admin login', $r['code'] === 200 && ! empty($r['body']['token']), "HTTP {$r['code']} " . ($r['raw'] ?? ''));
$adminTok = $r['body']['token'] ?? null;

$demoPass = 'HillGoDemo@2026!';

$r = req('POST', '/customer/auth/login', ['email' => 'customer@demo.hillgo.app', 'password' => $demoPass]);
if ($r['code'] !== 200) {
    $r = req('POST', '/customer/auth/login', ['phone' => '+8801710000001', 'password' => $demoPass]);
}
check('Customer login', $r['code'] === 200 && ! empty($r['body']['token']), "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 200));
$custTok = $r['body']['token'] ?? null;

$r = req('POST', '/rider/auth/login', ['email' => 'rider@demo.hillgo.app', 'password' => $demoPass]);
if ($r['code'] !== 200) {
    $r = req('POST', '/rider/auth/login', ['phone' => '+8801710000002', 'password' => $demoPass]);
}
check('Rider login', $r['code'] === 200 && ! empty($r['body']['token']), "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 200));
$riderTok = $r['body']['token'] ?? null;

$r = req('POST', '/merchant/auth/login', ['email' => 'merchant@demo.hillgo.app', 'password' => $demoPass]);
if ($r['code'] !== 200) {
    $r = req('POST', '/merchant/auth/login', ['phone' => '+8801710000003', 'password' => $demoPass]);
}
check('Merchant login', $r['code'] === 200 && ! empty($r['body']['token']), "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 200));
$merchTok = $r['body']['token'] ?? null;

$r = req('POST', '/courier/auth/login', ['email' => 'courier@demo.hillgo.app', 'password' => $demoPass]);
if ($r['code'] !== 200) {
    $r = req('POST', '/courier/auth/login', ['phone' => '+8801710000004', 'password' => $demoPass]);
}
check('Courier login', $r['code'] === 200 && ! empty($r['body']['token']), "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 200));
$courTok = $r['body']['token'] ?? null;

if (! $adminTok || ! $custTok || ! $riderTok || ! $merchTok || ! $courTok) {
    echo "\nFATAL: missing tokens — aborting remaining tests.\n";
    foreach ($results as [$s, $l, $d]) {
        echo "[{$s}] {$l}" . ($d ? " — {$d}" : '') . "\n";
    }
    exit(1);
}

// Me endpoints
foreach ([['admin', $adminTok], ['customer', $custTok], ['rider', $riderTok], ['merchant', $merchTok], ['courier', $courTok]] as [$role, $tok]) {
    $r = req('GET', "/{$role}/me", null, $tok);
    check("{$role} /me", $r['code'] === 200 && ! empty($r['body']['id'] ?? $r['body']['user']['id'] ?? null), "HTTP {$r['code']}");
}

// ------------------------------------------------------------------
// 2. Ensure rider online + courier online
// ------------------------------------------------------------------
$r = req('POST', '/rider/presence', ['online' => true], $riderTok);
check('Rider go online', in_array($r['code'], [200, 201], true), "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 200));

$r = req('PATCH', '/courier/presence', ['online' => true], $courTok);
check('Courier go online', in_array($r['code'], [200, 201], true), "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 200));

// ------------------------------------------------------------------
// 3. Admin surfaces
// ------------------------------------------------------------------
$adminGets = [
    '/admin/overview',
    '/admin/customers',
    '/admin/rides',
    '/admin/food-orders',
    '/admin/customer-parcels',
    '/admin/sos-alerts',
    '/admin/riders',
    '/admin/riders/kyc',
    '/admin/trips',
    '/admin/rider-payouts',
    '/admin/riders/map',
    '/admin/merchants',
    '/admin/merchant-onboarding',
    '/admin/merchant-orders',
    '/admin/merchant-payouts',
    '/admin/merchant-catalog',
    '/admin/courier/agents',
    '/admin/courier/kyc',
    '/admin/courier/parcels',
    '/admin/courier/withdrawals',
    '/admin/courier/incentives',
    '/admin/pricing/customer',
    '/admin/pricing/rider',
    '/admin/settings',
    '/admin/activity',
    '/admin/regions/divisions',
    '/admin/dashboards/customer',
    '/admin/dashboards/rider',
    '/admin/dashboards/merchant',
    '/admin/dashboards/courier',
    '/admin/public-web/faqs',
    '/admin/public-web/blog',
    '/admin/marketplace/products',
    '/admin/hotels',
    '/admin/rentals',
    '/admin/loyalty',
    '/admin/promos',
];
foreach ($adminGets as $path) {
    $r = req('GET', $path, null, $adminTok);
    check("Admin GET {$path}", $r['code'] === 200, "HTTP {$r['code']}");
}

// Attribution: region update writes by_user_id
$r = req('PATCH', '/admin/regions/districts/dhaka__dhaka', [
    'note' => 'E2E attribution check ' . date('H:i:s'),
], $adminTok);
check('Admin region update', $r['code'] === 200, "HTTP {$r['code']}");

// Pricing save writes by_user_id
$r = req('GET', '/admin/pricing/customer', null, $adminTok);
$values = $r['body'] ?? [];
if (isset($values['rideBase'])) {
    $values['rideBase'] = (float) $values['rideBase']; // no-op change may skip audit; bump then restore
    $orig = $values['rideBase'];
    $values['rideBase'] = $orig + 0.01;
    $r = req('PUT', '/admin/pricing/customer', ['values' => $values], $adminTok);
    check('Admin pricing save', $r['code'] === 200, "HTTP {$r['code']}");
    $values['rideBase'] = $orig;
    req('PUT', '/admin/pricing/customer', ['values' => $values], $adminTok);
}

// Admin wallet adjust (ledger)
$r = req('POST', '/admin/customers/4/wallet', ['delta' => 10, 'note' => 'E2E credit'], $adminTok);
check('Admin wallet adjust (+10)', $r['code'] === 200, "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 200));
$walletAfterCredit = (float) ($r['body']['wallet'] ?? -1);

// ------------------------------------------------------------------
// 4. Customer: ride flow (one-active-ride + ledger debit on wallet)
// ------------------------------------------------------------------
// Clear any leftover active rides from prior runs so the flow is deterministic.
$r = req('GET', '/customer/rides', null, $custTok);
$existing = $r['body']['data'] ?? [];
foreach ($existing as $er) {
    if (in_array($er['status'] ?? '', ['searching', 'assigned', 'in_progress'], true)) {
        req('POST', "/customer/rides/{$er['id']}/cancel", ['reason' => 'E2E cleanup'], $custTok);
    }
}

$r = req('GET', '/customer/wallet', null, $custTok);
$walletBeforeRide = (float) ($r['body']['balance'] ?? $r['body']['wallet_balance'] ?? $walletAfterCredit);
check('Customer wallet read', $r['code'] === 200, "HTTP {$r['code']} bal={$walletBeforeRide}");

$r = req('POST', '/customer/rides', [
    'vehicle_type' => 'bike',
    'pickup' => 'Gulshan 1',
    'drop' => 'Banani',
    'pickup_lat' => 23.7808, 'pickup_lng' => 90.4142,
    'drop_lat' => 23.7936, 'drop_lng' => 90.4066,
    'distance_km' => 3.2,
    'duration_min' => 12,
    'payment_method' => 'cash',
], $custTok);
check('Customer book ride #1', $r['code'] === 201, "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 300));
$ride1 = $r['body'];
$ride1Id = $ride1['id'] ?? null;

// Second concurrent ride must be rejected
$r = req('POST', '/customer/rides', [
    'vehicle_type' => 'bike',
    'pickup' => 'Dhanmondi',
    'drop' => 'Mirpur',
    'distance_km' => 5,
    'duration_min' => 20,
    'payment_method' => 'cash',
], $custTok);
check('Customer double-book blocked', $r['code'] === 422, "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 200));

// ------------------------------------------------------------------
// 5. Rider: offer accept → advance to completed → ledger credit
// ------------------------------------------------------------------
$r = req('GET', '/rider/offers/current', null, $riderTok);
check('Rider current offer', $r['code'] === 200, "HTTP {$r['code']}");
$offer = $r['body']['offer'] ?? null;
check('Rider has offer for ride', $offer && ($offer['type'] ?? '') === 'ride', json_encode($offer ? ['id' => $offer['id'], 'type' => $offer['type'], 'status' => $offer['status']] : null));

$tripId = $offer['id'] ?? null;
if ($tripId) {
    $r = req('GET', '/rider/earnings', null, $riderTok);
    $riderBalBefore = (float) ($r['body']['current_balance'] ?? 0);

    $r = req('POST', "/rider/offers/{$tripId}/accept", [], $riderTok);
    check('Rider accept offer', $r['code'] === 200, "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 200));

    // Advance through ride flow: accepted → arriving → arrived → in_progress → completed
    foreach (['arriving', 'arrived', 'in_progress', 'completed'] as $step) {
        $r = req('POST', "/rider/trips/{$tripId}/advance", [], $riderTok);
        check("Rider advance → {$step}", $r['code'] === 200 && ($r['body']['status'] ?? '') === $step, "HTTP {$r['code']} status=" . ($r['body']['status'] ?? '?'));
    }

    $r = req('GET', '/rider/earnings', null, $riderTok);
    $riderBal = (float) ($r['body']['current_balance'] ?? 0);
    check('Rider balance credited after trip', $riderBal > $riderBalBefore, "before={$riderBalBefore} after={$riderBal}");
}

// Rate the ride
if ($ride1Id) {
    $r = req('POST', "/customer/rides/{$ride1Id}/rate", ['rating' => 5, 'comment' => 'E2E'], $custTok);
    check('Customer rate ride', $r['code'] === 200, "HTTP {$r['code']}");
}

// ------------------------------------------------------------------
// 6. Customer: wallet ride (debit) + cancel (refund)
// ------------------------------------------------------------------
$r = req('GET', '/customer/wallet', null, $custTok);
$walletBefore = (float) ($r['body']['balance'] ?? $r['body']['wallet_balance'] ?? 0);

$r = req('POST', '/customer/rides', [
    'vehicle_type' => 'bike',
    'pickup' => 'Uttara',
    'drop' => 'Airport',
    'distance_km' => 4,
    'duration_min' => 15,
    'payment_method' => 'wallet',
], $custTok);
check('Customer wallet ride book', $r['code'] === 201, "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 300));
$walletRide = $r['body'];
$walletRideId = $walletRide['id'] ?? null;
$fare = (float) ($walletRide['fare'] ?? 0);

$r = req('GET', '/customer/wallet', null, $custTok);
$walletMid = (float) ($r['body']['balance'] ?? $r['body']['wallet_balance'] ?? 0);
check('Wallet debited on ride book', abs(($walletBefore - $fare) - $walletMid) < 0.02, "before={$walletBefore} fare={$fare} mid={$walletMid}");

if ($walletRideId) {
    // Cancel the offer on rider side by customer cancel
    $r = req('POST', "/customer/rides/{$walletRideId}/cancel", ['reason' => 'E2E cancel'], $custTok);
    check('Customer cancel wallet ride', $r['code'] === 200, "HTTP {$r['code']}");

    $r = req('GET', '/customer/wallet', null, $custTok);
    $walletAfter = (float) ($r['body']['balance'] ?? $r['body']['wallet_balance'] ?? 0);
    check('Wallet refunded on cancel', abs($walletAfter - $walletBefore) < 0.02, "before={$walletBefore} after={$walletAfter}");
}

// ------------------------------------------------------------------
// 7. Food order: customer → merchant accept/ready → rider deliver → store credit once
// ------------------------------------------------------------------
$r = req('GET', '/customer/food/restaurants', null, $custTok);
check('Customer food restaurants', $r['code'] === 200, "HTTP {$r['code']}");
$restaurants = $r['body']['data'] ?? $r['body'] ?? [];
if (isset($restaurants['data'])) {
    $restaurants = $restaurants['data'];
}
$storeId = null;
$productId = null;
if (is_array($restaurants) && count($restaurants) > 0) {
    $first = $restaurants[0];
    $storeId = $first['id'] ?? null;
    $r = req('GET', "/customer/food/restaurants/{$storeId}", null, $custTok);
    check('Customer restaurant detail', $r['code'] === 200, "HTTP {$r['code']}");
    $products = $r['body']['menu'] ?? [];
    if (isset($products[0]['items'][0]['id'])) {
        $productId = $products[0]['items'][0]['id'];
    } elseif (isset($products[0]['id'])) {
        $productId = $products[0]['id'];
    }
}

$orderId = null;
if ($storeId && $productId) {
    $r = req('POST', '/customer/food/orders', [
        'store_id' => $storeId,
        'items' => [['product_id' => $productId, 'qty' => 1]],
        'payment_method' => 'cash',
        'delivery_address' => 'E2E Test Address, Gulshan',
    ], $custTok);
    check('Customer food checkout', in_array($r['code'], [200, 201], true), "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 400));
    $orderId = $r['body']['id'] ?? $r['body']['order']['id'] ?? null;
}

if ($orderId && $merchTok) {
    $r = req('POST', "/merchant/orders/{$orderId}/accept", [], $merchTok);
    check('Merchant accept order', $r['code'] === 200, "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 200));

    $r = req('POST', "/merchant/orders/{$orderId}/ready", [], $merchTok);
    check('Merchant mark ready (dispatches rider)', $r['code'] === 200, "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 200));

    // Rider picks up the food offer
    usleep(200000);
    $r = req('GET', '/rider/offers/current', null, $riderTok);
    $foodOffer = $r['body']['offer'] ?? null;
    check('Rider food offer present', $foodOffer && ($foodOffer['type'] ?? '') === 'food', json_encode($foodOffer ? ['id' => $foodOffer['id'], 'type' => $foodOffer['type']] : $r['body']));

    if ($foodOffer) {
        $ftid = $foodOffer['id'];
        $r = req('POST', "/rider/offers/{$ftid}/accept", [], $riderTok);
        check('Rider accept food offer', $r['code'] === 200, "HTTP {$r['code']}");

        // Get store balance before completion
        $r = req('GET', '/merchant/revenue', null, $merchTok);
        $storeBalBefore = (float) ($r['body']['pending_payout'] ?? 0);

        foreach (['picked_up', 'completed'] as $step) {
            $r = req('POST', "/rider/trips/{$ftid}/advance", [], $riderTok);
            check("Rider food advance → {$step}", $r['code'] === 200, "HTTP {$r['code']} status=" . ($r['body']['status'] ?? '?'));
        }

        $r = req('GET', '/merchant/revenue', null, $merchTok);
        $storeBalAfter = (float) ($r['body']['pending_payout'] ?? 0);
        check('Store balance credited once after delivery', $storeBalAfter > $storeBalBefore, "before={$storeBalBefore} after={$storeBalAfter}");

        // Merchant trying to deliver again must fail (already delivered)
        $r = req('POST', "/merchant/orders/{$orderId}/deliver", [], $merchTok);
        check('Merchant re-deliver blocked', $r['code'] === 422, "HTTP {$r['code']}");
    }
}

// ------------------------------------------------------------------
// 8. Parcel: customer → courier OTP pickup/delivery → ledger credit
// ------------------------------------------------------------------
$r = req('PATCH', '/courier/bank', ['bank_last4' => '4242', 'method' => 'bKash'], $courTok);
// bank endpoint may have different fields — don't fail hard
check('Courier bank update (best-effort)', in_array($r['code'], [200, 201, 422], true), "HTTP {$r['code']}");

// Ensure courier bank_verified for later withdrawal (admin KYC)
$r = req('GET', '/admin/courier/kyc', null, $adminTok);
$kycRows = $r['body']['data'] ?? [];
$courierProfileId = $kycRows[0]['id'] ?? null;
if ($courierProfileId) {
    $r = req('POST', "/admin/courier/kyc/{$courierProfileId}/status", ['status' => 'verified', 'bankVerified' => true], $adminTok);
    check('Admin verify courier + bank', $r['code'] === 200, "HTTP {$r['code']}");
}

$r = req('POST', '/customer/parcels', [
    'type' => 'Box',
    'priority' => 'standard',
    'pickup_address' => 'Gulshan Circle 1',
    'sender_name' => 'Demo Customer',
    'sender_phone' => '+8801710000001',
    'receiver_name' => 'Receiver',
    'receiver_phone' => '+8801710000099',
    'drop_address' => 'Banani 11',
    'weight_kg' => 1.5,
    'distance_km' => 4.0,
    'payment_method' => 'cash',
], $custTok);
check('Customer book parcel', $r['code'] === 201, "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 300));
$parcel = $r['body'];
$parcelId = $parcel['id'] ?? null;
$pickupOtp = $parcel['pickup_otp'] ?? null;
$deliveryOtp = $parcel['delivery_otp'] ?? null;

if ($parcelId) {
    // Force online courier assignment if not auto-assigned
    $r = req('GET', '/courier/parcels/assigned', null, $courTok);
    $assigned = $r['body'] ?? [];
    $mine = collect_first($assigned, $parcelId);

    if (! $mine) {
        // Admin reassign
        $r = req('POST', "/admin/courier/parcels/{$parcelId}/reassign", [], $adminTok);
        check('Admin reassign parcel', in_array($r['code'], [200, 201], true), "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 200));
        $r = req('GET', '/courier/parcels/assigned', null, $courTok);
        $assigned = $r['body'] ?? [];
        $mine = collect_first($assigned, $parcelId);
    }

    check('Courier has assigned parcel', (bool) $mine, json_encode(is_array($assigned) ? array_slice($assigned, 0, 2) : $assigned));

    if ($mine && $pickupOtp && $deliveryOtp) {
        $r = req('POST', "/courier/parcels/{$parcelId}/pickup-otp", ['otp' => $pickupOtp], $courTok);
        check('Courier pickup OTP', $r['code'] === 200, "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 200));

        $r = req('POST', "/courier/parcels/{$parcelId}/start-transit", [], $courTok);
        check('Courier start transit', $r['code'] === 200, "HTTP {$r['code']}");

        $r = req('GET', '/courier/earnings/dashboard', null, $courTok);
        $courBalBefore = (float) ($r['body']['balance'] ?? 0);

        $r = req('POST', "/courier/parcels/{$parcelId}/delivery-otp", ['otp' => $deliveryOtp], $courTok);
        check('Courier delivery OTP', $r['code'] === 200, "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 200));

        $r = req('GET', '/courier/earnings/dashboard', null, $courTok);
        $courBalAfter = (float) ($r['body']['balance'] ?? 0);
        check('Courier balance credited', $courBalAfter > $courBalBefore, "before={$courBalBefore} after={$courBalAfter}");
    }
}

// ------------------------------------------------------------------
// 9. Soft-delete safety: hard-deleting a user with wallet history must FAIL
// ------------------------------------------------------------------
// Use artisan tinker-style via a small PHP bootstrap
$restrictOk = false;
try {
    require __DIR__ . '/../vendor/autoload.php';
    $app = require __DIR__ . '/../bootstrap/app.php';
    $app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

    $user = App\Models\User::find(4);
    $hadTx = App\Models\WalletTransaction::where('user_id', 4)->exists();
    try {
        // Force delete bypasses SoftDeletes — should hit RESTRICT FK
        $user->forceDelete();
        $restrictOk = false;
        $restrictDetail = 'forceDelete succeeded (SHOULD NOT)';
        // Restore from soft-delete path isn't possible after force — this is bad
    } catch (Throwable $e) {
        $restrictOk = true;
        $restrictDetail = get_class($e) . ': ' . substr($e->getMessage(), 0, 120);
    }
    // Soft delete should succeed
    $softOk = false;
    try {
        $user = App\Models\User::find(4);
        $user->delete(); // soft
        $softOk = App\Models\User::withTrashed()->find(4)?->trashed() === true;
        $user->restore();
    } catch (Throwable $e) {
        $softOk = false;
        $restrictDetail .= ' | soft: ' . $e->getMessage();
    }
    check('FK RESTRICT blocks force-delete of user with wallet history', $restrictOk && $hadTx, $restrictDetail);
    check('Soft-delete user works and is restorable', $softOk, 'trashed+restored');
} catch (Throwable $e) {
    check('Soft-delete / FK check harness', false, $e->getMessage());
}

// ------------------------------------------------------------------
// 10. NID encryption + attribution columns in DB
// ------------------------------------------------------------------
try {
    $nid = Illuminate\Support\Facades\DB::table('rider_profiles')->whereNotNull('nid')->value('nid');
    check('NID stored encrypted (ciphertext)', is_string($nid) && str_starts_with($nid, 'eyJ'), 'prefix=' . substr((string) $nid, 0, 20));

    // Model decrypts transparently
    $rp = App\Models\RiderProfile::whereNotNull('nid')->first();
    if ($rp) {
        // Set a known NID via model and verify round-trip
        $rp->nid = '1234567890';
        $rp->save();
        $raw = Illuminate\Support\Facades\DB::table('rider_profiles')->where('id', $rp->id)->value('nid');
        $rp->refresh();
        check('NID encrypt round-trip', str_starts_with((string) $raw, 'eyJ') && $rp->nid === '1234567890', 'raw_prefix=' . substr((string) $raw, 0, 16) . ' decrypted=' . $rp->nid);
    }

    $byUser = Illuminate\Support\Facades\DB::table('activity_logs')->whereNotNull('by_user_id')->orderByDesc('id')->first();
    check('activity_logs.by_user_id written', (bool) $byUser, $byUser ? "id={$byUser->id} by_user_id={$byUser->by_user_id}" : 'none');

    $dist = Illuminate\Support\Facades\DB::table('districts')->where('id', 'dhaka__dhaka')->first();
    check('districts.updated_by_user_id written', ! empty($dist->updated_by_user_id), 'updated_by_user_id=' . ($dist->updated_by_user_id ?? 'null'));

    $pa = Illuminate\Support\Facades\DB::table('pricing_audits')->whereNotNull('by_user_id')->orderByDesc('id')->first();
    check('pricing_audits.by_user_id written', (bool) $pa, $pa ? "id={$pa->id} by_user_id={$pa->by_user_id}" : 'none');

    $idx = Illuminate\Support\Facades\DB::select("SHOW INDEX FROM otp_codes WHERE Column_name='expires_at'");
    check('otp_codes.expires_at indexed', count($idx) > 0, 'indexes=' . count($idx));

    // Ledger rows for rider/courier exist after our flows
    $riderLedger = Illuminate\Support\Facades\DB::table('wallet_transactions')->where('user_id', 5)->where('ref_type', 'trip')->count();
    check('Rider trip ledger rows exist', $riderLedger > 0, "count={$riderLedger}");

    $courLedger = Illuminate\Support\Facades\DB::table('wallet_transactions')->where('user_id', 7)->where('ref_type', 'parcel')->count();
    check('Courier parcel ledger rows exist', $courLedger > 0, "count={$courLedger}");
} catch (Throwable $e) {
    check('DB verification block', false, $e->getMessage());
}

// ------------------------------------------------------------------
// 11. OTP cooldown (use an existing demo phone so the account lookup succeeds)
// ------------------------------------------------------------------
$r1 = req('POST', '/customer/auth/otp/request', ['phone' => '+8801710000001']);
$r2 = req('POST', '/customer/auth/otp/request', ['phone' => '+8801710000001']);
check('OTP request #1 allowed', in_array($r1['code'], [200, 201], true), "HTTP {$r1['code']} " . substr($r1['raw'] ?? '', 0, 120));
check('OTP cooldown blocks rapid re-request', $r2['code'] === 422, "HTTP {$r2['code']} " . substr($r2['raw'] ?? '', 0, 200));

// ------------------------------------------------------------------
// Report
// ------------------------------------------------------------------
echo "\n=== RESULTS ===\n";
$passN = 0;
$failN = 0;
foreach ($results as [$s, $l, $d]) {
    echo "[{$s}] {$l}" . ($d ? " — {$d}" : '') . "\n";
    $s === 'PASS' ? $passN++ : $failN++;
}
echo "\nPassed: {$passN}  Failed: {$failN}\n";
exit($failN === 0 ? 0 : 1);

function collect_first($list, $id)
{
    if (! is_array($list)) {
        return null;
    }
    foreach ($list as $row) {
        if (is_array($row) && (int) ($row['id'] ?? 0) === (int) $id) {
            return $row;
        }
    }
    return null;
}

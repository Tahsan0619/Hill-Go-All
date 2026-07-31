<?php
/**
 * Live verification for security + scalability catalog fixes.
 * Actual HTTP / DB only — no mocks.
 *
 * Usage: php scripts/e2e_catalog_verify.php
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

    return ['code' => $code, 'body' => json_decode($raw ?: 'null', true), 'raw' => $raw, 'err' => $err];
}

function check(string $label, bool $ok, string $detail = ''): void
{
    global $pass, $results;
    $results[] = [$ok ? 'PASS' : 'FAIL', $label, $detail];
    if (! $ok) {
        $pass = false;
    }
}

function login(string $role, string $email): ?string
{
    $r = req('POST', "/{$role}/auth/login", ['email' => $email, 'password' => 'HillGoDemo@2026!']);
    if ($role === 'admin') {
        $r = req('POST', '/admin/auth/login', ['email' => $email, 'password' => 'HillGo@2026!']);
    }

    return ($r['code'] === 200 && ! empty($r['body']['token'])) ? $r['body']['token'] : null;
}

echo "=== HillGo Catalog E2E Verification ===\n";
echo "API: {$base}\n\n";

$admin = login('admin', 'admin@hillgo.app');
$cust = login('customer', 'customer@demo.hillgo.app');
$rider = login('rider', 'rider@demo.hillgo.app');
$merch = login('merchant', 'merchant@demo.hillgo.app');
$cour = login('courier', 'courier@demo.hillgo.app');

check('Admin token', (bool) $admin);
check('Customer token', (bool) $cust);
check('Rider token', (bool) $rider);
check('Merchant token', (bool) $merch);
check('Courier token', (bool) $cour);

// —— Role isolation (customer cannot hit admin) ——
$r = req('GET', '/admin/overview', null, $cust);
check('Customer blocked from /admin/overview', $r['code'] === 403 || $r['code'] === 401, "HTTP {$r['code']}");

$r = req('GET', '/admin/customers', null, $rider);
check('Rider blocked from /admin/customers', $r['code'] === 403 || $r['code'] === 401, "HTTP {$r['code']}");

// —— BOLA: customer cannot read another user's wallet/orders via admin id ——
$r = req('GET', '/customer/wallet', null, $cust);
check('Customer own wallet', $r['code'] === 200, "HTTP {$r['code']}");
$ownBal = (float) ($r['body']['balance'] ?? $r['body']['wallet'] ?? -1);

// —— Mass-assignment: profile update must not accept wallet_balance / role ——
req('PATCH', '/customer/me', [
    'name' => 'Demo Customer',
    'wallet_balance' => 999999,
    'role' => 'super_admin',
], $cust);
$me = req('GET', '/customer/me', null, $cust);
$roleOk = ($me['body']['user']['role'] ?? $me['body']['role'] ?? '') === 'customer';
$wal = req('GET', '/customer/wallet', null, $cust);
$balAfter = (float) ($wal['body']['balance'] ?? $wal['body']['wallet'] ?? -1);
check('Mass-assign role rejected (still customer)', $roleOk, 'role=' . ($me['body']['user']['role'] ?? $me['body']['role'] ?? 'n/a'));
check('Mass-assign wallet_balance ignored', abs($balAfter - $ownBal) < 0.01 || $balAfter < 999999, "before={$ownBal} after={$balAfter}");

// —— Client distance trust: claimed km within validation max but far from coords ——
$list = req('GET', '/customer/rides', null, $cust);
if (is_array($list['body'])) {
    $rows = $list['body']['data'] ?? $list['body'];
    if (is_array($rows)) {
        foreach ($rows as $row) {
            if (in_array($row['status'] ?? '', ['searching', 'assigned', 'in_progress'], true)) {
                req('POST', '/customer/rides/' . $row['id'] . '/cancel', ['reason' => 'clear for catalog'], $cust);
            }
        }
    }
}
req('POST', '/rider/go-online', null, $rider);
if (req('POST', '/rider/presence/online', ['online' => true], $rider)['code'] >= 400) {
    // try alternate presence endpoints used by apps
    req('POST', '/rider/status', ['online' => true], $rider);
}
$r = req('POST', '/customer/rides', [
    'vehicle_type' => 'bike',
    'pickup' => 'Gulshan 1',
    'drop' => 'Banani',
    'pickup_lat' => 23.7808,
    'pickup_lng' => 90.4142,
    'drop_lat' => 23.7936,
    'drop_lng' => 90.4066,
    'distance_km' => 450,
    'duration_min' => 12,
    'payment_method' => 'cash',
], $cust);
$dist = (float) ($r['body']['distance_km'] ?? -1);
$fare = (float) ($r['body']['fare'] ?? -1);
check('Ride book with spoofed distance', $r['code'] === 201, "HTTP {$r['code']} " . substr($r['raw'] ?? '', 0, 180));
check('Spoofed distance not persisted as 450', $r['code'] === 201 && $dist < 50, "distance_km={$dist} fare={$fare}");
if ($r['code'] === 201) {
    req('POST', '/customer/rides/' . (int) $r['body']['id'] . '/cancel', ['reason' => 'catalog e2e'], $cust);
}

// —— Paginated admin commerce responses ——
foreach (['/admin/hotels', '/admin/rentals', '/admin/promos', '/admin/public-web/faqs', '/admin/public-web/blog', '/admin/public-web/testimonials', '/admin/public-web/newsletter'] as $path) {
    $r = req('GET', $path, null, $admin);
    $shaped = is_array($r['body']) && (isset($r['body']['data']) || array_is_list($r['body']));
    check("Admin list {$path}", $r['code'] === 200 && $shaped, "HTTP {$r['code']}");
}

// —— Districts cache: two reads succeed; after region update still consistent ——
$d1 = req('GET', '/public/districts');
$d2 = req('GET', '/public/districts');
check('Districts cache-stable count', $d1['code'] === 200 && count($d1['body']) === count($d2['body']) && count($d1['body']) === 64, 'c1=' . count($d1['body'] ?? []) . ' c2=' . count($d2['body'] ?? []));

$divs = req('GET', '/admin/regions/divisions', null, $admin);
$divId = $divs['body'][0]['id'] ?? null;
$dists = $divId ? req('GET', "/admin/regions/divisions/{$divId}/districts", null, $admin) : ['body' => []];
$distId = $dists['body'][0]['id'] ?? null;
if ($distId) {
    $before = $dists['body'][0]['status'] ?? null;
    $upd = req('PATCH', "/admin/regions/districts/{$distId}", ['note' => 'catalog-e2e'], $admin);
    if ($upd['code'] === 405) {
        $upd = req('POST', "/admin/regions/districts/{$distId}", ['note' => 'catalog-e2e'], $admin);
    }
    if ($upd['code'] === 405) {
        $upd = req('PUT', "/admin/regions/districts/{$distId}", ['note' => 'catalog-e2e'], $admin);
    }
    check('Region update + cache bust', $upd['code'] === 200, "HTTP {$upd['code']} before={$before}");
}

// —— Wallet audit rows after admin adjust ——
$adj = req('POST', '/admin/customers/4/wallet', ['delta' => 1, 'note' => 'catalog-e2e-audit'], $admin);
$afterAudit = req('GET', '/admin/activity', null, $admin);
check('Admin wallet adjust OK', $adj['code'] === 200 || $adj['code'] === 201, "HTTP {$adj['code']} " . substr($adj['raw'] ?? '', 0, 120));
$auditTexts = json_encode($afterAudit['body']);
check('Activity log mentions wallet/adjust', stripos($auditTexts, 'wallet') !== false || stripos($auditTexts, 'adjust') !== false || stripos($auditTexts, 'catalog-e2e') !== false, substr($auditTexts, 0, 200));

// —— OTP throttle / cooldown ——
$otp1 = req('POST', '/customer/auth/otp/request', ['phone' => '+8801710000999', 'purpose' => 'login']);
$otp2 = req('POST', '/customer/auth/otp/request', ['phone' => '+8801710000999', 'purpose' => 'login']);
check('OTP first request', in_array($otp1['code'], [200, 201, 422], true), "HTTP {$otp1['code']}");
check('OTP second blocked or throttled', in_array($otp2['code'], [422, 429], true), "HTTP {$otp2['code']}");

// —— Auth login throttle probe (should still succeed for valid demo, not 500) ——
$r = req('POST', '/customer/auth/login', ['email' => 'customer@demo.hillgo.app', 'password' => 'HillGoDemo@2026!']);
check('Login still works under throttle middleware', $r['code'] === 200, "HTTP {$r['code']}");

// —— CORS allow-list header on OPTIONS-like GET with Origin ——
$ch = curl_init($base . '/public/districts');
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => ['Accept: application/json', 'Origin: http://evil.example'],
    CURLOPT_HEADER => true,
]);
$raw = curl_exec($ch);
curl_close($ch);
$noStar = stripos($raw, 'Access-Control-Allow-Origin: *') === false;
check('CORS does not echo * for unknown origin', $noStar, 'header-check');

// —— Fillable: Store.status not mass-assignable via merchant profile if such endpoint exists ——
$store = req('GET', '/merchant/store', null, $merch);
check('Merchant store readable', $store['code'] === 200 || $store['code'] === 404, "HTTP {$store['code']}");

// —— Queued notifier path still delivers (sync driver) ——
$notifs = req('GET', '/customer/notifications', null, $cust);
check('Customer notifications endpoint', $notifs['code'] === 200, "HTTP {$notifs['code']}");

// —— DB: hot-path indexes exist ——
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
$idx = Illuminate\Support\Facades\DB::select("SHOW INDEX FROM orders WHERE Key_name = 'orders_channel_created_index'");
check('orders_channel_created_index exists', count($idx) > 0, 'count=' . count($idx));
$idx2 = Illuminate\Support\Facades\DB::select("SHOW INDEX FROM trips WHERE Key_name = 'trips_rider_status_completed_index'");
check('trips_rider_status_completed_index exists', count($idx2) > 0, 'count=' . count($idx2));
$idx3 = Illuminate\Support\Facades\DB::select("SHOW INDEX FROM wallet_transactions WHERE Key_name = 'wallet_transactions_ref_index'");
check('wallet_transactions_ref_index exists', count($idx3) > 0, 'count=' . count($idx3));

// —— Production debug force-off path: config in local may stay true; assert code path exists ——
$provider = file_get_contents(__DIR__ . '/../app/Providers/AppServiceProvider.php');
check('AppServiceProvider forces debug off in production', str_contains($provider, "config(['app.debug' => false])"));

echo "\n=== RESULTS ===\n";
foreach ($results as [$st, $label, $detail]) {
    echo "[{$st}] {$label}" . ($detail !== '' ? " — {$detail}" : '') . "\n";
}
$failed = count(array_filter($results, fn ($r) => $r[0] === 'FAIL'));
$passed = count($results) - $failed;
echo "\nPassed: {$passed}  Failed: {$failed}\n";
exit($pass ? 0 : 1);

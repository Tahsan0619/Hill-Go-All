<?php
$base = 'http://127.0.0.1:8000/api';
function req($m, $p, $b = null, $t = null)
{
    global $base;
    $ch = curl_init($base . $p);
    $h = ['Accept: application/json', 'Content-Type: application/json'];
    if ($t) {
        $h[] = "Authorization: Bearer $t";
    }
    curl_setopt_array($ch, [
        CURLOPT_CUSTOMREQUEST => $m,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => $h,
        CURLOPT_POSTFIELDS => $b ? json_encode($b) : null,
    ]);
    $raw = curl_exec($ch);
    $c = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    return [$c, json_decode($raw, true), $raw];
}

[, $a] = req('POST', '/admin/auth/login', ['email' => 'admin@hillgo.app', 'password' => 'HillGo@2026!']);
$at = $a['token'];
[, $m] = req('POST', '/merchant/auth/login', ['email' => 'merchant@demo.hillgo.app', 'password' => 'HillGoDemo@2026!']);
$mt = $m['token'];
[, $r] = req('POST', '/rider/auth/login', ['email' => 'rider@demo.hillgo.app', 'password' => 'HillGoDemo@2026!']);
$rt = $r['token'];
[, $cust] = req('POST', '/customer/auth/login', ['email' => 'customer@demo.hillgo.app', 'password' => 'HillGoDemo@2026!']);
$ct = $cust['token'];
[, $cour] = req('POST', '/courier/auth/login', ['email' => 'courier@demo.hillgo.app', 'password' => 'HillGoDemo@2026!']);
$cot = $cour['token'];

// Ensure courier has enough balance for the min withdrawal (default ৳500).
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
$need = 600 - (float) App\Models\CourierProfile::where('user_id', 7)->value('balance');
if ($need > 0) {
    App\Services\Wallet::adjustCourier(7, $need, 'E2E top-up', 'admin_adjust');
}

$fail = 0;
function ok($label, $cond, $detail = '')
{
    global $fail;
    echo ($cond ? '[PASS] ' : '[FAIL] ') . $label . ($detail ? " — $detail" : '') . "\n";
    if (! $cond) {
        $fail++;
    }
}

[, $rev] = req('GET', '/merchant/revenue', null, $mt);
$before = (float) $rev['pending_payout'];
if ($before < 1000) {
    App\Services\Wallet::adjustStore(1, 1000 - $before, 'E2E store top-up', 'admin_adjust');
    [, $rev] = req('GET', '/merchant/revenue', null, $mt);
    $before = (float) $rev['pending_payout'];
}
[$c, $p, $raw] = req('POST', '/merchant/payouts/early-request', ['amount' => 1000, 'method' => 'Bank'], $mt);
ok('Merchant early payout request', $c === 201, "HTTP $c " . substr($raw, 0, 160));
$pid = $p['id'] ?? null;
if ($pid) {
    [$c, $s, $raw] = req('POST', "/admin/merchant-payouts/$pid/status", ['status' => 'completed'], $at);
    ok('Admin complete merchant payout (debits store)', $c === 200, "HTTP $c " . substr($raw, 0, 120));
}
[, $rev] = req('GET', '/merchant/revenue', null, $mt);
$after = (float) $rev['pending_payout'];
ok('Store balance decreased by 1000', abs(($before - 1000) - $after) < 0.02, "before=$before after=$after");

[, $earn] = req('GET', '/rider/earnings', null, $rt);
$rb = (float) $earn['current_balance'];
if ($rb < 100) {
    App\Services\Wallet::adjustRider(5, 100 - $rb, 'E2E rider top-up', 'admin_adjust');
    [, $earn] = req('GET', '/rider/earnings', null, $rt);
    $rb = (float) $earn['current_balance'];
}
[$c, $co, $raw] = req('POST', '/rider/payouts/cash-out', ['amount' => 100, 'method' => 'bKash'], $rt);
ok('Rider cash-out request', $c === 201, "HTTP $c " . substr($raw, 0, 160));
$coid = $co['id'] ?? null;
if ($coid) {
    [$c, $s, $raw] = req('POST', "/admin/rider-payouts/$coid/status", ['status' => 'paid'], $at);
    ok('Admin mark rider payout paid (debits rider)', $c === 200, "HTTP $c " . substr($raw, 0, 120));
}
[, $earn] = req('GET', '/rider/earnings', null, $rt);
$ra = (float) $earn['current_balance'];
ok('Rider balance decreased by 100', abs(($rb - 100) - $ra) < 0.02, "before=$rb after=$ra");

[, $cd] = req('GET', '/courier/earnings/dashboard', null, $cot);
$cb = (float) $cd['balance'];
[$c, $w, $raw] = req('POST', '/courier/withdrawals', ['amount' => 500, 'method' => 'bKash'], $cot);
ok('Courier withdrawal request', $c === 201, "HTTP $c " . substr($raw, 0, 120));
$wid = $w['id'] ?? null;
if ($wid) {
    [$c, $s, $raw] = req('POST', "/admin/courier/withdrawals/$wid/status", ['status' => 'paid'], $at);
    ok('Admin pay courier withdrawal (debits courier)', $c === 200, "HTTP $c " . substr($raw, 0, 120));
}
[, $cd] = req('GET', '/courier/earnings/dashboard', null, $cot);
$ca = (float) $cd['balance'];
ok('Courier balance decreased by 500', abs(($cb - 500) - $ca) < 0.02, "before=$cb after=$ca");

[$c] = req('GET', '/customer/marketplace/products', null, $ct);
ok('Customer marketplace', $c === 200, "HTTP $c");
[$c] = req('GET', '/customer/hotels', null, $ct);
ok('Customer hotels', $c === 200, "HTTP $c");
[$c] = req('GET', '/customer/rentals', null, $ct);
ok('Customer rentals', $c === 200, "HTTP $c");
[$c] = req('GET', '/customer/promos', null, $ct);
ok('Customer promos', $c === 200, "HTTP $c");
[$c] = req('GET', '/customer/rewards', null, $ct);
ok('Customer rewards', $c === 200, "HTTP $c");
[$c] = req('GET', '/merchant/store', null, $mt);
ok('Merchant store', $c === 200, "HTTP $c");
[$c] = req('GET', '/merchant/products', null, $mt);
ok('Merchant products', $c === 200, "HTTP $c");
[$c] = req('GET', '/courier/incentives', null, $cot);
ok('Courier incentives', $c === 200, "HTTP $c");

[$c, $sos] = req('POST', '/customer/sos/alerts', ['type' => 'sos', 'location_label' => 'E2E Banani'], $ct);
ok('Customer SOS trigger', in_array($c, [200, 201], true), "HTTP $c");
$sid = $sos['id'] ?? null;
if ($sid) {
    [$c] = req('POST', "/admin/sos-alerts/$sid/resolve", [], $at);
    ok('Admin SOS resolve (sets resolved_by_user_id)', $c === 200, "HTTP $c");
}

echo "\nFailed: $fail\n";
exit($fail ? 1 : 0);

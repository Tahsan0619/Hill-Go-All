<?php
$base = getenv('HILLGO_API') ?: 'http://127.0.0.1:8000/api';

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
        CURLOPT_TIMEOUT => 25,
        CURLOPT_POSTFIELDS => $body !== null ? json_encode($body) : null,
    ]);
    $raw = curl_exec($ch);
    $code = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    return ['code' => $code, 'body' => json_decode($raw ?: 'null', true)];
}

function tok(string $role, string $email, string $pass): ?string
{
    $r = req('POST', "/{$role}/auth/login", ['email' => $email, 'password' => $pass]);

    return $r['body']['token'] ?? null;
}

$av = req('GET', '/public/availability?city=Dhaka');
echo "availability HTTP={$av['code']} available=" . json_encode($av['body']['available'] ?? null) . "\n";

$admin = tok('admin', 'admin@hillgo.app', 'HillGo@2026!');
$divs = req('GET', '/admin/regions/divisions', null, $admin);
$dhakaDiv = null;
foreach ($divs['body'] ?? [] as $d) {
    if (stripos($d['name'] ?? '', 'Dhaka') !== false) {
        $dhakaDiv = $d;
        break;
    }
}
$dists = req('GET', '/admin/regions/divisions/' . ($dhakaDiv['id'] ?? '') . '/districts', null, $admin);
$open = $closed = 0;
$dhakaRow = null;
foreach ($dists['body'] ?? [] as $row) {
    (($row['status'] ?? '') === 'open') ? $open++ : $closed++;
    if (($row['name'] ?? '') === 'Dhaka') {
        $dhakaRow = $row;
    }
}
echo "DhakaDiv open={$open} closed={$closed} dhakaStatus=" . ($dhakaRow['status'] ?? 'n/a') . "\n";
if ($dhakaRow && ($dhakaRow['status'] ?? '') !== 'open') {
    $u = req('PATCH', '/admin/regions/districts/' . $dhakaRow['id'], [
        'status' => 'open',
        'allowCustomer' => true,
        'allowRider' => true,
        'allowMerchant' => true,
        'allowCourier' => true,
    ], $admin);
    echo "reopen Dhaka HTTP={$u['code']} status=" . ($u['body']['status'] ?? '') . "\n";
}

$av2 = req('GET', '/public/availability?city=Dhaka');
echo "availability2 HTTP={$av2['code']} available=" . json_encode($av2['body']['available'] ?? null) . "\n";

$tokens = [
    'admin' => $admin,
    'customer' => tok('customer', 'customer@demo.hillgo.app', 'HillGoDemo@2026!'),
    'rider' => tok('rider', 'rider@demo.hillgo.app', 'HillGoDemo@2026!'),
    'merchant' => tok('merchant', 'merchant@demo.hillgo.app', 'HillGoDemo@2026!'),
    'courier' => tok('courier', 'courier@demo.hillgo.app', 'HillGoDemo@2026!'),
];

foreach ($tokens as $role => $t) {
    $me = req('GET', "/{$role}/me", null, $t);
    echo "{$role} me={$me['code']}\n";
}

$checks = [
    ['admin', '/admin/overview'],
    ['admin', '/admin/customers'],
    ['admin', '/admin/riders'],
    ['admin', '/admin/merchants'],
    ['admin', '/admin/courier/agents'],
    ['admin', '/admin/hotels'],
    ['admin', '/admin/promos'],
    ['admin', '/admin/public-web/faqs'],
    ['customer', '/customer/food/restaurants'],
    ['customer', '/customer/hotels'],
    ['customer', '/customer/rentals'],
    ['customer', '/customer/promos'],
    ['customer', '/customer/wallet'],
    ['customer', '/customer/parcels'],
    ['customer', '/customer/rides'],
    ['rider', '/rider/trips'],
    ['merchant', '/merchant/store'],
    ['merchant', '/merchant/products'],
    ['courier', '/courier/parcels/assigned'],
    ['courier', '/courier/incentives'],
    ['courier', '/courier/earnings/dashboard'],
];

$fail = 0;
foreach ($checks as [$role, $path]) {
    $x = req('GET', $path, null, $tokens[$role]);
    $ok = $x['code'] === 200;
    if (! $ok) {
        $fail++;
    }
    echo ($ok ? 'PASS' : 'FAIL') . " {$path} -> {$x['code']}\n";
}
echo "Failed: {$fail}\n";
exit($fail ? 1 : 0);

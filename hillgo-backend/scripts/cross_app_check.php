<?php

/**
 * Full cross-app data sync verification.
 *
 * Logs in bot users for every role, pushes data through customer →
 * rider / merchant / courier, and asserts admin sees the same records.
 *
 * Usage: php scripts/cross_app_check.php
 */

declare(strict_types=1);

$base = getenv('HILLGO_API_BASE') ?: 'http://127.0.0.1:8000/api';
$password = getenv('SEED_DEMO_PASSWORD') ?: 'HillGoDemo@2026!';
$adminPassword = getenv('SEED_ADMIN_PASSWORD') ?: 'HillGo@2026!';
$outPath = __DIR__ . '/../storage/app/cross_app_check_last_run.json';

$issues = [];
$checks = [];
$t0 = microtime(true);

function elapsed(): float
{
    global $t0;

    return round((microtime(true) - $t0) * 1000);
}

function logCheck(string $name, bool $ok, array $data = [], ?string $issue = null): void
{
    global $checks, $issues;
    $checks[] = [
        'ms' => elapsed(),
        'name' => $name,
        'ok' => $ok,
        'data' => $data,
        'issue' => $issue,
    ];
    $mark = $ok ? 'PASS' : 'FAIL';
    echo sprintf("[%5dms] %-6s %s %s\n", elapsed(), $mark, $name, $data === [] ? '' : json_encode($data, JSON_UNESCAPED_SLASHES));
    if (! $ok && $issue) {
        $issues[] = $issue;
        echo "         → {$issue}\n";
    }
}

function httpJson(string $method, string $url, ?array $body = null, ?string $token = null): array
{
    $ch = curl_init($url);
    $headers = ['Accept: application/json', 'Content-Type: application/json'];
    if ($token) {
        $headers[] = 'Authorization: Bearer '.$token;
    }
    curl_setopt_array($ch, [
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => $headers,
        CURLOPT_TIMEOUT => 30,
    ]);
    if ($body !== null) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($body));
    }
    $raw = curl_exec($ch);
    $code = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $err = curl_error($ch);
    if ($raw === false) {
        throw new RuntimeException("HTTP error: {$err}");
    }
    $json = json_decode($raw, true);
    if (! is_array($json)) {
        throw new RuntimeException("Invalid JSON (HTTP {$code}): {$raw}");
    }

    return ['_http' => $code, '_body' => $json];
}

function expectOk(array $res, string $label): array
{
    $code = $res['_http'];
    $body = $res['_body'];
    if ($code >= 400) {
        $msg = $body['message'] ?? ($body['error'] ?? json_encode($body));
        throw new RuntimeException("{$label} failed HTTP {$code}: ".(is_string($msg) ? $msg : json_encode($msg)));
    }

    return $body;
}

try {
    echo "=== HillGo cross-app check ===\nbase={$base}\n\n";

    // —— Auth bots ——
    $admin = expectOk(httpJson('POST', "{$base}/admin/auth/login", [
        'email' => 'admin@hillgo.app',
        'password' => $adminPassword,
    ]), 'admin login');
    $adminToken = $admin['token'] ?? null;
    logCheck('admin_login', (bool) $adminToken, ['name' => $admin['user']['name'] ?? null], $adminToken ? null : 'Admin login returned no token');

    $customer = expectOk(httpJson('POST', "{$base}/customer/auth/login", [
        'email' => 'customer@demo.hillgo.app',
        'password' => $password,
    ]), 'customer login');
    $customerToken = $customer['token'];
    $customerId = $customer['user']['id'];
    logCheck('customer_bot_login', true, ['id' => $customerId]);

    $rider = expectOk(httpJson('POST', "{$base}/rider/auth/login", [
        'email' => 'rider@demo.hillgo.app',
        'password' => $password,
    ]), 'rider login');
    $riderToken = $rider['token'];
    logCheck('rider_bot_login', true, ['id' => $rider['user']['id'] ?? null]);

    $merchant = expectOk(httpJson('POST', "{$base}/merchant/auth/login", [
        'email' => 'merchant@demo.hillgo.app',
        'password' => $password,
    ]), 'merchant login');
    $merchantToken = $merchant['token'];
    logCheck('merchant_bot_login', true, ['id' => $merchant['user']['id'] ?? null]);

    $courier = expectOk(httpJson('POST', "{$base}/courier/auth/login", [
        'email' => 'courier@demo.hillgo.app',
        'password' => $password,
    ]), 'courier login');
    $courierToken = $courier['token'];
    logCheck('courier_bot_login', true, ['id' => $courier['user']['id'] ?? null]);

    // —— Admin lists bot users ——
    $adminCustomers = expectOk(httpJson('GET', "{$base}/admin/customers?per_page=50", null, $adminToken), 'admin customers');
    $customerRows = $adminCustomers['data'] ?? $adminCustomers;
    $foundCustomer = collectLike($customerRows, fn ($r) => ($r['email'] ?? '') === 'customer@demo.hillgo.app' || (string) ($r['id'] ?? '') === (string) $customerId);
    logCheck('admin_sees_customer_bot', $foundCustomer !== null, ['customer_id' => $customerId], $foundCustomer ? null : 'Demo customer missing from admin /customers');

    $adminRiders = expectOk(httpJson('GET', "{$base}/admin/riders?per_page=50", null, $adminToken), 'admin riders');
    $foundRider = collectLike($adminRiders['data'] ?? $adminRiders, fn ($r) => stripos((string) ($r['name'] ?? ''), 'Demo Rider') !== false || ($r['phone'] ?? '') === '+8801710000002');
    logCheck('admin_sees_rider_bot', $foundRider !== null, ['rider_id' => $foundRider['id'] ?? null], $foundRider ? null : 'Demo rider missing from admin /riders');

    $adminMerchants = expectOk(httpJson('GET', "{$base}/admin/merchants?per_page=50", null, $adminToken), 'admin merchants');
    $foundMerchant = collectLike($adminMerchants['data'] ?? $adminMerchants, fn ($r) => stripos((string) ($r['name'] ?? $r['store_name'] ?? ''), 'Demo Kitchen') !== false || ($r['email'] ?? '') === 'merchant@demo.hillgo.app');
    logCheck('admin_sees_merchant_bot', $foundMerchant !== null, [], $foundMerchant ? null : 'Demo merchant/store missing from admin /merchants');

    $adminCouriers = expectOk(httpJson('GET', "{$base}/admin/courier/agents?per_page=50", null, $adminToken), 'admin couriers');
    $foundCourier = collectLike($adminCouriers['data'] ?? $adminCouriers, fn ($r) => ($r['email'] ?? '') === 'courier@demo.hillgo.app' || stripos((string) ($r['name'] ?? ''), 'Demo Courier') !== false || ($r['phone'] ?? '') === '+8801710000004');
    logCheck('admin_sees_courier_bot', $foundCourier !== null, [], $foundCourier ? null : 'Demo courier missing from admin /courier/agents');

    // —— Wallet push: admin → customer ——
    $walletBefore = expectOk(httpJson('GET', "{$base}/customer/wallet", null, $customerToken), 'customer wallet');
    $balBefore = (float) ($walletBefore['balance'] ?? $walletBefore['wallet_balance'] ?? 0);
    expectOk(httpJson('POST', "{$base}/admin/customers/{$customerId}/wallet", [
        'delta' => 25,
        'note' => 'cross_app_check credit',
    ], $adminToken), 'admin wallet adjust');
    $walletAfter = expectOk(httpJson('GET', "{$base}/customer/wallet", null, $customerToken), 'customer wallet after');
    $balAfter = (float) ($walletAfter['balance'] ?? $walletAfter['wallet_balance'] ?? 0);
    $walletOk = abs(($balAfter - $balBefore) - 25) < 0.01;
    logCheck('admin_wallet_push_to_customer', $walletOk, [
        'before' => $balBefore,
        'after' => $balAfter,
    ], $walletOk ? null : "Customer wallet did not reflect +25 (before={$balBefore}, after={$balAfter})");

    // —— Food: customer → merchant → admin ——
    $restaurants = expectOk(httpJson('GET', "{$base}/customer/food/restaurants", null, $customerToken), 'food restaurants');
    $restList = $restaurants['data'] ?? $restaurants;
    if (! is_array($restList)) {
        $restList = [];
    }
    $demoStore = collectLike($restList, fn ($r) => stripos((string) ($r['name'] ?? ''), 'Demo Kitchen') !== false);
    logCheck('customer_sees_demo_kitchen', $demoStore !== null, [
        'restaurant_count' => count($restList),
        'store_id' => $demoStore['id'] ?? null,
    ], $demoStore ? null : 'Demo Kitchen not in customer food restaurants (category mismatch or inactive)');

    $orderId = null;
    $orderCode = null;
    if ($demoStore) {
        $detail = expectOk(httpJson('GET', "{$base}/customer/food/restaurants/{$demoStore['id']}", null, $customerToken), 'restaurant detail');
        $products = [];
        foreach ($detail['menu'] ?? [] as $cat) {
            foreach ($cat['items'] ?? [] as $p) {
                $products[] = $p;
            }
        }
        $product = $products[0] ?? null;
        logCheck('demo_kitchen_has_products', $product !== null, [
            'product_count' => count($products),
            'product_id' => $product['id'] ?? null,
        ], $product ? null : 'Demo Kitchen has no active menu products for checkout');

        if ($product) {
            $order = expectOk(httpJson('POST', "{$base}/customer/food/orders", [
                'store_id' => (int) $demoStore['id'],
                'items' => [['product_id' => (int) $product['id'], 'qty' => 1]],
                'delivery_address' => 'BOT food drop Gulshan 1, Dhaka',
                'payment_method' => 'cash',
                'customer_note' => 'cross_app_check food order',
            ], $customerToken), 'food checkout');
            $orderId = $order['id'] ?? null;
            $orderCode = $order['code'] ?? null;
            logCheck('customer_food_order_created', (bool) $orderId, [
                'order_id' => $orderId,
                'code' => $orderCode,
                'status' => $order['status'] ?? null,
            ], $orderId ? null : 'Food checkout returned no order id');

            $merchantOrders = expectOk(httpJson('GET', "{$base}/merchant/orders", null, $merchantToken), 'merchant orders');
            $mRows = $merchantOrders['data'] ?? $merchantOrders;
            $mOrder = collectLike($mRows, fn ($r) => (string) ($r['id'] ?? '') === (string) $orderId || ($r['code'] ?? '') === $orderCode);
            logCheck('merchant_receives_food_order', $mOrder !== null, [
                'order_id' => $orderId,
                'merchant_status' => $mOrder['status'] ?? null,
            ], $mOrder ? null : "Merchant app did not receive food order #{$orderId}");

            if ($mOrder) {
                expectOk(httpJson('POST', "{$base}/merchant/orders/{$orderId}/accept", null, $merchantToken), 'merchant accept');
                expectOk(httpJson('POST', "{$base}/merchant/orders/{$orderId}/ready", null, $merchantToken), 'merchant ready');
                $custOrder = expectOk(httpJson('GET', "{$base}/customer/food/orders/{$orderId}", null, $customerToken), 'customer order after ready');
                $statusOk = in_array($custOrder['status'] ?? '', ['ready', 'on_the_way', 'preparing'], true);
                logCheck('customer_sees_merchant_status', $statusOk, [
                    'status' => $custOrder['status'] ?? null,
                ], $statusOk ? null : 'Customer order status not updated after merchant accept/ready');
            }

            $adminFood = expectOk(httpJson('GET', "{$base}/admin/food-orders?per_page=50", null, $adminToken), 'admin food orders');
            $aFood = collectLike($adminFood['data'] ?? $adminFood, fn ($r) => (string) ($r['id'] ?? '') === (string) $orderId || ($r['code'] ?? '') === $orderCode);
            logCheck('admin_sees_food_order', $aFood !== null, ['order_id' => $orderId], $aFood ? null : "Admin panel API missing food order #{$orderId}");
        }
    }

    // —— Parcel: customer → courier → admin ——
    expectOk(httpJson('PATCH', "{$base}/courier/presence", ['online' => true], $courierToken), 'courier online');
    $parcel = expectOk(httpJson('POST', "{$base}/customer/parcels", [
        'type' => 'Box',
        'priority' => 'standard',
        'pickup_address' => 'BOT parcel pickup Gulshan 1',
        'sender_name' => 'Demo Customer',
        'sender_phone' => '+8801710000001',
        'receiver_name' => 'Parcel Receiver',
        'receiver_phone' => '+8801710999999',
        'drop_address' => 'Banani 11, Dhaka',
        'pickup_lat' => 23.7808,
        'pickup_lng' => 90.4169,
        'drop_lat' => 23.7937,
        'drop_lng' => 90.4066,
        'weight_kg' => 1.5,
        'distance_km' => 3.2,
        'payment_method' => 'cash',
        'notes' => 'cross_app_check parcel',
    ], $customerToken), 'parcel create');
    $parcelId = $parcel['id'] ?? null;
    $parcelCode = $parcel['code'] ?? null;
    $pickupOtp = $parcel['pickup_otp'] ?? null;
    $deliveryOtp = $parcel['delivery_otp'] ?? null;
    logCheck('customer_parcel_created', (bool) $parcelId, [
        'parcel_id' => $parcelId,
        'code' => $parcelCode,
        'status' => $parcel['status'] ?? null,
        'courier_id' => $parcel['courier_id'] ?? null,
    ], $parcelId ? null : 'Parcel create failed');

    // Customer create response masks assigned→booked; confirm via courier assigned list + agent payload.
    $cParcel = null;
    $deadline = microtime(true) + 10;
    while (microtime(true) < $deadline) {
        $cList = expectOk(httpJson('GET', "{$base}/courier/parcels/assigned", null, $courierToken), 'courier parcels assigned');
        $cRows = is_array($cList) && array_is_list($cList) ? $cList : ($cList['data'] ?? $cList);
        $cParcel = collectLike($cRows, fn ($r) => (string) ($r['id'] ?? '') === (string) $parcelId
            || ($r['code'] ?? '') === $parcelCode
            || ($r['order_id'] ?? '') === $parcelCode);
        if ($cParcel) {
            break;
        }
        usleep(300_000);
    }
    logCheck('courier_receives_parcel', $cParcel !== null, [
        'parcel_id' => $parcelId,
        'status' => $cParcel['status'] ?? null,
        'customer_agent' => $parcel['agent']['name'] ?? null,
    ], $cParcel ? null : "Courier bot never received parcel #{$parcelId} (is courier online + verified?)");

    if ($cParcel && $pickupOtp && $deliveryOtp) {
        expectOk(httpJson('POST', "{$base}/courier/parcels/{$parcelId}/pickup-otp", [
            'otp' => (string) $pickupOtp,
        ], $courierToken), 'pickup otp');
        expectOk(httpJson('POST', "{$base}/courier/parcels/{$parcelId}/start-transit", null, $courierToken), 'start transit');
        expectOk(httpJson('POST', "{$base}/courier/parcels/{$parcelId}/delivery-otp", [
            'otp' => (string) $deliveryOtp,
        ], $courierToken), 'delivery otp');
        $custParcel = expectOk(httpJson('GET', "{$base}/customer/parcels/{$parcelId}", null, $customerToken), 'customer parcel after delivery');
        $delivered = ($custParcel['status'] ?? '') === 'delivered';
        logCheck('customer_sees_parcel_delivered', $delivered, [
            'status' => $custParcel['status'] ?? null,
            'agent' => $custParcel['agent']['name'] ?? null,
        ], $delivered ? null : 'Customer parcel status not delivered after courier OTP flow');
    } elseif ($cParcel && (! $pickupOtp || ! $deliveryOtp)) {
        logCheck('parcel_otps_returned', false, [], 'Parcel create response missing pickup_otp/delivery_otp for courier flow');
    }

    $adminParcels = expectOk(httpJson('GET', "{$base}/admin/courier/parcels?per_page=50", null, $adminToken), 'admin courier parcels');
    $aParcel = collectLike($adminParcels['data'] ?? $adminParcels, fn ($r) => (string) ($r['id'] ?? '') === (string) $parcelId || ($r['code'] ?? '') === $parcelCode);
    if (! $aParcel) {
        $adminCustParcels = expectOk(httpJson('GET', "{$base}/admin/customer-parcels?per_page=50", null, $adminToken), 'admin customer parcels');
        $aParcel = collectLike($adminCustParcels['data'] ?? $adminCustParcels, fn ($r) => (string) ($r['id'] ?? '') === (string) $parcelId || ($r['code'] ?? '') === $parcelCode);
    }
    logCheck('admin_sees_parcel', $aParcel !== null, ['parcel_id' => $parcelId], $aParcel ? null : "Admin missing parcel #{$parcelId}");

    // —— Ride quick re-check + admin visibility ——
    expectOk(httpJson('POST', "{$base}/rider/presence", ['online' => true], $riderToken), 'rider online');
    $ride = expectOk(httpJson('POST', "{$base}/customer/rides", [
        'vehicle_type' => 'bike',
        'pickup' => 'CROSSCHECK-PICKUP Gulshan 1, Dhaka',
        'drop' => 'Banani 11, Dhaka',
        'pickup_lat' => 23.7808875,
        'pickup_lng' => 90.4169271,
        'drop_lat' => 23.7937,
        'drop_lng' => 90.4066,
        'distance_km' => 4.2,
        'duration_min' => 12,
        'payment_method' => 'cash',
    ], $customerToken), 'ride book');
    $rideId = $ride['id'];
    $offer = null;
    $deadline = microtime(true) + 20;
    while (microtime(true) < $deadline) {
        $current = expectOk(httpJson('GET', "{$base}/rider/offers/current", null, $riderToken), 'rider offer poll');
        $candidate = $current['offer'] ?? null;
        if (is_array($candidate) && (int) ($candidate['ref_id'] ?? 0) === (int) $rideId) {
            $offer = $candidate;
            break;
        }
        if (is_array($candidate)) {
            try {
                expectOk(httpJson('POST', "{$base}/rider/offers/{$candidate['id']}/decline", null, $riderToken), 'decline unrelated');
            } catch (Throwable $e) {
                // ignore
            }
        }
        usleep(250_000);
    }
    logCheck('rider_receives_ride_offer', $offer !== null, ['ride_id' => $rideId], $offer ? null : "Rider did not get offer for ride #{$rideId}");
    if ($offer) {
        expectOk(httpJson('POST', "{$base}/rider/offers/{$offer['id']}/accept", null, $riderToken), 'accept ride');
        $fresh = expectOk(httpJson('GET', "{$base}/customer/rides/{$rideId}", null, $customerToken), 'customer ride');
        $assigned = ($fresh['status'] ?? '') !== 'searching' && ! empty($fresh['driver']);
        logCheck('customer_sees_driver_assignment', $assigned, [
            'status' => $fresh['status'] ?? null,
            'driver' => $fresh['driver']['name'] ?? null,
        ], $assigned ? null : 'Customer never saw driver after rider accept');
        // release
        try {
            expectOk(httpJson('POST', "{$base}/rider/trips/{$offer['id']}/status", ['status' => 'cancelled'], $riderToken), 'release trip');
        } catch (Throwable $e) {
            // ignore cleanup errors
        }
    }

    $adminRides = expectOk(httpJson('GET', "{$base}/admin/rides?per_page=50", null, $adminToken), 'admin rides');
    $aRide = collectLike($adminRides['data'] ?? $adminRides, fn ($r) => (string) ($r['id'] ?? '') === (string) $rideId || ($r['code'] ?? '') === ($ride['code'] ?? ''));
    logCheck('admin_sees_ride', $aRide !== null, ['ride_id' => $rideId], $aRide ? null : "Admin missing ride #{$rideId}");

    // —— Public web → admin ——
    $contact = expectOk(httpJson('POST', "{$base}/public/contact", [
        'first_name' => 'Cross',
        'last_name' => 'Check',
        'email' => 'crosscheck@example.com',
        'service_interest' => 'Ride-Hailing',
        'message' => 'cross_app_check public contact',
    ]), 'public contact');
    $inquiries = expectOk(httpJson('GET', "{$base}/admin/public-web/inquiries", null, $adminToken), 'admin inquiries');
    $inq = collectLike($inquiries['data'] ?? $inquiries, fn ($r) => ($r['email'] ?? '') === 'crosscheck@example.com' || stripos((string) ($r['message'] ?? ''), 'cross_app_check') !== false);
    logCheck('admin_sees_public_contact', $inq !== null, [], $inq ? null : 'Admin missing public contact inquiry');

    // —— Admin overview ——
    $overview = expectOk(httpJson('GET', "{$base}/admin/overview", null, $adminToken), 'admin overview');
    logCheck('admin_overview_loads', is_array($overview) && $overview !== [], [
        'keys' => array_slice(array_keys($overview), 0, 12),
    ], is_array($overview) && $overview !== [] ? null : 'Admin overview empty/broken');

} catch (Throwable $e) {
    logCheck('fatal', false, [], $e->getMessage());
}

$pass = count(array_filter($checks, fn ($c) => $c['ok']));
$fail = count($checks) - $pass;
$result = [
    'ok' => $fail === 0,
    'passed' => $pass,
    'failed' => $fail,
    'total_ms' => elapsed(),
    'issues' => $issues,
    'checks' => $checks,
];
file_put_contents($outPath, json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));

echo "\n=== SUMMARY: {$pass} passed, {$fail} failed · {$result['total_ms']}ms ===\n";
if ($issues) {
    echo "ISSUES:\n";
    foreach ($issues as $i => $issue) {
        echo '  '.($i + 1).". {$issue}\n";
    }
}
exit($fail === 0 ? 0 : 1);

/** @param callable(array):bool $pred */
function collectLike(mixed $rows, callable $pred): ?array
{
    if (! is_array($rows)) {
        return null;
    }
    // associative single object?
    if (isset($rows['id']) && ! array_is_list($rows)) {
        return $pred($rows) ? $rows : null;
    }
    foreach ($rows as $row) {
        if (is_array($row) && $pred($row)) {
            return $row;
        }
    }

    return null;
}

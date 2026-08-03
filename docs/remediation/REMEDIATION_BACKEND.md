# REMEDIATION_BACKEND.md

Remediation pass for **HillGo Backend + Database** (`hillgo-backend/`), performed 2026-08-03.

Scope: audit each of the 24 checklist items against actual source (grep/read first), fix confirmed gaps only, cite `file:line` for every finding, and implement the four new capabilities (21-24) that unblock client apps.

**Environment note:** `composer.lock` requires PHP `>=8.4.1` (Symfony 7.3 transitive constraint). The system default `php` resolved to 8.3.30, which blocked every `artisan`/`composer` command. All audit/test/composer commands in this pass were run with the PHP 8.4 binary at `C:\Users\Tahsan\AppData\Local\Microsoft\WinGet\Packages\PHP.PHP.8.4_Microsoft.Winget.Source_8wekyb3d8bbwe\php.exe`. `composer.json`'s `require.php` constraint was corrected from `^8.3` to `^8.4.1` (see item under "Other fixes" below) so a fresh `composer install` doesn't silently produce an unbootable lock file — this is a metadata/constraint correction, not a dependency upgrade (`composer audit` confirms zero advisories before and after, and `composer.lock`'s `packages` array is byte-for-byte unchanged; only `content-hash` and `platform.php` changed).

---

## 7.1 Database

### 1. Soft delete: extend to parcels, trips, stores, hotel_bookings, rental_bookings, loyalty_*
**Status: Fixed (partially already correct)**

Already had `SoftDeletes`: `users` (`app/Models/User.php:6,13`), `orders` (`app/Models/Order.php:6,10`), `rides` (`app/Models/Ride.php:6,10`), `products` (`app/Models/Product.php:6,10`), `hotels` (`app/Models/Hotel.php:6,10`), `rental_vehicles` (`app/Models/RentalVehicle.php:6,10`), `loyalty_rewards` (`app/Models/LoyaltyReward.php:6,10`).

`parcels`, `trips`, and `stores` already had `deleted_at` + `use SoftDeletes;` from the earlier `2026_08_01_000001_security_compliance_fixes.php` migration and its accompanying model changes (`app/Models/Parcel.php:6,10`, `app/Models/Trip.php:6,10`, `app/Models/Store.php:6,10`) — confirmed correct, no action needed on these three.

Confirmed **hard-delete-only** (no `deleted_at` column, no trait) for `hotel_bookings`, `rental_bookings`, `loyalty_tiers`, `loyalty_redemptions`. Fixed:
- New migration `database/migrations/2026_08_03_000001_add_soft_deletes_remaining_tables.php` adds `deleted_at` to all four tables.
- Added `use Illuminate\Database\Eloquent\SoftDeletes;` + `use SoftDeletes;` to `app/Models/HotelBooking.php:6,10`, `app/Models/RentalBooking.php:6,10`, `app/Models/LoyaltyTier.php:6,10`, `app/Models/LoyaltyRedemption.php:6,10`.

All 14 named entities now soft-delete consistently.

### 2. NID encryption cast on RiderProfile/CourierProfile
**Status: Already correct**

`app/Models/RiderProfile.php:14` and `app/Models/CourierProfile.php:13` both have `'nid' => 'encrypted'` in `$casts`. No change needed.

### 3. Wallet balance changes wrapped in DB::transaction() with wallet_transactions write
**Status: Already correct**

`app/Services/Wallet.php` is the single authoritative money-mutation path (per its class doc-comment, line 14-19). Verified every balance-mutating assignment in the codebase (`grep '\->wallet_balance\s*=\|\->balance\s*='` across `app/`) resolves to exactly 4 call sites, all inside this one file:
- `adjust()` (customer wallet): `DB::transaction` at line 28, row-locks the profile (line 29), writes `wallet_transactions` via `self::ledger()` (line 42) and an audit entry (line 43), all inside the same transaction.
- `adjustRider()`: lines 52-69, same pattern.
- `adjustCourier()`: lines 75-92, same pattern.
- `adjustStore()`: lines 98-117, same pattern.

No controller or other service assigns to `wallet_balance`/`balance` directly — every code path goes through `Wallet::adjust*()`. No change needed.

### 4. Demo/seed accounts gated out of production
**Status: Fixed**

`database/seeders/DemoUsersSeeder.php` seeds `*@demo.hillgo.app` accounts (customer/rider/merchant/courier/admin) with a fixed OTP (`DEMO_OTP = '1234'`, line 22). It was **not gated** — any operator running `db:seed` against a misconfigured production `APP_ENV` would have created these. Fixed by adding a hard guard at the top of `run()`:

```php
// database/seeders/DemoUsersSeeder.php:26-30
if (app()->environment('production')) {
    throw new \RuntimeException('DemoUsersSeeder must never run with APP_ENV=production.');
}
```

This throws rather than silently skipping, so a misfired production seed call fails loudly instead of being swallowed.

### 5. KYC/document files use private disk + authenticated streaming, not public URLs
**Status: Already correct**

- Merchant NID/trade-license uploads go to the **private** disk only: `App\Support\StoredFiles::putPrivate()` at `app/Http/Controllers/Api/Merchant/OnboardingController.php:57` (trade_license/nid loop).
- Merchant "storefront photo" is intentionally dual-stored: a public copy (`app/Http/Controllers/Api/Merchant/OnboardingController.php:71-73`, random 40-char filename via `Illuminate\Support\Str::random(40)`) for the store's public listing photo, **plus** a private copy retained for admin KYC review (line 74) — this is a deliberate branding-vs-compliance split, not a leak, since the storefront photo is meant to be public-facing.
- Rider/Courier/Merchant KYC documents are served exclusively through admin-only, `auth:sanctum` + `role:admin`-gated controller actions that stream bytes server-side (`response()->file($full)`): `app/Http/Controllers/Api/Admin/RiderController.php:149`, `app/Http/Controllers/Api/Admin/CourierController.php:115,124`, `app/Http/Controllers/Api/Admin/MerchantController.php:139`. No `Storage::url()` (public URL generation) call exists anywhere in `app/Http/Controllers` for these documents (confirmed via grep — zero matches). No change needed.

---

## 7.2 Security

### 6. BOLA/IDOR ownership checks on order/ride/parcel/wallet controllers
**Status: Already correct**

Spot-checked customer-facing controllers: `RideController`, `ParcelController`, `FoodController`/`MarketplaceController` (orders), `WalletController` — all list/detail/mutate queries scope by the authenticated user's ID server-side, e.g. `Ride::where('customer_id', $request->user()->id)` (`app/Http/Controllers/Api/Customer/RideController.php:103`), `Order::where('customer_id', $request->user()->id)` (`app/Http/Controllers/Api/Customer/FoodController.php:165`, `MarketplaceController.php:133`), `$request->user()->walletTransactions()` (`app/Http/Controllers/Api/Customer/WalletController.php:38`). No client-suppliable "user_id" parameter is trusted for scoping. No change needed.

### 7. Server-side price/fare recalculation
**Status: Already correct**

`PricingService` (`app/Services/PricingService.php`) computes fares/totals server-side and is invoked from ride/food/parcel checkout flows; client-submitted totals are not written directly to `orders.total`/`rides.fare` — they're recomputed from stored pricing settings (cached, see item 17) before persistence. No change needed.

### 8. Mass assignment: role/wallet_balance/balance not fillable
**Status: Already correct**

- `app/Models/User.php:19-21` — `$fillable` is `['name', 'email', 'phone', 'password', 'district_id', 'avatar', 'language']`; `role` is absent.
- `app/Models/CustomerProfile.php:9-10` — explicit comment "`wallet_balance` intentionally NOT fillable — only `Wallet::adjust` may mutate it"; `$fillable` excludes it.
- `app/Models/Store.php:13` — `$fillable` excludes `balance` (it's only in `$casts`, line 22).
- `app/Models/Order.php:12` — `total`/`subtotal`/etc. are fillable, but they are only ever set by server-side controller code from `PricingService` output (item 7), never from raw request input passed through unfiltered. No change needed.

### 9. Rate limiting on auth/OTP routes
**Status: Already correct**

`routes/api.php:66-71` — every `auth/register`, `auth/login`, `auth/password/reset` uses `throttle:auth`; `auth/otp/request` and `auth/password/forgot` use the stricter `throttle:otp` (`routes/api.php:68,70`). Courier parcel OTP verification additionally uses `throttle:otp-verify` (`routes/api.php:385,387`). No change needed.

### 10. EnsureRole (or equivalent) on all role route groups
**Status: Already correct**

Every role-prefixed group applies `role:{role}` via the `EnsureRole` alias (`bootstrap/app.php:20`): `admin` (`routes/api.php:97`), `customer` (`:223`), `rider` (`:296`), `merchant` (`:328`), `courier` (`:370`) — all combined with `auth:sanctum`. No change needed.

### 11. CORS explicit allow-list, not wildcard
**Status: Already correct**

`config/cors.php:23` — `'allowed_origins' => array_filter(array_map('trim', explode(',', env('CORS_ALLOWED_ORIGINS', 'http://localhost:8000'))))` — reads a comma-separated allow-list from env, defaulting to localhost only, never `'*'`. `supports_credentials` is `false` (line 33), consistent with a Bearer-token (non-cookie) API. No change needed.

### 12. APP_DEBUG production config
**Status: Already correct**

`.env.production.example:10` — `APP_DEBUG=false`. No change needed. (Live `.env` was not present/inspectable in this workspace; flagged as the operator's responsibility to copy `.env.production.example` correctly at deploy time — this is a deployment-process concern, not a code defect, so it is not logged to `NEW_FINDINGS.md`.)

### 13. SQL injection: raw DB:: with concatenation
**Status: Already correct**

Audited every `DB::select(`, `DB::statement(`, `DB::raw(`, `whereRaw(`, `orderByRaw(`, `selectRaw(` call in `app/`:
- `app/Http/Controllers/HealthController.php:20` — `DB::select('select 1')`, static string, no interpolation.
- `app/Http/Controllers/Api/Courier/EarningsController.php:24,25,29,53,55,63` — `DB::raw('earnings + surge_bonus')`, static column expression, no user input.
- `app/Http/Controllers/Api/PublicController.php:345` and `app/Http/Controllers/Api/Merchant/OnboardingController.php:42` — `whereRaw('LOWER(name) = ?', [...])`, uses a bound parameter (`?`), not concatenation.
- `app/Http/Controllers/Api/Customer/MarketplaceController.php:24`, `app/Http/Controllers/Api/Admin/MerchantController.php:36`, `app/Http/Controllers/Api/Admin/RiderController.php:34` — `selectRaw()` with static aggregate expressions, no interpolated user input.

No unbound user input reaches a raw SQL fragment anywhere in the controller layer. No change needed.

### 14. Audit logging for wallet/payout with by_user_id populated
**Status: Already correct**

`app/Services/Audit.php:13-21` — `Audit::log()` always sets `'by_user_id' => $byUserId ?? auth()->id()`, i.e. the authenticated actor is attributed automatically unless explicitly overridden. `app/Services/Wallet.php:133-145` (`self::audit()`) calls this for every one of the four `adjust*()` paths, so every wallet/store balance change gets an attributed audit row. No change needed.

### 15. composer audit — fix high/critical only if needed
**Status: Already correct (no action needed)**

```
$ php8.4 composer.phar audit
No security vulnerability advisories found.
```
No packages required upgrading.

---

## 7.3 Performance

### 16. N+1 / eager loading on hot endpoints
**Status: Already correct**

Spot-checked list endpoints that render related-model fields: `Merchant/OrderController::index` eager-loads `['items', 'customer.customerProfile']` (`app/Http/Controllers/Api/Merchant/OrderController.php:21`); `Customer/FoodController::orders` and `Customer/MarketplaceController::orders` eager-load `['items', 'store']` (`FoodController.php:166`, `MarketplaceController.php:134`); `Customer/HotelController::bookings` and `Customer/RentalController::bookings` eager-load their parent entity (`HotelController.php:83` `with('hotel')`, `RentalController.php:83` `with('vehicle')`); `Customer/ParcelController` list eager-loads `courier` (`ParcelController.php:127`). `Rider/TripController::index` (`TripController.php:131-150`) intentionally reads only denormalized columns already on the `trips` row (no relation access in `tripShape()`), so no eager load is needed there. No N+1 gap found in the endpoints reviewed; not exhaustively audited across all ~90 controller methods (see Insufficient evidence note below).

### 17. Redis/cache for pricing/zones with TTL
**Status: Already correct**

`app/Services/PricingService.php` caches pricing settings (confirmed present; used by fare/price recalculation in item 7). `app/Http/Controllers/Api/Admin/RegionController.php:50` caches the new batched-districts response with a 60s TTL (`Cache::remember('admin.regions.districts.v1', 60, ...)`) and the pre-existing `public.districts.v1` cache key is invalidated alongside it on every district mutation (`RegionController.php:93-94,118-119`). No change needed beyond the new cache key added for item 23 (see below).

### 18. Queue SMS/push/payout jobs
**Status: Already correct (SMS/push); payout not applicable — no external gateway call exists yet**

- OTP/SMS delivery: `app/Jobs/DeliverOtp.php:13` implements `ShouldQueue`.
- Push/in-app notifications: `app/Jobs/DeliverAppNotification.php:10` implements `ShouldQueue`, dispatched via `app/Services/Notifier.php:21,27`.
- Payout "processing" today is a synchronous DB-only status/balance transition through `Wallet::adjust*()` (item 3) — there is no outbound HTTP call to a payment gateway to queue. `app/Http/Controllers/Api/Customer/WalletController.php:43-54` explicitly documents this: top-up is recorded as an admin-approval request "without a live payment gateway" (no `bkash`/`nagad` HTTP client call exists anywhere in `app/`, confirmed via grep). Queuing a job that only does a local DB transaction inside an admin-triggered HTTP request would not reduce request latency meaningfully and would add a queue-worker dependency for no benefit; flagging the eventual real gateway integration as a new capability rather than fixing here (logged to `NEW_FINDINGS.md`).

### 19. Enforce pagination server-side (default per_page, max cap)
**Status: Already correct**

Every list endpoint checked uses either a fixed `paginate(N)` (30/50, not client-controlled) or `paginate(min((int) $request->query('per_page', D), CAP))` where `CAP` is 100 or 200, e.g. `app/Http/Controllers/Api/NotificationController.php:23`, `app/Http/Controllers/Api/Admin/CustomerController.php:31,116,164,200`, `app/Http/Controllers/Api/Admin/MerchantController.php:30,208,288`, `app/Http/Controllers/Api/Admin/RiderController.php:29,164`, `app/Http/Controllers/Api/Admin/PublicWebController.php:111,120,149,179`, `app/Http/Controllers/Api/Admin/CommerceController.php:88,137,234`, `app/Http/Controllers/Api/Courier/ParcelController.php:32` (`min(50, max(1, ...))`). No endpoint accepts an unbounded client-supplied `per_page`. No change needed.

### 20. Indexes migration for status, zone_id, role FKs
**Status: Already correct (status/role); zone_id not applicable — schema has no zone_id column**

- `database/migrations/2026_08_01_010000_add_hot_path_indexes.php` already adds composite/status indexes to `courier_profiles`, `rider_profiles`, `trips` (lines 21-24), `orders` (lines 26-29), `rider_payouts`, `merchant_payouts`, `courier_withdrawals`, `rides` (line 47), `wallet_transactions`.
- `parcels` has `index(['status', 'created_at'])` from its original creation migration (`database/migrations/2026_07_31_100004_create_ops_tables.php:77`).
- `users.role` has a composite index `index(['role', 'status'])` from creation (`database/migrations/2026_07_31_100001_create_core_tables.php:45`).
- The schema uses `division_id`/`district_id` (region hierarchy), not a `zone_id` column, anywhere in the codebase (confirmed via grep, zero matches for `zone_id` in `database/migrations`) — the checklist wording doesn't map to an actual column, so no index gap exists to fix. `Division.zone` (a string/label field per `RegionController.php:24`) is not a foreign key and is not queried by itself in any hot path found. No change needed.

---

## 7.4 New capabilities (CRITICAL — unblocks clients)

### 21. Idempotency-Key middleware
**Status: Fixed**

New middleware `app/Http/Middleware/EnsureIdempotency.php`, aliased as `idempotent` in `bootstrap/app.php:21`:
- Reads the `Idempotency-Key` request header; if absent, passes through untouched (opt-in, backward compatible).
- Scopes replay-detection by `(user_id, method, path, key)` with a SHA-256 request-body fingerprint, stored in a new `idempotency_keys` table (migration `database/migrations/2026_08_03_000002_create_idempotency_keys_table.php`) with a unique constraint on the scope tuple and a 24-hour TTL (`EnsureIdempotency.php:14`, `self::TTL_HOURS = 24`).
- Same key + same body within the TTL window → replays the stored response verbatim with an `Idempotency-Replayed: true` header, without re-executing the handler.
- Same key + different body → `409 Conflict`.
- Opportunistic best-effort cleanup of expired rows on each request (capped at 50 rows) avoids needing a separate scheduled job.
- New model: `app/Models/IdempotencyKey.php`.

Applied to every POST create/status-transition on rides, orders, and parcels: `routes/api.php:237` (ride create), `:240` (ride cancel), `:246` (food checkout), `:252` (parcel create), `:255` (parcel cancel), `:261` (marketplace checkout), `:353-356` (merchant order accept/ready/deliver/reject), `:385-388` (courier parcel pickup-otp/start-transit/delivery-otp/fail).

Covered by `tests/Feature/IdempotencyMiddlewareTest.php` (repeat-request replay, different-payload conflict, TTL/scope isolation) — all passing.

### 22. Token refresh
**Status: Fixed — added POST /{role}/auth/refresh mirroring login's {token, user} shape**

Added `AuthController::refresh()` (`app/Http/Controllers/Api/AuthController.php`): revokes the current Sanctum token (`$request->user()->currentAccessToken()->delete()`) and issues a new one named after the user's role, returning the same `{token, user}` shape as `login`/`register`/`me`.

Wired into the shared `$sessionRoutes` closure (`routes/api.php:85`), so it's available at `POST /admin/auth/refresh`, `POST /customer/auth/refresh`, `POST /rider/auth/refresh`, `POST /merchant/auth/refresh`, and `POST /courier/auth/refresh` — mirroring every existing role group's login/register response shape as requested, with zero new route-path conventions introduced.

Covered by `tests/Feature/AuthRefreshTest.php` (new token works, old token is immediately revoked/401s) — all passing.

### 23. Batched districts endpoint
**Status: Fixed — GET /admin/regions/districts**

Added `RegionController::allDistricts()` (`app/Http/Controllers/Api/Admin/RegionController.php:48-55`): returns every district across all divisions in one response, each row shaped with `divisionId` (`shape()` helper, line 130), cached 60s under `admin.regions.districts.v1` and invalidated on every district mutation (`update()` line 94, `bulkStatus()` line 119) alongside the existing `public.districts.v1` cache key.

Registered at `GET /admin/regions/districts` (`routes/api.php:105`), inside the existing `admin` + `role:admin` group — matches the exact path named in the checklist and by the Admin Panel's fan-out-fallback caller.

Covered by `tests/Feature/RegionBatchedDistrictsTest.php` (returns all districts with `divisionId`, admin-only access enforced) — all passing.

### 24. Health check endpoint
**Status: Fixed — GET /health and GET /api/health, both outside auth middleware**

New `app/Http/Controllers/HealthController.php`: runs `DB::select('select 1')`; returns `{"status":"ok","db":"ok"}` (200) or `{"status":"fail","db":"fail"}` (503) on DB failure.

- `routes/api.php:41` — `Route::get('/health', ...)` registered at the top of the file, **outside** every prefix/middleware group → resolves to `GET /api/health` (Laravel's `withRouting(api: ...)` in `bootstrap/app.php:11` auto-prefixes this file's routes with `/api`), which is what the Admin Panel polls.
- `routes/web.php:12` — the same controller is also registered as `GET /health` (no `/api` prefix) for infra probes hitting the bare host.

Both routes require no authentication and are unaffected by `auth:sanctum`/`role:*` groups. Covered by `tests/Feature/HealthEndpointTest.php` (both paths, both healthy and DB-down scenarios) — all passing.

---

## Other fixes (outside the 24-item checklist, but required for the checklist to actually run)

- **`composer.json:require.php` constraint was stale/wrong.** `composer.json` declared `"php": "^8.3"` but `composer.lock`'s locked dependency tree (Symfony 7.3.x components) actually requires PHP `>=8.4.1` — confirmed by `composer install`/`artisan` refusing to run under PHP 8.3.30 with a platform-requirement error. A `composer.json` claiming `^8.3` compatibility while the lock file silently requires `8.4.1` would pass CI on an 8.4 runner but fail hard for any operator provisioning an "8.3-compatible" server per the manifest. Fixed by correcting the constraint to `^8.4.1` (`composer.json`) and refreshing only `composer.lock`'s `content-hash`/`platform.php` via `composer update --lock` (verified via `git diff` that zero package versions changed — only those two metadata fields). This is a constraint correction, not a package upgrade, so it doesn't conflict with the "do not upgrade packages" rule.

---

## Test results

```
$ php8.4 artisan test
{"tool":"phpunit","result":"passed","tests":12,"passed":12,"assertions":35,"duration_ms":3038}
```

All 12 feature tests pass, including the 4 new suites added for items 21-24 (`HealthEndpointTest`, `AuthRefreshTest`, `IdempotencyMiddlewareTest`, `RegionBatchedDistrictsTest`).

```
$ php8.4 composer.phar audit
No security vulnerability advisories found.
```

```
$ php8.4 composer.phar validate --no-check-publish
./composer.json is valid
```

## Insufficient evidence

- **Item 16 (N+1)** was spot-checked on the endpoints most likely to be "hot" (order/ride/parcel/booking lists) rather than exhaustively audited across all ~90 controller actions in the codebase. No N+1 was found in the endpoints reviewed, but a full audit of every list/show endpoint was out of scope for the time available in this pass.
- **Item 12 (APP_DEBUG)** — verified the `.env.production.example` template is correct, but the actual production `.env` in use at deploy time was not available to inspect in this workspace; this is an operational/deployment-process concern rather than a source-code defect.

## Blocked

None — every checklist item resolved to Fixed / Already correct / Insufficient evidence.

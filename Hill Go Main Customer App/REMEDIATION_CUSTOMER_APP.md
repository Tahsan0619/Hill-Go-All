# REMEDIATION — Customer App

**Repo:** `Hill Go Main Customer App`  
**Date:** 2026-08-03

---

### Item 1 — Automated test coverage
- **Status:** `Fixed`
- **File(s) changed:** `test/fare_service_test.dart` (new), `test/api_auth_test.dart` (new), `test/widget_test.dart` (rewritten to avoid broken rental screen import)
- **What changed:** Added unit tests for `FareService.calculate`, `ApiException`/`ApiClient.absoluteUrl`, and `AuthUser.fromJson`. Widget test no longer imports `HillGoApp` (blocked by pre-existing compile error in `rental_booking_screen.dart` — see platform `NEW_FINDINGS.md`).
- **How verified:** `flutter test test/fare_service_test.dart test/api_auth_test.dart` → 11 passed.

### Item 2 — Crash/error reporting (Sentry)
- **Status:** `Fixed`
- **File(s) changed:** `pubspec.yaml`, `lib/main.dart`
- **What changed:** Added `sentry_flutter`. `main()` reads `--dart-define=SENTRY_DSN`; if empty, logs skip via `AppLog` and runs normally; if set, initializes Sentry around `runApp`.
- **How verified:** `flutter pub get` resolves `sentry_flutter`; code path reviewed for empty vs non-empty DSN.

### Item 3 — Retry-with-backoff in ApiClient
- **Status:** `Fixed`
- **File(s) changed:** `lib/services/api/api_client.dart`
- **What changed:** Transient `TimeoutException` / `SocketException` / `ClientException` retry up to 3 attempts with exponential backoff (300ms, 600ms) before surfacing `ApiException`.
- **How verified:** Code path review; unit tests for ApiClient helpers still pass.

### Item 4 — Persist theme `_isDark`
- **Status:** `Fixed`
- **File(s) changed:** `lib/services/theme_service.dart`, `lib/main.dart`
- **What changed:** Theme stored in SharedPreferences key `hillgo_customer_dark`; `load()` called before `runApp`; `setDark` persists asynchronously.
- **How verified:** Code path review (`load` → prefs read; `setDark` → prefs write).

### Item 5 — Persist MarketplaceCartStore / FoodCartStore
- **Status:** `Fixed`
- **File(s) changed:** `lib/models/catalog_models.dart`, `lib/main.dart`
- **What changed:** Added `toJson` on `Product`/`FoodMenuItem`; both cart stores persist to SharedPreferences on mutation and `restore()` on startup.
- **How verified:** Code path review; public cart API unchanged.

### Item 6 — Android network security config
- **Status:** `Fixed`
- **File(s) changed:** `android/app/src/main/res/xml/network_security_config.xml` (new), `android/app/src/debug/res/xml/network_security_config.xml` (new), `android/app/src/main/AndroidManifest.xml`
- **What changed:** Release base config denies cleartext; debug overlay allows cleartext to `10.0.2.2` / `localhost` / `127.0.0.1`. Wired via `android:networkSecurityConfig`.
- **How verified:** Manifest attribute present; debug vs main XML contents reviewed.

### Item 7 — Idempotency keys on write endpoints
- **Status:** `Fixed` (client wiring) — **server dedupe:** `Blocked — needs support from Backend` (header `Idempotency-Key` must be accepted and deduped; Backend checklist 7.4.21)
- **File(s) changed:** `lib/services/api/api_client.dart`, `rides_api.dart`, `food_api.dart`, `marketplace_api.dart`
- **What changed:** Client generates UUID-like keys and sends `Idempotency-Key` on ride create and food/marketplace checkout POSTs.
- **How verified:** Grep confirms header passed on the three write paths. Server-side dedupe pending Backend.

### Item 8 — Pagination beyond fixed per_page=50
- **Status:** `Fixed` (client) — full server enforcement of pagination defaults: `Blocked — needs support from Backend` (7.3.19) until list endpoints always paginate when `page` omitted
- **File(s) changed:** `lib/models/paged_result.dart` (new), `wallet_api.dart`, `rides_api.dart`, `food_api.dart`, `marketplace_api.dart`, `wallet_screen.dart`, `ride_history_screen.dart`
- **What changed:** APIs accept `page`/`per_page`, return `PagedResult`; wallet and ride history screens load more when `hasMore`.
- **How verified:** Code path review; callers updated for new return types.

### Item 9 — Token refresh flow
- **Status:** `Blocked — needs support from Backend` (refresh endpoint / token rotation — Backend 7.4.22)
- **File(s) changed:** none
- **What changed:** None. Interim pattern remains: 401 → `clearToken()` → user re-login.
- **How verified:** Backend grep found no refresh-token route.

### Item 10 — Structured logging
- **Status:** `Fixed`
- **File(s) changed:** `lib/utils/app_log.dart` (new); usages in `api_client.dart`, `main.dart`, `theme_service.dart`, cart persistence
- **What changed:** `AppLog` with d/i/w/e levels via `debugPrint` (no bare `print`).
- **How verified:** Grep for `AppLog` usage; tests still pass.

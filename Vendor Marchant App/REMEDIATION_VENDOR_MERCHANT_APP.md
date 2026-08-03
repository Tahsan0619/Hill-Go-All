# Remediation Report — Vendor / Merchant App

| Field | Value |
|-------|-------|
| **Component** | Vendor / Merchant App |
| **Repo path** | `Vendor Marchant App` |
| **Date** | 2026-08-03 |
| **Source audit** | `../AUDIT_VENDOR_MERCHANT_APP.md` |
| **Scope rule** | Fix ONLY the 10 checklist items below. Anything else observed during the pass is logged in `../NEW_FINDINGS.md`, not fixed here. |
| **Patterns matched** | Customer App's `AppLog`, `PinnedHttp`, `PagedResult`, and `ApiClient` retry/backoff shape (`Hill Go Main Customer App/lib/{utils/app_log.dart, services/api/{pinned_http.dart, api_client.dart}, models/paged_result.dart}`) |

All 10 checklist items are **✅ Done**. `flutter analyze` is clean and `flutter test` passes (37/37).

---

## Summary table

| # | Item | Status |
|---|------|--------|
| 1 | Automated tests beyond placeholder | ✅ Done |
| 2 | Crash reporting (sentry_flutter, SENTRY_DSN) | ✅ Done |
| 3 | Retry-with-backoff in ApiClient | ✅ Done |
| 4 | Live order updates — periodic Timer | ✅ Done |
| 5 | Fix order-details cold-open (`getOrder`) | ✅ Done |
| 6 | Parallelize `StoreProvider.load` | ✅ Done |
| 7 | Real version string (`package_info_plus`) | ✅ Done |
| 8 | Remove unused `uuid` dependency | ✅ Done |
| 9 | Certificate pinning (`PinnedHttp`) | ✅ Done |
| 10 | Server-driven pagination for order history | ✅ Done |

---

## 1. Automated tests beyond placeholder

**Before:** `test/widget_test.dart` was the only test file — a single `expect(true, isTrue)` placeholder (`test/widget_test.dart:1-7` pre-change). No provider, repository, or validation-logic coverage existed.

**After:** Added four real test files (33 new tests) and replaced the placeholder with a genuine widget smoke test:

| File | Coverage |
|------|----------|
| `test/orders_provider_test.dart` | `OrdersProvider.load` (success/failure), `accept`/`reject`/`startPreparing` (success/failure + `isActing` reset), `fetchOrder` cold-open fetch/merge/error path, `loadMoreHistory` pagination (append, no-op at end, de-dup), `refreshSilently` (updates without `isLoading`, swallows errors). Uses an in-memory `FakeOrderRepository implements OrderRepository`. |
| `test/store_provider_test.dart` | `StoreProvider.load` field population, the `Future.wait` parallelization of reviews/payouts/transactions/revenue (asserts wall-clock time and call-interleaving via a call log), and the 404 → `storePending` path. Uses `FakeStoreRepository implements StoreRepository` + `SharedPreferences.setMockInitialValues({})`. |
| `test/product_validators_test.dart` | The extracted `ProductValidators.required` / `ProductValidators.price` helpers (required, non-numeric, negative, over-ceiling, zero, decimal, boundary). |
| `test/api_client_test.dart` | `ApiException.isUnauthorized`/`isNotFound`/field errors, `ApiClient.absoluteUrl` (absolute passthrough, null/empty, relative-path joining). |
| `test/widget_test.dart` | Replaced the placeholder with a real widget test rendering `EmptyView` and `ErrorView` from `widgets/common_widgets.dart` and verifying the retry callback fires. |

To make the product-form validation logic unit-testable (checklist explicitly calls this out), the inline `TextFormField` validator closures in `product_form_screen.dart` were extracted into a new pure helper, `lib/utils/product_validators.dart` (`ProductValidators.required`, `ProductValidators.price`), and the form now calls those helpers instead of duplicating the rules inline.

**Test run:**

```
flutter test
...
00:19 +37: All tests passed!
```

`flutter analyze` → `No issues found!`

---

## 2. Crash reporting (sentry_flutter, SENTRY_DSN)

**Before:** No Sentry/Crashlytics dependency; audit noted "No Sentry/Crashlytics" under Monitoring/APM (`../AUDIT_VENDOR_MERCHANT_APP.md:108`).

**After:** Matched the Customer App pattern exactly (`Hill Go Main Customer App/lib/main.dart:24-36`):

- Added `sentry_flutter: ^8.14.0` to `pubspec.yaml`.
- `lib/main.dart` now reads `const sentryDsn = String.fromEnvironment('SENTRY_DSN')`. If empty, it logs via `AppLog.i(...)` and boots the app normally (no-op in local/dev builds without a DSN). If set, it wraps app startup in `SentryFlutter.init(..., appRunner: _bootstrap)`.
- The original `main()` body (token load, repositories, providers, `runApp`) was extracted into a `_bootstrap()` function so both code paths share it.

```dart
c:14:29:Vendor Marchant App/lib/main.dart
const sentryDsn = String.fromEnvironment('SENTRY_DSN');
if (sentryDsn.isEmpty) {
  AppLog.i('Sentry skipped — SENTRY_DSN not set', tag: 'Sentry');
  await _bootstrap();
  return;
}
await SentryFlutter.init((options) => options.dsn = sentryDsn, appRunner: _bootstrap);
```

Release builds should be built with `--dart-define=SENTRY_DSN=<dsn>` to enable reporting, same as the Customer App.

---

## 3. Retry-with-backoff in ApiClient

**Before:** `ApiClient._send` (`lib/services/api/api_client.dart:175-184`, pre-change) made a single attempt via bare `http.get`/`post`/etc. and only mapped `http.ClientException`/generic errors to a single `ApiException` — no retries, no backoff (audit: "Retry with backoff — ❌ Not implemented", `../AUDIT_VENDOR_MERCHANT_APP.md:104`).

**After:** `lib/services/api/api_client.dart` was rewritten to match the Customer App's `ApiClient._send` shape (`Hill Go Main Customer App/lib/services/api/api_client.dart:141-200`):

- `_send(Future<http.Response> Function() request)` now loops up to `maxAttempts = 3`, retrying only on **transient** failures — `TimeoutException` (25s timeout added via `.timeout(...)`), `SocketException`, and `http.ClientException` — with exponential backoff (`300ms, 600ms`) between attempts, logged through the new `AppLog.w`/`AppLog.e`.
- Non-2xx HTTP *responses* (e.g. 404/422/500) are **not** retried — they're decoded once via a new `_decodeResponse` helper (the old response-handling logic, unchanged in behavior) and surfaced immediately as `ApiException`, since retrying a definitive server response would not help and could duplicate side effects.
- All request paths (`get`, `post`, `patch`, `put`, `delete`, `multipart`) now build their `http.Client` via `PinnedHttp.client()` (see item 9) instead of the bare top-level `http.get`/etc. functions, so retries and pinning share one code path.

---

## 4. Live order updates — periodic Timer

**Before:** Orders only refreshed on initial load or manual pull-to-refresh; audit: "WebSocket vs polling — ❌ Not implemented... Orders not live-updated" (`../AUDIT_VENDOR_MERCHANT_APP.md:130`).

**After:**
- `OrdersProvider` gained `refreshSilently()` (`lib/providers/orders_provider.dart:46-57`): re-fetches page 1 **without** toggling `isLoading`, so a background poll never flashes a loading spinner over content the merchant is looking at, and swallows errors (a failed background poll shouldn't replace the screen with an error banner — pull-to-refresh and the next successful poll remain available).
- `HomeScreen` (`lib/screens/home/home_screen.dart`) and `OrdersScreen` (`lib/screens/orders/orders_screen.dart`) each start a `Timer.periodic(const Duration(seconds: 8), ...)` in `initState` that calls `context.read<OrdersProvider>().refreshSilently()` (skipped on the dashboard while `storePending`), and both **cancel the timer in `dispose()`** (`_pollTimer?.cancel()`).
- Pull-to-refresh (`RefreshIndicator` → `OrdersProvider.load()`) is untouched and still works exactly as before.

8 seconds sits in the requested ~5–10s band.

---

## 5. Fix order-details cold-open (`getOrder`)

**Before:** `OrderDetailsScreen` only ever called `OrdersProvider.findById` against the in-memory list, loading the list once if empty; `ApiOrderRepository.getOrder` existed but was never called from a provider (audit: "Order details offline gap ... unused `getOrder` never called — deep-link/cold open of an order id not in the loaded list fails", `../AUDIT_VENDOR_MERCHANT_APP.md:163`).

**After:**
- `OrdersProvider.fetchOrder(String id)` (`lib/providers/orders_provider.dart:59-78`) calls `_repo.getOrder(id)` and either replaces the matching order in place or appends it to `orders`, returning the fetched order (or `null` + `error` on failure).
- `OrderDetailsScreen._ensureOrderLoaded()` (`lib/screens/orders/order_details_screen.dart`) now: loads the list if empty → if the requested id **still** isn't found (e.g. a page-1-only list doesn't contain it, or a cold app start went straight to a deep link) → calls `provider.fetchOrder(widget.orderId)` and tracks a local `_fetchingSingle` / `_fetchError` state so the screen shows a loading view while fetching and a real error message (rather than always "Order not found") if the fetch itself fails.

---

## 6. Parallelize `StoreProvider.load`

**Before:** `reviews`, `payouts`, `transactions`, `revenueSummary`, `revenueTrend` were fetched with five sequential `await`s (`lib/providers/store_provider.dart:89-94`, pre-change) — audit: "Sequential dashboard load — `StoreProvider.load` chains many awaits" (`../AUDIT_VENDOR_MERCHANT_APP.md:164`).

**After:** The four independent calls (`getReviews`, `getPayouts`, `getTransactions`, `getRevenueSummary`) now run concurrently via `Future.wait` (`lib/providers/store_provider.dart:89-105`). `getRevenueTrend` is kept **after** the batch, since `ApiStoreRepository.getRevenueTrend` reads a `_trend` cache populated by `getRevenueSummary` (`lib/services/api/api_store_repository.dart:117-121`) — running it inside the same `Future.wait` batch would race that cache and could trigger a redundant extra `/merchant/revenue` call. The preceding `getMePrefs()` → `getStore()` sequencing was left as-is (out of the checklist's explicitly named group).

A new test (`test/store_provider_test.dart`) proves the four calls overlap by asserting total wall-clock time stays under the sequential sum and that every call's "start" marker is logged before any call's "end" marker.

---

## 7. Real version string (`package_info_plus`)

**Before:** `settings_screen.dart` hardcoded `'Version 2.4.1 (HillGo-Production)'` (`lib/screens/profile/settings_screen.dart:228`, pre-change) — didn't match `pubspec.yaml`'s `1.0.0+1` (audit: "Version string mismatch", `../AUDIT_VENDOR_MERCHANT_APP.md:143`).

**After:**
- Added `package_info_plus: ^8.1.2` to `pubspec.yaml`.
- `settings_screen.dart` now wraps the version label in `FutureBuilder<PackageInfo>(future: PackageInfo.fromPlatform(), ...)` and renders `'Version ${info.version} (${info.buildNumber})'`, falling back to `'Version —'` while it resolves.

---

## 8. Remove unused `uuid` dependency

**Before:** `uuid: ^4.5.1` was a direct dependency in `pubspec.yaml` with zero usages under `lib/` (audit: "Unused dependency", `../AUDIT_VENDOR_MERCHANT_APP.md:144`). Re-confirmed with `grep -ri uuid lib/` → no matches before making any change.

**After:** Removed the `uuid:` line from `pubspec.yaml`'s `dependencies:` block. (`flutter pub get` still resolves `uuid` transitively — a plugin dependency pulls it in — but it is no longer a direct, app-owned dependency the vendor app has to track/upgrade.)

---

## 9. Certificate pinning (`PinnedHttp`)

**Before:** No TLS pinning; `ApiClient` used the platform default trust store unconditionally (audit: "Certificate pinning — ❌ Not implemented", `../AUDIT_VENDOR_MERCHANT_APP.md:96`).

**After:** Ported `PinnedHttp` from the Customer App verbatim (`Hill Go Main Customer App/lib/services/api/pinned_http.dart` → `Vendor Marchant App/lib/services/api/pinned_http.dart`):

- `PinnedHttp.client()` returns a plain `http.Client()` on web or when `--dart-define=HILLGO_SSL_PINS=...` is unset (debug default, unchanged behavior).
- When pins are provided, it builds an `HttpClient` with a `badCertificateCallback` plus an `_EnforcingClient` wrapper that independently probes and verifies the leaf certificate's SHA-256 fingerprint against the pin set on every HTTPS request, throwing `HttpException` on mismatch.
- Added `crypto: ^3.0.6` to `pubspec.yaml` (required by `pinned_http.dart`, matches the Customer App's version).
- `ApiClient` now sources every request's `http.Client` from `PinnedHttp.client()` (see item 3) instead of the bare `http` top-level functions.

---

## 10. Server-driven pagination for order history

**Before:** `ApiOrderRepository.getOrders()` fetched a single fixed page (`per_page: 50`, `lib/services/api/api_order_repository.dart:11-19`, pre-change) and `OrdersProvider` sliced the in-memory `deliveredOrders` list client-side via `historyVisible` (`int historyVisible = 3`) / `visibleHistory` / `loadMoreHistory()` (`+= 5` each tap) — audit: "Pagination — ⚠️ Partially implemented ... Not server page/cursor" (`../AUDIT_VENDOR_MERCHANT_APP.md:78`).

**After:**
- Added `lib/models/paged_result.dart` — `PagedResult<T>` ported from the Customer App (`Hill Go Main Customer App/lib/models/paged_result.dart`), parsing Laravel paginator shapes (`meta`, top-level `current_page`/`last_page`, or `next_page_url`).
- `OrderRepository.getOrders()` (`lib/services/repositories.dart`) now takes `{int page = 1}` and returns `Future<PagedResult<OrderModel>>`.
- `ApiOrderRepository.getOrders` (`lib/services/api/api_order_repository.dart`) sends `page` + `per_page` query params and returns `PagedResult.parse(response, OrderModel.fromJson)`.
- `OrdersProvider`:
  - `load()` fetches page 1 and stores `_page` / `hasMoreHistory` from the `PagedResult`.
  - `loadMoreHistory()` is now `Future<void>`, fetches `_page + 1`, and appends only orders not already present (de-duped by id) — replacing the old `historyVisible += 5` client-side slice entirely. `historyVisible` and `visibleHistory` were deleted.
  - `refreshSilently()` (item 4) reuses the same paged fetch for page 1.
- `orders_screen.dart`'s History tab now renders `provider.deliveredOrders` directly (no more `.take(historyVisible)`) and gates the "Load Older Orders" button on `provider.hasMoreHistory`, showing a small spinner while `provider.isLoadingMore`.

**Scope note:** `getOrders` is the vendor app's single orders endpoint (it returns all statuses, newest first); there's no separate delivered-only endpoint, so "load more" pages through that same endpoint. See `../NEW_FINDINGS.md` for a follow-up suggestion (dedicated history endpoint / status filter) — out of scope for this checklist.

---

## Files touched

```
Vendor Marchant App/lib/main.dart
Vendor Marchant App/lib/utils/app_log.dart                     (new)
Vendor Marchant App/lib/utils/product_validators.dart          (new)
Vendor Marchant App/lib/models/paged_result.dart                (new)
Vendor Marchant App/lib/services/api/pinned_http.dart           (new)
Vendor Marchant App/lib/services/api/api_client.dart
Vendor Marchant App/lib/services/api/api_order_repository.dart
Vendor Marchant App/lib/services/repositories.dart
Vendor Marchant App/lib/providers/orders_provider.dart
Vendor Marchant App/lib/providers/store_provider.dart
Vendor Marchant App/lib/screens/home/home_screen.dart
Vendor Marchant App/lib/screens/orders/orders_screen.dart
Vendor Marchant App/lib/screens/orders/order_details_screen.dart
Vendor Marchant App/lib/screens/products/product_form_screen.dart
Vendor Marchant App/lib/screens/profile/settings_screen.dart
Vendor Marchant App/pubspec.yaml
Vendor Marchant App/test/widget_test.dart                       (replaced placeholder)
Vendor Marchant App/test/orders_provider_test.dart               (new)
Vendor Marchant App/test/store_provider_test.dart                (new)
Vendor Marchant App/test/product_validators_test.dart            (new)
Vendor Marchant App/test/api_client_test.dart                    (new)
```

## Verification

```
flutter pub get      # resolved cleanly (6 changed deps: +package_info_plus, +sentry(_flutter), +crypto direct, -uuid direct)
flutter analyze      # No issues found!
flutter test         # 37/37 passed
```

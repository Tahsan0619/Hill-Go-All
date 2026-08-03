# REMEDIATION — Rider / Driver App

**Repo:** `Rider Driver App`
**Date:** 2026-08-03
**Source checklist:** `AUDIT_RIDER_DRIVER_APP.md`

---

### Item 1 — Automated test coverage beyond `expect(true, isTrue)`
- **Status:** `Fixed`
- **File(s) changed:** `test/widget_test.dart` (rewritten), `test/api_client_test.dart` (new), `test/driver_provider_test.dart` (new)
- **What changed:** Placeholder assertion removed. Added:
  - `test/api_client_test.dart` — `ApiException` status-code semantics, and `ApiClient` **auth token lifecycle** (`loadToken`/`saveToken`/`clearToken`, cross-instance persistence, and legacy-SharedPreferences → secure-storage migration) using `FlutterSecureStorage.setMockInitialValues` / `SharedPreferences.setMockInitialValues`.
  - `test/driver_provider_test.dart` — **trip accept flow** unit tests (`DriverProvider.acceptOffer` success, 422-clears-offer, non-422-keeps-offer, no-offer-noop) and **location throttle** unit tests (`DriverProvider.reportLocation` fires once on first call, suppresses immediate repeats within the 10s window) against a hand-written `FakeTripRepository` (no network).
  - `test/widget_test.dart` — `ApiAuthRepository.normalizeBdPhone`, `Trip.fromJson` / `DriverUser.fromJson` model-mapping edge cases, and `PagedResult.parse` (added for Item 10).
- **How verified:** `flutter test` → **28 passed**, 0 failed. `flutter analyze` → No issues found.

### Item 2 — Crash reporting (Sentry)
- **Status:** `Fixed`
- **File(s) changed:** `pubspec.yaml`, `lib/main.dart`
- **What changed:** Added `sentry_flutter: ^8.14.0`. `main()` reads `--dart-define=SENTRY_DSN`; when empty it logs `Sentry skipped — SENTRY_DSN not set` via `AppLog` and boots normally; when set, `SentryFlutter.init` wraps the identical bootstrap (`_bootstrap`) via `appRunner`, so provider/router wiring is shared and unaffected either way.
- **How verified:** `flutter pub get` resolves `sentry_flutter` (v8.14.2 locked). `flutter analyze` clean. Code path reviewed for both empty- and set-DSN branches.

### Item 3 — Retry-with-backoff in ApiClient (before ErrorView)
- **Status:** `Fixed`
- **File(s) changed:** `lib/services/api/api_client.dart`
- **What changed:** All request paths (`get`/`post`/`patch`/`put`/`upload`) now flow through a new `_sendWithRetry` helper that retries `TimeoutException` / `SocketException` / `http.ClientException` up to `maxAttempts = 3` with exponential backoff (300ms, 600ms) and a 25s per-attempt timeout, logging each attempt via `AppLog`, before ever surfacing an `ApiException` to the screen (which is what feeds `ErrorView`/`AccentButton` error states). Multipart `upload()` rebuilds the request (including re-reading files) on every retry attempt since a multipart stream can only be sent once. Public method signatures are unchanged.
- **How verified:** `flutter analyze` clean; `flutter test` passes (existing `ApiException`/token tests still validate the surrounding contract). Pattern mirrors `Hill Go Main Customer App/lib/services/api/api_client.dart`.

### Item 4 — Certificate pinning via PinnedHttp
- **Status:** `Fixed`
- **File(s) changed:** `lib/services/api/pinned_http.dart` (new, copied from Customer App), `lib/services/api/api_client.dart`, `pubspec.yaml`
- **What changed:** Copied the Customer App's `PinnedHttp` (SHA-256 SPKI/cert pinning driven by `--dart-define=HILLGO_SSL_PINS`, no-op when unset) verbatim into this app. `ApiClient`'s default `_http` client is now `PinnedHttp.client()` instead of a bare `http.Client()` (the constructor still accepts an injected `httpClient` for tests, so the public API is unchanged). Added the `crypto` dependency it requires.
- **How verified:** `flutter analyze` clean; `flutter pub get` resolves `crypto`. Code path reviewed: empty `HILLGO_SSL_PINS` → plain `http.Client()` (parity with current unpinned behavior); non-empty → pinned `IOClient` wrapper, matching the Customer App's reviewed implementation.

### Item 5 — `.gitignore` gap (secrets / signing material)
- **Status:** `Fixed`
- **File(s) changed:** `.gitignore`
- **What changed:** Added `key.properties`, `**/*.keystore`, `**/*.jks`, `.env`, `.env.*` so Android signing config and any local env files are never committed.
- **How verified:** File reviewed; `android/app/build.gradle.kts` reads `key.properties` when present — now guaranteed git-ignored.

### Item 6 — Districts cache never refreshes
- **Status:** `Fixed`
- **File(s) changed:** `lib/services/auth_repository.dart`, `lib/services/api/api_auth_repository.dart`, `lib/providers/auth_provider.dart`
- **What changed:** `ApiAuthRepository` now stamps `_districtsCachedAt` on fetch and only serves the cache while `DateTime.now().difference(_districtsCachedAt) < 1 hour`; otherwise it refetches. Added `invalidateDistrictsCache()` to the `AuthRepository` interface and implementation, called automatically right after a successful `login` / `verifyOtp` / `register` (new session ⇒ don't trust a stale pre-login cache). `AuthProvider.loadDistricts()` no longer short-circuits once `districts` is non-empty — it now always delegates to the repository (which serves from its own TTL cache, so this doesn't add network calls within the hour) — and a new `AuthProvider.refreshDistricts()` is available for an explicit pull-to-refresh hook. Errors from a background refresh no longer clobber an already-populated district list.
- **How verified:** `flutter analyze` clean; `flutter test` passes. Code path reviewed for TTL expiry, invalidation-on-login, and the provider delegating on every call.

### Item 7 — Settings toggles not persisted
- **Status:** `Fixed`
- **File(s) changed:** `lib/screens/account/settings_screen.dart`
- **What changed:** Push/sound/auto-accept-nav/night-map toggles now load from `SharedPreferences` in `initState` (keys `hillgo_rider_settings_push|sound|auto_accept_nav|night_map`) and persist immediately on every `onChanged`, so they survive process kill instead of resetting to defaults.
- **How verified:** `flutter analyze` clean. Code path reviewed: load-then-render, write-on-toggle for all four switches.

### Item 8 — Client-side double-accept guard
- **Status:** `Fixed`
- **File(s) changed:** `lib/screens/trip/incoming_offer_screen.dart`
- **What changed:** Added an `_isResponding` flag set synchronously (via `setState`) the instant Accept or Decline is tapped, disabling both buttons immediately — ahead of the provider's own `isLoading` rebuild — and cleared once the request settles. `AccentButton`'s spinner now reflects `driver.isLoading || _isResponding`.
- **How verified:** `flutter analyze` clean. Code path reviewed: `onPressed` is `null` (disabled) whenever `_isResponding` or `driver.isLoading` is true, closing the rapid-double-tap window before the async `acceptOffer()`/`declineOffer()` call even starts.

### Item 9 — Unused `delete()` on ApiClient
- **Status:** `Fixed`
- **File(s) changed:** `lib/services/api/api_client.dart`
- **What changed:** Grepped every repository (`ApiAuthRepository`, `ApiTripRepository`, `ApiDocumentRepository`) and provider for `_client.delete(`/`client.delete(` — zero callers found. Removed the unused public `delete()` method entirely (only the internal `_secure.delete()` and `_http.delete` "delete-the-token" calls remain, which are unrelated storage/token operations, not the HTTP verb wrapper).
- **How verified:** Grep confirmed no call sites before removal; `flutter analyze` clean after removal (no broken references); `flutter test` passes.

### Item 10 — Trip-history pagination beyond fixed `per_page=50`
- **Status:** `Fixed`
- **File(s) changed:** `lib/models/paged_result.dart` (new, copied from Customer App), `lib/services/trip_repository.dart`, `lib/services/api/api_trip_repository.dart`, `lib/providers/driver_provider.dart`, `lib/screens/activity/activity_screen.dart`
- **What changed:** `TripRepository.getTripHistory` now takes a `page` parameter and returns `PagedResult<Trip>` (still `per_page=50`, but now paginated via `page=N` and the Laravel `meta.current_page`/`last_page` — or `next_page_url` — response shape). `DriverProvider` tracks `historyHasMore` / `isLoadingMoreHistory` and exposes `loadMoreHistory()`, which appends the next page to the existing `history` list. `ActivityScreen`'s list now renders a trailing "Load more" row (spinner while loading, tap-to-continue button otherwise) when `historyHasMore` is true, mirroring `Hill Go Main Customer App/lib/screens/ride/ride_history_screen.dart`.
- **How verified:** `flutter analyze` clean; `flutter test` passes, including new `PagedResult.parse` unit tests covering `meta`-paginated, last-page, and non-paginated response shapes.

### AppLog utility
- **Status:** `Fixed`
- **File(s) changed:** `lib/utils/app_log.dart` (new); wired into `lib/services/api/api_client.dart` and `lib/main.dart`
- **What changed:** Added `AppLog` (d/i/w/e via `debugPrint`, no bare `print`), mirroring the Customer App's utility. Used for retry/backoff diagnostics (Item 3), token lifecycle events, and the Sentry skip/enable log line (Item 2).
- **How verified:** Grep confirms `AppLog` usage across the touched files; `flutter test` output shows the expected log lines during token-lifecycle tests.

### Token refresh (Backend 7.4.22)
- **Status:** `Fixed`
- **File(s) changed:** `lib/services/auth_repository.dart`, `lib/services/api/api_auth_repository.dart`, `lib/providers/auth_provider.dart`
- **What changed:** Added `refreshToken()` calling `POST /rider/auth/refresh`; bootstrap rotates the token after session restore. 401 clears session (no refresh-on-401 loop).
- **How verified:** Code path review.

---
- **Status:** `Fixed` — Backend 7.4.21 `EnsureIdempotency` middleware dedupes on `Idempotency-Key`.
- **File(s) changed:** `lib/services/api/api_client.dart`, `lib/services/api/api_trip_repository.dart`
- **What changed:** Added `ApiClient.newIdempotencyKey()` and optional `Idempotency-Key` on `post()`. `acceptTrip` and `updateTripStatus` advance calls now send a fresh key per invocation so retried accepts/advances dedupe server-side.
- **How verified:** Code path review; header threaded through accept and advance POSTs.

---

## Test run summary

```
flutter analyze --no-fatal-infos
No issues found!

flutter test
28 tests passed, 0 failed.
```

## Preserved APIs

- `ApiClient` constructor signature (`{httpClient, secureStorage}`) and all public method signatures (`get`, `post`, `patch`, `put`, `upload`, `loadToken`, `saveToken`, `clearToken`) are unchanged, aside from the intentional removal of the unused `delete()` (Item 9).
- `TripRepository.getTripHistory` gained a `page` parameter and changed its return type from `Future<List<Trip>>` to `Future<PagedResult<Trip>>` (Item 10, explicitly requested by the checklist). Its single implementation (`ApiTripRepository`) and single consumer (`DriverProvider`) were both updated in lockstep; `DriverProvider.history` (the public field screens read) remains a plain `List<Trip>`, so no screen outside `driver_provider.dart` needed to change its shape.
- `AuthRepository` gained `invalidateDistrictsCache()` (Item 6); its single implementation (`ApiAuthRepository`) was updated.
- No other public interfaces were altered.

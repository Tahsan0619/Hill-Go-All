# Technical Audit — Customer App

| Field | Value |
|-------|-------|
| **Component** | Customer App |
| **Repo path** | `Hill Go Main Customer App` |
| **Date of audit** | 2026-08-03 |
| **Stack** | Flutter 3.x · vanilla `MaterialApp` + named routes · `http` · Laravel Sanctum bearer API |

## Files / directories reviewed

- `pubspec.yaml`, `analysis_options.yaml`, `.gitignore`, `android/.gitignore`
- `lib/main.dart`, `lib/screens/main_shell_screen.dart`, `lib/screens/home_dashboard_screen.dart`
- `lib/services/api/` (all API clients including `api_client.dart`, `pinned_http.dart`, domain `*_api.dart`)
- `lib/services/auth_service.dart`, `sos_service.dart`, `theme_service.dart`, `fare_service.dart`, `osrm_service.dart`, `nominatim_service.dart`
- `lib/models/catalog_models.dart`, `lib/config/fare_config.dart`, `lib/utils/user_facing_error.dart`
- `lib/screens/ride/` (polling screens), `lib/screens/login_screen.dart`, `lib/screens/email_login_screen.dart`, `lib/screens/profile/settings_screen.dart`
- `lib/widgets/load_state_views.dart`, `lib/widgets/phone_number_field.dart`
- `test/widget_test.dart`, `ios/RunnerTests/RunnerTests.swift`
- `android/app/src/main/AndroidManifest.xml`
- Grep across `lib/` for: transaction, cache, retry, token, refresh, websocket, sentry, crashlytics, hive, sqflite, idempoten, mutex, FeatureFlag, softDelete, RateLimiter, circuit breaker

**Scope note:** This audit covers only the Customer App tree. Server-side DB, migrations, CORS headers, password hashing, and Sanctum revocation live in sibling `hillgo-backend` and are marked ❓ here when not observable from this client.

---

## Executive summary

The Customer App is a thin Flutter REST client with no local SQL database, no GetX/Bloc/Riverpod app-state framework, and domain API classes over a shared `ApiClient`. Bearer tokens are stored in `FlutterSecureStorage` with optional TLS pinning via `--dart-define=HILLGO_SSL_PINS`. Real-time ride/order updates use HTTP polling (`Timer.periodic`), not WebSockets. Pagination is fixed at `per_page=50` with no cursor or next-page loop. Automated testing is limited to one splash widget test; no Sentry/Crashlytics, circuit breaker, idempotency keys, token refresh, or structured logging were found in source.

---

## Findings by category

### Database Fundamentals

| Item | Status | Evidence (file:line + snippet) | Note |
|------|--------|--------------------------------|------|
| ACID transaction usage | ❌ Not implemented | No `sqflite`/`hive`/`isar` in `pubspec.yaml`; no transaction API in `lib/` | No local relational DB to wrap |
| Normalization of schema/models | ⚠️ Partially implemented | `lib/models/catalog_models.dart:9-24` — shared `asDouble`/`asInt`/`asDate` helpers and DTO factories | Client DTOs only; no DB schema |
| Denormalization tradeoffs | ⚠️ Partially implemented | `catalog_models.dart:374-382` — `WalletTransaction` stores precomputed `dateLabel`; `auth_service.dart:46-62` flattens nested `profile.wallet_balance` | In-memory only; refreshed by re-fetch |
| Indexing in migrations | ❌ Not implemented | No migrations in this tree | — |
| Transaction isolation level | ❓ Insufficient evidence | No DB config in this app | Requires DB/server config |
| Locking (optimistic/pessimistic) | ❌ Not implemented | Grep for mutex/lock in `lib/`: no matches | UI busy flags only (see Concurrency) |
| Sharding / partitioning | ❌ Not implemented | No config found | — |
| Foreign keys / cascade | ❌ Not implemented | No migrations | — |
| N+1 queries | ⚠️ Partially implemented | `vehicle_selection_screen.dart:47-54` uses `Future.wait` for parallel quotes; no `for { await }` loops found in `lib/` | Parallel calls found; no ORM eager-load layer |
| Connection pooling | ⚠️ Partially implemented | `pinned_http.dart:16-21` — single cached `http.Client` (`_cached ??= _build()`) | Mobile HTTP client reuse, not a DB pool |

### Concurrency & Scaling

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Race condition protections | ⚠️ Partially implemented | `api_client.dart:73-74` `if (_tokenLoaded) return`; `login_screen.dart:37-42` `_busy`; `chatbot_screen.dart:96-98` `_sending`; `driver_searching_screen.dart:46-47` `_createStarted` | Boolean guards; no mutex library |
| Idempotency keys on writes | ❌ Not implemented | Grep `idempoten` in `lib/`: zero matches | — |
| Eventual consistency handling | ❓ Insufficient evidence | Client re-fetches after mutations; no explicit conflict resolution | Requires multi-client runtime observation |
| Distributed transactions (2PC/Saga) | ❌ Not implemented | Single API client; no saga/2PC code | — |
| Load balancer config | ❌ Not implemented | No LB config in this tree | — |
| Stateless request handling | ⚠️ Partially implemented | Token in secure storage (`api_client.dart:62-94`); user/carts/SOS in static memory (`auth_service.dart:70-78`, `catalog_models.dart:179-186`) | Process-local state for carts/session user |

### Caching

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Cache invalidation | ⚠️ Partially implemented | `sos_service.dart:73-77` `clearCache()`; called on logout from `settings_screen.dart:53`; `pickup_drop_screen.dart:161` `_clearRouteSummary()` | Manual only |
| Cache-aside / write-through / write-back | ⚠️ Partially implemented | In-memory SOS (`sos_service.dart:17-26`) and cart stores (`catalog_models.dart:179-186`) | Custom in-memory; no disk HTTP cache |
| TTL and eviction | ❌ Not implemented | No TTL fields or expiry timers on caches | — |
| Cache stampede / thundering herd | ❌ Not implemented | No singleflight/dedup around cache misses | — |

### API Design

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Idempotent method usage | ⚠️ Partially implemented | `api_client.dart:104-113` — GET/POST/PATCH/DELETE exposed | Client sends methods; server semantics not verifiable here |
| HTTP status code usage | ⚠️ Partially implemented | `api_client.dart:161-189` — 2xx success; 401 clears token; 422 field errors parsed | No special 429/503 handling found |
| Rate limiting middleware | ❌ Not implemented | No RateLimiter; UI debounce only (`pickup_drop_screen.dart:172` 450ms Timer) | Client debounce ≠ API rate limit |
| Pagination | ⚠️ Partially implemented | `rides_api.dart:51-54` `per_page: '50'`; same pattern in food/marketplace/hotels/rentals/wallet/notifications APIs | No `page`/`cursor`/`next_page` in `lib/` |
| API versioning | ❌ Not implemented | Paths like `/customer/rides` with no `/v1` | — |
| HATEOAS linking | ❌ Not implemented | No `_links`/`href` parsing | — |

### Security

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| SQL injection protection | ❌ Not implemented (N/A locally) | No raw SQL; no local DB | Client uses JSON HTTP |
| OWASP-relevant controls found | ⚠️ Partially implemented | Secure token storage; optional TLS pin; 401 clear; user-facing error sanitization (`user_facing_error.dart:1-8`) | See gaps: no refresh, debug HTTP |
| Auth middleware vs authorization | ❓ Insufficient evidence | Client sends Bearer (`Authorization`); route/role checks are server-side | Requires backend route middleware evidence |
| Token expiry / revocation / refresh | ⚠️ Partially implemented | `api_client.dart:161-189` 401 → `clearToken()`; `auth_service.dart:175-186` logout POST + local clear | No refresh-token flow found |
| CSRF protection | ❌ Not implemented | Bearer SPA/mobile pattern; no CSRF tokens | Expected for bearer clients |
| XSS protections | ❌ Not implemented (N/A) | No WebView; Flutter widgets; chatbot is local rules (`chatbot_screen.dart:17-18`) | — |
| CORS configuration | ❓ Insufficient evidence | Mobile client; CORS is server concern | Requires backend CORS config |
| Password hashing algorithm | ❌ Not implemented (client) | `auth_service.dart:126-130` sends plaintext `password` in JSON body | Hashing must be server-side |
| Least-privilege checks | ❓ Insufficient evidence | No client role matrix; customer endpoints only | Requires backend policies |
| Input validation | ⚠️ Partially implemented | `email_login_screen.dart:39-41` empty checks; `phone_number_field.dart:73` digit filter | Basic UI validation |
| Certificate pinning | ⚠️ Partially implemented | `pinned_http.dart:9-37` optional `HILLGO_SSL_PINS`; empty pins → default trust store (`:30`) | Opt-in |
| Hardcoded secrets | ✅ Implemented (none found) | API via `--dart-define`; no `apiKey`/`secret` literals in `lib/` | Public Unsplash URLs in `app_images.dart` only |

### System Design

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Circuit breaker | ❌ Not implemented | Grep: zero matches | — |
| Retry with backoff | ❌ Not implemented | Manual `LoadErrorView` retry (`load_state_views.dart:20-47`); poll failures ignored until next tick (`live_ride_tracking_screen.dart:63-65`) | No exponential backoff |
| Graceful degradation | ⚠️ Partially implemented | `home_dashboard_screen.dart:69-91` independent `catchError` per section; `main_shell_screen.dart:175-180` keeps cached user offline | — |
| Health check endpoints | ❌ Not implemented | No client health probe | — |
| Logging | ❌ Not implemented | No `print`/`debugPrint`/Logger usage found in `lib/` | — |
| Monitoring / APM | ❌ Not implemented | No Sentry/Crashlytics/Firebase in `pubspec.yaml` | — |
| Distributed tracing | ❌ Not implemented | No OTel/trace headers | — |
| Message queue usage | ❌ Not implemented | Timer polling only | — |
| SOLID/DRY (sample) | ⚠️ Partially implemented | Single `ApiClient`; domain `*Api` classes; shared DTOs in `catalog_models.dart`; `userFacingError` | Large model file; static services |

### Testing & Reliability

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Unit tests | ❌ Not implemented | Only splash widget test | — |
| Integration tests | ❌ Not implemented | No `integration_test/` | — |
| E2E tests | ❌ Not implemented | — | — |
| Test coverage tooling | ❌ Not implemented | No coverage config; `analysis_options.yaml` is flutter_lints only | — |
| Migration up/down | ❌ Not implemented | No migrations | — |
| Rollback strategy | ❓ Insufficient evidence | No client rollback docs | Requires deploy/ops evidence |
| Feature flags | ❌ Not implemented | Grep `FeatureFlag`: zero | — |
| Existing test file | ⚠️ Partially implemented | `test/widget_test.dart:1-14` pumps `HillGoApp`, expects splash text | Smoke only |

### Networking

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| TLS/HTTPS enforcement | ⚠️ Partially implemented | Release requires `HILLGO_API_BASE` (`api_client.dart:38-46`); debug default `http://127.0.0.1:8000/api`; OSRM/Nominatim/OSM tiles use `https://` | HTTPS depends on dart-define value |
| Stateless HTTP handling | ⚠️ Partially implemented | Bearer per request; in-memory user/carts | — |
| WebSocket vs polling | ⚠️ Partially implemented (polling only) | `live_ride_tracking_screen.dart:35-36` 2s poll; driver search 3s; food/parcel 5s; assigned 1s | WebSocket: zero matches |

### Miscellaneous

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Timezone handling | ⚠️ Partially implemented | `catalog_models.dart:21-24` `DateTime.tryParse(...)?.toLocal()`; `friendlyDateTime` uses `DateTime.now()` | Device-local; no UTC policy in client |
| Currency / money types | ⚠️ Partially implemented | `fare_config.dart:1-17` `double` BDT rates; `fare_service.dart` returns `roundToDouble()` | No `Decimal`/`Money` package |
| Soft delete vs hard delete | ❌ Not implemented (hard delete) | `profile_api.dart:49-51` `DELETE /customer/addresses/$id`; `notifications_api.dart:43-45` DELETE | Soft-delete flag not present client-side |
| Audit trail | ❌ Not implemented | No client audit log | — |
| Environment config separation | ⚠️ Partially implemented | `--dart-define=HILLGO_API_BASE` / `HILLGO_SSL_PINS`; no `.env` files in app | — |
| Secrets management | ⚠️ Partially implemented | `android/.gitignore:10-14` ignores `key.properties` / keystores; token in secure storage | Root app `.gitignore` does not list `.env` explicitly |

---

## Insufficient evidence log

| Item | Reason |
|------|--------|
| Transaction isolation level | Requires DB/server config not in this app |
| Eventual consistency behavior under concurrent clients | Requires runtime multi-device observation |
| Authz / least-privilege per route | Enforced on Laravel backend, not in this client |
| CORS origins | Server response headers; not in this tree |
| Password hashing algorithm | Server-side; client sends plaintext password over HTTPS/HTTP |
| Migration rollback / deploy strategy | Ops/infra evidence not present |
| Production TLS pin values / live traffic | Requires build pipeline and production config |

---

## Additional findings

1. **In-memory carts lost on process kill** — `MarketplaceCartStore` / `FoodCartStore` are static lists (`catalog_models.dart:179-186`); not persisted to disk.
2. **Theme not persisted** — `theme_service.dart:4-18` keeps `_isDark` in memory only; no SharedPreferences write.
3. **25s request timeout** — `api_client.dart:139-143` `.timeout(const Duration(seconds: 25))`.
4. **Android cleartext** — No `usesCleartextTraffic` / network security config found; debug HTTP to localhost may fail on Android 9+ without extra config not present in manifests.
5. **No structured observability** — Failures surface as UI strings via `userFacingError`; no crash reporting package in `pubspec.yaml`.


# Technical Audit — Courier Agent App

| Field | Value |
|-------|-------|
| **Component** | Courier Agent App |
| **Repo path** | `Courier Agent App` |
| **Date of audit** | 2026-08-03 |
| **Stack** | Flutter 3.8+ · Provider · GoRouter · `http` · Laravel Sanctum bearer API |

## Files / directories reviewed

- `pubspec.yaml`, `.gitignore`, `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts`
- `lib/main.dart`, `lib/router/app_router.dart`
- `lib/services/api/api_client.dart`, `api_auth_repository.dart`, `api_parcel_repository.dart`, `api_earnings_repository.dart`, `api_profile_repository.dart`, `api_notification_repository.dart`
- `lib/services/repositories.dart`
- `lib/providers/auth_provider.dart`, `parcel_provider.dart`, `earnings_provider.dart`, `profile_provider.dart`
- `lib/models/parcel_model.dart`, `earnings_model.dart`, `notification_model.dart`, `user_model.dart`, `document_model.dart`
- `lib/screens/auth/login_screen.dart`, `login_otp_screen.dart`, `lib/screens/dashboard/dashboard_screen.dart`
- `lib/screens/history/history_screen.dart`, `lib/screens/profile/language_screen.dart`
- `lib/widgets/common_widgets.dart`, `lib/widgets/app_map.dart`, `lib/widgets/otp_input.dart`
- `test/widget_test.dart`
- Grep across `lib/` for: transaction, cache, retry, token, refresh, websocket, sentry, crashlytics, hive, sqflite, idempoten, mutex, FeatureFlag, softDelete, RateLimiter, timezone, UTC

**Scope note:** Backend DB/authz/CORS/hashing are outside this tree.

---

## Executive summary

The Courier Agent App is an online-first REST client for `/courier/*` with clear Provider → repository → `ApiClient` layering. Tokens are in `FlutterSecureStorage`; 401 triggers `onUnauthorized` → session expiry handler. Parcel history implements server pagination (`page` + `per_page`). OTP login has client-side attempt lockout. There is no local database, no response cache, no WebSocket, no automatic retry/backoff, no APM, and only a placeholder test. Money is formatted as `double` with a hard-coded `৳` symbol. Release builds require `HILLGO_API_BASE`; debug uses cleartext localhost HTTP.

---

## Findings by category

### Database Fundamentals

| Item | Status | Evidence (file:line + snippet) | Note |
|------|--------|--------------------------------|------|
| ACID transaction usage | ❌ Not implemented | No sqflite/hive/drift; `PayoutTransaction` is a model name only (`earnings_model.dart:70`) | — |
| Normalization of schema/models | ⚠️ Partially implemented | Separate model files + `fromJson` mappers | Client DTOs |
| Denormalization | ❌ Not implemented | No cached derived DB fields; providers refetch | — |
| Indexing in migrations | ❌ Not implemented | No migrations | — |
| Isolation levels | ❓ Insufficient evidence | No DB config | Server |
| Locking | ❌ Not implemented | No mutex; UI loading flags only | — |
| Sharding / partitioning | ❌ Not implemented | Not found | — |
| Foreign keys / cascade | ❌ Not implemented | No migrations | — |
| N+1 / sequential HTTP | ⚠️ Partially implemented | `parcel_provider.dart:37-44` assigned then dashboard stats; `profile_provider.dart:34-38` profile then stats; registration document upload loop (`auth_provider.dart:133-141`) | Sequential API calls |
| Connection pooling | ⚠️ Partially implemented | Single reused `http.Client` (`api_client.dart:48-50`) | — |

### Concurrency & Scaling

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Race protections | ⚠️ Partially implemented | `auth_provider.dart:187-201` `_guarded`; `parcel_provider.dart:99-101` `loadingMore`; OTP `_submitting`; `earnings_provider` `withdrawing`; presence switch disabled while updating | — |
| Idempotency keys | ❌ Not implemented | Grep: zero | — |
| Eventual consistency | ❓ Insufficient evidence | Refetch after mutations | Runtime |
| Distributed transactions | ❌ Not implemented | Not found | — |
| Load balancer config | ❌ Not implemented | Not in tree | — |
| Stateless handling | ⚠️ Partially implemented | Token secure storage (`api_client.dart:62-82`); `keepLoggedIn` in prefs (`api_auth_repository`) | — |

### Caching

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Cache invalidation | ❌ Not implemented | Providers refetch on load; no cache layer to invalidate | — |
| Cache patterns | ⚠️ Partially implemented | In-memory `_token` only (`api_client.dart:52-53`) | — |
| TTL / eviction | ❌ Not implemented | Not found | — |
| Cache stampede | ❌ Not implemented | Not found | — |

### API Design

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Idempotent methods | ⚠️ Partially implemented | `api_client.dart:104-121` GET/POST/PATCH + multipart; no DELETE/PUT | — |
| HTTP status codes | ⚠️ Partially implemented | `api_client.dart:167-180` 2xx / 401 clear + `onUnauthorized`; parcel provider handles 403/404 (`parcel_provider.dart:136-138`) | No 429 |
| Rate limiting | ⚠️ Partially implemented | OTP resend timer (`otp_input.dart:104-137`); OTP lockout 5 attempts / 30s (`login_otp_screen.dart:21-22,109-111`) | Client UX limits, not API RateLimiter |
| Pagination | ⚠️ Partially implemented | History: `page` + `per_page: 50` (`api_parcel_repository.dart:27-31`) + `loadMoreHistory` (`parcel_provider.dart:99-110`); notifications `per_page: 50` only (`api_notification_repository.dart:12-14`) | History has pages; notifications do not |
| API versioning | ❌ Not implemented | No `/v1` | — |
| HATEOAS | ❌ Not implemented | Not found | — |

### Security

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| SQL injection | ❌ Not implemented (N/A) | No SQL | — |
| OWASP-relevant controls | ⚠️ Partially implemented | Secure token; 401 session expiry wired (`main.dart:29-31`); upload size cap 5MB (`api_client.dart:34`); registration secrets cleared (`auth_provider.dart:173-180`); `allowBackup="false"` | No cert pin |
| Auth vs authz | ❓ Insufficient evidence | GoRouter redirect + Bearer | Server enforces |
| Token expiry / refresh / revocation | ⚠️ Partially implemented | 401 clears + `handleSessionExpired`; logout POST; no refresh token | — |
| CSRF | ❌ Not implemented | Bearer | — |
| XSS | ❌ Not implemented (N/A) | Flutter | — |
| CORS | ❓ Insufficient evidence | Mobile | Server |
| Password hashing | ❌ Not implemented (client) | Password sent to login/register/reset endpoints | Server |
| Least privilege | ❓ Insufficient evidence | Courier endpoints | Backend |
| Input validation | ⚠️ Partially implemented | Login form validators (`login_screen.dart:131-165`); withdraw amount checks (`withdraw_sheet.dart:45-73`); Laravel error message parse (`api_client.dart:183-194`) | — |
| Certificate pinning | ❌ Not implemented | Standard `http` | — |
| Hardcoded secrets | ✅ Implemented (none found) | dart-define base URL; keystore via external `key.properties` | — |

### System Design

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Circuit breaker | ❌ Not implemented | Not found | — |
| Retry with backoff | ❌ Not implemented | Manual `ErrorView.onRetry` (`common_widgets.dart:203-220`) | — |
| Graceful degradation / offline | ❌ Not implemented | `SocketException` → ApiException (`api_client.dart:145-154`); no offline queue; "Offline" label is presence UI (`dashboard_screen.dart:75`) | — |
| Health checks | ❌ Not implemented | Not found | — |
| Logging | ❌ Not implemented | No structured logger in `lib/` | — |
| Monitoring / APM | ❌ Not implemented | No Sentry/Crashlytics | — |
| Distributed tracing | ❌ Not implemented | Not found | — |
| Message queues | ❌ Not implemented | Not found | — |
| SOLID/DRY | ⚠️ Partially implemented | Abstract repos (`repositories.dart:7-30`); shared `ApiClient`; provider-per-domain | Repeated load/error boilerplate |

### Testing & Reliability

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Unit / widget tests | ❌ Not implemented | `test/widget_test.dart:1-7` `expect(1 + 1, 2)` | — |
| Integration / E2E | ❌ Not implemented | Not found | — |
| Coverage tooling | ❌ Not implemented | `/coverage/` gitignored; no runner config | — |
| Migration up/down | ❌ Not implemented | No migrations | — |
| Rollback strategy | ❓ Insufficient evidence | Not in app | Ops |
| Feature flags | ❌ Not implemented | Grep: zero | — |

### Networking

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| TLS/HTTPS enforcement | ⚠️ Partially implemented | `api_client.dart:36-45` release requires define; debug HTTP; map tiles HTTPS (`app_map.dart:46`) | — |
| Stateless HTTP | ⚠️ Partially implemented | Bearer per request | — |
| WebSocket vs polling | ❌ Not implemented | No websocket deps; dashboard loads once on init (`dashboard_screen.dart:30-36`); no periodic parcel poll | — |

### Miscellaneous

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Timezone | ⚠️ Partially implemented | `parcel_model.dart:141` `DateTime.tryParse` without UTC conversion; `intl` `DateFormat` for display | — |
| Currency / money | ⚠️ Partially implemented | `history_screen.dart:62` `৳${...toStringAsFixed(2)}` on `double` | No Decimal package |
| Soft delete | ❌ Not implemented | Grep softDelete/deleted_at: zero | — |
| Audit trail | ⚠️ Partially implemented | Delivery photo proof noted as audited alternative (`otp_confirmation_screen.dart:89-90`); no client audit log | Server may audit proof uploads |
| Environment config | ✅ Implemented | `String.fromEnvironment('HILLGO_API_BASE')` (`api_client.dart:25-26,38`) | — |
| Secrets management | ⚠️ Partially implemented | Secure storage; Android signing via `key.properties` reference | — |
| i18n | ⚠️ Partially implemented | Language preference PATCH (`language_screen.dart:11-12`) but UI strings hardcoded English; no `flutter_localizations` | Preference stored; UI not localized |

---

## Insufficient evidence log

| Item | Reason |
|------|--------|
| DB isolation / FK / sharding | No DB in this app |
| Authz / CORS / password hash | Backend |
| Soft-delete server behavior | Client never sends/reads `deleted_at` |
| Proof-upload audit persistence | Comment only; needs backend + runtime |
| Production HTTPS / dart-define values | Build pipeline not in this tree |
| Ops rollback | Not present |

---

## Additional findings

1. **History pagination is the strongest among Flutter apps audited** — explicit `page` + `loadMoreHistory` (`parcel_provider.dart:99-110`).
2. **Client OTP lockout** is local-only (`login_otp_screen.dart`); server rate limits are not visible here.
3. **No live assigned-parcel updates** — agent must leave/re-enter or manually retry; no polling timer on dashboard.
4. **Upload size enforced client-side** at 5MB (`api_client.dart:34`) before multipart send.


# Technical Audit — Rider / Driver App

| Field | Value |
|-------|-------|
| **Component** | Rider / Driver App |
| **Repo path** | `Rider Driver App` |
| **Date of audit** | 2026-08-03 |
| **Stack** | Flutter 3.8+ · Provider · GoRouter · `http` · Laravel Sanctum bearer API |

## Files / directories reviewed

- `pubspec.yaml`, `.gitignore`, `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`
- `lib/main.dart`, `lib/router/app_router.dart`
- `lib/services/api/api_client.dart`, `api_auth_repository.dart`, `api_trip_repository.dart`, `api_document_repository.dart`
- `lib/services/trip_repository.dart`, `auth_repository.dart`, `document_repository.dart`, `routing_service.dart`, `fare_config.dart`
- `lib/providers/auth_provider.dart`, `driver_provider.dart`, `document_provider.dart`
- `lib/models/models.dart`
- `lib/screens/home/home_dashboard_screen.dart`, `lib/screens/trip/trip_navigation_screen.dart`, `incoming_offer_screen.dart`
- `lib/screens/auth/login_screen.dart`, `lib/screens/account/settings_screen.dart`
- `lib/widgets/common.dart`, `lib/widgets/hillgo_map.dart`
- `test/widget_test.dart`, `ios/RunnerTests/RunnerTests.swift`
- Grep across `lib/` for: transaction, cache, retry, token, refresh, websocket, sentry, crashlytics, hive, sqflite, idempoten, mutex, FeatureFlag, softDelete, RateLimiter, PinnedHttp, ssl pin

**Scope note:** Backend DB, Sanctum policies, CORS, and password hashing are outside this tree (`hillgo-backend`). Marked ❓ when not verifiable here.

---

## Executive summary

The Rider/Driver App is a Provider + repository-pattern Flutter client against `/rider/*` APIs. Tokens live in `FlutterSecureStorage` with legacy SharedPreferences migration. Offer and cancel detection use 5-second HTTP polling; location updates are throttled to once per 10 seconds. There is no local SQL database, no certificate pinning, no token refresh, no WebSockets, no Sentry/Crashlytics, and only a placeholder unit test. Trip history requests a fixed `per_page=50` without cursor iteration. Release builds require `--dart-define=HILLGO_API_BASE`; debug defaults to cleartext `http://127.0.0.1:8000/api`.

---

## Findings by category

### Database Fundamentals

| Item | Status | Evidence (file:line + snippet) | Note |
|------|--------|--------------------------------|------|
| ACID transaction usage | ❌ Not implemented | No `sqflite`/`hive`/`isar` in `pubspec.yaml`; no transaction API in `lib/` | — |
| Normalization of schema/models | ⚠️ Partially implemented | `models.dart:37-43` — `asDouble` accepts Laravel DECIMAL strings or nums; JSON DTOs (`DriverUser`, `Trip`, …) | Client models only |
| Denormalization tradeoffs | ⚠️ Partially implemented | `api_trip_repository.dart:11-22` — `_customerByTripId` cache re-attaches customer block omitted by accept/advance responses | In-memory denormalized join |
| Indexing in migrations | ❌ Not implemented | No migrations | — |
| Transaction isolation level | ❓ Insufficient evidence | No DB config in app | Requires server/DB config |
| Locking | ❌ Not implemented | No mutex/lock packages; route refresh latch is UI-level (`trip_navigation_screen.dart:399-410`) | — |
| Sharding / partitioning | ❌ Not implemented | Not found | — |
| Foreign keys / cascade | ❌ Not implemented | No migrations | — |
| N+1 queries | ❌ Not implemented (no ORM) | Screens call repositories directly; no loop-of-queries pattern found for DB | HTTP fan-out not observed as systematic N+1 |
| Connection pooling | ⚠️ Partially implemented | One `http.Client` per `ApiClient` instance (`api_client.dart`) | Not a DB pool |

### Concurrency & Scaling

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Race condition protections | ⚠️ Partially implemented | `trip_navigation_screen.dart:399-410` `_routeRefreshPending` latch; `incoming_offer_screen.dart:43-50` timer keyed by `offer.id`; `driver_provider.dart:134-147` 10s location throttle | No client guard against double-accept; relies on server |
| Idempotency keys | ❌ Not implemented | Grep `idempoten`: zero | — |
| Eventual consistency | ❓ Insufficient evidence | Polling refreshes offer/trip state; no conflict resolver | Requires runtime observation |
| Distributed transactions | ❌ Not implemented | Not found | — |
| Load balancer config | ❌ Not implemented | Not in this tree | — |
| Stateless request handling | ⚠️ Partially implemented | Token in `FlutterSecureStorage` (`api_client.dart:58-84`); Provider holds online/trip state in memory | Process-local state |

### Caching

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Cache invalidation | ⚠️ Partially implemented | Token cleared on logout/401; districts cache never invalidated (`api_auth_repository.dart:149-156`) | — |
| Cache patterns | ⚠️ Partially implemented | In-memory `_token` (`api_client.dart:51-52`); `_districtsCache`; `_customerByTripId` | Cache-aside style for districts |
| TTL / eviction | ❌ Not implemented | No TTL on districts or customer map | Customer map grows per trip id |
| Cache stampede | ❌ Not implemented | No dedup lock on concurrent district fetch | — |

### API Design

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Idempotent method usage | ⚠️ Partially implemented | `api_client.dart:100-139` GET/POST/PATCH/PUT/DELETE | `delete()` defined; no repository callers found |
| HTTP status codes | ✅ Implemented | `api_client.dart:168-174` 2xx success; 401 clears token; 404/403/422 handled in callers | — |
| Rate limiting | ❌ Not implemented | No client RateLimiter; location throttle is UX/network conservation only | — |
| Pagination | ⚠️ Partially implemented | `api_trip_repository.dart:32-40` `per_page: '50'` + optional `q`/`filter` | No page/cursor loop |
| API versioning | ❌ Not implemented | Paths `/rider/...` without `/v1` | — |
| HATEOAS | ❌ Not implemented | Hard-coded paths | — |

### Security

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| SQL injection protection | ❌ Not implemented (N/A locally) | No SQL | JSON HTTP only |
| OWASP-relevant controls | ⚠️ Partially implemented | Secure token storage; 401 clear; form validators | No cert pin; debug HTTP |
| Auth vs authorization | ❓ Insufficient evidence | Bearer sent; GoRouter auth redirect client-side | Server must enforce `/rider/*` |
| Token expiry / refresh / revocation | ⚠️ Partially implemented | `api_auth_repository.dart:101-109` logout POST + clear; 401 auto-clear; no refresh token | — |
| CSRF | ❌ Not implemented | Bearer pattern | — |
| XSS | ❌ Not implemented (N/A) | Flutter widgets; no WebView found | — |
| CORS | ❓ Insufficient evidence | Mobile client | Server concern |
| Password hashing | ❌ Not implemented (client) | Password sent in login body to API | Server hashes |
| Least privilege | ❓ Insufficient evidence | Driver role assumed by endpoint namespace | Backend policies |
| Input validation | ✅ Implemented | `login_screen.dart:93-98` phone digit length validator; onboarding form validators present | — |
| Certificate pinning | ❌ Not implemented | Plain `http.Client()`; no `PinnedHttp` / SSL pin code | Contrast: Customer App has optional pinning |
| Hardcoded secrets | ✅ Implemented (none found) | Base URL via dart-define; no API keys in source | Demo phone hint only |

### System Design

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Circuit breaker | ❌ Not implemented | Not found | — |
| Retry with backoff | ❌ Not implemented | `common.dart:281-300` `ErrorView` manual Retry button only | — |
| Graceful degradation | ⚠️ Partially implemented | `driver_provider.dart:116-131` polling failures swallowed; location best-effort (`:134-147`) | GPS simulation fallback present in navigation flows |
| Health checks | ❌ Not implemented | Not found | — |
| Logging | ❌ Not implemented | Silent `catch (_)`; no structured logger | — |
| Monitoring / APM | ❌ Not implemented | No Sentry/Crashlytics in deps | — |
| Distributed tracing | ❌ Not implemented | Not found | — |
| Message queues | ❌ Not implemented | Not found | — |
| SOLID/DRY | ⚠️ Partially implemented | Abstract `TripRepository` (`trip_repository.dart:3-18`); `ApiClient` shared; Provider DI in `main.dart:15-28` | Clean layering |

### Testing & Reliability

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Unit / widget tests | ❌ Not implemented | `test/widget_test.dart:1-7` — `expect(true, isTrue)` placeholder | — |
| Integration / E2E | ❌ Not implemented | Not found | — |
| Coverage tooling | ❌ Not implemented | `/coverage/` in gitignore; no coverage config | — |
| Migration up/down | ❌ Not implemented | No migrations | — |
| Rollback strategy | ❓ Insufficient evidence | Not in app | Ops evidence needed |
| Feature flags | ❌ Not implemented | Settings toggles are local UI state (`settings_screen.dart:18-22`), not remote flags | — |

### Networking

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| TLS/HTTPS enforcement | ⚠️ Partially implemented | `api_client.dart:35-44` — debug HTTP localhost; release requires define; OSM tiles HTTPS (`hillgo_map.dart:38-40`) | — |
| Stateless HTTP | ⚠️ Partially implemented | Bearer per request; Provider memory state | — |
| WebSocket vs polling | ⚠️ Partially implemented (polling) | `home_dashboard_screen.dart:69-82` offer poll 5s; `trip_navigation_screen.dart:82-91` cancel poll 5s | WebSocket: zero matches |
| Location reporting | ✅ Implemented | `api_trip_repository.dart:124-126` `POST /rider/location` | Throttled in provider |

### Miscellaneous

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Timezone | ⚠️ Partially implemented | `models.dart:369-371` `DateTime.tryParse(...)?.toLocal()` | No explicit UTC policy |
| Currency / money | ⚠️ Partially implemented | `fare_config.dart:67-79` `formatTaka` with `amount.round()`; amounts as `double` | No Decimal type |
| Soft delete | ❌ Not implemented | Grep: zero | — |
| Audit trail | ❌ Not implemented | No client audit log | — |
| Environment config | ✅ Implemented | `--dart-define=HILLGO_API_BASE` (`api_client.dart:35-44`); `routing_service.dart:57-63` same env | — |
| Secrets management | ⚠️ Partially implemented | Token secure storage; `key.properties` loaded if present (`build.gradle.kts:11-15`); app `.gitignore` does **not** list `key.properties` | Risk if keystore props committed |

---

## Insufficient evidence log

| Item | Reason |
|------|--------|
| DB isolation / FK / sharding | No DB layer in this app; lives in backend if anywhere |
| Concurrent accept race outcome | Server 422 handling assumed; needs runtime tests |
| Authz policies for drivers | Backend middleware not in this tree |
| CORS / password hash | Server-side |
| Production HTTPS URL and TLS | Build/deploy dart-define values not in repo |
| Rollback / ops strategy | Not present in client |

---

## Additional findings

1. **No certificate pinning** — unlike Customer App's `PinnedHttp`, this app uses plain `http.Client`.
2. **Districts cache never refreshed** after first successful load (`api_auth_repository.dart:149-156`).
3. **Settings toggles are ephemeral** — push/sound/auto-accept/night-map flags reset on process kill (`settings_screen.dart:18-22`).
4. **`.gitignore` gap** — does not exclude `key.properties` / `.env` while Gradle reads `key.properties` for signing.
5. **Placeholder-only tests** — no coverage of auth, trip accept, or location reporting.


# Technical Audit — Vendor / Merchant App

| Field | Value |
|-------|-------|
| **Component** | Vendor / Merchant App |
| **Repo path** | `Vendor Marchant App` |
| **Date of audit** | 2026-08-03 |
| **Stack** | Flutter 3.8+ · Provider · GoRouter · `http` · `cached_network_image` · Laravel Sanctum bearer API |

## Files / directories reviewed

- `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`, `android/app/src/debug/AndroidManifest.xml`
- `lib/main.dart`, `lib/services/api/api_client.dart`
- `lib/services/api/api_auth_repository.dart`, `api_order_repository.dart`, `api_product_repository.dart`, `api_store_repository.dart`
- `lib/services/repositories.dart`
- `lib/providers/auth_provider.dart`, `orders_provider.dart`, `products_provider.dart`, `store_provider.dart`
- `lib/models/order_model.dart`, `product_model.dart`, `store_model.dart`
- `lib/screens/auth/login_screen.dart`, `lib/screens/home/home_screen.dart`, `lib/screens/orders/order_details_screen.dart`
- `lib/screens/products/product_form_screen.dart`, `lib/screens/profile/settings_screen.dart`
- `lib/widgets/common_widgets.dart`
- `test/widget_test.dart`, `ios/RunnerTests/RunnerTests.swift`
- Grep across `lib/` for: transaction, cache, retry, token, refresh, websocket, sentry, crashlytics, hive, sqflite, idempoten, mutex, FeatureFlag, softDelete, RateLimiter

**Scope note:** Server DB/migrations/authz/CORS are in `hillgo-backend`, not this tree.

---

## Executive summary

The Vendor/Merchant App is a Provider + repository Flutter client for `/merchant/*` APIs. Auth tokens use `FlutterSecureStorage` with SharedPreferences migration. Image URLs use `cached_network_image`. Store dashboard loading performs multiple sequential HTTP calls (me, store, reviews, payouts, transactions, revenue). Order actions use an `isActing` flag to reduce double-taps. There is no WebSocket or order polling—only pull-to-refresh. Tests are a placeholder; no APM, circuit breaker, idempotency keys, token refresh, or local database were found. Debug API base is cleartext localhost HTTP.

---

## Findings by category

### Database Fundamentals

| Item | Status | Evidence (file:line + snippet) | Note |
|------|--------|--------------------------------|------|
| ACID transaction usage | ❌ Not implemented | No local SQL/ORM deps; `TransactionModel` is revenue ledger DTO (`store_model.dart:183-210`) | Not a DB transaction |
| Normalization of schema/models | ⚠️ Partially implemented | Domain models (`OrderModel`, `ProductModel`, `TransactionModel`) with `fromJson` | Client DTOs |
| Denormalization | ⚠️ Partially implemented | `ApiStoreRepository._trend` holds revenue trend from last summary (`api_store_repository.dart:10-11,117-120`) | In-memory |
| Indexing in migrations | ❌ Not implemented | No migrations | — |
| Isolation levels | ❓ Insufficient evidence | No DB config | Server concern |
| Locking | ❌ Not implemented | No mutex; `isActing` is UI guard | — |
| Sharding / partitioning | ❌ Not implemented | Not found | — |
| Foreign keys / cascade | ❌ Not implemented | No migrations | — |
| N+1 / sequential fan-out | ⚠️ Partially implemented | `store_provider.dart:37-94` sequential me→store→reviews→payouts→transactions→revenue; `products_provider.dart:24-31` products then categories; `api_auth_repository.dart:14-18` me then onboarding | Client HTTP fan-out |
| Connection pooling | ❌ Not implemented | Default `package:http` client; no custom pool | — |

### Concurrency & Scaling

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Race protections | ⚠️ Partially implemented | `orders_provider.dart:14,125-138` `isActing`; UI disables buttons (`order_details_screen.dart:247`); optimistic category visibility with rollback (`products_provider.dart:86-97`) | — |
| Idempotency keys | ❌ Not implemented | Grep `idempoten`: zero | — |
| Eventual consistency | ❓ Insufficient evidence | Optimistic UI + reload; no version tokens | Runtime needed |
| Distributed transactions | ❌ Not implemented | Not found | — |
| Load balancer config | ❌ Not implemented | Not in tree | — |
| Stateless handling | ⚠️ Partially implemented | Token in secure storage (`api_client.dart:52-70`); settings in memory only (`store_provider.dart:31` comment) | — |

### Caching

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Cache invalidation | ⚠️ Partially implemented | Pull-to-refresh reloads (`home_screen.dart:96-100`); token clear on 401 | No TTL invalidation |
| Cache patterns | ⚠️ Partially implemented | `_trend` in-memory (`api_store_repository.dart:10-11`); `CachedNetworkImage` (`common_widgets.dart:389-405`) | Image cache + one API field cache |
| TTL / eviction | ❌ Not implemented | Not found | — |
| Cache stampede | ❌ Not implemented | Not found | — |

### API Design

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Idempotent methods | ⚠️ Partially implemented | `api_client.dart:108-133` GET/POST/PATCH/PUT/DELETE + multipart | — |
| HTTP status codes | ⚠️ Partially implemented | `api_client.dart:195-201` 2xx / 401 clear; helpers `isUnauthorized`/`isNotFound` (`:16-17`) | No 429/503 specials |
| Rate limiting | ❌ Not implemented | Not found | — |
| Pagination | ⚠️ Partially implemented | `api_order_repository.dart:11-15` `per_page: 50`; `orders_provider.dart:20,120-123` client-side `historyVisible` / `loadMoreHistory` slices local list | Not server page/cursor |
| API versioning | ❌ Not implemented | `/merchant/...` only | — |
| HATEOAS | ❌ Not implemented | Not found | — |

### Security

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| SQL injection | ❌ Not implemented (N/A) | No SQL | — |
| OWASP-relevant controls | ⚠️ Partially implemented | Secure token; form validators; `allowBackup="false"` (`AndroidManifest.xml:6`) | No cert pin |
| Auth vs authz | ❓ Insufficient evidence | Bearer + GoRouter; server must enforce merchant scope | — |
| Token expiry / refresh / revocation | ⚠️ Partially implemented | 401 → `clearToken()` (`api_client.dart:195-201`); logout via auth repo; no refresh | — |
| CSRF | ❌ Not implemented | Bearer | — |
| XSS | ❌ Not implemented (N/A) | Flutter UI | — |
| CORS | ❓ Insufficient evidence | Mobile | Server |
| Password hashing | ❌ Not implemented (client) | Login posts password to API | Server hashes |
| Least privilege | ❓ Insufficient evidence | Merchant endpoints only | Backend |
| Input validation | ✅ Implemented | `login_screen.dart:229-257` email/password; OTP `^\d{6}$` (`:291-296`); price bounds (`product_form_screen.dart:322-329`) | — |
| Certificate pinning | ❌ Not implemented | Not found | — |
| Hardcoded secrets | ✅ Implemented (none found) | No apiKey/secret in `lib/` | — |

### System Design

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Circuit breaker | ❌ Not implemented | Not found | — |
| Retry with backoff | ❌ Not implemented | `ErrorView` Retry button only (`common_widgets.dart:92-112`) | — |
| Graceful degradation / offline | ❌ Not implemented | Network failure → `ApiException` (`api_client.dart:179-183`); no connectivity package | — |
| Health checks | ❌ Not implemented | Not found | — |
| Logging | ❌ Not implemented | No Logger/debugPrint in `lib/` | — |
| Monitoring / APM | ❌ Not implemented | No Sentry/Crashlytics | — |
| Distributed tracing | ❌ Not implemented | Not found | — |
| Message queues | ❌ Not implemented | Not found | — |
| SOLID/DRY | ⚠️ Partially implemented | Abstract repos (`repositories.dart:5-10`); shared `ApiClient`; repeated load/error patterns across providers | `getOrder` unused by providers (`api_order_repository.dart:22-27`); details use `findById` only |

### Testing & Reliability

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Unit / widget tests | ❌ Not implemented | `test/widget_test.dart:1-7` placeholder `expect(true, isTrue)` | — |
| Integration / E2E | ❌ Not implemented | No `integration_test/` | — |
| Coverage tooling | ❌ Not implemented | Not found | — |
| Migration up/down | ❌ Not implemented | No migrations | — |
| Rollback strategy | ❓ Insufficient evidence | Not in app | Ops |
| Feature flags | ❌ Not implemented | Grep: zero | — |

### Networking

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| TLS/HTTPS enforcement | ⚠️ Partially implemented | `api_client.dart:34-43` release requires `HILLGO_API_BASE`; debug `http://127.0.0.1:8000/api` | HTTPS only if define is HTTPS |
| Stateless HTTP | ⚠️ Partially implemented | Bearer; in-memory providers | — |
| WebSocket vs polling | ❌ Not implemented | No websocket; no `Timer.periodic` order poll; pull-to-refresh only (`home_screen.dart:96-100`) | Orders not live-updated |
| Cleartext config | ❓ Insufficient evidence | INTERNET in debug manifest (`debug/AndroidManifest.xml:6`); no `usesCleartextTraffic` in main | Device behavior needs runtime check |

### Miscellaneous

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Timezone | ⚠️ Partially implemented | `order_model.dart:91-92` `DateTime.tryParse` without `toUtc`/`toLocal` | Device parse semantics |
| Currency / money | ⚠️ Partially implemented | `product_model.dart:158` `double price`; UI `Price (BDT)` / `৳` (`product_form_screen.dart:315-321`) | No Decimal |
| Soft delete | ❌ Not implemented | Hard `DELETE /merchant/products/$id` (`api_product_repository.dart:91-94`) | — |
| Audit trail | ❌ Not implemented | No client audit | — |
| Environment config | ⚠️ Partially implemented | `--dart-define=HILLGO_API_BASE` only | No `.env` |
| Secrets management | ⚠️ Partially implemented | Secure token storage; no committed secrets found | — |
| Version string mismatch | ⚠️ Partially implemented | UI shows `Version 2.4.1 (HillGo-Production)` (`settings_screen.dart:228`) vs `pubspec.yaml` `1.0.0+1` | Hardcoded marketing version |
| Unused dependency | ⚠️ Partially implemented | `uuid` in `pubspec.yaml` with no `lib/` usage found | Dead dependency |

---

## Insufficient evidence log

| Item | Reason |
|------|--------|
| DB isolation / FK / sharding / indexing | No DB in this app |
| Authz / CORS / password hashing | Backend |
| Cleartext traffic on device | Manifest incomplete; needs device/runtime |
| Eventual consistency under concurrent staff devices | Runtime |
| Ops rollback | Not in repo |

---

## Additional findings

1. **No live order channel** — merchants must pull-to-refresh; no WebSocket/polling for incoming orders.
2. **Order details offline gap** — `order_details_screen.dart:48-49` uses in-memory `findById` only; unused `getOrder` never called — deep-link/cold open of an order id not in the loaded list fails.
3. **Sequential dashboard load** — `StoreProvider.load` chains many awaits, increasing time-to-interactive vs `Future.wait`.
4. **Hardcoded production version label** does not match `pubspec.yaml`.


# Technical Audit — Admin Panel

| Field | Value |
|-------|-------|
| **Component** | Admin Panel |
| **Repo path** | `Hill Go Admin Panel` |
| **Date of audit** | 2026-08-03 |
| **Stack** | Static vanilla HTML/JS SPA · Tailwind CDN · Leaflet · consumes external Laravel `/admin/*` API |

## Files / directories reviewed

- `ui/index.html`, `ui/README.md`
- `ui/js/store.js`, `app.js`, `router.js`, `ui.js`, `maps.js`
- `ui/js/pages/overview.js`, `region.js`, `customer.js`, `rider.js`, `merchant.js`, `courier.js`, `settings.js`
- `STITCH_ADMIN_SCREENS.md` (design docs; checked against live code)
- `stitch_hillgo_super_admin_panel/**` (mock HTML; not runtime)
- Repo-root `.gitignore` (secrets patterns)
- Grep across panel for: transaction, SQL, migration, idempotency, WebSocket, sentry, retry, rateLimit, CSRF, FeatureFlag, softDelete, test/spec

**Scope note:** This folder has **no** PHP, SQL, migrations, `package.json`, or `composer.json`. Database ACID, indexing, FK, pooling, password hashing, CORS headers, and server authz live in sibling `hillgo-backend`. Those items are ❌ (absent here) or ❓ as noted.

---

## Executive summary

The Admin Panel is a browser SPA (`ui/`) that talks to a Laravel API with Bearer tokens in `sessionStorage`, an in-memory cache, optimistic mutations, and 30-second polling for selected collections. It implements XSS escaping helpers, a CSP meta tag (with `'unsafe-inline'`), Leaflet SRI, client role gate for `admin`, and hybrid pagination (server `per_page=50`, UI pages of 8). There are no tests, no WebSockets, no circuit breaker, no retry/backoff, no APM, no idempotency keys, and no local database. Default API base is cleartext `http://127.0.0.1:8000/api`. README still documents removed `seed.js` / localStorage mock storage; live code uses the API.

---

## Findings by category

### Database Fundamentals

| Item | Status | Evidence (file:line + snippet) | Note |
|------|--------|--------------------------------|------|
| ACID transaction usage | ❌ Not implemented | Zero `.php`/`.sql` files; browser `fetch` only (`store.js:98-120`) | No DB in this component |
| Normalization of schema/models | ❌ Not implemented | No schema; client maps API JSON via `sid()` helpers | — |
| Denormalization tradeoffs | ⚠️ Partially implemented | `store.js:254-268` joins divisions→districts in memory for open/closed counts | Client-side join |
| Indexing in migrations | ❌ Not implemented | No migrations | — |
| Isolation levels | ❓ Insufficient evidence | No DB config here | Backend |
| Locking | ❌ Not implemented | Optimistic `patchRow`/`mergeRow` (`store.js:197-210`); no ETags/`If-Match` | — |
| Sharding / partitioning | ❌ Not implemented | Grep: none | — |
| Foreign keys / cascade | ❌ Not implemented | No schema | — |
| N+1 queries | ⚠️ Partially implemented | `store.js:137-140` — one districts GET **per division** via `Promise.all(divisions.map(...))` | Client request fan-out |
| Connection pooling | ❌ Not implemented | Browser `fetch`; no pool | — |

### Concurrency & Scaling

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Race condition protections | ❌ Not implemented | Optimistic writes without locks/version checks | Last-write-wins at UI |
| Idempotency keys | ❌ Not implemented | No `Idempotency` / `X-Idempotency` headers | — |
| Eventual consistency | ⚠️ Partially implemented | Optimistic mutate → reconcile; `setInterval` refresh 30s (`store.js:236-239`) | Client pattern only |
| Distributed transactions | ❌ Not implemented | Not found | — |
| Load balancer config | ❌ Not implemented | No nginx/HAProxy/etc. in folder | — |
| Stateless request handling | ✅ Implemented | Bearer in `sessionStorage` (`store.js:49-65`); hash router (`router.js:9-16`); no server session cookie in client | SPA is client-stateless aside from token |

### Caching

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Cache invalidation | ⚠️ Partially implemented | `fail(..., reloadKeys)` → `refresh` (`store.js:127-131`); success paths selective refresh | — |
| Cache-aside / write-through / write-back | ⚠️ Partially implemented | Cache-aside reads from `state` (`store.js:1-4`); writes optimistic then HTTP — not write-through | — |
| TTL / eviction | ❌ Not implemented | No TTL; only interval refresh of subsets | — |
| Cache stampede | ❌ Not implemented | No singleflight around `refresh` | — |

### API Design

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Idempotent method usage | ⚠️ Partially implemented | GET/PATCH/PUT used; mutating POSTs for wallet/status/KYC (`store.js` L309, L323, L386, L615) | Method choice client-side |
| HTTP status codes | ✅ Implemented | `store.js:98-120` — 401 clears token + event; `!res.ok` throws message/errors | — |
| Rate limiting | ❌ Not implemented | No throttle / Retry-After handling | — |
| Pagination | ⚠️ Partially implemented | Server `per_page=50` (`store.js:133-142`); UI `paginate(..., 8)` (`ui.js:161-167`) slices in memory | Hybrid; cannot page beyond first 50 from server |
| API versioning | ❌ Not implemented | `/admin/...` without `/v1` | — |
| HATEOAS | ❌ Not implemented | No `_links` parsing | — |

### Security

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| SQL injection protection | ❌ Not implemented (N/A in panel) | No SQL; JSON `fetch` only | Backend ORM not in this tree |
| OWASP-relevant controls | ⚠️ Partially implemented | Login+Bearer; `escapeHtml` (`ui.js:12-14`); CSP + Leaflet SRI (`index.html:6-12`); wallet bounds (`store.js:314-321`); documented XSS risk of sessionStorage (`store.js:6-7`) | CSP includes `'unsafe-inline'` |
| Auth vs authorization | ⚠️ Partially implemented | Login (`store.js:218-222`); client role gate (`app.js:119-132`) blocks non-`admin`; comment states server still enforces | Client gate alone is insufficient if API mishandled |
| Token expiry / refresh / revocation | ⚠️ Partially implemented | 401 → clear + re-login; logout POST; **no refresh token** | — |
| CSRF protection | ❌ Not implemented | No CSRF tokens; Bearer SPA pattern | — |
| XSS protections | ⚠️ Partially implemented | `escapeHtml` used in UI builders; CSP present but weakened by `'unsafe-inline'` | — |
| CORS configuration | ❓ Insufficient evidence | CSP `connect-src` lists localhost + `https:` (`index.html:6`); CORS headers are server-side | — |
| Password hashing | ❌ Not implemented (client) | Password sent in JSON login body (`store.js:218-222`) | Server hashes |
| Least-privilege checks | ⚠️ Partially implemented | `user.role !== 'admin'` gate (`app.js:119-132`) | Single role check in UI |
| Input validation | ⚠️ Partially implemented | Wallet ±1e7 finite check; pricing finite checks; HTML `required`/`type=email` | — |
| Hardcoded secrets | ✅ Implemented (none found) | Default API URL only (`index.html:228`, `store.js:10`) — not a secret key | — |

### System Design

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Circuit breaker | ❌ Not implemented | Grep: none | — |
| Retry with backoff | ❌ Not implemented | Grep: none | — |
| Graceful degradation | ⚠️ Partially implemented | `Promise.allSettled` in `refresh` (`store.js:181-187`); map mount catch (`maps.js:178-184`); route error UI | — |
| Health check endpoints | ❌ Not implemented | Sidebar “System Active” is static markup (`index.html:163-167`), not a probe | — |
| Logging | ⚠️ Partially implemented | `console.error` / `console.warn` only | — |
| Monitoring / APM | ❌ Not implemented | No Sentry/Datadog/OTel | — |
| Distributed tracing | ❌ Not implemented | Not found | — |
| Message queues | ❌ Not implemented | Not found | — |
| SOLID/DRY | ⚠️ Partially implemented | Shared `LOADERS`, `UI`, `escapeHtml`; duplicated `escapeHtml` in `maps.js` | Thin SPA structure |

### Testing & Reliability

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Unit / integration / E2E tests | ❌ Not implemented | No test/spec runners or files in panel | — |
| Coverage tooling | ❌ Not implemented | No package.json | — |
| Migration up/down | ❌ Not implemented | No migrations | — |
| Rollback strategy | ❓ Insufficient evidence | Static files; deploy strategy not in folder | Ops |
| Feature flags | ❌ Not implemented | Grep: none | — |
| 2FA | ⚠️ Partially implemented | Settings checkbox only (`settings.js:27`); no OTP challenge flow in panel | Preference UI, not enforcement |

### Networking

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| TLS/HTTPS enforcement | ⚠️ Partially implemented | Default API `http://127.0.0.1:8000/api` (`store.js:10`, `index.html:228`); CDNs over `https://` | Production must set `HILLGO_API_BASE` |
| Stateless HTTP | ✅ Implemented | Hash router + Bearer (`router.js:9-16`, `store.js:49-65`) | — |
| WebSocket vs polling | ⚠️ Partially implemented (polling) | `store.js:236-239` `setInterval(..., 30000)` | WebSocket: none |

### Miscellaneous

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Timezone handling | ⚠️ Partially implemented | Settings options Asia/Dhaka, UTC, Asia/Kolkata (`settings.js:22-26`); display via `toLocaleString('en-BD')` (`ui.js:27-31`) | Setting sent to API; local display uses browser locale |
| Currency / money types | ⚠️ Partially implemented | JS `Number` + `Math.round` in `formatTk` (`ui.js:22-25`); wallet cents round (`store.js:314-321`) | Float arithmetic |
| Soft delete | ❌ Not implemented | No `deleted_at` / soft-delete usage | — |
| Audit trail | ✅ Implemented (client consume) | Loaders for `pricingAudit`, `activityLog` (`store.js:175-177`); rendered in settings/overview pages | Attribution depends on API payload |
| Environment config | ⚠️ Partially implemented | `window.HILLGO_API_BASE` only; no `.env` in panel | — |
| Secrets management | ⚠️ Partially implemented | Repo-root `.gitignore` ignores `**/.env` etc.; no API keys in panel source | — |

---

## Insufficient evidence log

| Item | Reason |
|------|--------|
| DB ACID / isolation / indexes / FK / pooling / sharding | No database code in Admin Panel; requires `hillgo-backend` |
| Server authz enforcement | Client gate found; server middleware not in this tree |
| CORS allowlist origins | Server headers |
| Password hashing algorithm | Server |
| Whether activity/pricing audit rows attribute actors correctly | Depends on API response fields + DB |
| Production TLS termination / LB | Infra not in this folder |
| Deploy rollback | Static hosting config not present |

---

## Additional findings

1. **Stale README** — `ui/README.md` still describes opening static files; docs elsewhere mention removed `seed.js` / `localStorage` mock (`hillgo-admin-v1`). Runtime is live API (`store.js`).
2. **STITCH docs contradict runtime** — `STITCH_ADMIN_SCREENS.md` claimed mock-only admin; `index.html` shows “Live backend” and `store.js` performs real `fetch`.
3. **Pagination ceiling** — UI only ever loads `per_page=50` per collection; client pages of 8 cannot show records beyond the first 50.
4. **Token XSS surface** — explicitly documented (`store.js:6-7`): `sessionStorage` is JS-readable; prefers HttpOnly cookies for production.
5. **Districts N+1** — one HTTP call per division (`store.js:137-140`) scales poorly as divisions grow.


# Technical Audit — Public Web

| Field | Value |
|-------|-------|
| **Component** | Public Web |
| **Repo path** | `Hill Go Public Web` |
| **Date of audit** | 2026-08-03 |
| **Stack** | Static multi-page HTML + `css/style.css` + vanilla `js/main.js` · no build tool · calls external `/public/*` API |

## Files / directories reviewed

- All HTML pages: `index.html`, `about.html`, `blog.html`, `contact.html`, `driver.html`, `faq.html`, `food.html`, `merchant.html`, `parcel.html`, `privacy.html`, `register.html`, `ride.html`, `services.html`, `terms.html`
- `css/style.css`, `js/main.js`
- `assets/img/` (local SVGs)
- Repo-root `.gitignore` (secrets patterns)
- Grep across Public Web for: transaction, cache, retry, token, refresh, intercept, pagination, websocket, sentry, rateLimit, csrf, cors, password, secret, apiKey, http://, https, softDelete, timezone, UTC, decimal, escapeHtml, localStorage, sessionStorage

**Scope note:** This folder has **no** backend, database, Node package, or auth system. Server DB, rate limits, CORS headers, and CSRF (if any) live in `hillgo-backend`.

---

## Executive summary

HillGo Public Web is a static marketing site with a thin `fetch` client for public endpoints (track, quotes, availability, newsletter, contact, partner applications). There is no authentication, no token storage, no caching layer, no retries, no WebSockets, no tests, and no CSP. API default is cleartext `http://127.0.0.1:8000/api`. XSS risk is reduced by using `textContent`/`createElement` for dynamic output, but a defined `escapeHtml` helper is never called. Forms use HTML `required`/`maxlength`/`pattern` constraints. Credentials are omitted on API calls (`credentials: 'omit'`).

---

## Findings by category

### Database Fundamentals

| Item | Status | Evidence (file:line + snippet) | Note |
|------|--------|--------------------------------|------|
| ACID transaction usage | ❌ Not implemented | No SQL/ORM; only marketing copy mentioning “transactions” (`services.html:94`) | Static site |
| Normalization of schema/models | ❌ Not implemented | No models/schema | — |
| Denormalization | ❌ Not implemented | Not found | — |
| Indexing in migrations | ❌ Not implemented | No migrations | — |
| Isolation levels | ❓ Insufficient evidence | No DB here | Backend |
| Locking | ❌ Not implemented | Submit button disable only (`main.js:137-148`) | UX, not DB lock |
| Sharding / partitioning | ❌ Not implemented | Marketing “scalability” copy only (`services.html:93-97`) | Not code |
| Foreign keys / cascade | ❌ Not implemented | No schema | — |
| N+1 queries | ❌ Not implemented | Single `hgApi` calls per form action | — |
| Connection pooling | ❌ Not implemented | Browser `fetch` | — |

### Concurrency & Scaling

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Race condition protections | ⚠️ Partially implemented | `btn.disabled = true` during track submit (`main.js:137-148`) | Prevents double-click UX only |
| Idempotency keys | ❌ Not implemented | Not found | — |
| Eventual consistency | ❓ Insufficient evidence | Stateless GETs/POSTs | No multi-writer state in site |
| Distributed transactions | ❌ Not implemented | Not found | — |
| Load balancer config | ❌ Not implemented | Not in folder | — |
| Stateless request handling | ✅ Implemented | No cookies (`credentials: 'omit'`, `main.js:26-27`); no sessionStorage/localStorage usage found | Fully stateless client |

### Caching

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Cache invalidation | ❌ Not implemented | Grep `cache`: zero in source | — |
| Cache-aside / write-through / write-back | ❌ Not implemented | Not found | — |
| TTL / eviction | ❌ Not implemented | Not found | — |
| Cache stampede | ❌ Not implemented | Not found | — |

### API Design

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Idempotent method usage | ⚠️ Partially implemented | GET for track/availability; POST for quotes/newsletter/contact/partner (`main.js` callers at 140, 226, 259, 280, 304, 319) | Client method choice |
| HTTP status codes | ⚠️ Partially implemented | `hgApi` throws on `!res.ok` with Laravel `message`/`errors` (`main.js:33-36`) | No 429/503 specials |
| Rate limiting | ❌ Not implemented | Grep `rateLimit`: zero | Server may rate-limit; not in this tree |
| Pagination | ❌ Not implemented | Grep: zero | — |
| API versioning | ❌ Not implemented | Paths `/public/...` without `/v1` | — |
| HATEOAS | ❌ Not implemented | Not found | — |

**API surface found:**

| Method | Path | Evidence |
|--------|------|----------|
| GET | `/public/track/{id}` | `main.js:140` |
| POST | `/public/quotes` | `main.js:226` |
| GET | `/public/availability?city=` | `main.js:259` |
| POST | `/public/newsletter` | `main.js:280` |
| POST | `/public/contact` | `main.js:304` |
| POST | `/public/partner-applications` | `main.js:319` |

### Security

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| SQL injection protection | ❌ Not implemented (N/A) | No SQL; JSON POST + encoded GET params | — |
| OWASP-relevant controls | ⚠️ Partially implemented | `credentials: 'omit'`; `encodeURIComponent` on track/availability; `textContent` for toasts/quotes; HTML maxlength/required | No CSP; unused `escapeHtml` |
| Auth vs authorization | ❌ Not implemented | No login/token flow; “Log In” links to `contact.html` (`index.html:22-24`) | Marketing only |
| Token expiry / refresh / revocation | ❌ Not implemented | No tokens | — |
| CSRF protection | ❌ Not implemented | Grep `csrf`: zero; cookie-less API calls | Cookie CSRF N/A with `credentials: 'omit'`; still no anti-automation tokens |
| XSS protections | ⚠️ Partially implemented | `escapeHtml` defined (`main.js:5-7`) but **never called**; toasts/quotes use `textContent` (`main.js:228-241`, `405-412`); no `innerHTML`/`eval` matches | Dead helper |
| CORS configuration | ⚠️ Partially implemented | Client sets `mode: 'cors'` (`main.js:26`); warns on `file://` (`main.js:13-14`) | Server CORS headers not in this tree |
| Password hashing | ❌ Not implemented | No password fields in Public Web | — |
| Least privilege | ❓ Insufficient evidence | Public endpoints only from this site | Backend must restrict `/public/*` |
| Input validation | ⚠️ Partially implemented | HTML constraints e.g. `register.html:89-96` maxlength/pattern/required; JS payload assembly for quotes | No JS schema validator |
| Hardcoded secrets | ✅ Implemented (none found) | No apiKey/password/secret literals; only default API base URL | — |

### System Design

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Circuit breaker | ❌ Not implemented | Not found | — |
| Retry with backoff | ❌ Not implemented | Grep `retry`: zero | — |
| Graceful degradation | ⚠️ Partially implemented | Errors → `showToast` (`main.js:33-36` + callers); site still renders without API | Forms fail with toast only |
| Health check endpoints | ❌ Not implemented | Grep `health`: zero | — |
| Logging | ⚠️ Partially implemented | `console.info` for file:// only (`main.js:14`) | — |
| Monitoring / APM | ❌ Not implemented | No Sentry | — |
| Distributed tracing | ❌ Not implemented | Not found | — |
| Message queues | ❌ Not implemented | Not found | — |
| SOLID/DRY | ⚠️ Partially implemented | Single `hgApi` helper; repeated form init patterns in `main.js` | Appropriate for small static site |

### Testing & Reliability

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Unit / integration / E2E tests | ❌ Not implemented | No `*.test.*` / `*.spec.*` / test runners | — |
| Coverage tooling | ❌ Not implemented | No package.json | — |
| Migration up/down | ❌ Not implemented | No migrations | — |
| Rollback strategy | ❓ Insufficient evidence | Static hosting deploy not documented here | Ops |
| Feature flags | ❌ Not implemented | Not found | — |

### Networking

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| TLS/HTTPS enforcement | ❌ Not implemented | Default `HG_API = ... 'http://127.0.0.1:8000/api'` (`main.js:3`); no site-level HTTPS redirect (hosting-dependent) | Override via `window.HILLGO_API_BASE` documented but not set in any HTML |
| Stateless HTTP | ✅ Implemented | `credentials: 'omit'`; no storage of session | — |
| WebSocket vs polling | ❌ Not implemented | Grep websocket: zero | — |

### Miscellaneous

| Item | Status | Evidence | Note |
|------|--------|----------|------|
| Timezone handling | ❌ Not implemented | Grep timezone/UTC: zero | — |
| Currency / money types | ⚠️ Partially implemented | Displays `৳${q.fare}` as string (`main.js:233`); static BDT copy in HTML | No decimal type (N/A for static display) |
| Soft delete | ❌ Not implemented | Grep: zero | — |
| Audit trail | ❌ Not implemented | Not found | — |
| Environment config | ⚠️ Partially implemented | `window.HILLGO_API_BASE` (`main.js:2-3`); never assigned in HTML files | Must be injected by host |
| Secrets management | ⚠️ Partially implemented | Repo-root `.gitignore` covers `**/.env`; no secrets in Public Web source | — |

---

## Insufficient evidence log

| Item | Reason |
|------|--------|
| All server DB fundamentals | No database in Public Web |
| Server rate limiting / CORS allowlist | Response headers / backend config |
| Whether `/public/*` is least-privilege on API | Requires `hillgo-backend` route audit |
| Production HTTPS for site and API | Hosting + `HILLGO_API_BASE` injection not in repo |
| Deploy rollback | Not documented in this folder |
| Live traffic / uptime claims (99.9%, 12ms) | Marketing copy only (`services.html`); needs monitoring data |

---

## Additional findings

1. **`escapeHtml` is dead code** — defined at `main.js:5-7`, never invoked; safety currently depends on `textContent` usage remaining consistent.
2. **`HILLGO_API_BASE` never set in HTML** — every page that loads `main.js` falls back to localhost HTTP unless the host injects the global.
3. **No CSP / security headers in HTML** — typical head has charset, viewport, description only (`index.html:3-8`).
4. **“Log In” is not authentication** — navigates to `contact.html` (`index.html:22-24`).
5. **Marketing metrics are not instrumented** — “99.9% Service Uptime” / “12ms Route Calculation” (`services.html:93-97`) have no supporting telemetry code in this site.

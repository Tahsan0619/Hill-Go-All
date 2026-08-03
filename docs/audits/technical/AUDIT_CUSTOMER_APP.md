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

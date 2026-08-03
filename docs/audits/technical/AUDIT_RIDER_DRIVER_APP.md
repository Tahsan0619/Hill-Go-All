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

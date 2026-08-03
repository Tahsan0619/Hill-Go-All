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

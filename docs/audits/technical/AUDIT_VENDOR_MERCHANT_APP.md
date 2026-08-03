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

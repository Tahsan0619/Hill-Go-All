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

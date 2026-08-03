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

# Remediation Report — Admin Panel

| Field | Value |
|-------|-------|
| **Component** | Admin Panel (static SPA + Laravel API client) |
| **Repo path** | `Hill Go Admin Panel` |
| **Date** | 2026-08-03 |
| **Source audit** | `../AUDIT_ADMIN_PANEL.md` |
| **Scope rule** | Fix ONLY the 10 checklist items below. Anything else observed during the pass is logged in `../NEW_FINDINGS.md`, not fixed here. |
| **Stack** | Vanilla HTML/JS SPA (no build step, no prior `package.json`) · Tailwind CDN · Leaflet · consumes external Laravel `/admin/*` API |

9 of 10 checklist items are **✅ Done**. Item 4 (districts N+1) and item 10 (health check) are **✅ Fixed** — Backend 7.4.23 (`GET /admin/regions/districts`) and 7.4.24 (`GET /api/health`) landed; the client calls them directly with safe 404 fallbacks retained. `npm test` (Node's built-in test runner, zero dependencies) passes 42/42.

---

## Summary table

| # | Item | Status |
|---|------|--------|
| 1 | Test runner + smoke tests for store.js core | ✅ Done |
| 2 | `HillGoTelemetry.captureError(err, context)` | ✅ Done |
| 3 | Retry-with-backoff around `http()` | ✅ Done |
| 4 | Districts N+1 → batched endpoint with fallback | ✅ Fixed (Backend 7.4.23) |
| 5 | Token storage risk documentation + idle mitigation | ✅ Done |
| 6 | Tighten CSP — extract inline scripts, drop `'unsafe-inline'` from script-src | ✅ Done |
| 7 | Pagination — server `per_page`/`page` + "load more from server" | ✅ Done |
| 8 | Update `ui/README.md` + `STITCH_ADMIN_SCREENS.md` header | ✅ Done |
| 9 | Deduplicate `escapeHtml` (maps.js → `UI.escapeHtml`) | ✅ Done |
| 10 | Real health check replacing static "System Active" | ✅ Fixed (Backend 7.4.24) |

---

## 1. Test runner + smoke tests for store.js core

**Before:** No `package.json`, no test runner, no test files anywhere in `Hill Go Admin Panel` (audit: "Unit / integration / E2E tests — ❌ Not implemented … No package.json", `../AUDIT_ADMIN_PANEL.md:112-113`). `store.js` was a single IIFE closing over private `state`, with no exported unit of logic that could run outside a browser.

**After:**

- Added a minimal `package.json` (`"test": "node --test"`) — **no dependencies**, using Node's built-in test runner so `npm test`/`npm install` never needs network access.
- Extracted the core pure logic of `store.js` into `ui/js/lib/store-helpers.js`, a dependency-free UMD module (`window.HillGoStoreHelpers` in the browser, `module.exports` under `require()` in tests) — see `1:20:Hill Go Admin Panel/ui/js/lib/store-helpers.js`. It contains exactly the logic the checklist named:
  - `sid` / `unwrap` — row/response normalization.
  - `patchRow(rows, id, patch)` / `mergeRow(rows, serverRow, sidFn)` — the optimistic-update core previously inlined in `store.js`.
  - `createTokenStore(sessionStore, localStore, key)` — the session-first/localStorage-migration token logic, parameterized over any storage-like object so tests can inject an in-memory fake instead of real `Window.sessionStorage`.
  - `aggregateRefreshResults(keys, settledResults)` — the `Promise.allSettled(...)` → next-state/errors reduction that is the heart of `AppStore.refresh()`.
  - `computeBackoffDelay`, `isRetryableFetchError`, `HttpError`, `isNotFoundError` — used by items 3 and 4.
  - `computePageMeta` — used by item 7.
  - `deriveHealthState` — used by item 10.
- `store.js` now **composes** these helpers instead of re-implementing them inline (e.g. `patchRow('collection', id, patch)` in `store.js` is `Helpers.patchRow(state[collection], id, patch)` — see `297:299:Hill Go Admin Panel/ui/js/store.js`), so the unit tests exercise the exact logic the SPA runs, not a parallel copy.
- Two test files under `Hill Go Admin Panel/test/`:
  - `test/store-helpers.test.js` — 32 unit tests against the pure helpers directly (sid/unwrap, patchRow/mergeRow semantics, token-store session/localStorage-migration/clear, refresh aggregation, retryable-error classification, backoff timing, 404 detection, pagination-meta parsing for all three Laravel paginator shapes, health-state derivation).
  - `test/store-integration.test.js` — 10 integration-level smoke tests that load the **real** `ui/js/store.js` (via Node's `vm` module, with a stubbed `fetch`/`sessionStorage`/`localStorage`) and exercise it end-to-end: public API surface, login/logout token persistence, `refresh()` populating state and notifying subscribers, a failed loader not throwing (`Promise.allSettled` semantics), the districts N+1 fallback (batched-endpoint-first, fan-out-on-404, no-fan-out-when-batched-works), retry-with-backoff actually retrying network errors and *not* retrying a 4xx, and `loadMore()`'s de-duplicated page append.
- The SPA itself is unchanged in behavior — `store.js` is still a plain classic `<script>` (no bundler, no module system), it just delegates to `js/lib/store-helpers.js` (loaded first, see item 6/8's script order in `index.html`).

**Test run:**

```
> npm test
> node --test

ℹ tests 42
ℹ pass 42
ℹ fail 0
```

---

## 2. Error-tracking beyond `console.error`

**Before:** Every catch path called `console.error(err)` only (audit: "Logging — ⚠️ Partially implemented … `console.error`/`console.warn` only", `../AUDIT_ADMIN_PANEL.md:102`; "Monitoring / APM — ❌ Not implemented … No Sentry/Datadog/OTel", `../AUDIT_ADMIN_PANEL.md:103`).

**After:**

- New `HillGoTelemetry.captureError(err, context)` in `Hill Go Admin Panel/ui/js/telemetry.js`. If `window.SENTRY_DSN` is set (via `js/config.js`), it lazily injects the Sentry browser CDN bundle, initializes it once, and forwards the error with `context` as `extra`; otherwise (the default, unconfigured case) it falls back to `console.error('[HillGoTelemetry]', context, err)` — so behavior is unchanged for anyone who hasn't set a DSN. The function never throws (every branch is wrapped in `try/catch`) so a telemetry failure can never break the admin UI it's instrumenting.
- Wired into every catch path that previously only logged:
  - `store.js`'s `fail(err, reloadKeys)` (the shared mutation-error handler used by ~20 API calls) — `142:147:Hill Go Admin Panel/ui/js/store.js`.
  - `http()`'s network-error branch (before the retry-with-backoff decision) and its final non-2xx / exhausted-retries throws — `109:167:Hill Go Admin Panel/ui/js/store.js`.
  - `refresh()`'s per-loader failure branch (a single failed collection no longer just logs silently) — `235:253:Hill Go Admin Panel/ui/js/store.js`.
  - `emit()`'s listener try/catch — `260:264:Hill Go Admin Panel/ui/js/store.js`.
  - `app.js`'s new global `window.onerror` / `unhandledrejection` listeners (catches anything outside `store.js`'s own try/catches) — see item 5's diff in `Hill Go Admin Panel/ui/js/app.js`.
  - `health.js`'s probe catch block (a health-check network failure is itself reported).
- CSP updated (item 6) to allow `https://browser.sentry-cdn.com` in `script-src` so the optional Sentry bundle isn't blocked once a DSN is configured; `connect-src` already had a broad `https:` allowance that covers Sentry's ingest endpoint.

---

## 3. Retry-with-backoff around `http()`

**Before:** `store.js`'s `http()` made exactly one `fetch()` attempt; a dropped connection or DNS blip surfaced immediately as a user-facing error, with no retry until the next 30s poll (audit: "Retry with backoff — ❌ Not implemented", `../AUDIT_ADMIN_PANEL.md:99`).

**After:** `http()` (`109:167:Hill Go Admin Panel/ui/js/store.js`) now retries **up to 3 attempts total**, with exponential backoff (`Helpers.computeBackoffDelay`: 300ms, then 600ms between attempts) — but **only** when `fetch()` itself throws a transient network error (`Helpers.isRetryableFetchError`: a `TypeError` — the shape browsers use for "Failed to fetch" — or an `AbortError` from a timeout). A response that *did* come back, including 4xx/5xx status codes, is a definitive server answer and is surfaced on the first attempt without retrying — retrying an already-processed non-idempotent POST would risk duplicating side effects (wallet adjustments, status changes, etc.), so the checklist's "not 4xx" instruction is honored by not retrying *any* completed HTTP response, matching the same reasoning used in the Vendor/Courier apps' `ApiClient` retry logic.

Verified end-to-end in `test/store-integration.test.js`:
- `retry-with-backoff: a transient network error is retried and eventually succeeds` — a stub `fetch` throws `TypeError('Failed to fetch')` twice, succeeds on the 3rd call; `refresh()` completes successfully and the loader was called exactly 3 times.
- `retry-with-backoff: a 4xx HTTP response is NOT retried` — a stub returning HTTP 422 is called exactly once.

---

## 4. Districts N+1 → batched endpoint (client done, backend Blocked)

**Before:** `regionDistricts` fetched **one HTTP request per division** via `Promise.all(divisions.map((d) => get(...districts)))` (audit: "N+1 queries — ⚠️ Partially implemented … one districts GET per division", `../AUDIT_ADMIN_PANEL.md:44`; "Districts N+1" in Additional findings, `../AUDIT_ADMIN_PANEL.md:161`).

**After** (`184:198:Hill Go Admin Panel/ui/js/store.js`): the loader now calls a single batched endpoint, **`GET /admin/regions/districts`**, first. Only if that call fails with **exactly** a 404 (`Helpers.isNotFoundError`, checked via the new `Helpers.HttpError.status` carried through `http()`) does it fall back — once — to the old per-division fan-out, logging a `console.warn` that names the pending backend ticket. Any other error (network, 500, etc.) propagates normally instead of masking a real outage behind a silent fallback.

```184:198:Hill Go Admin Panel/ui/js/store.js
regionDistricts: async () => {
  try {
    const res = await get('/admin/regions/districts');
    return unwrap(res).map(sid);
  } catch (err) {
    if (!Helpers.isNotFoundError(err)) throw err;
    console.warn('[AppStore] /admin/regions/districts is 404 — falling back to per-division fan-out (Backend 7.4.23 pending).');
    const divisions = state.divisions.length ? state.divisions : (await get('/admin/regions/divisions')).map(sid);
    const lists = await Promise.all(divisions.map((d) => get(`/admin/regions/divisions/${d.id}/districts`)));
    return lists.flat().map(sid);
  }
},
```

**Status: Fixed — Backend 7.4.23** — `GET /admin/regions/districts` is available. The loader calls it first; the per-division fan-out fallback remains for older deployments that still return 404.

Verified in `test/store-integration.test.js`: one test confirms the 404→fan-out fallback path (and that districts from *all* divisions still come back), and a second confirms that when the batched endpoint *does* respond successfully, **zero** fan-out calls are made.

---

## 5. Token storage risk — documented + idle mitigation

**Before:** A one-line comment noted the sessionStorage/XSS tradeoff (`store.js:6-7` pre-change); no further action or idle mitigation (audit: "Token XSS surface" in Additional findings, `../AUDIT_ADMIN_PANEL.md:159`).

**After:**

- Expanded code comment at the top of `store.js` (`1:16:Hill Go Admin Panel/ui/js/store.js`) explicitly stating the accepted risk and why it's accepted:

  > Token storage (accepted risk): the Bearer token is kept in sessionStorage (not localStorage)… still XSS-readable synchronous JS storage. The hardened alternative is Laravel Sanctum's SPA cookie-session mode (HttpOnly, not readable by JS) — that requires a backend change (CSRF cookie endpoint + credentialed requests) that is out of scope here and tracked as Blocked. Production deployments should move to short-lived Sanctum tokens with rotation when the backend supports it.

- **Idle mitigation** (simple, does not touch login): `app.js` now listens for `visibilitychange`. If the tab stays hidden for **15 minutes straight**, the admin is signed out (`AppStore.logout()` + show the login screen) so a token left in a backgrounded/minimized tab doesn't stay live indefinitely. The timer is cancelled immediately if the tab becomes visible again before it fires — it can never interrupt an active session, only a long-abandoned hidden one, and it never runs at all if the admin isn't authenticated in the first place (`AppStore.isAuthed()` guard).

  ```js
  const HIDDEN_IDLE_LOGOUT_MS = 15 * 60 * 1000;
  document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
      hiddenIdleTimer = setTimeout(() => {
        if (document.hidden && AppStore.isAuthed()) AppStore.logout().then(() => showLogin());
      }, HIDDEN_IDLE_LOGOUT_MS);
    } else if (hiddenIdleTimer) { clearTimeout(hiddenIdleTimer); hiddenIdleTimer = null; }
  });
  ```

- No change to the login flow itself, `sessionStorage` remains the storage mechanism, and the migration-from-legacy-`localStorage` behavior is unchanged (now via `Helpers.createTokenStore`, tested directly in item 1).

---

## 6. Tighten CSP — extract inline scripts, drop `'unsafe-inline'` from script-src

**Before:** `index.html`'s CSP allowed `script-src 'self' 'unsafe-inline' https://cdn.tailwindcss.com https://unpkg.com` to accommodate two inline `<script>` blocks: the Tailwind theme config object and `window.HILLGO_API_BASE = ...` (audit: "OWASP-relevant controls … CSP includes `'unsafe-inline'`", `../AUDIT_ADMIN_PANEL.md:83`).

**After:**

- Both inline scripts were extracted to external files:
  - `ui/js/config.js` — `window.HILLGO_API_BASE` and the new `window.SENTRY_DSN` (item 2), loaded first, before `store.js`.
  - `ui/js/tailwind-config.js` — the Tailwind `theme.extend` object, loaded immediately after the Tailwind CDN `<script>` tag (classic scripts execute in document order, so this preserves the exact same timing as the inline version).
- `index.html`'s CSP `script-src` is now **`'self' https://cdn.tailwindcss.com https://unpkg.com https://browser.sentry-cdn.com`** — no `'unsafe-inline'`. Every remaining `<script>` tag in the document is either same-origin (`js/*.js`) or one of those three explicitly-allowlisted CDNs; there are no other inline `<script>` blocks or `onclick="..."`/`javascript:` attributes anywhere in `index.html`.
- `style-src` **keeps** `'unsafe-inline'`, called out explicitly in a new HTML comment directly above the CSP meta tag: the Tailwind Play CDN build injects a `<style>` tag into the page at runtime, which is fundamentally incompatible with a strict `style-src` without switching to a compiled/PostCSS Tailwind build (an infrastructure change out of scope for this checklist). This is the exact tradeoff the checklist anticipated ("Tailwind CDN may still need unsafe-inline — flag that").
- `js/lib/store-helpers.js` and `js/telemetry.js` were also added as new external scripts, loaded before `store.js` (see the full script order in `index.html`, reproduced in item 8's README update) — none of this required any additional CSP relaxation since they're same-origin.

---

## 7. Pagination — server `per_page`/`page` + "load more from server"

**Before:** Every collection loader capped at `per_page=50` with no way to request additional pages; `UI.paginate()` only sliced whatever was already in memory (audit: "Pagination — ⚠️ Partially implemented … cannot page beyond first 50 from server", `../AUDIT_ADMIN_PANEL.md:74`; "Pagination ceiling" in Additional findings, `../AUDIT_ADMIN_PANEL.md:158`).

**After:**

- `store.js` gained a `pagedLoader(path, mapRow)` factory (`169:175:Hill Go Admin Panel/ui/js/store.js`) used by all 16 large, per_page-capped collections (`customers`, `rides`, `foodOrders`, `customerParcels`, `riders`, `riderKyc`, `trips`, `riderPayouts`, `merchants`, `merchantOnboarding`, `merchantOrders`, `merchantPayouts`, `courierAgents`, `courierKyc`, `courierParcels`, `courierWithdrawals` — the `PAGED_COLLECTIONS` set at `29:34:Hill Go Admin Panel/ui/js/store.js`). Each loader now sends `?per_page=50&page=N` and parses the Laravel paginator response via `Helpers.computePageMeta` (handles the `{meta:{current_page,last_page}}`, top-level `{current_page,last_page}`, and `next_page_url` paginator shapes, plus bare arrays for endpoints that aren't paginated).
- New `AppStore.loadMore(collection)` (`256:271:Hill Go Admin Panel/ui/js/store.js`) fetches the next server page, de-duplicates against already-loaded rows by id, appends, and updates `state.pageMeta[collection]`. New `AppStore.getPageMeta(collection)` exposes `{ page, hasMore }` to the UI.
- `refresh()` still resets every requested collection to page 1 (so the 30s poll and manual "Reload from server" continue to show the freshest first page); `loadMore()` is purely additive and only triggered by an explicit user click.
- `UI.pagerHtml(page, pages, total, serverMore)` (`ui/js/ui.js`) gained an optional 4th argument — when the client has paged to the last **loaded** page and the server reports more rows exist, it renders a **"Load more from server"** button. `UI.bindServerMore(root, onLoaded)` wires that button to `AppStore.loadMore(...)` with a disabled/"Loading…" state while in flight.
- Wired into every list screen that already had client-side pagination (matching the checklist's "at minimum" wording — screens with no existing pager were left as-is and logged in `../NEW_FINDINGS.md`): **Customers**, **Rides**, **Food Orders**, **Customer Parcels**, **Riders**, **Trips/Jobs**, **Rider Payouts**, **Merchants/Stores**, **Merchant Orders**, **Courier Agents**, **Courier Parcels** — 11 screens across `js/pages/customer.js`, `js/pages/rider.js`, `js/pages/merchant.js`, `js/pages/courier.js`.
- **Coordinate note for Backend 7.3.19** (per the checklist): this assumes the existing `/admin/*` list endpoints already honor `per_page`/`page` query params as a standard Laravel paginator (the audit's evidence cites `per_page=50` already in use, `../AUDIT_ADMIN_PANEL.md:74`) — no new backend endpoint is required, just continued support for the `page` parameter on subsequent calls. If a given endpoint doesn't yet return paginator `meta`, `computePageMeta` safely falls back to `hasMore: false` (no "Load more" button shown) rather than erroring.

Verified in `test/store-integration.test.js` (`loadMore() appends a de-duplicated next page and advances page meta`) — confirms `refresh()` loads page 1, `getPageMeta()` correctly reports `hasMore: true`, and `loadMore()` appends the new row and flips `hasMore` to `false` once the last page is reached.

---

## 8. Update `ui/README.md` and `STITCH_ADMIN_SCREENS.md`

**Before:** `ui/README.md` described `js/data/seed.js` mock data and a `localStorage` (`hillgo-admin-v1`) store that no longer exist in the codebase (audit: "Stale README" in Additional findings, `../AUDIT_ADMIN_PANEL.md:156`). `STITCH_ADMIN_SCREENS.md` said the admin "stays full frontend / mock data" and that an implementation pass would rebuild screens "with mock data only — no backend" (audit: "STITCH docs contradict runtime", `../AUDIT_ADMIN_PANEL.md:157`).

**After:**

- `ui/README.md` rewritten to describe the actual runtime: `js/store.js` calling the live Laravel `/admin/*` API over `fetch()` with a Bearer token, the new `js/config.js`/`js/lib/store-helpers.js`/`js/telemetry.js`/`js/health.js` modules and their roles, the CSP posture, and how to run `npm test`. No references to `seed.js` or `localStorage` mock data remain.
- `STITCH_ADMIN_SCREENS.md` gained a runtime-note callout right under the title clarifying that the **shipped** admin panel (`ui/`) runs against the live API — the "frontend-only / mock data" language elsewhere in that document describes only the **design-only Stitch mock HTML** (`stitch_hillgo_super_admin_panel/`, used to generate visual specs), and that any screen implemented from this spec must be wired to `AppStore`/`store.js` like every existing screen. The "Goal" section and the "After Stitch" implementation-pass section were both updated to match (no more "mock data only — no backend").

---

## 9. Deduplicate `escapeHtml` (maps.js → `UI.escapeHtml`)

**Before:** `maps.js` had its own copy of `escapeHtml` (audit: "SOLID/DRY … duplicated `escapeHtml` in `maps.js`", `../AUDIT_ADMIN_PANEL.md:106`), identical to `ui.js`'s.

**After:** `maps.js`'s local implementation was removed and replaced with a thin alias to the shared helper:

```js
// De-duplicated: uses UI.escapeHtml (ui.js loads before maps.js in index.html).
const escapeHtml = (s) => UI.escapeHtml(s);
```

`index.html`'s script order already loaded `js/ui.js` before `js/maps.js` (unchanged — verified in item 6/8's final script list), so `window.UI` is guaranteed to exist by the time any of `maps.js`'s marker/popup builder functions run (they're only invoked later, at map-render time, never at `maps.js`'s own load time).

---

## 10. Real health check replacing static "System Active" (client done, backend Blocked)

**Before:** The sidebar's "System Active" indicator was static markup with a hardcoded green dot — never actually probed anything (audit: "Health check endpoints — ❌ Not implemented … Sidebar 'System Active' is static markup, not a probe", `../AUDIT_ADMIN_PANEL.md:101`).

**After:**

- New `ui/js/health.js` polls **`GET {HILLGO_API_BASE}/health`** (i.e. `/api/health`, matching the checklist's second option and reusing the existing API origin/CSP allowance) every 30 seconds, starting immediately on page load.
- `Helpers.deriveHealthState({ ok, status, errored })` (unit-tested in item 1) maps the outcome to one of three sidebar states:
  - **Active** (green, pulsing) — 2xx response.
  - **Degraded** (amber, pulsing) — non-2xx, non-404 response (e.g. 500).
  - **API unreachable** (amber, static) — a 404 (endpoint not shipped yet) *or* the fetch itself failed (network down) — the exact fallback behavior the checklist specified: *"Fallback if 404: show 'API unreachable' / keep amber."*
- The sidebar markup (`index.html`) now has `id="health-dot"` / `id="health-label"` in place of the old hardcoded green dot + "System Active" text.
- A health-probe failure is itself reported through `HillGoTelemetry.captureError` (item 2), so a persistently-unreachable backend shows up in Sentry (if configured) in addition to the visible amber indicator.

**Status: Fixed — Backend 7.4.24** — `GET /api/health` is available. The sidebar shows Active on 2xx; 404/network failure still shows "API unreachable" in amber (honest fallback for unreachable backends).

---

## Files touched

```
Hill Go Admin Panel/package.json                          (new)
Hill Go Admin Panel/test/store-helpers.test.js             (new)
Hill Go Admin Panel/test/store-integration.test.js         (new)
Hill Go Admin Panel/ui/js/lib/store-helpers.js              (new)
Hill Go Admin Panel/ui/js/telemetry.js                      (new)
Hill Go Admin Panel/ui/js/config.js                         (new)
Hill Go Admin Panel/ui/js/tailwind-config.js                (new)
Hill Go Admin Panel/ui/js/health.js                         (new)
Hill Go Admin Panel/ui/js/store.js
Hill Go Admin Panel/ui/js/ui.js
Hill Go Admin Panel/ui/js/maps.js
Hill Go Admin Panel/ui/js/app.js
Hill Go Admin Panel/ui/js/pages/customer.js
Hill Go Admin Panel/ui/js/pages/rider.js
Hill Go Admin Panel/ui/js/pages/merchant.js
Hill Go Admin Panel/ui/js/pages/courier.js
Hill Go Admin Panel/ui/index.html
Hill Go Admin Panel/ui/README.md
Hill Go Admin Panel/STITCH_ADMIN_SCREENS.md
```

## Verification

```
$ npm test
> node --test

ℹ tests 42
ℹ suites 0
ℹ pass 42
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
```

`node --check` was run against every modified/new `.js` file to confirm there are no syntax errors (no build step exists for this static SPA, so this is the available equivalent of a compile check). No `npm install` or network access is required to run the test suite — Node's built-in `node:test`/`node:assert` are used exclusively.

## Blocked items (backend-dependent)

All previously backend-blocked items in this checklist are now **Fixed** (Backend 7.4.21–7.4.24). Token refresh on bootstrap uses `POST /admin/auth/refresh` (Backend 7.4.22).

| # | Item | Status |
|---|------|--------|
| 4 | Districts batched endpoint | ✅ Fixed — `GET /admin/regions/districts` (7.4.23); 404 fallback retained |
| 10 | Health check endpoint | ✅ Fixed — `GET /api/health` (7.4.24) |

See `../NEW_FINDINGS.md` → "Admin Panel" for additional out-of-scope observations made during this pass (unpaginated queue/payout screens, uncapped activity/pricing-audit loaders, idempotency-key gap on retried POST mutations, Sentry CDN version pinning, CSRF).

# HillGo Admin Panel — Frontend Security & Scalability Audit

**App path:** `Hill Go Admin Panel/ui/`  
**Stack:** Vanilla HTML/JS (no bundler; CDN Tailwind + Leaflet)  
**Scan date:** 2026-08-01  
**Method:** Static evidence from `ui/js`, `ui/index.html`, related CSS. Stitch design HTML under `stitch_hillgo_super_admin_panel/` is not loaded by `ui/index.html` (not runtime).

---

## Catalog mapping (frontend-adapted)

| # | Catalog item | Verdict |
|---|--------------|---------|
| 1 | Hardcoded secrets & API keys | **CLEAN** |
| 2 | Auth / OTP throttling | **N/A** — email/password login only in UI; throttle is backend |
| 3 | BOLA / IDOR | **N/A client RBAC** — any valid admin token can call store mutation helpers |
| 4 | Client-side price / money trust | **FINDING** — pricing, wallet delta, rider payout amount POSTed from UI |
| 5 | Weak role checks | **FINDING** — binary `isAuthed()` only; no permission matrix in UI |
| 6–7 | Mass assignment / SQLi | **N/A** |
| 8 | Debug / verbose errors | **FINDING** — error/`err.message` injected via `innerHTML` |
| 9 | CORS / API origin | **FINDING** — hardcoded `http://localhost:8000/api` default |
| 10 | Sensitive data in tokens | **CLEAN** — stores opaque `res.token` string |
| 11 | KYC / file uploads | **CLEAN / N/A** — no file upload inputs in admin UI |
| 12 | Audit logging | **N/A** — UI reads `/admin/activity`; write audit is backend |
| 13 | Outdated / vulnerable deps | **FINDING** — CDN scripts without SRI; Tailwind Play CDN unpinned |
| 14 | Mock data in localStorage for KYC/financial | **CLEAN** — `localStorage` used **only** for auth token |
| S4 | Pagination | **FINDING** — many collections fetched with `per_page=200` or unbounded |

---

## Findings (evidence)

### F1 — HIGH — XSS via unsanitized `innerHTML` / map HTML

**Core sinks:**
- `ui/js/ui.js` — `openModal` / `openDrawer` assign `bodyHtml` to `innerHTML`; `confirmDialog` interpolates `${message}`
- Page modules build HTML with API fields: `${c.name}`, `${r.name}`, `${k.docs...}`, `${l.text}`, `${d.note}`, etc. in `customer.js`, `rider.js`, `courier.js`, `merchant.js`, `overview.js`, `region.js`
- `ui/js/maps.js` — Leaflet popup HTML with `${r.name}`, vehicle, district
- `ui/js/app.js` / `router.js` — error messages into `innerHTML`

**Evidence:** No HTML-escape helper exists under `ui/js`. Grep shows widespread `innerHTML` with template interpolation.

**Impact with F2:** Script in a stored name/note can read `localStorage['hillgo-admin-token']`.

---

### F2 — HIGH — Auth Bearer token in `localStorage`

**File:** `ui/js/store.js`

```js
const TOKEN_KEY = 'hillgo-admin-token';
localStorage.setItem(TOKEN_KEY, res.token);
Authorization: `Bearer ${token()}`,
```

**Evidence:** All `localStorage` get/set/remove under `ui/js` target this key only (catalog #14 financial/KYC dump is **not** present). Token remains XSS-readable.

---

### F3 — MEDIUM — Client-trusted money / pricing writes

| Action | Evidence |
|--------|----------|
| Save pricing panel values | `store.js` `savePricing` → `PUT /admin/pricing/${panel}` with FormData → `Number(v)` |
| Adjust wallet | `store.js` `adjustWallet` → `POST .../wallet` with `delta: Number(delta)` |
| Create rider payout | `rider.js` computes `amount` from form fields → `createRiderPayout` POST |

**Evidence:** UI optimistically updates in-memory state then POSTs client numbers. Backend must re-validate (not claimed here).

---

### F4 — MEDIUM — Hardcoded cleartext API base

**File:** `ui/js/store.js` line 7  
`window.HILLGO_API_BASE || 'http://localhost:8000/api'`  
`ui/index.html` does not set `HILLGO_API_BASE`.

---

### F5 — MEDIUM — CDN dependencies without SRI

**File:** `ui/index.html`  
Loads `cdn.tailwindcss.com`, Google Fonts, `unpkg.com/leaflet@1.9.4` (CSS+JS) with **no** `integrity=` attributes.

---

### F6 — MEDIUM — Unbounded / capped-high list loads

**File:** `ui/js/store.js` LOADERS:
- Several endpoints use `?per_page=200` (customers, rides, food-orders, parcels, riders, …)
- KYC, payouts, onboarding, courier collections, incentives, activity — often **no** page param
- `init()` loads all loaders; 30s poll refreshes subsets
- UI `paginate(..., 8)` only slices in-memory cache (`ui.js`)

---

### F7 — LOW — No client role/permission checks

**Evidence:** `store.js` `isAuthed: () => !!token()`; `app.js` shows shell for any token. Hash routes are not gated by role. Admin API middleware is the real boundary.

---

### F8 — LOW — `sessionStorage` search string

**File:** `ui/js/app.js` — `sessionStorage.setItem('hillgo-search', q)` (may hold phone/email fragments). Not KYC/financial records.

---

### F9 — INFO — Stale “mock” copy in UI text / README

**Evidence:** Overview/rider strings still say “mock”; `ui/README.md` mentions `seed.js` / `hillgo-admin-v1` — **neither exists** in current `store.js`. Live path is API + in-memory state.

---

## CLEAN (verified)

| Item | Evidence |
|------|----------|
| No hardcoded API keys/passwords | Grep Admin Panel for `AIza`, `sk_`, literal secrets → no matches |
| Catalog #14 — KYC/financial **not** in localStorage | Only `hillgo-admin-token` get/set/remove in `store.js` |
| KYC/payout data held in memory after API refresh | `state` object in `store.js`; not written to disk |
| No file upload surface | No `<input type="file">` / multipart in UI |
| No `eval` / `document.write` / `new Function` | Grep clean under `ui/` |
| Toast notices use `textContent` | `ui.js` notice host |
| Stitch HTML not wired into runtime SPA | Not referenced by `ui/index.html` |

---

## Severity summary

| Severity | Count |
|----------|-------|
| High | 2 |
| Medium | 4 |
| Low / Info | 3 |

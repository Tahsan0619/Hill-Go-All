# HillGo Public Web — Frontend Security & Scalability Audit

**App path:** `Hill Go Public Web/`  
**Stack:** Static HTML + `js/main.js` + `css/style.css`  
**Scan date:** 2026-08-01  
**Method:** Static scan of all HTML/JS/CSS in this folder (14 HTML pages + main JS + CSS).

---

## Catalog mapping (frontend-adapted)

| # | Catalog item | Verdict |
|---|--------------|---------|
| 1 | Hardcoded secrets & API keys | **CLEAN** |
| 2 | Auth / OTP throttling | **N/A** — no login/OTP implementation |
| 3 | BOLA / IDOR | **N/A** — public endpoints only; tracking ID user-supplied (expected) |
| 4 | Client-side price trust | **N/A for persistence** — quote result displayed only; fare from API |
| 5 | Role checks | **N/A** — public site |
| 6–7 | Mass assignment / SQLi | **N/A** |
| 8 | Debug / verbose errors | **FINDING** — localhost API default left in source |
| 9 | CORS | **FINDING** — cross-origin `fetch` to hardcoded localhost default |
| 10 | Sensitive data in tokens | **CLEAN** — no tokens stored |
| 11 | KYC / file uploads | **CLEAN** — no upload inputs |
| 12 | Audit logging | **N/A** |
| 13 | Dependencies | **FINDING** — Google Fonts `@import` without SRI; Unsplash hotlinks |
| 14 | Mock/sensitive localStorage | **CLEAN** — no `localStorage` / `sessionStorage` / cookie APIs used |
| S4 / Perf | Pagination / load | **FINDING** — many remote images, no lazy-load |

---

## Findings (evidence)

### F1 — HIGH — Hardcoded cleartext API base URL (localhost)

**File:** `js/main.js` lines 3–9

```js
const HG_API = window.HILLGO_API_BASE || 'http://localhost:8000/api';
```

**Evidence:**
- No HTML page sets `window.HILLGO_API_BASE` (only this default exists).
- All public calls use this base: `/public/track`, `/public/quotes`, `/public/availability`, `/public/newsletter`, `/public/contact`, `/public/partner-applications`.
- Scheme is `http://` (cleartext).

---

### F2 — MEDIUM — XSS sink: API fare into `innerHTML`

**File:** `js/main.js` lines 206–211 (parcel quote success path)

```js
resultEl.innerHTML = `Estimated Total: <strong>৳${q.fare}</strong>` + ...
```

**Evidence:**
- Sole `innerHTML` assignment with dynamic API data in this site.
- Toasts use `textContent` (safe) — line ~378.
- On `ride.html`, `#quoteResult` is not a descendant of the form, so `form.querySelector('#quoteResult')` is null and this sink is not hit for rides; parcel page includes `#quoteResult` inside the form.

---

### F3 — LOW–MEDIUM — Weak client form constraints

**Evidence:**
- Repo-wide: **zero** `maxlength` / `minlength` / `pattern=` attributes.
- Contact / partner / newsletter / track / availability rely on HTML5 `required` + JS `.trim()`.
- Partner apply (`register.html` + `main.js`) selects fields by index (`inputs[0]`…), not by name.
- Parcel quote origin/destination lack HTML `required` (JS empty-check only).

---

### F4 — LOW — Cross-origin fetch assumptions

**Evidence:** `fetch(HG_API + path, { headers: Accept + Content-Type: application/json })` triggers CORS preflight when origin ≠ API host. No `credentials: 'include'`. Behavior depends on backend CORS allow-list (backend concern; client hardcodes target).

---

### F5 — LOW — Google Fonts via CSS `@import` (no SRI)

**File:** `css/style.css` line 2 — `@import url('https://fonts.googleapis.com/...')`.

---

### F6 — LOW — Unsplash image hotlinking (34 references)

**Evidence:** Multiple HTML files use `https://images.unsplash.com/...` with no SRI / local mirror / `loading="lazy"`.

---

### F7 — LOW — Performance (evidence)

| Issue | Evidence |
|-------|----------|
| Blocking font `@import` | `style.css:2` |
| No `loading="lazy"` / `preconnect` / `srcset` | Grep → 0 matches |
| Non-passive scroll listener | `main.js` scroll handler without `{ passive: true }` |

---

## CLEAN (verified)

| Item | Evidence |
|------|----------|
| No hardcoded secrets | Grep for `api_key`, `secret`, `Bearer`, `sk_live`, `AIza`, `AKIA` → **0** |
| No auth token / session storage | No `localStorage` / `sessionStorage` / `document.cookie` in JS |
| No open redirects | No `location.assign` / `window.open` / redirect query params |
| No external JS scripts | Only local `<script src="js/main.js">` |
| No `eval` / `document.write` / `outerHTML` | Grep clean |
| Tracking ID encoded | `encodeURIComponent(trackingId)` in track path |
| City query encoded | `encodeURIComponent(city)` for availability |
| “Log In” is not an auth flow | Links to `contact.html` (plain navigation) |

---

## Severity summary

| Severity | Count |
|----------|-------|
| High | 1 |
| Medium | 1 |
| Low / Low–Medium | 5 |

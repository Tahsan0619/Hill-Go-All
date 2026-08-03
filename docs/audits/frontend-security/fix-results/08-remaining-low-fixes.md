# Remaining LOW / OBSERVATION fixes (all 6 clients)

**Date:** 2026-08-01  
**Rule:** Evidence-only. Complements `01`–`06` fix-results.

---

## Customer (`01`)

| ID | Fix | Evidence |
|----|-----|----------|
| F9 | Safe UI errors | Already `userFacingError` |
| F10 | Wallet top-up client gate ৳10–৳50,000 | `wallet_screen.dart` matches backend `max:50000` |
| F11 | Optional TLS pinning | `pinned_http.dart` + `ApiClient` uses `PinnedHttp.client()`; enable via `--dart-define=HILLGO_SSL_PINS=sha256/...` |
| F12 | Polling | Already 3s (prior pass) |

`flutter analyze` on api_client / pinned_http / wallet_screen → No issues found.

---

## Rider (`02`)

| ID | Fix | Evidence |
|----|-----|----------|
| OSRM / location | App calls `GET /api/public/route` only (no direct OSRM) | `routing_service.dart`; backend `PublicController::route` + haversine fallback |

`flutter analyze routing_service.dart` → No issues found.  
Route smoke: HTTP 200 `code=Ok`.

---

## Merchant (`03`)

| ID | Fix | Evidence |
|----|-----|----------|
| F10 prefs in SharedPreferences | Prefs loaded from `/merchant/me`, written only via PATCH settings; legacy keys removed | `store_provider.dart`, `getMePrefs()` |

`flutter analyze` store provider + repos → No issues found.

---

## Courier (`04`)

| ID | Fix | Evidence |
|----|-----|----------|
| F11 unbounded lists | Client `per_page=50`; backend caps assigned/history | `api_parcel_repository.dart`, `api_notification_repository.dart`, `ParcelController` |

---

## Admin (`05`)

| ID | Fix | Evidence |
|----|-----|----------|
| F7 client role gate | Non-admin users logged out after `/admin/me` | `app.js` `startApp` |
| F8 search string | Cleared on logout | `store.js` logout removes `hillgo-search` |
| CDN SRI | Leaflet CSS/JS integrity attributes | `index.html` |
| CSP | Content-Security-Policy meta | `index.html` |
| Private file read | `openAuthenticatedFile` + KYC Open buttons | `store.js`, rider/courier/merchant pages |
| httpOnly cookies | Not full Sanctum SPA cookie redesign; mitigated with sessionStorage token + CSP + role gate + search clear. Same-origin cookie auth still recommended for production hardening. | — |

`node --check` on store/app/pages → exit 0.

---

## Public Web (`06`)

| ID | Fix | Evidence |
|----|-----|----------|
| F4 CORS fetch | `mode: 'cors'`, `credentials: 'omit'`, file:// warning | `main.js` |
| F5 Google Fonts | Removed `@import` + preconnects; system font stack | `css/style.css`, HTML heads |
| F6 Unsplash | Replaced with local `assets/img/*.svg` (0 unsplash refs left) | HTML pages + `assets/img/` |

`node --check main.js` → exit 0.

---

## Storage

See `07-storage-e2e-results.md` — **43/43 PASS**.

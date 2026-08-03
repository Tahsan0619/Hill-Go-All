# HillGo Super Admin (frontend)

**Runtime is a live Laravel API** — there is no `seed.js` / `localStorage` mock
data path anymore. `js/store.js` calls the real `/admin/*` endpoints over
`fetch()` with a Bearer token (see "Auth" below); every screen renders
server-returned rows. `ui/index.html` also reflects this ("Live backend" in
the sidebar footer, hitting `GET /health` for the status indicator).

Open this folder with any static server (or open `index.html` via Live Server).
A Laravel backend must be running and reachable at `window.HILLGO_API_BASE`
(see `js/config.js`) for the panel to load any data.

```bash
cd ui
python -m http.server 8765
# → http://127.0.0.1:8765
```

## Architecture

| File | Role |
|------|------|
| `index.html` | Shell (sidebar, header, modal, drawer); CSP meta tag |
| `js/config.js` | Runtime config — `window.HILLGO_API_BASE`, `window.SENTRY_DSN` (extracted from index.html so CSP can drop `'unsafe-inline'` on scripts) |
| `js/tailwind-config.js` | Tailwind Play CDN theme config (also extracted for CSP) |
| `js/lib/store-helpers.js` | Pure helpers used by `store.js` (`sid`, `unwrap`, patch/merge, token store, backoff, pagination-meta parsing) — unit tested under `node --test` (see `../test/`) |
| `js/telemetry.js` | `HillGoTelemetry.captureError(err, context)` — sends to Sentry if `window.SENTRY_DSN` is set, else `console.error` |
| `js/health.js` | Polls `GET {API_BASE}/health` every 30s and paints the sidebar status dot (Active / Degraded / API unreachable) |
| `js/store.js` | Live API client — in-memory cache, optimistic mutations, retry-with-backoff on network errors, server-side pagination (`AppStore.loadMore(collection)`) |
| `js/ui.js` | Modal, drawer, confirm, CSV export, notices, pager (incl. "load more from server") |
| `js/maps.js` | Leaflet map helpers (uses `UI.escapeHtml`, no local duplicate) |
| `js/router.js` | Hash router (`#/overview`, `#/rider/pay`, …) |
| `js/pages/*.js` | Screen renderers |
| `js/app.js` | Route registration, login, chrome wiring, global error → telemetry hookup |

All primary actions mutate the store (KYC, pay salary → payout log, region
open/close, pricing save, etc.) and call the matching `/admin/*` endpoint.
Notices reflect real API responses. Export buttons download real CSV files
built from whatever is currently loaded in the store.

## Auth

Bearer token lives in `sessionStorage` (not `localStorage`) — see the comment
at the top of `js/store.js` for the accepted-risk tradeoff versus HttpOnly
Sanctum SPA cookies (blocked on a backend change).

## Tests

```bash
npm test
```

Runs `node --test` against `../test/*.test.js`, covering the pure helpers in
`js/lib/store-helpers.js` (patch/merge row, token store, refresh aggregation,
backoff timing, pagination-meta parsing, health-state derivation). No build
step or dependency install required.

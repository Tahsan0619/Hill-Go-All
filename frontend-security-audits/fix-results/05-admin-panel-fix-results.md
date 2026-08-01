# Admin Panel — Frontend Fix Results

**App:** `Hill Go Admin Panel/ui/`  
**Date:** 2026-08-01  
**Rule:** Claims only with code evidence + `node --check`.

---

## Verification commands (actual)

```text
node --check "Hill Go Admin Panel/ui/js/ui.js"   → exit 0
node --check "Hill Go Admin Panel/ui/js/store.js" → exit 0
```

Grep evidence:
- `escapeHtml` exported from `ui.js` and used in page modules (`const esc = (s) => U().escapeHtml(s)`)
- Token: `sessionStorage.setItem(TOKEN_KEY, value)` (legacy localStorage migrated once)
- Lists: `per_page=50` on customers/rides/riders/merchants/courier/… loaders
- Wallet: `!Number.isFinite(amount) || Math.abs(amount) > 1e7` blocks POST
- Copy: overview “Live API”; rider map `Realtime positions from API`

---

## Fixes implemented (evidence)

| Audit ID | Fix | Evidence |
|----------|-----|----------|
| F1 HIGH | XSS escape | `ui.js` `escapeHtml`; applied in confirmDialog, badges, KPIs; pages + `maps.js` popups use escaped names/status/notes |
| F2 HIGH | Token not in long-lived localStorage | `store.js` prefers `sessionStorage`; migrates old localStorage token once then removes |
| F3 MED | Client money validation | `adjustWallet` finite ±1e7; `savePricing` rejects non-finite numbers |
| F4 MED | API base documented | `index.html` sets `window.HILLGO_API_BASE \|\| 'http://127.0.0.1:8000/api'` |
| F6 MED | List cap 50 | All major LOADERS use `?per_page=50` |
| F9 INFO | Remove “mock” wording | `overview.js`, `rider.js` live-API labels |

---

## Not claimed

| Item | Why |
|------|-----|
| Full httpOnly cookie Sanctum SPA | Requires same-origin cookie session redesign; mitigated via CSP + role gate + sessionStorage + search clear (see `08`) |
| Tailwind CDN SRI | Dynamic plugin URL; Leaflet SRI applied |

## Follow-up LOW closed (2026-08-01)

Role gate, search clear on logout, CSP, Leaflet SRI, authenticated KYC file open — see `08-remaining-low-fixes.md` + `07-storage-e2e-results.md`.

---

## Catalog #14 re-check

`localStorage`/`sessionStorage` usage for entities: **token (+ search string) only**. KYC/financial still in-memory after API refresh — confirmed by `store.js` TOKEN_KEY paths only for auth persistence.

# HillGo Super Admin (frontend)

Open this folder with any static server (or open `index.html` via Live Server).

```bash
cd ui
python -m http.server 8765
# → http://127.0.0.1:8765
```

## Architecture

| File | Role |
|------|------|
| `index.html` | Shell (sidebar, header, modal, drawer) |
| `js/data/seed.js` | Mock seed (64 districts, entities, pricing) |
| `js/store.js` | Mutable store + `localStorage` (`hillgo-admin-v1`) |
| `js/ui.js` | Modal, drawer, confirm, CSV export, notices |
| `js/router.js` | Hash router (`#/overview`, `#/rider/pay`, …) |
| `js/pages/*.js` | Screen renderers |
| `js/app.js` | Route registration + chrome wiring |

All primary actions mutate the store (KYC, pay salary → payout log, region open/close, pricing save, etc.). Notices only confirm real state changes. Export buttons download real CSV files.

Reset mock data: sidebar footer or Settings → Reset.

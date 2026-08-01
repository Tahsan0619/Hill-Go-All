# Public Web — Frontend Fix Results

**App:** `Hill Go Public Web/`  
**Date:** 2026-08-01  
**Rule:** Claims only with code evidence + `node --check`.

---

## Verification commands (actual)

```text
node --check "Hill Go Public Web/js/main.js" → exit 0
```

Grep evidence:
- Quote result uses `textContent` / `createElement('strong')` — **not** `innerHTML` with `q.fare`
- `passive: true` on scroll listener
- Default API `http://127.0.0.1:8000/api`
- HTML: `maxlength`, `required`, `name=`, `loading="lazy"` on Unsplash images across pages

---

## Fixes implemented (evidence)

| Audit ID | Fix | Evidence |
|----------|-----|----------|
| F1 HIGH | Documented local API default | `main.js` line 3: `HG_API = window.HILLGO_API_BASE \|\| 'http://127.0.0.1:8000/api'` |
| F2 MED | XSS quote sink removed | `main.js` ~212–225: clear + append text nodes; `strong.textContent = \`৳${q.fare}\`` |
| F3 LOW–MED | Form constraints | `contact.html`, `register.html` (`name=` + tel `pattern`), `parcel.html` required origin/destination, track/city/newsletter `maxlength` |
| F7 LOW | Perf | Unsplash `loading="lazy"`; scroll `{ passive: true }`; preconnect on pages |

---

## Not claimed

| Item | Why |
|------|-----|
| Auth/token storage | Still N/A — no auth on public site |

## Follow-up LOW closed (2026-08-01)

Unsplash removed (local SVG assets), Google Fonts CDN removed, CORS fetch mode explicit — see `08-remaining-low-fixes.md`.

---

## Positive re-check

- Toasts still use `textContent`
- Tracking ID still `encodeURIComponent`
- No `localStorage` / secrets introduced

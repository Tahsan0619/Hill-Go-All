# Remediation — Public Web

| Field | Value |
|-------|-------|
| **Component** | Public Web |
| **Repo path** | `Hill Go Public Web` |
| **Date of remediation** | 2026-08-03 |
| **Source audit** | `../AUDIT_PUBLIC_WEB.md` |
| **Scope rule** | Fix ONLY the 7-item checklist below. Anything else noticed along the way is logged in `../NEW_FINDINGS.md`, not fixed here. |

---

## Summary

All 7 checklist items are complete. 14/14 HTML pages now ship a CSP + referrer
meta tag, the dead `escapeHtml` helper is gone (with a comment documenting the
real XSS strategy), the API base is deploy-injectable via `js/config.js` with a
safe non-localhost fallback and a user-facing warning, the four listed form
submissions retry on network failure, every "Log In" link/label that pointed
at a non-existent auth flow now says "Contact us", and the two fake-precision
uptime/latency numbers on `services.html` were replaced with honest,
non-specific claims. A new `js/api.js` module extracts the pure networking
logic and is covered by 12 passing vitest tests.

```
cd "Hill Go Public Web"
npm install
npm test
# ✓ test/api.test.js (12 tests)
```

---

## 1. CSP meta tag on all HTML pages

**Status: ✅ Done — all 14 pages.**

Added to the `<head>` of every page, directly after the viewport meta tag:

```html
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self' http://127.0.0.1:8000 http://localhost:8000 https:; base-uri 'self'; form-action 'self';">
<meta name="referrer" content="strict-origin-when-cross-origin">
```

Pages touched (14/14): `index.html`, `about.html`, `blog.html`, `contact.html`,
`driver.html`, `faq.html`, `food.html`, `merchant.html`, `parcel.html`,
`privacy.html`, `register.html`, `ride.html`, `services.html`, `terms.html`.

**Why these directives, and why nothing broke:**

- `script-src 'self'` (no `'unsafe-inline'`) — verified there are **zero**
  inline `<script>` blocks and **zero** inline event-handler attributes
  (`onclick=`, etc.) anywhere in the 14 pages; every page has exactly one
  `<script src="js/...">` tag chain. Confirmed via `rg '<script src'` /
  `rg 'onclick='` before writing the policy.
- `style-src 'self' 'unsafe-inline'` — the pages use many inline
  `style="..."` attributes (hero layout tweaks, badge colors, etc.) and there
  is no build step to move them into `css/style.css` or add nonces/hashes
  within this checklist's scope, so `'unsafe-inline'` for styles only (not
  scripts) is the pragmatic, still-meaningfully-safer choice — matches the
  Admin Panel's own CSP style (`Hill Go Admin Panel/ui/index.html:6`), which
  also uses `'unsafe-inline'` for `style-src`.
- `img-src 'self' data:` — all images are local SVGs under `assets/img/`;
  `data:` is harmless headroom for any future inline data-URI icon and isn't
  currently used.
- `connect-src 'self' http://127.0.0.1:8000 http://localhost:8000 https:` —
  keeps local dev (`hgApi` default) working, and `https:` leaves room for
  whatever production API origin gets injected via `js/config.js` (see
  item 3) without needing a CSP edit on every deploy. See
  `deploy/README.md` for tightening this to one exact origin if desired.
- `base-uri 'self'` / `form-action 'self'` — no `<base>` tag is used and all
  forms are intercepted with `e.preventDefault()` and submitted via `fetch`
  (never a native browser form submission), so this has zero functional
  impact and closes a `<base>`-tag / form-hijack injection vector for free.
- No external CDNs, fonts, or trackers exist anywhere in this site (verified:
  `css/style.css:2` — "Fonts: local system stack only"; no `https://` in any
  `.html`/`.css`/`.js` other than the `HG_API` default and the CSP's own
  `connect-src` allowance) — so a strict, `'self'`-first policy needed no
  extra domain allowlisting.

## 2. Dead `escapeHtml` in `main.js`

**Status: ✅ Done — removed, per the "prefer remove" option.**

Removed the unused `escapeHtml()` function from `js/main.js` and replaced it
with a comment documenting the actual (and already-correct) XSS strategy:

```js
// XSS strategy: all dynamic/user/API-sourced content is inserted via textContent or
// createElement (see initTrackForm, initQuoteCalculator, showToast, etc.) — never via
// innerHTML — so no HTML-escaping helper is needed in this file.
```

Verified no other file in `Hill Go Public Web` calls `escapeHtml`, and
re-confirmed every dynamic-content call site (`initTrackForm`,
`initQuoteCalculator`, `showToast`) still uses `textContent` /
`createElement`/`createTextNode`, never `innerHTML`.

## 3. `window.HILLGO_API_BASE` via deploy injection

**Status: ✅ Done.**

- **`js/config.js`** (new file, loaded first on every page):

  ```js
  // Overridden at deploy time. Do not commit production secrets.
  window.HILLGO_API_BASE = window.HILLGO_API_BASE || '';
  ```

- **`js/api.js`** (new file — see item 4) exports `resolveApiBase(win)`:
  - Returns `window.HILLGO_API_BASE` if it's set to a non-empty string.
  - Otherwise, falls back to `http://127.0.0.1:8000/api` **only** when
    `location.hostname` is `localhost` or `127.0.0.1`.
  - Otherwise (an unconfigured non-local deployment) returns `''` — no more
    silent production traffic to a developer's loopback address.

- **`js/main.js`** now computes `HG_API = window.HillGoApi.resolveApiBase(window)`
  and, on `DOMContentLoaded`, calls a new `warnIfApiBaseUnset()` that shows a
  toast — *"This deployment has no API configured yet — some features are
  unavailable."* — whenever `HG_API` is empty. `assertApiReachableConfig()`
  also short-circuits (`if (!HG_API) return null;`) instead of constructing a
  misleading same-page `URL()` when there's no base configured.

- **Script load order updated on all 14 pages:**

  ```html
  <script src="js/config.js"></script>
  <script src="js/api.js"></script>
  <script src="js/main.js"></script>
  ```

- **`deploy/README.md`** (new) documents: there is **no** existing deploy
  pipeline anywhere in `Hill Go Public Web/` (confirmed — no CI config, no
  build/hosting config of any kind; this is pure static HTML/CSS/JS), and
  gives three concrete options for injecting `HILLGO_API_BASE` at deploy time
  (overwrite `config.js`, placeholder string-replace, or edge-injected
  pre-`config.js` script), plus what happens if the step is skipped, plus how
  the CSP's `connect-src https:` interacts with the injected origin.

## 4. Minimal automated tests for `main.js`

**Status: ✅ Done — extracted `js/api.js`, tested with vitest.**

- **`js/api.js`** (new) — pure, DOM-independent module holding everything
  `main.js` needs to talk to the backend: `resolveApiBase`, `hgApi`,
  `hgApiWithRetry`, `extractErrorMessage`, and two error classes
  (`HgHttpError` for non-2xx responses, `HgNetworkError` for failed
  requests — see item 5). Written as a small UMD-style wrapper so the exact
  same file works as a plain `<script>` in the browser (attaches
  `window.HillGoApi`) and as a `module.exports` in Node for testing —
  no build/bundle step needed either way.
- **`js/main.js`** was refactored to two thin wrappers, `hgApi(method, path, body)`
  and `hgApiRetry(method, path, body)`, that just forward to
  `window.HillGoApi.hgApi` / `.hgApiWithRetry` with the page's resolved
  `HG_API`. All existing call sites keep the same call signature.
- **`package.json`** (new) — `"type": "commonjs"`, one dev dependency
  (`vitest`), one script: `npm test` → `vitest run`. This file exists solely
  to run these tests; it is not a build/bundle config for the site itself
  (confirmed: no bundler, no `dist`/`build` output, HTML pages still load
  `js/*.js` directly as plain scripts).
- **`test/api.test.js`** (new) — 12 tests covering:
  - `resolveApiBase`: explicit override wins; `localhost`/`127.0.0.1`
    fallback; empty string for an unconfigured non-local host.
  - `hgApi`: rejects with `HgNetworkError` when no API base is configured
    and when the underlying `fetch` itself rejects (offline/DNS/CORS);
    rejects with `HgHttpError` (carrying the server's `message`, or the
    joined Laravel-style `errors` object) on a non-2xx response; resolves
    with the parsed JSON body on success.
  - `hgApiWithRetry`: retries and recovers after a transient network
    failure; gives up after exactly 3 attempts on persistent network
    failure; does **not** retry (single attempt) when the server responds
    with a real `HgHttpError` (e.g. a 422 validation error) — retrying a
    rejected submission would not change the outcome and could look like a
    duplicate-submission bug.

  ```
  cd "Hill Go Public Web" && npm install && npm test
  ✓ test/api.test.js (12 tests) — 1 file passed
  ```

## 5. Retry-with-backoff for form submissions

**Status: ✅ Done — quotes, newsletter, contact, partner (exactly the 4 listed).**

`js/api.js`'s `hgApiWithRetry(apiBase, method, path, body, options)`:

- Retries up to `attempts` (default **3**) total attempts.
- **Only** retries on `HgNetworkError` (the request never reached the
  server — offline, DNS failure, CORS preflight failure, etc.). A
  `HgHttpError` (server responded, just with a non-2xx status — e.g. a
  duplicate-newsletter-email 422) is thrown immediately on the first
  attempt and is **never** retried, since the server already made a
  decision and resubmitting identical data wouldn't change it (and could
  look like the user "double-submitted").
- Backoff: `baseDelayMs * attempt` between attempts (default base 400ms →
  waits ~400ms, then ~800ms), injectable via `options.sleep` for
  instant/deterministic tests.

Wired into exactly the four call sites named in the checklist, in
`js/main.js`:

| Form | Function | Endpoint |
|------|----------|----------|
| Parcel/ride quote | `initQuoteCalculator` | `POST /public/quotes` |
| Newsletter signup | `initNewsletterForms` | `POST /public/newsletter` |
| Contact form | `initContactForm` (contact branch) | `POST /public/contact` |
| Partner application | `initContactForm` (partner branch, `register.html`) | `POST /public/partner-applications` |

The track-order lookup (`initTrackForm`) and city-availability check
(`initAvailabilityForms`) were left on plain `hgApi` (no retry) — they're
read-only `GET` lookups, not listed in the checklist, and are already
idempotent single-shot UX (user can just click again).

## 6. "Log In" link → "Contact us"

**Status: ✅ Done — relabeled on all 8 nav instances + the register.html hero CTA.**

Per the checklist's preferred option, kept the existing `href="contact.html"`
and changed the visible label from **"Log In"** to **"Contact us"** — no fake
auth page was invented, and `contact.html` already exists and is a genuinely
useful destination (there is no customer-facing login/session system
anywhere in this static site to link to instead).

Checked navigation on **all 14 pages** for consistency
(`rg 'Log In|Login|nav-actions'`) — the header `nav-actions` block only
renders the login-style link on pages that had it; `driver.html`, `ride.html`,
`terms.html`, `privacy.html`, and `blog.html` never had a "Log In" link (their
`nav-actions` only ever contained "Get Started" or, on `blog.html`, a search
icon), so they were left untouched.

Pages updated:

| Page | Before | After |
|------|--------|-------|
| `index.html`, `about.html`, `faq.html`, `services.html`, `food.html`, `parcel.html`, `merchant.html`, `contact.html` | `<a href="contact.html" class="btn btn-outline btn-sm">Log In</a>` | `<a href="contact.html" class="btn btn-outline btn-sm">Contact us</a>` |
| `register.html` (hero CTA, not nav) | `<a href="contact.html" class="btn btn-outline btn-lg">Login to Portal</a>` | `<a href="contact.html" class="btn btn-outline btn-lg">Contact us</a>` |

`register.html`'s hero CTA was included because it's the same underlying
issue named by the checklist — a "Login"-labeled link to `contact.html`,
implying a partner portal login that doesn't exist in this codebase — not a
distinct, unrelated finding.

## 7. Soften `services.html` marketing claims

**Status: ✅ Done — the two named stats, plus the one sentence describing them.**

```diff
- <p>Our algorithmic core powers millions of daily transactions with industry-leading uptime and sub-millisecond route calculations.</p>
+ <p>Our algorithmic core powers millions of daily transactions with a focus on high availability and fast route calculations.</p>
  <div class="why-stats">
-   <div class="why-stat"><strong>99.9%</strong><span>Service Uptime</span></div>
-   <div class="why-stat"><strong>12ms</strong><span>Route Calculation</span></div>
+   <div class="why-stat"><strong>High</strong><span>Availability</span></div>
+   <div class="why-stat"><strong>Fast</strong><span>Route Calculation</span></div>
  </div>
```

The lead-in sentence's "sub-millisecond route calculations" was softened
alongside the two stat numbers since it's the same specific fake-precision
claim (the checklist named the two `<strong>` figures; the sentence directly
above them asserts the same unsupported number in prose) — not treated as an
unrelated finding.

**Left untouched (out of this item's scope):** `index.html`'s unrelated
`why-stats` block (`99.9% Safe Trips`, `24/7 Live Support`, `100% Verified`)
— the checklist named `services.html`'s "99.9% Service Uptime" / "12ms Route
Calculation" specifically; `index.html`'s numbers are a different claim
(safety rate / support hours, not unmeasured infra latency) and were not
flagged in the audit or the checklist, so per the "fix only checklist" rule
they were left as-is and are not re-logged in `NEW_FINDINGS.md` (the audit
already covered them in `AUDIT_PUBLIC_WEB.md`'s "Insufficient evidence log").

---

## Files changed / added

**Added:**
- `js/config.js` — deploy-injectable `HILLGO_API_BASE` default.
- `js/api.js` — pure `hgApi`/`hgApiWithRetry`/`resolveApiBase` helpers, UMD (browser + Node).
- `package.json` — `vitest` dev dependency + `npm test` script (tests only, no build step).
- `test/api.test.js` — 12 vitest tests for `js/api.js`.
- `deploy/README.md` — deploy-injection instructions; confirms no existing deploy pipeline.
- `REMEDIATION_PUBLIC_WEB.md` — this file.

**Modified:**
- `js/main.js` — removed dead `escapeHtml`; delegate to `window.HillGoApi`; added `warnIfApiBaseUnset`; added `hgApiRetry` and wired it into the 4 listed form submissions.
- `index.html`, `about.html`, `blog.html`, `contact.html`, `driver.html`, `faq.html`, `food.html`, `merchant.html`, `parcel.html`, `privacy.html`, `register.html`, `ride.html`, `services.html`, `terms.html` — CSP + referrer meta tags; `js/config.js` + `js/api.js` script tags before `js/main.js`.
- `index.html`, `about.html`, `faq.html`, `services.html`, `food.html`, `parcel.html`, `merchant.html`, `contact.html`, `register.html` — "Log In"/"Login to Portal" → "Contact us".
- `services.html` — softened uptime/latency marketing copy (item 7).

## Verification performed

- `npm test` in `Hill Go Public Web/` → 12/12 vitest tests passing.
- `rg 'Content-Security-Policy'` across `*.html` → 14/14 matches.
- `rg '<script src'` across `*.html` → every page has exactly `config.js` → `api.js` → `main.js`, in that order, and no other script tags.
- `rg 'Log In|Login'` across `*.html` → zero remaining fake-login labels (only unrelated prose survives: `privacy.html`'s "Social media login info" data-category bullet).
- `rg '99\.9%|12ms|Uptime|Route Calculation'` across `*.html` → only `index.html`'s unrelated, out-of-scope safety stat remains (see item 7).
- Manually re-read the full `js/main.js` after edits to confirm every `hgApi`/`hgApiRetry` call site and the `DOMContentLoaded` handler are intact and consistent.

Not fixed here (outside checklist scope) — logged in `../NEW_FINDINGS.md` under "Public Web".

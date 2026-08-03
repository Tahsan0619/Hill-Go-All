# Deploying Hill Go Public Web

## There is no deploy pipeline in this folder

This confirms, for the record, that `Hill Go Public Web/` contains **no** CI/CD
config, build script, Dockerfile, or hosting config of any kind — no
`.github/workflows`, no `netlify.toml` / `vercel.json`, no `nginx.conf`, no
`package.json` "build"/"deploy" script (the `package.json` at the folder root
exists solely to run the `js/api.js` unit tests — see [Testing](#testing)
below). This is a set of static files (`*.html`, `css/style.css`,
`js/*.js`, `assets/`) meant to be served as-is by any static host (S3 +
CloudFront, Nginx, Netlify, Vercel, GitHub Pages, etc.). Whoever wires up
hosting for this site must also perform the one manual step below.

## Required: set the production API base before/at deploy

The site never hardcodes a production API origin. `js/config.js` is loaded
before `js/api.js` and `js/main.js` on every page and sets a single global
that everything else reads:

```js
// js/config.js — committed as-is, with an empty default.
window.HILLGO_API_BASE = window.HILLGO_API_BASE || '';
```

At deploy time, do **one** of the following to point the site at the real API:

1. **Replace the file** — have your deploy pipeline overwrite
   `js/config.js` with a generated version, e.g.:

   ```js
   window.HILLGO_API_BASE = 'https://api.hillgo.com';
   ```

   This is the simplest approach for static hosts (S3, Netlify, Nginx): the
   build step writes this file from an environment variable
   (`$HILLGO_API_BASE`) right before upload, and the committed version in
   git always stays the safe empty-string default.

2. **String-replace a placeholder** — if your host only supports
   post-build text substitution, replace a marker instead of the whole
   file, e.g. keep `window.HILLGO_API_BASE = window.HILLGO_API_BASE || '__HILLGO_API_BASE__';`
   in a deploy-only copy and `sed`/`envsubst` `__HILLGO_API_BASE__` to the
   real origin during the release step.

3. **Inject via the hosting platform** — some static hosts (e.g. a
   CDN edge function) can inject a small `<script>` before `js/config.js`
   that sets `window.HILLGO_API_BASE` from an edge/environment variable. Any
   value set before `js/config.js` runs is respected, since `config.js` only
   assigns a default (`||`) rather than overwriting an existing value.

**Do not commit a real production API origin into `js/config.js` in git** —
keep the checked-in default as the empty string shown above, and perform the
substitution as a deploy-time step outside version control.

## What happens if `HILLGO_API_BASE` is left unset

- `js/api.js`'s `resolveApiBase()` only falls back to
  `http://127.0.0.1:8000/api` when the page is actually being viewed from
  `localhost` or `127.0.0.1` (local development). On any other hostname with
  no configured base, it returns an empty string instead of silently
  pointing production traffic at a developer's loopback address.
- When the resolved API base is empty, `main.js` shows a one-time toast on
  page load ("This deployment has no API configured yet — some features are
  unavailable.") and every `hgApi`/`hgApiRetry` call rejects immediately with
  a clear `HgNetworkError` instead of hanging or silently failing.

## Content-Security-Policy and the API origin

All 14 HTML pages ship a `Content-Security-Policy` `<meta>` tag whose
`connect-src` directive is:

```
connect-src 'self' http://127.0.0.1:8000 http://localhost:8000 https:;
```

The trailing `https:` allows a fetch to **any** HTTPS origin, so pointing
`HILLGO_API_BASE` at an HTTPS production API (e.g.
`https://api.hillgo.com`) needs no CSP changes. If production API traffic
must be locked down to one exact origin instead of `https:` (any HTTPS
host), replace `https:` in every page's CSP meta tag with the specific
origin, e.g. `https://api.hillgo.com`, as part of the same deploy step that
sets `HILLGO_API_BASE`.

## Testing

```bash
cd "Hill Go Public Web"
npm install
npm test
```

Runs the `js/api.js` unit tests (vitest) — `resolveApiBase`, `hgApi`, and
`hgApiWithRetry`, including the network-failure retry path and the
no-retry-on-validation-error path. See `test/api.test.js`.

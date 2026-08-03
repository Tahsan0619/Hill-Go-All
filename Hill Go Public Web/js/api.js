// HillGo Public Website - API helpers
//
// Pure, DOM-free networking helpers shared by js/main.js. Kept in a separate
// file (rather than inline in main.js) so they can be unit-tested directly in
// Node with vitest — see test/api.test.js. Works as a plain browser <script>
// (attaches `window.HillGoApi`) and as a CommonJS module (for Node tests).

(function (global) {
  'use strict';

  /** Thrown when the server responded, but with a non-2xx status. Not retried. */
  class HgHttpError extends Error {
    constructor(message, status) {
      super(message);
      this.name = 'HgHttpError';
      this.status = status;
    }
  }

  /** Thrown when the request never reached the server (offline, DNS, CORS, timeout, etc). Retried. */
  class HgNetworkError extends Error {
    constructor(message, cause) {
      super(message);
      this.name = 'HgNetworkError';
      this.cause = cause;
    }
  }

  /**
   * Resolve the API base URL for the current environment.
   * - Explicit `window.HILLGO_API_BASE` (set by js/config.js at deploy time) always wins.
   * - Otherwise, only fall back to the local dev API when actually running on localhost/127.0.0.1.
   * - Otherwise, return '' so callers can detect an unconfigured deployment instead of
   *   silently pointing production traffic at a developer's loopback address.
   */
  function resolveApiBase(win) {
    const w = win || (typeof window !== 'undefined' ? window : undefined);
    const configured = w && w.HILLGO_API_BASE;
    if (configured) return configured;

    const hostname = w && w.location ? w.location.hostname : '';
    const isLocalHost = hostname === 'localhost' || hostname === '127.0.0.1';
    return isLocalHost ? 'http://127.0.0.1:8000/api' : '';
  }

  /** Extract a human-readable message from a (possibly Laravel-shaped) error body. */
  function extractErrorMessage(json, status) {
    if (json && json.message) return json.message;
    if (json && json.errors) return Object.values(json.errors).flat().join(' ');
    return `Request failed (${status})`;
  }

  /**
   * Perform one API call. Throws `HgHttpError` for non-2xx responses (validation
   * errors, etc — these should NOT be retried) and `HgNetworkError` when the
   * request itself failed to reach the server (these ARE safe to retry).
   */
  async function hgApi(apiBase, method, path, body, fetchImpl) {
    const doFetch = fetchImpl || (typeof fetch !== 'undefined' ? fetch : undefined);
    if (!doFetch) throw new HgNetworkError('fetch is not available in this environment');
    if (!apiBase) throw new HgNetworkError('HillGo API base is not configured for this deployment.');

    let res;
    try {
      res = await doFetch(apiBase + path, {
        method,
        mode: 'cors',
        credentials: 'omit',
        headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
        body: body !== undefined ? JSON.stringify(body) : undefined,
      });
    } catch (err) {
      throw new HgNetworkError(err && err.message ? err.message : 'Network request failed', err);
    }

    let json = null;
    try { json = await res.json(); } catch (_) { /* empty or non-JSON body */ }

    if (!res.ok) {
      throw new HgHttpError(extractErrorMessage(json, res.status), res.status);
    }
    return json;
  }

  /**
   * Same as `hgApi`, but retries with backoff on `HgNetworkError` only — a
   * rejected/invalid submission (`HgHttpError`, e.g. validation errors) is
   * never retried since resubmitting would not change the outcome.
   */
  async function hgApiWithRetry(apiBase, method, path, body, options) {
    const opts = options || {};
    const attempts = opts.attempts || 3;
    const baseDelayMs = opts.baseDelayMs || 400;
    const fetchImpl = opts.fetchImpl;
    const sleep = opts.sleep || ((ms) => new Promise((resolve) => setTimeout(resolve, ms)));

    let lastErr;
    for (let attempt = 1; attempt <= attempts; attempt++) {
      try {
        return await hgApi(apiBase, method, path, body, fetchImpl);
      } catch (err) {
        lastErr = err;
        const isNetworkError = err instanceof HgNetworkError;
        if (!isNetworkError || attempt === attempts) throw err;
        await sleep(baseDelayMs * attempt);
      }
    }
    throw lastErr;
  }

  const HillGoApi = {
    HgHttpError,
    HgNetworkError,
    resolveApiBase,
    extractErrorMessage,
    hgApi,
    hgApiWithRetry,
  };

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = HillGoApi;
  }
  if (typeof window !== 'undefined') {
    window.HillGoApi = HillGoApi;
  }
})(typeof globalThis !== 'undefined' ? globalThis : this);

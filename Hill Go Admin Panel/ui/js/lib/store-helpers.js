/**
 * Pure, dependency-free helpers extracted from store.js so they can run
 * under `node --test` without a DOM/fetch/sessionStorage environment.
 *
 * Loaded as a plain classic <script> in the browser (attaches
 * `window.HillGoStoreHelpers`) and via CommonJS `require()` in tests
 * (UMD-style export). Keep this file free of `window`/`fetch`/storage
 * calls — anything that touches the browser environment belongs in
 * store.js, which composes these pure functions.
 */
(function (root, factory) {
  const mod = factory();
  if (typeof module === 'object' && module.exports) {
    module.exports = mod;
  }
  if (root) {
    root.HillGoStoreHelpers = mod;
  }
}(typeof self !== 'undefined' ? self : (typeof globalThis !== 'undefined' ? globalThis : undefined), function factory() {
  /** Normalize a server row's id to a string so client comparisons are consistent. */
  function sid(row) {
    return { ...row, id: String(row.id) };
  }

  /** Laravel resources return either a bare array or `{ data: [...] }`. */
  function unwrap(res) {
    return Array.isArray(res) ? res : (res && res.data) || [];
  }

  /** Error thrown by http() for non-2xx responses; carries the HTTP status. */
  class HttpError extends Error {
    constructor(message, status) {
      super(message);
      this.name = 'HttpError';
      this.status = status;
    }
  }

  function isNotFoundError(err) {
    return !!err && err.status === 404;
  }

  /**
   * Retry only real network failures (DNS/connection/timeout — fetch()
   * rejects with a TypeError in browsers, or an AbortError on timeout).
   * A completed HTTP round trip (including 4xx/5xx) must NOT be retried
   * here — that's a definitive server answer, not a transient failure.
   */
  function isRetryableFetchError(err) {
    if (!err) return false;
    if (err instanceof HttpError) return false;
    if (err.name === 'AbortError') return true;
    if (err.name === 'TypeError') return true;
    return false;
  }

  /** Exponential backoff delay in ms for a given attempt (1-indexed). */
  function computeBackoffDelay(attempt, baseMs = 300) {
    const safeAttempt = Math.max(1, attempt);
    return baseMs * (2 ** (safeAttempt - 1));
  }

  /**
   * Optimistically patch a cached row in place. `rows` is mutated (matches
   * the original store.js semantics) and the found row is returned.
   */
  function patchRow(rows, id, patch) {
    const row = rows.find((x) => String(x.id) === String(id));
    if (row) Object.assign(row, patch);
    return row;
  }

  /** Replace (or prepend) a cached row with the server's version. Mutates `rows`. */
  function mergeRow(rows, serverRow, sidFn = sid) {
    const norm = sidFn(serverRow);
    const idx = rows.findIndex((x) => String(x.id) === norm.id);
    if (idx >= 0) rows[idx] = { ...rows[idx], ...norm };
    else rows.unshift(norm);
    return rows;
  }

  /**
   * Session-first token store with one-time migration from localStorage
   * (legacy). Storage args only need getItem/setItem/removeItem, so tests
   * can pass an in-memory fake instead of real Web Storage.
   */
  function createTokenStore(sessionStore, localStore, key) {
    function token() {
      let t = sessionStore.getItem(key) || '';
      if (!t) {
        t = localStore.getItem(key) || '';
        if (t) {
          sessionStore.setItem(key, t);
          localStore.removeItem(key);
        }
      }
      return t;
    }
    function setToken(value) {
      sessionStore.setItem(key, value);
      localStore.removeItem(key);
    }
    function clearToken() {
      sessionStore.removeItem(key);
      localStore.removeItem(key);
    }
    return { token, setToken, clearToken };
  }

  /**
   * Aggregate a Promise.allSettled(...) batch keyed by loader name into a
   * partial next-state object plus a list of errors — the core logic of
   * AppStore.refresh() without any actual network/DOM dependency.
   */
  function aggregateRefreshResults(keys, settledResults) {
    const nextState = {};
    const errors = [];
    settledResults.forEach((r, i) => {
      const key = keys[i];
      if (r.status === 'fulfilled') nextState[key] = r.value;
      else errors.push({ key, reason: r.reason });
    });
    return { nextState, errors };
  }

  /**
   * Parse a Laravel-style paginator (or plain array) into hasMore/page info
   * so list pages can offer a "load more from server" affordance.
   */
  function computePageMeta(res, requestedPage = 1) {
    if (Array.isArray(res)) return { page: requestedPage, hasMore: false };
    const meta = (res && res.meta) || res || {};
    const current = Number(meta.current_page ?? requestedPage);
    if (meta.last_page != null) {
      return { page: current, hasMore: current < Number(meta.last_page) };
    }
    if (meta.next_page_url != null) {
      return { page: current, hasMore: !!meta.next_page_url };
    }
    return { page: current, hasMore: false };
  }

  /** Map a health probe outcome to a display state for the sidebar indicator. */
  function deriveHealthState({ ok, status, errored }) {
    if (errored) return 'unreachable';
    if (status === 404) return 'unreachable';
    if (!ok) return 'degraded';
    return 'active';
  }

  return {
    sid,
    unwrap,
    HttpError,
    isNotFoundError,
    isRetryableFetchError,
    computeBackoffDelay,
    patchRow,
    mergeRow,
    createTokenStore,
    aggregateRefreshResults,
    computePageMeta,
    deriveHealthState,
  };
}));

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const H = require('../ui/js/lib/store-helpers.js');

// —— sid / unwrap ——

test('sid() stringifies the id and preserves other fields', () => {
  const row = H.sid({ id: 42, name: 'Dhaka' });
  assert.equal(row.id, '42');
  assert.equal(typeof row.id, 'string');
  assert.equal(row.name, 'Dhaka');
});

test('unwrap() accepts a bare array', () => {
  assert.deepEqual(H.unwrap([1, 2, 3]), [1, 2, 3]);
});

test('unwrap() accepts a Laravel { data: [...] } paginator response', () => {
  assert.deepEqual(H.unwrap({ data: [1, 2] }), [1, 2]);
});

test('unwrap() falls back to [] for null/missing data', () => {
  assert.deepEqual(H.unwrap(null), []);
  assert.deepEqual(H.unwrap({}), []);
});

// —— patchRow / mergeRow (AppStore's optimistic-update core) ——

test('patchRow() mutates the matching row in place and returns it', () => {
  const rows = [{ id: '1', status: 'active' }, { id: '2', status: 'active' }];
  const patched = H.patchRow(rows, '2', { status: 'suspended' });
  assert.equal(patched.status, 'suspended');
  assert.equal(rows[1].status, 'suspended');
  assert.equal(rows[0].status, 'active', 'other rows are untouched');
});

test('patchRow() compares ids as strings (numeric id, string lookup)', () => {
  const rows = [{ id: 7, status: 'active' }];
  const patched = H.patchRow(rows, '7', { status: 'suspended' });
  assert.equal(patched.status, 'suspended');
});

test('patchRow() returns undefined when no row matches', () => {
  const rows = [{ id: '1' }];
  assert.equal(H.patchRow(rows, '999', { status: 'x' }), undefined);
});

test('mergeRow() replaces an existing row, keeping other fields via spread', () => {
  const rows = [{ id: '1', name: 'Old', extra: 'kept' }];
  H.mergeRow(rows, { id: 1, name: 'New' });
  assert.equal(rows.length, 1);
  assert.equal(rows[0].name, 'New');
  assert.equal(rows[0].extra, 'kept');
});

test('mergeRow() prepends a server row that is not already cached', () => {
  const rows = [{ id: '1', name: 'Existing' }];
  H.mergeRow(rows, { id: 2, name: 'Brand new' });
  assert.equal(rows.length, 2);
  assert.equal(rows[0].id, '2', 'new row is unshifted to the front');
});

// —— auth token handling ——

function fakeStorage() {
  const map = new Map();
  return {
    getItem: (k) => (map.has(k) ? map.get(k) : null),
    setItem: (k, v) => map.set(k, v),
    removeItem: (k) => map.delete(k),
    _map: map,
  };
}

test('createTokenStore() reads straight from session storage when present', () => {
  const session = fakeStorage();
  const local = fakeStorage();
  session.setItem('tok', 'session-token');
  const store = H.createTokenStore(session, local, 'tok');
  assert.equal(store.token(), 'session-token');
});

test('createTokenStore() migrates a legacy localStorage token to sessionStorage once', () => {
  const session = fakeStorage();
  const local = fakeStorage();
  local.setItem('tok', 'legacy-token');
  const store = H.createTokenStore(session, local, 'tok');
  assert.equal(store.token(), 'legacy-token');
  assert.equal(session.getItem('tok'), 'legacy-token', 'migrated into sessionStorage');
  assert.equal(local.getItem('tok'), null, 'removed from localStorage after migration');
});

test('createTokenStore() returns empty string when neither storage has a token', () => {
  const store = H.createTokenStore(fakeStorage(), fakeStorage(), 'tok');
  assert.equal(store.token(), '');
});

test('createTokenStore().setToken() writes session and clears any legacy local value', () => {
  const session = fakeStorage();
  const local = fakeStorage();
  local.setItem('tok', 'stale');
  const store = H.createTokenStore(session, local, 'tok');
  store.setToken('fresh-token');
  assert.equal(session.getItem('tok'), 'fresh-token');
  assert.equal(local.getItem('tok'), null);
});

test('createTokenStore().clearToken() removes the token from both storages', () => {
  const session = fakeStorage();
  const local = fakeStorage();
  session.setItem('tok', 'a');
  local.setItem('tok', 'b');
  const store = H.createTokenStore(session, local, 'tok');
  store.clearToken();
  assert.equal(session.getItem('tok'), null);
  assert.equal(local.getItem('tok'), null);
});

// —— refresh() aggregation ——

test('aggregateRefreshResults() assigns fulfilled values by key', async () => {
  const keys = ['a', 'b'];
  const results = await Promise.allSettled([Promise.resolve([1, 2]), Promise.resolve([3])]);
  const { nextState, errors } = H.aggregateRefreshResults(keys, results);
  assert.deepEqual(nextState, { a: [1, 2], b: [3] });
  assert.deepEqual(errors, []);
});

test('aggregateRefreshResults() collects rejected loaders as errors without touching nextState for that key', async () => {
  const keys = ['ok', 'broken'];
  const boom = new Error('network down');
  const results = await Promise.allSettled([Promise.resolve('fine'), Promise.reject(boom)]);
  const { nextState, errors } = H.aggregateRefreshResults(keys, results);
  assert.deepEqual(nextState, { ok: 'fine' });
  assert.equal(errors.length, 1);
  assert.equal(errors[0].key, 'broken');
  assert.equal(errors[0].reason, boom);
});

// —— retry-with-backoff on network errors only ——

test('isRetryableFetchError() is true for a fetch-style TypeError (network failure)', () => {
  assert.equal(H.isRetryableFetchError(new TypeError('Failed to fetch')), true);
});

test('isRetryableFetchError() is true for an AbortError (timeout)', () => {
  const err = new Error('The operation was aborted');
  err.name = 'AbortError';
  assert.equal(H.isRetryableFetchError(err), true);
});

test('isRetryableFetchError() is false for a completed HTTP error response (e.g. 4xx)', () => {
  assert.equal(H.isRetryableFetchError(new H.HttpError('Not found', 404)), false);
});

test('isRetryableFetchError() is false for a plain generic error', () => {
  assert.equal(H.isRetryableFetchError(new Error('boom')), false);
});

test('isRetryableFetchError() is false for null/undefined', () => {
  assert.equal(H.isRetryableFetchError(null), false);
  assert.equal(H.isRetryableFetchError(undefined), false);
});

test('computeBackoffDelay() grows exponentially from a 300ms base', () => {
  assert.equal(H.computeBackoffDelay(1), 300);
  assert.equal(H.computeBackoffDelay(2), 600);
  assert.equal(H.computeBackoffDelay(3), 1200);
});

test('computeBackoffDelay() respects a custom base', () => {
  assert.equal(H.computeBackoffDelay(1, 100), 100);
  assert.equal(H.computeBackoffDelay(2, 100), 200);
});

test('isNotFoundError() only matches HTTP 404', () => {
  assert.equal(H.isNotFoundError(new H.HttpError('nope', 404)), true);
  assert.equal(H.isNotFoundError(new H.HttpError('server error', 500)), false);
  assert.equal(H.isNotFoundError(new Error('no status')), false);
});

// —— pagination meta (server-driven "load more") ——

test('computePageMeta() reports no more pages for a bare array response', () => {
  assert.deepEqual(H.computePageMeta([1, 2, 3], 1), { page: 1, hasMore: false });
});

test('computePageMeta() reads Laravel { meta: { current_page, last_page } } shape', () => {
  assert.deepEqual(
    H.computePageMeta({ meta: { current_page: 1, last_page: 3 } }, 1),
    { page: 1, hasMore: true },
  );
  assert.deepEqual(
    H.computePageMeta({ meta: { current_page: 3, last_page: 3 } }, 3),
    { page: 3, hasMore: false },
  );
});

test('computePageMeta() reads top-level current_page/last_page shape', () => {
  assert.deepEqual(
    H.computePageMeta({ current_page: 2, last_page: 5 }, 2),
    { page: 2, hasMore: true },
  );
});

test('computePageMeta() falls back to next_page_url presence when last_page is absent', () => {
  assert.deepEqual(
    H.computePageMeta({ current_page: 1, next_page_url: 'https://api/x?page=2' }, 1),
    { page: 1, hasMore: true },
  );
  assert.deepEqual(
    H.computePageMeta({ current_page: 2, next_page_url: null }, 2),
    { page: 2, hasMore: false },
  );
});

// —— health check state ——

test('deriveHealthState() is "active" for a healthy 2xx response', () => {
  assert.equal(H.deriveHealthState({ ok: true, status: 200, errored: false }), 'active');
});

test('deriveHealthState() is "unreachable" for a 404 (endpoint not shipped yet)', () => {
  assert.equal(H.deriveHealthState({ ok: false, status: 404, errored: false }), 'unreachable');
});

test('deriveHealthState() is "degraded" for a non-404 non-2xx response', () => {
  assert.equal(H.deriveHealthState({ ok: false, status: 500, errored: false }), 'degraded');
});

test('deriveHealthState() is "unreachable" when the request itself errored (network down)', () => {
  assert.equal(H.deriveHealthState({ ok: false, status: 0, errored: true }), 'unreachable');
});

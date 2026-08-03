'use strict';

/**
 * Integration-level smoke tests: load the REAL ui/js/store.js (not a copy)
 * into a sandboxed VM with a stubbed fetch/sessionStorage/localStorage, and
 * exercise refresh(), auth token handling, the districts N+1 fallback, and
 * retry-with-backoff end-to-end — i.e. the actual production code path,
 * on top of the pure-helper unit tests in store-helpers.test.js.
 */

const test = require('node:test');
const assert = require('node:assert/strict');
const vm = require('node:vm');
const fs = require('node:fs');
const path = require('node:path');

function makeStorage() {
  const map = new Map();
  return {
    getItem: (k) => (map.has(k) ? map.get(k) : null),
    setItem: (k, v) => map.set(k, String(v)),
    removeItem: (k) => map.delete(k),
  };
}

function fakeResponse({ status = 200, body = {} } = {}) {
  return {
    status,
    ok: status >= 200 && status < 300,
    json: async () => body,
    headers: { get: () => null },
  };
}

/** Boots a fresh AppStore instance (fresh module state) in a VM sandbox. */
function loadAppStore(fetchImpl) {
  const sandbox = {};
  sandbox.window = sandbox;
  sandbox.self = sandbox;
  sandbox.globalThis = sandbox;
  sandbox.console = console;
  sandbox.sessionStorage = makeStorage();
  sandbox.localStorage = makeStorage();
  sandbox.setTimeout = setTimeout;
  sandbox.clearInterval = clearInterval;
  sandbox.setInterval = setInterval;
  sandbox.CustomEvent = class CustomEvent {
    constructor(type, opts) { this.type = type; Object.assign(this, opts || {}); }
  };
  sandbox.window.addEventListener = () => {};
  sandbox.window.dispatchEvent = () => {};
  sandbox.HILLGO_API_BASE = 'http://test.local/api';
  sandbox.fetch = fetchImpl;
  vm.createContext(sandbox);

  const helpersSrc = fs.readFileSync(path.join(__dirname, '../ui/js/lib/store-helpers.js'), 'utf8');
  const storeSrc = fs.readFileSync(path.join(__dirname, '../ui/js/store.js'), 'utf8');
  vm.runInContext(helpersSrc, sandbox, { filename: 'store-helpers.js' });
  vm.runInContext(storeSrc, sandbox, { filename: 'store.js' });
  return sandbox;
}

test('AppStore exposes the expected public API surface', () => {
  const sandbox = loadAppStore(async () => fakeResponse());
  const api = sandbox.AppStore;
  ['isAuthed', 'login', 'logout', 'init', 'refresh', 'loadMore', 'getPageMeta',
    'getState', 'subscribe', 'getDivisions', 'listCustomers', 'updateCustomer'].forEach((m) => {
    assert.equal(typeof api[m], 'function', `AppStore.${m} should be a function`);
  });
});

test('auth token handling: login stores the token, isAuthed() flips, logout clears it', async () => {
  const sandbox = loadAppStore(async (url) => {
    if (String(url).includes('/admin/auth/login')) {
      return fakeResponse({ body: { token: 'abc123', user: { id: 1, name: 'Admin', role: 'admin' } } });
    }
    if (String(url).includes('/admin/auth/logout')) return fakeResponse({ body: {} });
    throw new Error(`unexpected fetch: ${url}`);
  });
  const api = sandbox.AppStore;

  assert.equal(api.isAuthed(), false, 'no token before login');
  const user = await api.login('admin@hillgo.app', 'secret');
  assert.equal(user.name, 'Admin');
  assert.equal(api.isAuthed(), true, 'token present after login');
  assert.equal(sandbox.sessionStorage.getItem('hillgo-admin-token'), 'abc123');

  await api.logout();
  assert.equal(api.isAuthed(), false, 'token cleared after logout');
  assert.equal(sandbox.sessionStorage.getItem('hillgo-admin-token'), null);
});

test('refresh() populates state from the API and notifies subscribers', async () => {
  const sandbox = loadAppStore(async (url) => {
    if (String(url).includes('/admin/overview')) return fakeResponse({ body: { revenue: 555, activeTrips: 3 } });
    throw new Error(`unexpected fetch: ${url}`);
  });
  const api = sandbox.AppStore;

  let notified = false;
  const unsubscribe = api.subscribe(() => { notified = true; });
  await api.refresh(['kpis']);
  unsubscribe();

  assert.equal(api.getState().kpis.revenue, 555);
  assert.equal(notified, true, 'subscribers are notified after refresh()');
});

test('refresh() logs failures for individual loaders without throwing (Promise.allSettled)', async () => {
  const sandbox = loadAppStore(async (url) => {
    if (String(url).includes('/admin/overview')) return fakeResponse({ status: 500, body: { message: 'boom' } });
    throw new Error(`unexpected fetch: ${url}`);
  });
  const api = sandbox.AppStore;
  await assert.doesNotReject(api.refresh(['kpis']));
  assert.equal(api.getState().kpis, null, 'failed loader leaves the previous (empty) state untouched');
});

test('districts N+1 fix: batched endpoint is preferred; a 404 falls back to the per-division fan-out once', async () => {
  const calls = [];
  const sandbox = loadAppStore(async (url) => {
    const u = String(url);
    calls.push(u);
    if (u.includes('/admin/regions/districts')) return fakeResponse({ status: 404, body: { message: 'Not found' } });
    if (u.endsWith('/admin/regions/divisions')) {
      return fakeResponse({ body: [{ id: 'dhaka', name: 'Dhaka' }, { id: 'sylhet', name: 'Sylhet' }] });
    }
    if (u.includes('/admin/regions/divisions/dhaka/districts')) {
      return fakeResponse({ body: [{ id: 1, name: 'Dhaka Sadar', divisionId: 'dhaka', status: 'open' }] });
    }
    if (u.includes('/admin/regions/divisions/sylhet/districts')) {
      return fakeResponse({ body: [{ id: 2, name: 'Sylhet Sadar', divisionId: 'sylhet', status: 'closed' }] });
    }
    throw new Error(`unexpected fetch: ${u}`);
  });
  const api = sandbox.AppStore;

  await api.refresh(['divisions', 'regionDistricts']);
  const districts = api.getState().regionDistricts;

  assert.equal(districts.length, 2, 'fan-out fallback still returns all districts across divisions');
  assert.ok(calls.some((c) => c.includes('/admin/regions/districts')), 'batched endpoint was tried first');
  assert.ok(calls.some((c) => c.includes('/admin/regions/divisions/dhaka/districts')), 'fell back to per-division fetch after 404');
});

test('districts N+1 fix: batched endpoint is used directly when available (no fan-out calls)', async () => {
  const calls = [];
  const sandbox = loadAppStore(async (url) => {
    const u = String(url);
    calls.push(u);
    if (u.includes('/admin/regions/districts')) {
      return fakeResponse({ body: [{ id: 1, name: 'Dhaka Sadar', divisionId: 'dhaka', status: 'open' }] });
    }
    throw new Error(`unexpected fetch (fan-out should not happen): ${u}`);
  });
  const api = sandbox.AppStore;

  await api.refresh(['regionDistricts']);
  assert.equal(api.getState().regionDistricts.length, 1);
  assert.equal(calls.length, 1, 'only the single batched call was made — no per-division fan-out');
});

test('retry-with-backoff: a transient network error is retried and eventually succeeds', async () => {
  let attempts = 0;
  const sandbox = loadAppStore(async (url) => {
    if (String(url).includes('/admin/overview')) {
      attempts += 1;
      if (attempts < 3) throw new TypeError('Failed to fetch');
      return fakeResponse({ body: { revenue: 42 } });
    }
    throw new Error(`unexpected fetch: ${url}`);
  });
  const api = sandbox.AppStore;

  await api.refresh(['kpis']);
  assert.equal(attempts, 3, 'retried twice (network errors) before the 3rd attempt succeeded');
  assert.equal(api.getState().kpis.revenue, 42);
});

test('retry-with-backoff: a 4xx HTTP response is NOT retried', async () => {
  let attempts = 0;
  const sandbox = loadAppStore(async (url) => {
    if (String(url).includes('/admin/overview')) {
      attempts += 1;
      return fakeResponse({ status: 422, body: { message: 'Validation failed' } });
    }
    throw new Error(`unexpected fetch: ${url}`);
  });
  const api = sandbox.AppStore;

  await api.refresh(['kpis']);
  assert.equal(attempts, 1, '4xx responses are surfaced immediately, not retried');
});

test('getPageMeta() defaults to page 1 / hasMore false before any load', () => {
  const sandbox = loadAppStore(async () => fakeResponse());
  // Objects crossing the vm context boundary aren't deepStrictEqual-comparable
  // (different Object prototype per realm), so compare fields directly.
  const meta = sandbox.AppStore.getPageMeta('customers');
  assert.equal(meta.page, 1);
  assert.equal(meta.hasMore, false);
});

test('loadMore() appends a de-duplicated next page and advances page meta', async () => {
  const sandbox = loadAppStore(async (url) => {
    const u = String(url);
    if (u.includes('/admin/customers') && u.includes('page=1')) {
      return fakeResponse({
        body: { data: [{ id: 1, name: 'A' }], meta: { current_page: 1, last_page: 2 } },
      });
    }
    if (u.includes('/admin/customers') && u.includes('page=2')) {
      return fakeResponse({
        body: { data: [{ id: 2, name: 'B' }], meta: { current_page: 2, last_page: 2 } },
      });
    }
    throw new Error(`unexpected fetch: ${u}`);
  });
  const api = sandbox.AppStore;

  await api.refresh(['customers']);
  assert.equal(api.getState().customers.length, 1);
  assert.equal(api.getPageMeta('customers').page, 1);
  assert.equal(api.getPageMeta('customers').hasMore, true);

  await api.loadMore('customers');
  assert.equal(api.getState().customers.length, 2);
  assert.equal(api.getPageMeta('customers').page, 2);
  assert.equal(api.getPageMeta('customers').hasMore, false);
});

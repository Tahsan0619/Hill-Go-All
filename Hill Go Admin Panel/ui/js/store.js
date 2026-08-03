/**
 * AppStore — live Laravel API client with an in-memory cache.
 * Reads are synchronous against the cache; mutations update the cache
 * optimistically, call the API, then reconcile with the server response.
 *
 * Token storage (accepted risk — see REMEDIATION_ADMIN_PANEL.md #5):
 * the Bearer token is kept in sessionStorage (not localStorage) so it
 * does not survive the browser session/tab close. It is still
 * XSS-readable synchronous JS storage. The hardened alternative is
 * Laravel Sanctum's SPA cookie-session mode (HttpOnly, not readable by
 * JS) — that requires a backend change (CSRF cookie endpoint + credentialed
 * requests) that is out of scope here and tracked as Blocked. Production
 * deployments use short-lived Sanctum tokens with rotation via
 * `POST /admin/auth/refresh` on bootstrap (`AppStore.init`). As a partial
 * mitigation, app.js clears
 * the token after the tab has been hidden for an extended idle period
 * (see `visibilitychange` handling in app.js).
 */
window.AppStore = (() => {
  const Helpers = window.HillGoStoreHelpers;
  const API_BASE = window.HILLGO_API_BASE || 'http://127.0.0.1:8000/api';
  const TOKEN_KEY = 'hillgo-admin-token';
  const PAGE_SIZE = 50;
  const listeners = new Set();

  const tokenStore = Helpers.createTokenStore(sessionStorage, localStorage, TOKEN_KEY);

  // Collections backed by a Laravel paginator; the UI can request more
  // pages beyond the first via loadMore() (see REMEDIATION_ADMIN_PANEL.md #7).
  const PAGED_COLLECTIONS = new Set([
    'customers', 'rides', 'foodOrders', 'customerParcels',
    'riders', 'riderKyc', 'trips', 'riderPayouts',
    'merchants', 'merchantOnboarding', 'merchantOrders', 'merchantPayouts',
    'courierAgents', 'courierKyc', 'courierParcels', 'courierWithdrawals',
  ]);

  let state = emptyState();
  let refreshTimer = null;

  function emptyState() {
    return {
      user: null,
      divisions: [],
      regionDistricts: [],
      customers: [],
      rides: [],
      foodOrders: [],
      customerParcels: [],
      riders: [],
      riderKyc: [],
      trips: [],
      riderPayouts: [],
      merchants: [],
      merchantOnboarding: [],
      merchantOrders: [],
      merchantPayouts: [],
      courierAgents: [],
      courierKyc: [],
      courierParcels: [],
      courierWithdrawals: [],
      incentives: [],
      pricing: { customer: {}, rider: {}, merchant: {}, courier: {} },
      pricingAudit: [],
      settings: {},
      activityLog: [],
      kpis: null,
      pageMeta: {},
    };
  }

  // —— HTTP ——

  function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  /** Fetch a private storage URL with the admin Bearer token and open it. */
  async function openAuthenticatedFile(fileUrl, fallbackName = 'document') {
    if (!fileUrl) throw new Error('No file URL');
    const res = await fetch(fileUrl, {
      headers: { Authorization: `Bearer ${tokenStore.token()}`, Accept: '*/*' },
    });
    if (res.status === 401) {
      tokenStore.clearToken();
      window.dispatchEvent(new CustomEvent('hillgo:unauthenticated'));
      throw new Error('Session expired. Please sign in again.');
    }
    if (!res.ok) throw new Error(`Could not open file (${res.status})`);
    const blob = await res.blob();
    const obj = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = obj;
    a.target = '_blank';
    a.rel = 'noopener';
    const cd = res.headers.get('content-disposition') || '';
    const m = /filename\*?=(?:UTF-8'')?["']?([^"';]+)/i.exec(cd);
    a.download = m ? decodeURIComponent(m[1]) : fallbackName;
    // Prefer new tab for images/PDFs; download attribute still helps naming.
    window.open(obj, '_blank', 'noopener');
    setTimeout(() => URL.revokeObjectURL(obj), 120000);
  }

  /**
   * Retry-with-backoff: up to 3 attempts, exponential backoff, but ONLY for
   * transient network failures (fetch() throwing — DNS/connection/timeout).
   * A response that came back with a 4xx/5xx status is a definitive server
   * answer, not a transient failure, and is surfaced immediately without
   * retrying (see REMEDIATION_ADMIN_PANEL.md #3).
   */
  async function http(method, path, body) {
    const maxAttempts = 3;
    let lastNetworkErr;
    for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
      let res;
      try {
        // eslint-disable-next-line no-await-in-loop
        res = await fetch(API_BASE + path, {
          method,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${tokenStore.token()}`,
          },
          body: body !== undefined ? JSON.stringify(body) : undefined,
        });
      } catch (err) {
        lastNetworkErr = err;
        if (attempt < maxAttempts && Helpers.isRetryableFetchError(err)) {
          console.warn(`[AppStore] network error on ${method} ${path} (attempt ${attempt}/${maxAttempts}); retrying…`, err);
          // eslint-disable-next-line no-await-in-loop
          await sleep(Helpers.computeBackoffDelay(attempt));
          continue;
        }
        window.HillGoTelemetry?.captureError(err, { source: 'AppStore.http', method, path, attempt });
        throw err;
      }

      if (res.status === 401) {
        tokenStore.clearToken();
        window.dispatchEvent(new CustomEvent('hillgo:unauthenticated'));
        throw new Helpers.HttpError('Session expired. Please sign in again.', 401);
      }
      let json = null;
      try { json = await res.json(); } catch (_) { /* empty body */ }
      if (!res.ok) {
        const msg = json?.message
          || (json?.errors ? Object.values(json.errors).flat().join(' ') : `Request failed (${res.status})`);
        const httpErr = new Helpers.HttpError(msg, res.status);
        if (res.status >= 500) window.HillGoTelemetry?.captureError(httpErr, { source: 'AppStore.http', method, path });
        throw httpErr;
      }
      return json;
    }
    // Exhausted retries without a response — surface the last network error.
    window.HillGoTelemetry?.captureError(lastNetworkErr, { source: 'AppStore.http', method, path, attempt: maxAttempts });
    throw lastNetworkErr;
  }

  const get = (path) => http('GET', path);
  const { unwrap, sid } = Helpers;

  function fail(err, reloadKeys) {
    console.error(err);
    window.HillGoTelemetry?.captureError(err, { source: 'AppStore.fail', reloadKeys });
    if (window.UI?.notice) UI.notice(err.message || 'Request failed', 'error');
    if (reloadKeys) refresh(reloadKeys);
  }

  /** Build a loader for a Laravel-paginated collection; returns {rows, meta}. */
  function pagedLoader(path, mapRow = sid) {
    return async (page = 1) => {
      const sep = path.includes('?') ? '&' : '?';
      const res = await get(`${path}${sep}per_page=${PAGE_SIZE}&page=${page}`);
      return { rows: unwrap(res).map(mapRow), meta: Helpers.computePageMeta(res, page) };
    };
  }

  // —— Collection loaders ——

  const LOADERS = {
    divisions: async () => (await get('/admin/regions/divisions')).map(sid),
    // Districts N+1 fix: prefer a single batched endpoint; fall back to the
    // old per-division fan-out (once) only if the batched endpoint 404s.
    regionDistricts: async () => {
      try {
        const res = await get('/admin/regions/districts');
        return unwrap(res).map(sid);
      } catch (err) {
        if (!Helpers.isNotFoundError(err)) throw err;
        console.warn('[AppStore] /admin/regions/districts is 404 — falling back to per-division fan-out.');
        const divisions = state.divisions.length ? state.divisions : (await get('/admin/regions/divisions')).map(sid);
        const lists = await Promise.all(divisions.map((d) => get(`/admin/regions/divisions/${d.id}/districts`)));
        return lists.flat().map(sid);
      }
    },
    customers: pagedLoader('/admin/customers'),
    rides: pagedLoader('/admin/rides'),
    foodOrders: pagedLoader('/admin/food-orders'),
    customerParcels: pagedLoader('/admin/customer-parcels'),
    riders: pagedLoader('/admin/riders'),
    riderKyc: pagedLoader('/admin/riders/kyc', (k) => ({
      ...sid(k),
      riderId: String(k.riderId ?? ''),
      docs: (k.docs || []).map((d) => d.title || d.key),
      docDetails: k.docs || [],
    })),
    trips: pagedLoader('/admin/trips'),
    riderPayouts: pagedLoader('/admin/rider-payouts'),
    merchants: pagedLoader('/admin/merchants'),
    merchantOnboarding: pagedLoader('/admin/merchant-onboarding'),
    merchantOrders: pagedLoader('/admin/merchant-orders'),
    merchantPayouts: pagedLoader('/admin/merchant-payouts'),
    courierAgents: pagedLoader('/admin/courier/agents'),
    courierKyc: pagedLoader('/admin/courier/kyc', (k) => ({
      ...sid(k),
      agentId: String(k.agentId ?? ''),
      docs: (k.docs || []).map((d) => d.title || d.key),
      docDetails: k.docs || [],
    })),
    courierParcels: pagedLoader('/admin/courier/parcels'),
    courierWithdrawals: pagedLoader('/admin/courier/withdrawals'),
    incentives: async () => (await get('/admin/courier/incentives')).map(sid),
    pricing: async () => {
      const [customer, rider, merchant, courier] = await Promise.all(
        ['customer', 'rider', 'merchant', 'courier'].map((p) => get(`/admin/pricing/${p}`)),
      );
      return { customer, rider, merchant, courier };
    },
    pricingAudit: async () => (await get('/admin/pricing-audit')).map(sid),
    settings: async () => get('/admin/settings'),
    activityLog: async () => (await get('/admin/activity')).map(sid),
    kpis: async () => get('/admin/overview'),
  };

  async function refresh(keys) {
    const wanted = keys || Object.keys(LOADERS);
    const results = await Promise.allSettled(wanted.map((k) => LOADERS[k](1)));
    const { nextState, errors } = Helpers.aggregateRefreshResults(wanted, results);
    wanted.forEach((k) => {
      if (!(k in nextState)) return;
      if (PAGED_COLLECTIONS.has(k)) {
        state[k] = nextState[k].rows;
        state.pageMeta[k] = nextState[k].meta;
      } else {
        state[k] = nextState[k];
      }
    });
    errors.forEach(({ key, reason }) => {
      console.error(`Failed loading ${key}:`, reason);
      window.HillGoTelemetry?.captureError(reason, { source: 'AppStore.refresh', key });
    });
    emit();
  }

  /** Fetch the next server page for a paginated collection and append it. */
  async function loadMore(collection) {
    if (!PAGED_COLLECTIONS.has(collection)) return;
    const meta = state.pageMeta[collection];
    if (!meta || !meta.hasMore) return;
    const nextPage = (meta.page || 1) + 1;
    try {
      const { rows, meta: newMeta } = await LOADERS[collection](nextPage);
      const existingIds = new Set(state[collection].map((r) => String(r.id)));
      const fresh = rows.filter((r) => !existingIds.has(String(r.id)));
      state[collection] = state[collection].concat(fresh);
      state.pageMeta[collection] = newMeta;
      emit();
    } catch (err) {
      fail(err);
    }
  }

  function getPageMeta(collection) {
    return state.pageMeta[collection] || { page: 1, hasMore: false };
  }

  function emit() {
    listeners.forEach((fn) => {
      try { fn(state); } catch (e) { console.error(e); window.HillGoTelemetry?.captureError(e, { source: 'AppStore.emit' }); }
    });
  }

  // Optimistic patch of a cached row, returns the row.
  function patchRow(collection, id, patch) {
    return Helpers.patchRow(state[collection], id, patch);
  }

  // Replace a cached row with the (string-id normalized) server version.
  function mergeRow(collection, serverRow) {
    Helpers.mergeRow(state[collection], serverRow, sid);
    emit();
  }

  const api = {
    // —— Session ——
    isAuthed: () => !!tokenStore.token(),
    currentUser: () => state.user,
    openAuthenticatedFile,
    async login(email, password) {
      const res = await http('POST', '/admin/auth/login', { email, password });
      tokenStore.setToken(res.token);
      state.user = res.user;
      return res.user;
    },
    async logout() {
      try { await http('POST', '/admin/auth/logout'); } catch (_) { /* token may already be dead */ }
      tokenStore.clearToken();
      sessionStorage.removeItem('hillgo-search');
      state = emptyState();
      if (refreshTimer) clearInterval(refreshTimer);
      window.dispatchEvent(new CustomEvent('hillgo:unauthenticated'));
    },
    async init() {
      try {
        const res = await http('POST', '/admin/auth/refresh');
        tokenStore.setToken(res.token);
        state.user = res.user;
      } catch (err) {
        if (err.status === 401) throw err;
        const me = await get('/admin/me');
        state.user = me.user ?? me;
      }
      await refresh();
      if (refreshTimer) clearInterval(refreshTimer);
      refreshTimer = setInterval(() => {
        refresh(['kpis', 'activityLog', 'rides', 'trips', 'merchantOrders', 'courierParcels']).catch(() => {});
      }, 30000);
      return state;
    },

    getState: () => state,
    subscribe(fn) {
      listeners.add(fn);
      return () => listeners.delete(fn);
    },
    refresh,
    loadMore,
    getPageMeta,
    resetData() {
      refresh().then(() => UI?.notice?.('Data reloaded from server')).catch((e) => fail(e));
    },

    // —— Region ——
    getDivisions() {
      return state.divisions.map((div) => {
        const districts = state.regionDistricts.filter((x) => x.divisionId === div.id);
        const open = districts.filter((x) => x.status === 'open').length;
        return {
          ...div,
          total: districts.length,
          open,
          closed: districts.length - open,
          status: open === 0 ? 'closed' : open === districts.length ? 'open' : 'partial',
        };
      });
    },
    getDistrictsByDivision(divisionId) {
      return state.regionDistricts.filter((d) => d.divisionId === divisionId);
    },
    getDistrict(id) {
      return state.regionDistricts.find((d) => String(d.id) === String(id));
    },
    updateDistrict(id, patch) {
      const row = patchRow('regionDistricts', id, patch);
      emit();
      http('PATCH', `/admin/regions/districts/${id}`, patch)
        .then((server) => { mergeRow('regionDistricts', server); refresh(['activityLog', 'divisions']); })
        .catch((e) => fail(e, ['regionDistricts']));
      return row;
    },
    setAllDistrictsInDivision(divisionId, status) {
      state.regionDistricts.filter((d) => d.divisionId === divisionId).forEach((d) => {
        d.status = status;
        const open = status === 'open';
        d.allowCustomer = open; d.allowRider = open; d.allowMerchant = open; d.allowCourier = open;
      });
      emit();
      http('POST', `/admin/regions/divisions/${divisionId}/bulk-status`, { status })
        .then(() => refresh(['regionDistricts', 'divisions', 'activityLog']))
        .catch((e) => fail(e, ['regionDistricts', 'divisions']));
    },

    // —— Customers ——
    listCustomers(filter = {}) {
      let rows = [...state.customers];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((c) => [c.name, c.phone, c.email, c.code, c.district].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') rows = rows.filter((c) => c.status === filter.status);
      return rows;
    },
    getCustomer(id) {
      return state.customers.find((c) => String(c.id) === String(id));
    },
    updateCustomer(id, patch) {
      const row = patchRow('customers', id, patch);
      emit();
      http('PATCH', `/admin/customers/${id}`, patch)
        .then((server) => { mergeRow('customers', server); refresh(['activityLog']); })
        .catch((e) => fail(e, ['customers']));
      return row;
    },
    adjustWallet(id, delta, note) {
      const amount = Number(delta);
      if (!Number.isFinite(amount) || Math.abs(amount) > 1e7) {
        if (window.UI?.notice) UI.notice('Invalid wallet amount (must be finite and within ±10,000,000)', 'error');
        return null;
      }
      const row = patchRow('customers', id, {});
      if (row) row.wallet = Math.round((row.wallet + amount) * 100) / 100;
      emit();
      http('POST', `/admin/customers/${id}/wallet`, { delta: amount, note: note || '' })
        .then((server) => { mergeRow('customers', server); refresh(['activityLog']); })
        .catch((e) => fail(e, ['customers']));
      return row;
    },

    // —— Rides / food / parcels ——
    listRides(filter = {}) {
      let rows = [...state.rides];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((r) => [r.code, r.customer, r.rider, r.pickup, r.drop, r.status].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') rows = rows.filter((r) => r.status === filter.status);
      return rows;
    },
    listFoodOrders(filter = {}) {
      let rows = [...state.foodOrders];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((r) => [r.code, r.restaurant, r.customer, r.status].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') rows = rows.filter((r) => r.status === filter.status);
      return rows;
    },
    listCustomerParcels(filter = {}) {
      let rows = [...state.customerParcels];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((r) => [r.code, r.type, r.customer, r.status].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') rows = rows.filter((r) => r.status === filter.status);
      return rows;
    },

    // —— Riders ——
    listRiders(filter = {}) {
      let rows = [...state.riders];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((r) => [r.code, r.name, r.phone, r.plate, r.district].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') rows = rows.filter((r) => r.status === filter.status);
      return rows;
    },
    updateRider(id, patch) {
      const row = patchRow('riders', id, patch);
      emit();
      http('PATCH', `/admin/riders/${id}`, patch)
        .then((server) => { mergeRow('riders', server); refresh(['activityLog']); })
        .catch((e) => fail(e, ['riders']));
      return row;
    },
    listRiderKyc(filter = {}) {
      let rows = [...state.riderKyc];
      if (filter.tab === 'priority') rows = rows.filter((k) => k.priority);
      if (filter.tab === 'flagged') rows = rows.filter((k) => k.flagged);
      if (filter.status && filter.status !== 'all') rows = rows.filter((k) => k.status === filter.status);
      return rows;
    },
    setRiderKycStatus(id, status) {
      const row = patchRow('riderKyc', id, { status });
      emit();
      http('POST', `/admin/riders/kyc/${id}/status`, { status })
        .then(() => refresh(['riderKyc', 'riders', 'activityLog']))
        .catch((e) => fail(e, ['riderKyc']));
      return row;
    },
    bulkRiderKyc(ids, status) {
      ids.forEach((id) => {
        const k = state.riderKyc.find((x) => String(x.id) === String(id));
        if (k && k.status !== 'verified') k.status = status;
      });
      emit();
      http('POST', '/admin/riders/kyc/bulk', { ids: ids.map(Number), status })
        .then(() => refresh(['riderKyc', 'riders', 'activityLog']))
        .catch((e) => fail(e, ['riderKyc']));
    },
    listTrips(filter = {}) {
      let rows = [...state.trips];
      if (filter.type && filter.type !== 'all') rows = rows.filter((t) => t.type === filter.type);
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((t) => [t.code, t.rider, t.route, t.status].join(' ').toLowerCase().includes(q));
      }
      return rows;
    },
    createRiderPayout(payload) {
      const optimistic = {
        id: `pending-${Date.now()}`,
        code: '…',
        riderId: String(payload.riderId),
        rider: payload.rider,
        amount: Number(payload.amount),
        method: payload.method,
        periodFrom: payload.periodFrom,
        periodTo: payload.periodTo,
        ref: payload.ref || '',
        paidAt: new Date().toISOString(),
        status: 'paid',
        tips: Number(payload.tips || 0),
        surge: Number(payload.surge || 0),
        deductions: Number(payload.deductions || 0),
        note: payload.note || '',
      };
      state.riderPayouts.unshift(optimistic);
      emit();
      http('POST', '/admin/rider-payouts', { ...payload, riderId: Number(payload.riderId) })
        .then(() => refresh(['riderPayouts', 'riders', 'activityLog']))
        .catch((e) => fail(e, ['riderPayouts']));
      return optimistic;
    },
    listRiderPayouts(filter = {}) {
      let rows = [...state.riderPayouts];
      if (filter.method && filter.method !== 'all') rows = rows.filter((p) => p.method === filter.method);
      if (filter.status && filter.status !== 'all') rows = rows.filter((p) => p.status === filter.status);
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((p) => [p.code, p.rider, p.ref, p.method].join(' ').toLowerCase().includes(q));
      }
      return rows;
    },
    setRiderPayoutStatus(id, status) {
      const row = patchRow('riderPayouts', id, { status });
      emit();
      http('POST', `/admin/rider-payouts/${id}/status`, { status })
        .then((server) => { mergeRow('riderPayouts', server); refresh(['activityLog']); })
        .catch((e) => fail(e, ['riderPayouts']));
      return row;
    },

    // —— Merchants ——
    listMerchants(filter = {}) {
      let rows = [...state.merchants];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((m) => [m.code, m.name, m.owner, m.category, m.district].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') rows = rows.filter((m) => m.status === filter.status);
      return rows;
    },
    updateMerchant(id, patch) {
      const row = patchRow('merchants', id, patch);
      emit();
      http('PATCH', `/admin/merchants/${id}`, patch)
        .then((server) => { mergeRow('merchants', server); refresh(['activityLog']); })
        .catch((e) => fail(e, ['merchants']));
      return row;
    },
    listOnboarding(filter = {}) {
      let rows = [...state.merchantOnboarding];
      if (filter.status && filter.status !== 'all') rows = rows.filter((o) => o.status === filter.status);
      return rows;
    },
    setOnboardingStatus(id, status) {
      const row = patchRow('merchantOnboarding', id, { status });
      emit();
      http('POST', `/admin/merchant-onboarding/${id}/status`, { status })
        .then(() => refresh(['merchantOnboarding', 'merchants', 'activityLog']))
        .catch((e) => fail(e, ['merchantOnboarding']));
      return row;
    },
    listMerchantOrders(filter = {}) {
      let rows = [...state.merchantOrders];
      if (filter.tab === 'active') rows = rows.filter((o) => ['new_order', 'preparing', 'ready'].includes(o.status));
      if (filter.tab === 'scheduled') rows = rows.filter((o) => o.priority === 'scheduled');
      if (filter.tab === 'completed') rows = rows.filter((o) => ['delivered', 'rejected'].includes(o.status));
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((o) => [o.code, o.store, o.customer, o.status].join(' ').toLowerCase().includes(q));
      }
      return rows;
    },
    listMerchantPayouts(filter = {}) {
      let rows = [...state.merchantPayouts];
      if (filter.status && filter.status !== 'all') rows = rows.filter((p) => p.status === filter.status);
      return rows;
    },
    setMerchantPayoutStatus(id, status) {
      const row = patchRow('merchantPayouts', id, { status });
      emit();
      http('POST', `/admin/merchant-payouts/${id}/status`, { status })
        .then(() => refresh(['merchantPayouts', 'activityLog']))
        .catch((e) => fail(e, ['merchantPayouts']));
      return row;
    },

    // —— Courier ——
    listAgents(filter = {}) {
      let rows = [...state.courierAgents];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((a) => [a.code, a.name, a.phone, a.district].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') rows = rows.filter((a) => a.status === filter.status);
      return rows;
    },
    updateAgent(id, patch) {
      const row = patchRow('courierAgents', id, patch);
      emit();
      http('PATCH', `/admin/courier/agents/${id}`, patch)
        .then((server) => { mergeRow('courierAgents', server); refresh(['activityLog']); })
        .catch((e) => fail(e, ['courierAgents']));
      return row;
    },
    listCourierKyc(filter = {}) {
      let rows = [...state.courierKyc];
      if (filter.status && filter.status !== 'all') rows = rows.filter((k) => k.status === filter.status);
      return rows;
    },
    setCourierKycStatus(id, status, bankVerified) {
      const patch = { status };
      if (typeof bankVerified === 'boolean') patch.bankVerified = bankVerified;
      const row = patchRow('courierKyc', id, patch);
      emit();
      http('POST', `/admin/courier/kyc/${id}/status`, patch)
        .then(() => refresh(['courierKyc', 'courierAgents', 'activityLog']))
        .catch((e) => fail(e, ['courierKyc']));
      return row;
    },
    listCourierParcels(filter = {}) {
      let rows = [...state.courierParcels];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((p) => [p.code, p.agent, p.pickup, p.drop, p.status].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') rows = rows.filter((p) => p.status === filter.status);
      return rows;
    },
    reassignParcel(id, agentId) {
      http('POST', `/admin/courier/parcels/${id}/reassign`, { agentId: agentId ? Number(agentId) : null })
        .then(() => refresh(['courierParcels', 'activityLog']))
        .catch((e) => fail(e, ['courierParcels']));
    },
    listWithdrawals(filter = {}) {
      let rows = [...state.courierWithdrawals];
      if (filter.status && filter.status !== 'all') rows = rows.filter((w) => w.status === filter.status);
      return rows;
    },
    setWithdrawalStatus(id, status) {
      const row = patchRow('courierWithdrawals', id, { status });
      emit();
      http('POST', `/admin/courier/withdrawals/${id}/status`, { status })
        .then(() => refresh(['courierWithdrawals', 'courierAgents', 'activityLog']))
        .catch((e) => fail(e, ['courierWithdrawals']));
      return row;
    },
    listIncentives() {
      return [...state.incentives];
    },
    createIncentive(payload) {
      const optimistic = {
        id: `pending-${Date.now()}`,
        title: payload.title,
        description: payload.description || '',
        multiplier: Number(payload.multiplier || 1),
        district: payload.district || '',
        goalDeliveries: Number(payload.goalDeliveries || 0),
        bonusTk: Number(payload.bonusTk || 0),
        validUntil: payload.validUntil,
        active: !!payload.active,
        status: payload.active ? 'active' : 'scheduled',
      };
      state.incentives.unshift(optimistic);
      emit();
      http('POST', '/admin/courier/incentives', payload)
        .then(() => refresh(['incentives', 'activityLog']))
        .catch((e) => fail(e, ['incentives']));
      return optimistic;
    },
    toggleIncentive(id, active) {
      const row = patchRow('incentives', id, { active, status: active ? 'active' : 'scheduled' });
      emit();
      http('POST', `/admin/courier/incentives/${id}/toggle`, { active })
        .then((server) => mergeRow('incentives', server))
        .catch((e) => fail(e, ['incentives']));
      return row;
    },

    // —— Pricing ——
    getPricing(panel) {
      return { ...(state.pricing[panel] || {}) };
    },
    savePricing(panel, values) {
      for (const [key, val] of Object.entries(values)) {
        if (typeof val === 'number' && !Number.isFinite(val)) {
          if (window.UI?.notice) UI.notice(`Invalid pricing value for ${key}`, 'error');
          return;
        }
      }
      state.pricing[panel] = { ...state.pricing[panel], ...values };
      emit();
      http('PUT', `/admin/pricing/${panel}`, { values })
        .then((server) => { state.pricing[panel] = server; refresh(['pricingAudit', 'activityLog']); })
        .catch((e) => fail(e, ['pricing', 'pricingAudit']));
    },
    listPricingAudit(panel) {
      return state.pricingAudit.filter((a) => !panel || a.panel === panel);
    },

    // —— Settings ——
    getSettings() {
      return { ...state.settings };
    },
    saveSettings(patch) {
      Object.assign(state.settings, patch);
      emit();
      http('PUT', '/admin/settings', patch)
        .then((server) => { state.settings = server; emit(); })
        .catch((e) => fail(e, ['settings']));
    },

    // —— Aggregates ——
    overviewKpis() {
      return state.kpis || {
        revenue: 0, activeTrips: 0, foodOrders: 0, issues: 0,
        customers: 0, riders: 0, stores: 0, parcelsInTransit: 0,
        openDistricts: state.regionDistricts.filter((d) => d.status === 'open').length,
        totalDistricts: state.regionDistricts.length,
      };
    },
  };

  return api;
})();

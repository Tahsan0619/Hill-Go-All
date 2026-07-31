/**
 * AppStore — live Laravel API client with an in-memory cache.
 * Reads are synchronous against the cache; mutations update the cache
 * optimistically, call the API, then reconcile with the server response.
 */
window.AppStore = (() => {
  const API_BASE = window.HILLGO_API_BASE || 'http://localhost:8000/api';
  const TOKEN_KEY = 'hillgo-admin-token';
  const listeners = new Set();

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
    };
  }

  // —— HTTP ——

  function token() {
    return localStorage.getItem(TOKEN_KEY) || '';
  }

  async function http(method, path, body) {
    const res = await fetch(API_BASE + path, {
      method,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token()}`,
      },
      body: body !== undefined ? JSON.stringify(body) : undefined,
    });
    if (res.status === 401) {
      localStorage.removeItem(TOKEN_KEY);
      window.dispatchEvent(new CustomEvent('hillgo:unauthenticated'));
      throw new Error('Session expired. Please sign in again.');
    }
    let json = null;
    try { json = await res.json(); } catch (_) { /* empty body */ }
    if (!res.ok) {
      const msg = json?.message
        || (json?.errors ? Object.values(json.errors).flat().join(' ') : `Request failed (${res.status})`);
      throw new Error(msg);
    }
    return json;
  }

  const get = (path) => http('GET', path);
  const unwrap = (res) => (Array.isArray(res) ? res : (res?.data ?? []));
  const sid = (row) => ({ ...row, id: String(row.id) });

  function fail(err, reloadKeys) {
    console.error(err);
    if (window.UI?.notice) UI.notice(err.message || 'Request failed', 'error');
    if (reloadKeys) refresh(reloadKeys);
  }

  // —— Collection loaders ——

  const LOADERS = {
    divisions: async () => (await get('/admin/regions/divisions')).map(sid),
    regionDistricts: async () => {
      const divisions = state.divisions.length ? state.divisions : (await get('/admin/regions/divisions')).map(sid);
      const lists = await Promise.all(divisions.map((d) => get(`/admin/regions/divisions/${d.id}/districts`)));
      return lists.flat().map(sid);
    },
    customers: async () => unwrap(await get('/admin/customers?per_page=200')).map(sid),
    rides: async () => unwrap(await get('/admin/rides?per_page=200')).map(sid),
    foodOrders: async () => unwrap(await get('/admin/food-orders?per_page=200')).map(sid),
    customerParcels: async () => unwrap(await get('/admin/customer-parcels?per_page=200')).map(sid),
    riders: async () => unwrap(await get('/admin/riders?per_page=200')).map(sid),
    riderKyc: async () => unwrap(await get('/admin/riders/kyc')).map((k) => ({
      ...sid(k),
      riderId: String(k.riderId ?? ''),
      docs: (k.docs || []).map((d) => d.title || d.key),
      docDetails: k.docs || [],
    })),
    trips: async () => unwrap(await get('/admin/trips?per_page=200')).map(sid),
    riderPayouts: async () => unwrap(await get('/admin/rider-payouts')).map(sid),
    merchants: async () => unwrap(await get('/admin/merchants?per_page=200')).map(sid),
    merchantOnboarding: async () => unwrap(await get('/admin/merchant-onboarding')).map(sid),
    merchantOrders: async () => unwrap(await get('/admin/merchant-orders?per_page=200')).map(sid),
    merchantPayouts: async () => unwrap(await get('/admin/merchant-payouts')).map(sid),
    courierAgents: async () => unwrap(await get('/admin/courier/agents')).map(sid),
    courierKyc: async () => unwrap(await get('/admin/courier/kyc')).map((k) => ({
      ...sid(k),
      agentId: String(k.agentId ?? ''),
      docs: (k.docs || []).map((d) => d.title || d.key),
      docDetails: k.docs || [],
    })),
    courierParcels: async () => unwrap(await get('/admin/courier/parcels')).map(sid),
    courierWithdrawals: async () => unwrap(await get('/admin/courier/withdrawals')).map(sid),
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
    const results = await Promise.allSettled(wanted.map((k) => LOADERS[k]()));
    results.forEach((r, i) => {
      if (r.status === 'fulfilled') state[wanted[i]] = r.value;
      else console.error(`Failed loading ${wanted[i]}:`, r.reason);
    });
    emit();
  }

  function emit() {
    listeners.forEach((fn) => {
      try { fn(state); } catch (e) { console.error(e); }
    });
  }

  // Optimistic patch of a cached row, returns the row.
  function patchRow(collection, id, patch) {
    const row = state[collection].find((x) => String(x.id) === String(id));
    if (row) Object.assign(row, patch);
    return row;
  }

  // Replace a cached row with the (string-id normalized) server version.
  function mergeRow(collection, serverRow) {
    const norm = sid(serverRow);
    const idx = state[collection].findIndex((x) => String(x.id) === norm.id);
    if (idx >= 0) state[collection][idx] = { ...state[collection][idx], ...norm };
    else state[collection].unshift(norm);
    emit();
  }

  const api = {
    // —— Session ——
    isAuthed: () => !!token(),
    currentUser: () => state.user,
    async login(email, password) {
      const res = await http('POST', '/admin/auth/login', { email, password });
      localStorage.setItem(TOKEN_KEY, res.token);
      state.user = res.user;
      return res.user;
    },
    async logout() {
      try { await http('POST', '/admin/auth/logout'); } catch (_) { /* token may already be dead */ }
      localStorage.removeItem(TOKEN_KEY);
      state = emptyState();
      if (refreshTimer) clearInterval(refreshTimer);
      window.dispatchEvent(new CustomEvent('hillgo:unauthenticated'));
    },
    async init() {
      const me = await get('/admin/me');
      state.user = me.user ?? me;
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
      const row = patchRow('customers', id, {});
      if (row) row.wallet = Math.round((row.wallet + Number(delta)) * 100) / 100;
      emit();
      http('POST', `/admin/customers/${id}/wallet`, { delta: Number(delta), note: note || '' })
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

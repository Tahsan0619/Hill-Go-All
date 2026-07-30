/**
 * Mutable AppStore — localStorage-backed mock backend.
 * Swap method bodies for API calls later; keep method names stable.
 */
window.AppStore = (() => {
  const KEY = 'hillgo-admin-v1';
  const listeners = new Set();

  function cloneSeed() {
    return JSON.parse(JSON.stringify(window.HillGoSeed));
  }

  function load() {
    try {
      const raw = localStorage.getItem(KEY);
      if (raw) {
        const parsed = JSON.parse(raw);
        // Merge missing keys from seed if schema grew
        const seed = cloneSeed();
        return { ...seed, ...parsed, pricing: { ...seed.pricing, ...(parsed.pricing || {}) } };
      }
    } catch (_) { /* ignore */ }
    return cloneSeed();
  }

  let state = load();

  function persist() {
    localStorage.setItem(KEY, JSON.stringify(state));
  }

  function emit() {
    persist();
    listeners.forEach((fn) => {
      try { fn(state); } catch (e) { console.error(e); }
    });
  }

  function uid(prefix) {
    return `${prefix}-${Date.now().toString(36).slice(-6).toUpperCase()}`;
  }

  function pushLog(text) {
    state.activityLog.unshift({
      id: uid('LOG'),
      text,
      by: 'Admin User',
      at: new Date().toISOString(),
    });
    if (state.activityLog.length > 100) state.activityLog.length = 100;
  }

  const api = {
    getState: () => state,
    subscribe(fn) {
      listeners.add(fn);
      return () => listeners.delete(fn);
    },
    resetData() {
      state = cloneSeed();
      emit();
    },

    // —— Region ——
    getDivisions() {
      return state.divisions.map((d) => {
        const districts = state.regionDistricts.filter((x) => x.divisionId === d.id);
        const open = districts.filter((x) => x.status === 'open').length;
        return {
          ...d,
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
      return state.regionDistricts.find((d) => d.id === id);
    },
    updateDistrict(id, patch) {
      const d = state.regionDistricts.find((x) => x.id === id);
      if (!d) return null;
      Object.assign(d, patch, { updatedAt: new Date().toISOString(), updatedBy: 'Admin User' });
      if (d.status === 'open' && !d.openedAt) d.openedAt = new Date().toISOString().slice(0, 16);
      if (d.status === 'closed') {
        d.allowCustomer = false;
        d.allowRider = false;
        d.allowMerchant = false;
        d.allowCourier = false;
      }
      pushLog(`${d.name} (${d.divisionName}) → ${d.status}`);
      emit();
      return d;
    },
    setAllDistrictsInDivision(divisionId, status) {
      state.regionDistricts
        .filter((d) => d.divisionId === divisionId)
        .forEach((d) => {
          d.status = status;
          d.updatedAt = new Date().toISOString();
          d.updatedBy = 'Admin User';
          if (status === 'open') {
            d.openedAt = d.openedAt || new Date().toISOString().slice(0, 16);
            d.allowCustomer = true;
            d.allowRider = true;
            d.allowMerchant = true;
            d.allowCourier = true;
          } else {
            d.allowCustomer = false;
            d.allowRider = false;
            d.allowMerchant = false;
            d.allowCourier = false;
          }
        });
      const div = state.divisions.find((x) => x.id === divisionId);
      pushLog(`${div?.name || divisionId}: all districts ${status}`);
      emit();
    },

    // —— Customers ——
    listCustomers(filter = {}) {
      let rows = [...state.customers];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((c) =>
          [c.name, c.phone, c.email, c.id, c.district].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') {
        rows = rows.filter((c) => c.status === filter.status);
      }
      return rows;
    },
    getCustomer(id) {
      return state.customers.find((c) => c.id === id);
    },
    updateCustomer(id, patch) {
      const c = state.customers.find((x) => x.id === id);
      if (!c) return null;
      Object.assign(c, patch);
      pushLog(`Customer ${c.name} updated`);
      emit();
      return c;
    },
    adjustWallet(id, delta, note) {
      const c = state.customers.find((x) => x.id === id);
      if (!c) return null;
      c.wallet = Math.round((c.wallet + Number(delta)) * 100) / 100;
      pushLog(`Wallet ${c.name}: ${delta >= 0 ? '+' : ''}${delta} ৳${note ? ` (${note})` : ''}`);
      emit();
      return c;
    },

    // —— Rides / food / parcels ——
    listRides(filter = {}) {
      let rows = [...state.rides];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((r) => [r.id, r.customer, r.rider, r.pickup, r.drop, r.status].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') rows = rows.filter((r) => r.status === filter.status);
      return rows;
    },
    listFoodOrders(filter = {}) {
      let rows = [...state.foodOrders];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((r) => [r.id, r.restaurant, r.customer, r.status].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') rows = rows.filter((r) => r.status === filter.status);
      return rows;
    },
    listCustomerParcels(filter = {}) {
      let rows = [...state.customerParcels];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((r) => [r.id, r.type, r.customer, r.status].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') rows = rows.filter((r) => r.status === filter.status);
      return rows;
    },

    // —— Riders ——
    listRiders(filter = {}) {
      let rows = [...state.riders];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((r) => [r.id, r.name, r.phone, r.plate, r.district].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') rows = rows.filter((r) => r.status === filter.status);
      return rows;
    },
    updateRider(id, patch) {
      const r = state.riders.find((x) => x.id === id);
      if (!r) return null;
      Object.assign(r, patch);
      pushLog(`Rider ${r.name} → ${patch.status || 'updated'}`);
      emit();
      return r;
    },
    listRiderKyc(filter = {}) {
      let rows = [...state.riderKyc];
      if (filter.tab === 'priority') rows = rows.filter((k) => k.priority);
      if (filter.tab === 'flagged') rows = rows.filter((k) => k.flagged);
      if (filter.status && filter.status !== 'all') rows = rows.filter((k) => k.status === filter.status);
      return rows;
    },
    setRiderKycStatus(id, status) {
      const k = state.riderKyc.find((x) => x.id === id);
      if (!k) return null;
      k.status = status;
      if (status === 'verified') {
        const rider = state.riders.find((r) => r.id === k.riderId);
        if (rider && rider.status === 'onboarding') rider.status = 'active';
      }
      pushLog(`Rider KYC ${k.riderName}: ${status}`);
      emit();
      return k;
    },
    bulkRiderKyc(ids, status) {
      ids.forEach((id) => {
        const k = state.riderKyc.find((x) => x.id === id);
        if (k && k.status !== 'verified') k.status = status;
      });
      pushLog(`Bulk rider KYC → ${status} (${ids.length})`);
      emit();
    },
    listTrips(filter = {}) {
      let rows = [...state.trips];
      if (filter.type && filter.type !== 'all') rows = rows.filter((t) => t.type === filter.type);
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((t) => [t.id, t.rider, t.route, t.status].join(' ').toLowerCase().includes(q));
      }
      return rows;
    },
    createRiderPayout(payload) {
      const row = {
        id: uid('HG-PY'),
        riderId: payload.riderId,
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
      state.riderPayouts.unshift(row);
      pushLog(`Salary paid ${row.rider}: ৳${row.amount} via ${row.method}`);
      emit();
      return row;
    },
    listRiderPayouts(filter = {}) {
      let rows = [...state.riderPayouts];
      if (filter.method && filter.method !== 'all') rows = rows.filter((p) => p.method === filter.method);
      if (filter.status && filter.status !== 'all') rows = rows.filter((p) => p.status === filter.status);
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((p) => [p.id, p.rider, p.ref, p.method].join(' ').toLowerCase().includes(q));
      }
      return rows;
    },

    // —— Merchants ——
    listMerchants(filter = {}) {
      let rows = [...state.merchants];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((m) => [m.id, m.name, m.owner, m.category, m.district].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') rows = rows.filter((m) => m.status === filter.status);
      return rows;
    },
    updateMerchant(id, patch) {
      const m = state.merchants.find((x) => x.id === id);
      if (!m) return null;
      Object.assign(m, patch);
      pushLog(`Merchant ${m.name} updated`);
      emit();
      return m;
    },
    listOnboarding(filter = {}) {
      let rows = [...state.merchantOnboarding];
      if (filter.status && filter.status !== 'all') rows = rows.filter((o) => o.status === filter.status);
      return rows;
    },
    setOnboardingStatus(id, status) {
      const o = state.merchantOnboarding.find((x) => x.id === id);
      if (!o) return null;
      o.status = status;
      if (status === 'approved') {
        let m = state.merchants.find((x) => x.id === o.merchantId);
        if (!m) {
          m = {
            id: o.merchantId || uid('HG-MRT'),
            name: o.businessName,
            owner: o.owner,
            category: o.category,
            district: o.district,
            isOpen: true,
            acceptingOrders: true,
            status: 'active',
            rating: 0,
            gmvToday: 0,
          };
          state.merchants.unshift(m);
        } else {
          m.status = 'active';
          m.isOpen = true;
          m.acceptingOrders = true;
        }
      }
      pushLog(`Onboarding ${o.businessName}: ${status}`);
      emit();
      return o;
    },
    listMerchantOrders(filter = {}) {
      let rows = [...state.merchantOrders];
      if (filter.tab === 'active') rows = rows.filter((o) => ['new_order', 'preparing', 'ready'].includes(o.status));
      if (filter.tab === 'scheduled') rows = rows.filter((o) => o.priority === 'scheduled');
      if (filter.tab === 'completed') rows = rows.filter((o) => ['delivered', 'rejected'].includes(o.status));
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((o) => [o.id, o.store, o.customer, o.status].join(' ').toLowerCase().includes(q));
      }
      return rows;
    },
    listMerchantPayouts(filter = {}) {
      let rows = [...state.merchantPayouts];
      if (filter.status && filter.status !== 'all') rows = rows.filter((p) => p.status === filter.status);
      return rows;
    },
    setMerchantPayoutStatus(id, status) {
      const p = state.merchantPayouts.find((x) => x.id === id);
      if (!p) return null;
      p.status = status;
      pushLog(`Merchant payout ${p.store}: ${status} ৳${p.amount}`);
      emit();
      return p;
    },

    // —— Courier ——
    listAgents(filter = {}) {
      let rows = [...state.courierAgents];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((a) => [a.id, a.name, a.phone, a.district].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') rows = rows.filter((a) => a.status === filter.status);
      return rows;
    },
    updateAgent(id, patch) {
      const a = state.courierAgents.find((x) => x.id === id);
      if (!a) return null;
      Object.assign(a, patch);
      pushLog(`Courier ${a.name} updated`);
      emit();
      return a;
    },
    listCourierKyc(filter = {}) {
      let rows = [...state.courierKyc];
      if (filter.status && filter.status !== 'all') rows = rows.filter((k) => k.status === filter.status);
      return rows;
    },
    setCourierKycStatus(id, status, bankVerified) {
      const k = state.courierKyc.find((x) => x.id === id);
      if (!k) return null;
      k.status = status;
      if (typeof bankVerified === 'boolean') k.bankVerified = bankVerified;
      if (status === 'verified') {
        const a = state.courierAgents.find((x) => x.id === k.agentId);
        if (a) a.verified = true;
      }
      pushLog(`Courier KYC ${k.agentName}: ${status}`);
      emit();
      return k;
    },
    listCourierParcels(filter = {}) {
      let rows = [...state.courierParcels];
      if (filter.q) {
        const q = filter.q.toLowerCase();
        rows = rows.filter((p) => [p.id, p.agent, p.pickup, p.drop, p.status].join(' ').toLowerCase().includes(q));
      }
      if (filter.status && filter.status !== 'all') rows = rows.filter((p) => p.status === filter.status);
      return rows;
    },
    listWithdrawals(filter = {}) {
      let rows = [...state.courierWithdrawals];
      if (filter.status && filter.status !== 'all') rows = rows.filter((w) => w.status === filter.status);
      return rows;
    },
    setWithdrawalStatus(id, status) {
      const w = state.courierWithdrawals.find((x) => x.id === id);
      if (!w) return null;
      w.status = status;
      pushLog(`Withdrawal ${w.agent}: ${status} ৳${w.amount}`);
      emit();
      return w;
    },
    listIncentives() {
      return [...state.incentives];
    },
    createIncentive(payload) {
      const row = {
        id: uid('INC'),
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
      state.incentives.unshift(row);
      pushLog(`Incentive created: ${row.title}`);
      emit();
      return row;
    },
    toggleIncentive(id, active) {
      const i = state.incentives.find((x) => x.id === id);
      if (!i) return null;
      i.active = active;
      i.status = active ? 'active' : 'scheduled';
      emit();
      return i;
    },

    // —— Pricing ——
    getPricing(panel) {
      return { ...state.pricing[panel] };
    },
    savePricing(panel, values) {
      const prev = { ...state.pricing[panel] };
      state.pricing[panel] = { ...state.pricing[panel], ...values };
      Object.keys(values).forEach((field) => {
        if (prev[field] !== values[field]) {
          state.pricingAudit.unshift({
            id: uid('AUD'),
            panel,
            field,
            oldValue: prev[field],
            newValue: values[field],
            by: 'Admin User',
            at: new Date().toISOString(),
          });
        }
      });
      pushLog(`Pricing saved: ${panel}`);
      emit();
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
      pushLog('Settings saved');
      emit();
    },

    // —— Aggregates ——
    overviewKpis() {
      const openDistricts = state.regionDistricts.filter((d) => d.status === 'open').length;
      const onlineRiders = state.riders.filter((r) => r.online && r.status === 'active').length;
      const activeCustomers = state.customers.filter((c) => c.status === 'active').length;
      const activeStores = state.merchants.filter((m) => m.status === 'active').length;
      const inTransit = state.courierParcels.filter((p) => ['in_transit', 'picked_up', 'assigned'].includes(p.status)).length;
      const pendingKyc = state.riderKyc.filter((k) => k.status !== 'verified').length
        + state.courierKyc.filter((k) => k.status !== 'verified').length;
      const revenue = state.rides.filter((r) => r.status === 'completed').reduce((s, r) => s + r.fare, 0)
        + state.foodOrders.filter((o) => o.status === 'delivered').reduce((s, o) => s + o.total, 0)
        + state.merchantOrders.filter((o) => o.status === 'delivered').reduce((s, o) => s + o.total, 0);
      return {
        revenue,
        activeTrips: state.trips.filter((t) => ['in_progress', 'accepted'].includes(t.status)).length,
        foodOrders: state.foodOrders.length,
        issues: pendingKyc + state.customers.filter((c) => c.status === 'suspended').length,
        customers: activeCustomers,
        riders: onlineRiders,
        stores: activeStores,
        parcelsInTransit: inTransit,
        openDistricts,
        totalDistricts: state.regionDistricts.length,
      };
    },
  };

  return api;
})();

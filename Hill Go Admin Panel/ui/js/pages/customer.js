window.Pages = window.Pages || {};

(function customerPages() {
  const S = () => AppStore;
  const U = () => UI;
  const esc = (s) => U().escapeHtml(s);

  function pageHeader(title, crumbs, actions = '') {
    return `<div class="mb-6 flex justify-between items-end flex-wrap gap-3">
      <div>
        <nav class="flex items-center gap-2 text-xs text-outline mb-2">${U().breadcrumb(crumbs)}</nav>
        <h2 class="text-3xl font-bold">${title}</h2>
      </div>
      <div class="flex gap-2">${actions}</div>
    </div>`;
  }

  function openCustomerDrawer(id) {
    const c = S().getCustomer(id);
    if (!c) return;
    U().openDrawer({
      title: c.name,
      width: 'max-w-md',
      bodyHtml: `
        <div class="space-y-4 text-sm">
          <div class="flex items-center gap-3">
            <div class="w-12 h-12 rounded-full bg-primary-container text-white flex items-center justify-center font-bold">${esc(c.name.split(' ').map((x) => x[0]).slice(0, 2).join(''))}</div>
            <div>
              <p class="font-semibold">${esc(c.name)}</p>
              <p class="text-xs text-outline">${esc(c.id)} · ${U().badge(c.status)}</p>
            </div>
          </div>
          <dl class="grid grid-cols-2 gap-3">
            <div><dt class="text-xs text-outline">Phone</dt><dd>${esc(c.phone)}</dd></div>
            <div><dt class="text-xs text-outline">Email</dt><dd class="truncate">${esc(c.email)}</dd></div>
            <div><dt class="text-xs text-outline">District</dt><dd>${esc(c.district)}</dd></div>
            <div><dt class="text-xs text-outline">Tier</dt><dd>${esc(c.tier)}</dd></div>
            <div><dt class="text-xs text-outline">Wallet</dt><dd class="font-semibold">${U().formatTk(c.wallet)}</dd></div>
            <div><dt class="text-xs text-outline">Loyalty</dt><dd>${c.loyaltyPoints.toLocaleString()} pts</dd></div>
            <div><dt class="text-xs text-outline">Orders</dt><dd>${c.orders}</dd></div>
            <div><dt class="text-xs text-outline">Rating</dt><dd>${c.rating}★</dd></div>
          </dl>
          <div class="border-t pt-4 space-y-2">
            <label class="block text-xs font-semibold text-outline">Adjust wallet (৳)</label>
            <div class="flex gap-2">
              <input id="cw-delta" type="number" class="flex-1 rounded-lg border-slate-200 text-sm" placeholder="e.g. 100 or -50" />
              <button type="button" id="cw-apply" class="px-3 py-2 rounded-lg bg-primary-container text-white text-xs font-semibold">Apply</button>
            </div>
            <input id="cw-note" class="w-full rounded-lg border-slate-200 text-sm" placeholder="Note (optional)" />
          </div>
          <div class="flex gap-2 pt-2">
            <button type="button" id="cw-toggle" class="flex-1 px-3 py-2 rounded-lg border text-sm font-semibold ${c.status === 'active' ? 'text-error border-red-200' : 'text-emerald-700 border-emerald-200'}">
              ${c.status === 'active' ? 'Suspend account' : 'Reactivate account'}
            </button>
          </div>
        </div>`,
    });
    document.getElementById('cw-apply')?.addEventListener('click', () => {
      const delta = Number(document.getElementById('cw-delta').value);
      if (!delta) { U().notice('Enter a non-zero amount', 'error'); return; }
      S().adjustWallet(id, delta, document.getElementById('cw-note').value);
      U().notice(`Wallet updated for ${c.name}`);
      openCustomerDrawer(id);
      if (location.hash.includes('/customer/customers')) Router.navigate();
    });
    document.getElementById('cw-toggle')?.addEventListener('click', async () => {
      const next = c.status === 'active' ? 'suspended' : 'active';
      const ok = await U().confirmDialog({
        title: next === 'suspended' ? 'Suspend customer' : 'Reactivate customer',
        message: `${c.name} will be marked ${next}.`,
        danger: next === 'suspended',
        confirmLabel: next === 'suspended' ? 'Suspend' : 'Reactivate',
      });
      if (!ok) return;
      S().updateCustomer(id, { status: next });
      U().notice(`${c.name} is now ${next}`);
      U().closeDrawer();
      Router.navigate();
    });
  }

  window.Pages.customerDashboard = async function customerDashboard(root) {
    const customers = S().listCustomers();
    const active = customers.filter((c) => c.status === 'active').length;
    const rides = S().listRides();
    const food = S().listFoodOrders();
    const parcels = S().listCustomerParcels();
    const walletSum = customers.reduce((s, c) => s + c.wallet, 0);
    root.innerHTML = `
      ${pageHeader('Customer Insights', ['Customer Panel', 'Dashboard'], '<a href="#/customer/customers" class="px-4 py-2 text-sm font-semibold rounded-lg bg-primary-container text-white">Directory</a>')}
      <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4 mb-6">
        ${U().kpiCard('Active customers', active, `${customers.length} total`)}
        ${U().kpiCard('Rides', rides.length, `${rides.filter((r) => r.status === 'completed').length} completed`)}
        ${U().kpiCard('Food orders', food.length, '')}
        ${U().kpiCard('Wallet float', U().formatTk(walletSum), 'Sum of balances')}
      </div>
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div class="bg-white rounded-xl border shadow-sm p-5">
          <h3 class="font-semibold mb-3">Service mix</h3>
          <ul class="space-y-2 text-sm">
            <li class="flex justify-between"><span>Rides</span><span class="font-semibold">${rides.length}</span></li>
            <li class="flex justify-between"><span>Food</span><span class="font-semibold">${food.length}</span></li>
            <li class="flex justify-between"><span>Parcels</span><span class="font-semibold">${parcels.length}</span></li>
          </ul>
        </div>
        <div class="bg-white rounded-xl border shadow-sm overflow-hidden">
          <div class="px-5 py-3 border-b flex justify-between"><h3 class="font-semibold">Recent customers</h3><a href="#/customer/customers" class="text-xs text-primary-container font-semibold">View all</a></div>
          <ul class="divide-y">
            ${customers.slice(0, 5).map((c) => `
              <li class="px-5 py-3 flex justify-between text-sm cursor-pointer hover:bg-slate-50" data-cid="${esc(c.id)}">
                <div><p class="font-medium">${esc(c.name)}</p><p class="text-xs text-outline">${esc(c.district)} · ${esc(c.tier)}</p></div>
                ${U().badge(c.status)}
              </li>`).join('')}
          </ul>
        </div>
      </div>`;
    root.querySelectorAll('[data-cid]').forEach((el) => el.addEventListener('click', () => openCustomerDrawer(el.getAttribute('data-cid'))));
  };

  window.Pages.customerList = async function customerList(root) {
    const pendingQ = sessionStorage.getItem('hillgo-search') || '';
    if (pendingQ) sessionStorage.removeItem('hillgo-search');
    let filter = { q: pendingQ, status: 'all' };
    let page = 1;
    const render = () => {
      const all = S().listCustomers(filter);
      const pg = U().paginate(all, page, 8);
      page = pg.page;
      root.innerHTML = `
        ${pageHeader('Customer Directory', ['Customer Panel', 'Customers'], `<button type="button" id="cu-export" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Export CSV</button>`)}
        <div class="bg-white rounded-xl border shadow-sm mb-4 p-4 flex flex-wrap gap-3 items-end">
          <label class="flex-1 min-w-[180px] text-xs font-semibold text-outline">Search
            <input id="cu-q" value="${esc(filter.q)}" class="mt-1 w-full rounded-lg border-slate-200 text-sm" placeholder="Name, phone, ID…" />
          </label>
          <label class="text-xs font-semibold text-outline">Status
            <select id="cu-status" class="mt-1 block rounded-lg border-slate-200 text-sm">
              <option value="all">All</option>
              <option value="active" ${filter.status === 'active' ? 'selected' : ''}>Active</option>
              <option value="suspended" ${filter.status === 'suspended' ? 'selected' : ''}>Suspended</option>
            </select>
          </label>
          <button type="button" id="cu-apply" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Apply</button>
          <button type="button" id="cu-reset" class="px-4 py-2 rounded-lg border text-sm font-semibold">Reset</button>
        </div>
        <div class="flex gap-2 mb-3">
          ${['all', 'active', 'suspended'].map((s) => `
            <button type="button" data-chip="${s}" class="px-3 py-1.5 rounded-full text-xs font-semibold border ${filter.status === s ? 'bg-primary-container text-white border-primary-container' : 'bg-white'}">${s}</button>`).join('')}
        </div>
        <div class="bg-white rounded-xl border shadow-sm overflow-hidden">
          <table class="w-full text-sm">
            <thead class="bg-slate-50 text-xs uppercase text-outline text-left">
              <tr><th class="px-4 py-3">Customer</th><th class="px-4 py-3">District</th><th class="px-4 py-3">Wallet</th><th class="px-4 py-3">Tier</th><th class="px-4 py-3">Status</th><th class="px-4 py-3"></th></tr>
            </thead>
            <tbody class="divide-y">
              ${pg.rows.map((c) => `
                <tr class="hover:bg-slate-50">
                  <td class="px-4 py-3"><p class="font-medium">${esc(c.name)}</p><p class="text-xs text-outline">${esc(c.id)} · ${esc(c.phone)}</p></td>
                  <td class="px-4 py-3">${esc(c.district)}</td>
                  <td class="px-4 py-3 font-medium">${U().formatTk(c.wallet)}</td>
                  <td class="px-4 py-3">${esc(c.tier)}</td>
                  <td class="px-4 py-3">${U().badge(c.status)}</td>
                  <td class="px-4 py-3 text-right"><button type="button" data-view="${esc(c.id)}" class="text-xs font-semibold text-primary-container">View</button></td>
                </tr>`).join('') || '<tr><td colspan="6" class="px-4 py-8 text-center text-outline">No customers match</td></tr>'}
            </tbody>
          </table>
          ${U().pagerHtml(pg.page, pg.pages, pg.total, { collection: 'customers', hasMore: S().getPageMeta('customers').hasMore })}
        </div>`;
      root.querySelector('#cu-apply')?.addEventListener('click', () => {
        filter.q = root.querySelector('#cu-q').value.trim();
        filter.status = root.querySelector('#cu-status').value;
        page = 1; render();
      });
      root.querySelector('#cu-reset')?.addEventListener('click', () => { filter = { q: '', status: 'all' }; page = 1; render(); });
      root.querySelectorAll('[data-chip]').forEach((b) => b.addEventListener('click', () => { filter.status = b.getAttribute('data-chip'); page = 1; render(); }));
      root.querySelectorAll('[data-view]').forEach((b) => b.addEventListener('click', () => openCustomerDrawer(b.getAttribute('data-view'))));
      root.querySelector('#cu-export')?.addEventListener('click', () => U().downloadCsv('customers.csv', all));
      root.querySelector('[data-page-btn="prev"]')?.addEventListener('click', () => { page -= 1; render(); });
      root.querySelector('[data-page-btn="next"]')?.addEventListener('click', () => { page += 1; render(); });
      U().bindServerMore(root, () => { page += 1; render(); });
    };
    render();
    Router.onStore(() => { if (location.hash.includes('/customer/customers')) render(); });
  };

  function simpleTablePage(root, opts) {
    let filter = { q: '', status: 'all' };
    let page = 1;
    const render = () => {
      const all = opts.list(filter);
      const pg = U().paginate(all, page, 8);
      page = pg.page;
      root.innerHTML = `
        ${pageHeader(opts.title, opts.crumbs, `<button type="button" id="ex" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Export CSV</button>`)}
        <div class="bg-white rounded-xl border shadow-sm mb-4 p-4 flex flex-wrap gap-3">
          <input id="q" value="${esc(filter.q)}" class="flex-1 min-w-[200px] rounded-lg border-slate-200 text-sm" placeholder="Search…" />
          <select id="st" class="rounded-lg border-slate-200 text-sm">
            <option value="all">All statuses</option>
            ${opts.statuses.map((s) => `<option value="${s}" ${filter.status === s ? 'selected' : ''}>${s.replace(/_/g, ' ')}</option>`).join('')}
          </select>
          <button type="button" id="apply" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Apply</button>
        </div>
        <div class="bg-white rounded-xl border shadow-sm overflow-hidden">
          <table class="w-full text-sm"><thead class="bg-slate-50 text-xs uppercase text-outline text-left"><tr>${opts.headers.map((h) => `<th class="px-4 py-3">${h}</th>`).join('')}</tr></thead>
          <tbody class="divide-y">${pg.rows.map(opts.row).join('') || `<tr><td colspan="${opts.headers.length}" class="px-4 py-8 text-center text-outline">No rows</td></tr>`}</tbody></table>
          ${U().pagerHtml(pg.page, pg.pages, pg.total, opts.collection ? { collection: opts.collection, hasMore: S().getPageMeta(opts.collection).hasMore } : null)}
        </div>`;
      root.querySelector('#apply')?.addEventListener('click', () => {
        filter.q = root.querySelector('#q').value.trim();
        filter.status = root.querySelector('#st').value;
        page = 1; render();
      });
      root.querySelector('#ex')?.addEventListener('click', () => U().downloadCsv(opts.file, all));
      root.querySelector('[data-page-btn="prev"]')?.addEventListener('click', () => { page -= 1; render(); });
      root.querySelector('[data-page-btn="next"]')?.addEventListener('click', () => { page += 1; render(); });
      U().bindServerMore(root, () => { page += 1; render(); });
    };
    render();
  }

  window.Pages.customerFood = async function customerFood(root) {
    let filter = { q: '', status: 'all' };
    let page = 1;
    const render = () => {
      const all = S().listFoodOrders(filter);
      const pg = U().paginate(all, page, 8);
      page = pg.page;
      root.innerHTML = `
        <div class="mb-6 flex justify-between items-end flex-wrap gap-3">
          <div>
            <nav class="flex items-center gap-2 text-xs text-outline mb-2">${U().breadcrumb(['Customer Panel', 'Food Orders'])}</nav>
            <h2 class="text-3xl font-bold">Food Orders</h2>
          </div>
          <button type="button" id="ex" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Export CSV</button>
        </div>
        <div class="bg-white rounded-xl border shadow-sm mb-4 p-4 flex flex-wrap gap-3">
          <input id="q" value="${esc(filter.q)}" class="flex-1 min-w-[200px] rounded-lg border-slate-200 text-sm" placeholder="Search…" />
          <select id="st" class="rounded-lg border-slate-200 text-sm">
            <option value="all">All statuses</option>
            ${['placed', 'preparing', 'on_the_way', 'delivered'].map((s) => `<option value="${s}" ${filter.status === s ? 'selected' : ''}>${s.replace(/_/g, ' ')}</option>`).join('')}
          </select>
          <button type="button" id="apply" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Apply</button>
        </div>
        <div class="bg-white rounded-xl border shadow-sm overflow-hidden">
          <table class="w-full text-sm"><thead class="bg-slate-50 text-xs uppercase text-outline text-left"><tr>
            <th class="px-4 py-3">Order</th><th class="px-4 py-3">Restaurant</th><th class="px-4 py-3">Customer</th><th class="px-4 py-3">Total</th><th class="px-4 py-3">Fee</th><th class="px-4 py-3">Status</th>
          </tr></thead>
          <tbody class="divide-y">${pg.rows.map((r) => `<tr><td class="px-4 py-3 font-medium">${esc(r.id)}</td><td class="px-4 py-3">${esc(r.restaurant)}</td><td class="px-4 py-3">${esc(r.customer)}</td><td class="px-4 py-3">${U().formatTk(r.total)}</td><td class="px-4 py-3">${U().formatTk(r.deliveryFee)}</td><td class="px-4 py-3">${U().badge(r.status)}</td></tr>`).join('') || '<tr><td colspan="6" class="px-4 py-8 text-center text-outline">No rows</td></tr>'}</tbody></table>
          ${U().pagerHtml(pg.page, pg.pages, pg.total, { collection: 'foodOrders', hasMore: S().getPageMeta('foodOrders').hasMore })}
        </div>
        ${HillGoMaps.mapShell({
          id: 'map-food',
          title: 'Live Delivery Map (Dhaka)',
          liveLabel: 'Live updates',
          height: '300px',
          sideHtml: `
            <div class="bg-primary-container text-white rounded-xl p-6 h-full flex flex-col justify-between min-h-[300px]">
              <div>
                <span class="material-symbols-outlined text-[40px] mb-3">analytics</span>
                <h4 class="text-xl font-semibold mb-2">Operations efficiency</h4>
                <p class="text-sm text-blue-100 leading-relaxed">Active food orders plotted from store districts. Filter the table to focus the map on matching rows.</p>
              </div>
              <div class="mt-6">
                <div class="flex justify-between text-xs mb-1"><span>On the way</span><span>${all.filter((o) => o.status === 'on_the_way').length}</span></div>
                <div class="w-full bg-white/20 h-2 rounded-full overflow-hidden"><div class="bg-white h-full" style="width:${Math.min(100, all.filter((o) => o.status === 'on_the_way').length * 25)}%"></div></div>
              </div>
            </div>`,
        })}`;
      root.querySelector('#apply')?.addEventListener('click', () => {
        filter.q = root.querySelector('#q').value.trim();
        filter.status = root.querySelector('#st').value;
        page = 1; render();
      });
      root.querySelector('#ex')?.addEventListener('click', () => U().downloadCsv('food-orders.csv', all));
      root.querySelector('[data-page-btn="prev"]')?.addEventListener('click', () => { page -= 1; render(); });
      root.querySelector('[data-page-btn="next"]')?.addEventListener('click', () => { page += 1; render(); });
      U().bindServerMore(root, () => { page += 1; render(); });
      HillGoMaps.mount('map-food', {
        height: '300px',
        markers: HillGoMaps.markersFromOrders(all, 'restaurant'),
        circles: [
          { ...HillGoMaps.HUBS.dhanmondi, radius: 1600, color: '#0047ab' },
          { ...HillGoMaps.HUBS.gulshan, radius: 1600, color: '#505f76' },
        ],
      });
    };
    render();
  };

  window.Pages.customerParcels = async function customerParcels(root) {
    let filter = { q: '', status: 'all' };
    let page = 1;
    const render = () => {
      const all = S().listCustomerParcels(filter);
      const pg = U().paginate(all, page, 8);
      page = pg.page;
      root.innerHTML = `
        <div class="mb-6 flex justify-between items-end flex-wrap gap-3">
          <div>
            <nav class="flex items-center gap-2 text-xs text-outline mb-2">${U().breadcrumb(['Customer Panel', 'Parcels'])}</nav>
            <h2 class="text-3xl font-bold">Customer Parcels</h2>
          </div>
          <button type="button" id="ex" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Export CSV</button>
        </div>
        <div class="bg-white rounded-xl border shadow-sm mb-4 p-4 flex flex-wrap gap-3">
          <input id="q" value="${esc(filter.q)}" class="flex-1 min-w-[200px] rounded-lg border-slate-200 text-sm" placeholder="Search…" />
          <select id="st" class="rounded-lg border-slate-200 text-sm">
            <option value="all">All statuses</option>
            ${['booked', 'picked_up', 'in_transit', 'delivered', 'cancelled'].map((s) => `<option value="${s}" ${filter.status === s ? 'selected' : ''}>${s.replace(/_/g, ' ')}</option>`).join('')}
          </select>
          <button type="button" id="apply" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Apply</button>
        </div>
        <div class="bg-white rounded-xl border shadow-sm overflow-hidden">
          <table class="w-full text-sm"><thead class="bg-slate-50 text-xs uppercase text-outline text-left"><tr>
            <th class="px-4 py-3">Tracking</th><th class="px-4 py-3">Type</th><th class="px-4 py-3">Route</th><th class="px-4 py-3">Fare</th><th class="px-4 py-3">Status</th><th class="px-4 py-3">Customer</th>
          </tr></thead>
          <tbody class="divide-y">${pg.rows.map((r) => `<tr><td class="px-4 py-3 font-medium">${esc(r.id)}</td><td class="px-4 py-3">${esc(r.type)}</td><td class="px-4 py-3">${esc(r.pickup)} → ${esc(r.destination)}</td><td class="px-4 py-3">${U().formatTk(r.fare)}</td><td class="px-4 py-3">${U().badge(r.status)}</td><td class="px-4 py-3">${esc(r.customer)}</td></tr>`).join('') || '<tr><td colspan="6" class="px-4 py-8 text-center text-outline">No rows</td></tr>'}</tbody></table>
          ${U().pagerHtml(pg.page, pg.pages, pg.total, { collection: 'customerParcels', hasMore: S().getPageMeta('customerParcels').hasMore })}
        </div>
        ${HillGoMaps.mapShell({
          id: 'map-cparcels',
          title: 'Real-time Density Map',
          liveLabel: `${all.filter((p) => ['in_transit', 'picked_up'].includes(p.status)).length} active`,
          height: '320px',
          sideHtml: `
            <div class="bg-white rounded-xl border p-5 h-full">
              <h4 class="font-semibold mb-2">Active hubs</h4>
              <ul class="text-sm space-y-2 mb-4">
                <li class="flex items-center gap-2"><span class="w-2 h-2 rounded-full bg-primary-container"></span> Gulshan Peak</li>
                <li class="flex items-center gap-2"><span class="w-2 h-2 rounded-full bg-amber-500"></span> Dhanmondi Hub</li>
                <li class="flex items-center gap-2"><span class="w-2 h-2 rounded-full bg-emerald-500"></span> Uttara Node</li>
              </ul>
              <button type="button" id="expand-map" class="text-sm font-bold text-primary-container hover:underline">Expand map view</button>
            </div>`,
        })}`;
      root.querySelector('#apply')?.addEventListener('click', () => {
        filter.q = root.querySelector('#q').value.trim();
        filter.status = root.querySelector('#st').value;
        page = 1; render();
      });
      root.querySelector('#ex')?.addEventListener('click', () => U().downloadCsv('customer-parcels.csv', all));
      root.querySelector('[data-page-btn="prev"]')?.addEventListener('click', () => { page -= 1; render(); });
      root.querySelector('[data-page-btn="next"]')?.addEventListener('click', () => { page += 1; render(); });
      U().bindServerMore(root, () => { page += 1; render(); });
      root.querySelector('#expand-map')?.addEventListener('click', () => {
        const map = document.getElementById('map-cparcels');
        if (!map) return;
        map.style.height = map.style.height === '520px' ? '320px' : '520px';
        HillGoMaps.destroy('map-cparcels');
        HillGoMaps.mount('map-cparcels', {
          height: map.style.height,
          markers: HillGoMaps.markersFromParcels(all),
          circles: Object.values(HillGoMaps.HUBS).slice(0, 5).map((h) => ({ ...h, radius: 900, color: '#0047ab' })),
        });
        U().notice(map.style.height === '520px' ? 'Map expanded' : 'Map collapsed', 'info');
      });
      HillGoMaps.mount('map-cparcels', {
        height: '320px',
        markers: HillGoMaps.markersFromParcels(all),
        circles: [
          { ...HillGoMaps.HUBS.gulshan, radius: 1200, color: '#0047ab' },
          { ...HillGoMaps.HUBS.dhanmondi, radius: 1200, color: '#F59E0B' },
        ],
      });
    };
    render();
  };

  // keep simple rides table helper
  window.Pages.customerRides = async (root) => simpleTablePage(root, {
    title: 'Rides', crumbs: ['Customer Panel', 'Rides'], file: 'rides.csv', collection: 'rides',
    statuses: ['completed', 'in_progress', 'cancelled'],
    list: (f) => S().listRides(f),
    headers: ['Ride', 'Customer', 'Route', 'Fare', 'Status', 'Date'],
    row: (r) => `<tr><td class="px-4 py-3 font-medium">${esc(r.id)}<p class="text-xs text-outline">${esc(r.rider)}</p></td><td class="px-4 py-3">${esc(r.customer)}</td><td class="px-4 py-3">${esc(r.pickup)} → ${esc(r.drop)}</td><td class="px-4 py-3">${U().formatTk(r.fare)}</td><td class="px-4 py-3">${U().badge(r.status)}</td><td class="px-4 py-3 text-xs">${esc(r.date)}</td></tr>`,
  });

  window.Pages.customerPricing = async function customerPricing(root) {
    const render = () => {
      const p = S().getPricing('customer');
      const audit = S().listPricingAudit('customer').slice(0, 6);
      root.innerHTML = `
        ${pageHeader('Customer Pricing', ['Customer Panel', 'Pricing'])}
        <form id="cp-form" class="bg-white rounded-xl border shadow-sm p-6 grid grid-cols-1 md:grid-cols-2 gap-4 max-w-4xl">
          ${[
            ['rideBase', 'Ride base fare'], ['ridePerKm', 'Ride per km'], ['ridePerMin', 'Ride per minute'], ['rideMinimum', 'Ride minimum'],
            ['foodDeliveryFee', 'Food delivery fee'], ['freeDeliveryThreshold', 'Free delivery threshold'],
            ['parcelBase', 'Parcel base'], ['parcelPerKm', 'Parcel per km'], ['parcelPerKg', 'Parcel per kg'], ['parcelMinimum', 'Parcel minimum'],
            ['marketplaceDelivery', 'Marketplace delivery'], ['hotelServiceFeePct', 'Hotel service fee %'],
            ['rentalDriverPerDay', 'Rental driver / day'], ['rentalInsurancePerDay', 'Rental insurance / day'],
          ].map(([k, label]) => `
            <label class="text-xs font-semibold text-outline">${label}
              <div class="mt-1 relative"><span class="absolute left-3 top-2 text-outline">৳</span>
                <input name="${k}" type="number" step="any" value="${p[k]}" class="w-full rounded-lg border-slate-200 text-sm pl-8" />
              </div>
            </label>`).join('')}
          <div class="md:col-span-2 flex gap-2 justify-end pt-2">
            <button type="button" id="cp-discard" class="px-4 py-2 rounded-lg border text-sm font-semibold">Discard</button>
            <button type="submit" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Save changes</button>
          </div>
        </form>
        <div class="mt-6 bg-white rounded-xl border shadow-sm p-5 max-w-4xl">
          <h3 class="font-semibold mb-3">Audit</h3>
          <ul class="text-sm divide-y">${audit.map((a) => `<li class="py-2 flex justify-between"><span>${esc(a.field)}: ${esc(a.oldValue)} → ${esc(a.newValue)}</span><span class="text-xs text-outline">${U().formatDate(a.at)}</span></li>`).join('') || '<li class="text-outline">No changes yet</li>'}</ul>
        </div>`;
      root.querySelector('#cp-form')?.addEventListener('submit', (e) => {
        e.preventDefault();
        const fd = new FormData(e.target);
        const values = {};
        fd.forEach((v, k) => { values[k] = Number(v); });
        S().savePricing('customer', values);
        U().notice('Customer pricing saved');
        render();
      });
      root.querySelector('#cp-discard')?.addEventListener('click', () => { U().notice('Reverted to last saved values', 'info'); render(); });
    };
    render();
  };
})();

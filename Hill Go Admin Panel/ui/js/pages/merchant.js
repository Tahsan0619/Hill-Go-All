window.Pages = window.Pages || {};

(function merchantPages() {
  const S = () => AppStore;
  const U = () => UI;
  const esc = (s) => U().escapeHtml(s);
  const hdr = (title, crumbs, actions = '') => `
    <div class="mb-6 flex justify-between items-end flex-wrap gap-3">
      <div><nav class="flex items-center gap-2 text-xs text-outline mb-2">${U().breadcrumb(crumbs)}</nav><h2 class="text-3xl font-bold">${title}</h2></div>
      <div class="flex gap-2">${actions}</div>
    </div>`;

  function openOnboardingReview(id) {
    const o = S().listOnboarding().find((x) => x.id === id);
    if (!o) return;
    U().openDrawer({
      title: 'Review onboarding',
      width: 'max-w-md',
      bodyHtml: `
        <div class="space-y-3 text-sm">
          <p class="text-xl font-semibold">${esc(o.businessName)}</p>
          <p class="text-outline">${esc(o.id)} · ${U().badge(o.status)}</p>
          <dl class="grid grid-cols-2 gap-3">
            <div><dt class="text-xs text-outline">Owner</dt><dd>${esc(o.owner)}</dd></div>
            <div><dt class="text-xs text-outline">Category</dt><dd>${esc(o.category)}</dd></div>
            <div><dt class="text-xs text-outline">Phone</dt><dd>${esc(o.phone)}</dd></div>
            <div><dt class="text-xs text-outline">Email</dt><dd class="truncate">${esc(o.email)}</dd></div>
            <div class="col-span-2"><dt class="text-xs text-outline">Address</dt><dd>${esc(o.address)}, ${esc(o.city)} ${esc(o.zip)}</dd></div>
            <div><dt class="text-xs text-outline">District</dt><dd>${esc(o.district)}</dd></div>
            <div><dt class="text-xs text-outline">Submitted</dt><dd>${esc(o.submitted)}</dd></div>
          </dl>
          <div><p class="text-xs text-outline mb-1">Documents</p>
            <ul class="space-y-2">${(o.docFiles || []).map((d, i) => `
              <li class="flex items-center justify-between gap-2 rounded-lg border px-3 py-2">
                <span>${esc(d.name || (o.docs && o.docs[i]) || 'Document')}</span>
                ${d.fileUrl ? `<button type="button" data-doc-url="${esc(d.fileUrl)}" data-doc-name="${esc(d.name || 'document')}" class="text-xs font-semibold text-primary-container">Open</button>` : '<span class="text-xs text-outline">No file</span>'}
              </li>`).join('') || (o.docs || []).map((d) => `<li class="text-sm">${esc(d)}</li>`).join('') || '<li class="text-outline text-sm">None</li>'}
            </ul>
          </div>
          <div class="flex flex-col gap-2 pt-4">
            <button type="button" data-onb="approved" class="px-4 py-2 rounded-lg bg-emerald-600 text-white font-semibold">Approve</button>
            <button type="button" data-onb="changes_requested" class="px-4 py-2 rounded-lg border font-semibold">Request changes</button>
            <button type="button" data-onb="rejected" class="px-4 py-2 rounded-lg bg-error text-white font-semibold">Reject</button>
          </div>
        </div>`,
    });
    document.querySelectorAll('[data-doc-url]').forEach((b) => b.addEventListener('click', async () => {
      try {
        await S().openAuthenticatedFile(b.getAttribute('data-doc-url'), b.getAttribute('data-doc-name') || 'document');
      } catch (e) {
        U().notice(e.message || 'Could not open document', 'error');
      }
    }));
    document.querySelectorAll('[data-onb]').forEach((b) => b.addEventListener('click', async () => {
      const status = b.getAttribute('data-onb');
      const ok = await U().confirmDialog({ title: status.replace(/_/g, ' '), message: `Set ${o.businessName} to ${status}?`, danger: status === 'rejected' });
      if (!ok) return;
      S().setOnboardingStatus(id, status);
      U().closeDrawer();
      U().notice(`${o.businessName}: ${status}`);
      Router.navigate();
    }));
  }

  window.Pages.merchantDashboard = async function merchantDashboard(root) {
    const stores = S().listMerchants();
    const active = stores.filter((m) => m.status === 'active').length;
    const orders = S().listMerchantOrders();
    const pendingPay = S().listMerchantPayouts({ status: 'pending' });
    const onb = S().listOnboarding({ status: 'pending' }).length;
    const closedDistricts = new Set(S().getState().regionDistricts.filter((d) => d.status === 'closed').map((d) => d.name));
    const blocked = stores.filter((m) => closedDistricts.has(m.district));
    root.innerHTML = `
      ${hdr('Merchant Panel', ['Merchant Panel', 'Dashboard'], '<a href="#/merchant/onboarding" class="px-4 py-2 text-sm font-semibold rounded-lg bg-primary-container text-white">Onboarding queue</a>')}
      <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4 mb-6">
        ${U().kpiCard('Active stores', active, `${stores.length} total`)}
        ${U().kpiCard('Orders', orders.length, '')}
        ${U().kpiCard('Pending payouts', pendingPay.length, U().formatTk(pendingPay.reduce((s, p) => s + p.amount, 0)))}
        ${U().kpiCard('Onboarding', onb, `${blocked.length} in closed districts`)}
      </div>
      <div class="bg-white rounded-xl border overflow-hidden">
        <div class="px-5 py-3 border-b flex justify-between"><h3 class="font-semibold">Stores in closed districts</h3><a href="#/region" class="text-xs font-semibold text-primary-container">Region Lock</a></div>
        <ul class="divide-y">${blocked.map((m) => `<li class="px-5 py-3 text-sm flex justify-between"><span>${esc(m.name)} · ${esc(m.district)}</span>${U().badge('closed')}</li>`).join('') || '<li class="px-5 py-6 text-sm text-outline">None</li>'}</ul>
      </div>`;
  };

  window.Pages.merchantStores = async function merchantStores(root) {
    let filter = { q: '', status: 'all' };
    let page = 1;
    const render = () => {
      const all = S().listMerchants(filter);
      const pg = U().paginate(all, page, 8);
      page = pg.page;
      root.innerHTML = `
        ${hdr('Merchants / Stores', ['Merchant Panel', 'Stores'], '<button type="button" id="ex" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Export</button>')}
        <div class="bg-white rounded-xl border p-4 mb-4 flex flex-wrap gap-3">
          <input id="q" value="${esc(filter.q)}" class="flex-1 rounded-lg border-slate-200 text-sm" placeholder="Search…" />
          <select id="st" class="rounded-lg border-slate-200 text-sm">
            <option value="all">All</option>
            ${['active', 'pending', 'onboarding', 'suspended'].map((s) => `<option value="${s}" ${filter.status === s ? 'selected' : ''}>${s}</option>`).join('')}
          </select>
          <button type="button" id="apply" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Apply</button>
        </div>
        <div class="bg-white rounded-xl border overflow-hidden">
          <table class="w-full text-sm">
            <thead class="bg-slate-50 text-xs uppercase text-outline text-left"><tr>
              <th class="px-4 py-3">Store</th><th class="px-4 py-3">Category</th><th class="px-4 py-3">Open</th><th class="px-4 py-3">Accepting</th><th class="px-4 py-3">Status</th><th class="px-4 py-3"></th>
            </tr></thead>
            <tbody class="divide-y">${pg.rows.map((m) => `
              <tr>
                <td class="px-4 py-3"><p class="font-medium">${esc(m.name)}</p><p class="text-xs text-outline">${esc(m.id)} · ${esc(m.owner)} · ${esc(m.district)}</p></td>
                <td class="px-4 py-3">${esc(m.category)}</td>
                <td class="px-4 py-3"><button type="button" data-open="${esc(m.id)}" class="text-xs font-semibold">${m.isOpen ? U().badge('open') : U().badge('closed')}</button></td>
                <td class="px-4 py-3"><button type="button" data-acc="${esc(m.id)}" class="text-xs font-semibold text-primary-container">${m.acceptingOrders ? 'Yes' : 'No'}</button></td>
                <td class="px-4 py-3">${U().badge(m.status)}</td>
                <td class="px-4 py-3 text-right"><button type="button" data-sus="${esc(m.id)}" class="text-xs font-semibold text-error">${m.status === 'suspended' ? 'Activate' : 'Suspend'}</button></td>
              </tr>`).join('')}</tbody>
          </table>
          ${U().pagerHtml(pg.page, pg.pages, pg.total, { collection: 'merchants', hasMore: S().getPageMeta('merchants').hasMore })}
        </div>`;
      root.querySelector('#apply')?.addEventListener('click', () => {
        filter = { q: root.querySelector('#q').value.trim(), status: root.querySelector('#st').value };
        page = 1; render();
      });
      root.querySelector('#ex')?.addEventListener('click', () => U().downloadCsv('merchants.csv', all));
      root.querySelectorAll('[data-open]').forEach((b) => b.addEventListener('click', () => {
        const m = S().listMerchants().find((x) => x.id === b.getAttribute('data-open'));
        S().updateMerchant(m.id, { isOpen: !m.isOpen });
        U().notice(`${m.name} ${!m.isOpen ? 'opened' : 'closed'}`);
      }));
      root.querySelectorAll('[data-acc]').forEach((b) => b.addEventListener('click', () => {
        const m = S().listMerchants().find((x) => x.id === b.getAttribute('data-acc'));
        S().updateMerchant(m.id, { acceptingOrders: !m.acceptingOrders });
        U().notice(`${m.name} accepting orders: ${!m.acceptingOrders}`);
      }));
      root.querySelectorAll('[data-sus]').forEach((b) => b.addEventListener('click', async () => {
        const m = S().listMerchants().find((x) => x.id === b.getAttribute('data-sus'));
        const next = m.status === 'suspended' ? 'active' : 'suspended';
        const ok = await U().confirmDialog({ title: `${next} store`, message: `${m.name} → ${next}`, danger: next === 'suspended' });
        if (!ok) return;
        S().updateMerchant(m.id, { status: next, isOpen: next === 'active' ? m.isOpen : false, acceptingOrders: next === 'active' ? m.acceptingOrders : false });
        U().notice(`${m.name} ${next}`);
      }));
      root.querySelector('[data-page-btn="prev"]')?.addEventListener('click', () => { page -= 1; render(); });
      root.querySelector('[data-page-btn="next"]')?.addEventListener('click', () => { page += 1; render(); });
      U().bindServerMore(root, () => { page += 1; render(); });
    };
    render();
    Router.onStore(() => { if (location.hash.includes('/merchant/stores')) render(); });
  };

  window.Pages.merchantOnboarding = async function merchantOnboarding(root) {
    const render = () => {
      const rows = S().listOnboarding();
      root.innerHTML = `
        ${hdr('Onboarding Queue', ['Merchant Panel', 'Onboarding'])}
        <div class="bg-white rounded-xl border overflow-hidden">
          <table class="w-full text-sm">
            <thead class="bg-slate-50 text-xs uppercase text-outline text-left"><tr>
              <th class="px-4 py-3">Business</th><th class="px-4 py-3">Category</th><th class="px-4 py-3">District</th><th class="px-4 py-3">Status</th><th class="px-4 py-3"></th>
            </tr></thead>
            <tbody class="divide-y">${rows.map((o) => `
              <tr>
                <td class="px-4 py-3"><p class="font-medium">${esc(o.businessName)}</p><p class="text-xs text-outline">${esc(o.owner)} · ${esc(o.submitted)}</p></td>
                <td class="px-4 py-3">${esc(o.category)}</td>
                <td class="px-4 py-3">${esc(o.district)}</td>
                <td class="px-4 py-3">${U().badge(o.status)}</td>
                <td class="px-4 py-3 text-right"><button type="button" data-rev="${esc(o.id)}" class="text-xs font-semibold text-primary-container">Review</button></td>
              </tr>`).join('')}</tbody>
          </table>
        </div>`;
      root.querySelectorAll('[data-rev]').forEach((b) => b.addEventListener('click', () => openOnboardingReview(b.getAttribute('data-rev'))));
    };
    render();
    Router.onStore(() => { if (location.hash.includes('/merchant/onboarding')) render(); });
  };

  window.Pages.merchantOrders = async function merchantOrders(root) {
    let tab = 'active';
    let q = '';
    let page = 1;
    const render = () => {
      const all = S().listMerchantOrders({ tab, q });
      const pg = U().paginate(all, page, 8);
      page = pg.page;
      root.innerHTML = `
        ${hdr('Orders', ['Merchant Panel', 'Orders'], '<button type="button" id="ex" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Export</button>')}
        <div class="flex flex-wrap gap-2 mb-4">
          ${['active', 'scheduled', 'completed'].map((t) => `
            <button type="button" data-tab="${t}" class="px-3 py-1.5 rounded-full text-xs font-semibold border capitalize ${tab === t ? 'bg-primary-container text-white border-primary-container' : 'bg-white'}">${t}</button>`).join('')}
          <input id="q" value="${esc(q)}" class="ml-auto rounded-lg border-slate-200 text-sm" placeholder="Search…" />
          <button type="button" id="apply" class="px-3 py-1.5 rounded-lg bg-slate-900 text-white text-xs font-semibold">Search</button>
        </div>
        <div class="bg-white rounded-xl border overflow-hidden">
          <table class="w-full text-sm">
            <thead class="bg-slate-50 text-xs uppercase text-outline text-left"><tr>
              <th class="px-4 py-3">Order</th><th class="px-4 py-3">Store</th><th class="px-4 py-3">Customer</th><th class="px-4 py-3">Priority</th><th class="px-4 py-3">Total</th><th class="px-4 py-3">Status</th>
            </tr></thead>
            <tbody class="divide-y">${pg.rows.map((o) => `
              <tr>
                <td class="px-4 py-3 font-medium">${esc(o.id)}<p class="text-xs text-outline">${esc(o.date)}</p></td>
                <td class="px-4 py-3">${esc(o.store)}</td>
                <td class="px-4 py-3">${esc(o.customer)}</td>
                <td class="px-4 py-3 capitalize">${esc(o.priority)}</td>
                <td class="px-4 py-3">${U().formatTk(o.total)}</td>
                <td class="px-4 py-3">${U().badge(o.status)}</td>
              </tr>`).join('')}</tbody>
          </table>
          ${U().pagerHtml(pg.page, pg.pages, pg.total, { collection: 'merchantOrders', hasMore: S().getPageMeta('merchantOrders').hasMore })}
        </div>
        ${HillGoMaps.mapShell({
          id: 'map-merchant-orders',
          title: 'Live Order Heatmap',
          liveLabel: `${all.length} orders in view`,
          height: '300px',
          sideHtml: `
            <div class="bg-white rounded-xl border p-5 h-full relative overflow-hidden min-h-[300px]">
              <h4 class="text-sm font-bold text-primary mb-1">Density insight</h4>
              <p class="text-sm text-outline mb-4">Markers reflect filtered merchant orders across Dhaka hubs (Gulshan, Banani, Dhanmondi).</p>
              <ul class="text-sm space-y-2">
                <li>Active tab: <strong class="capitalize">${tab}</strong></li>
                <li>New / preparing / ready: <strong>${all.filter((o) => ['new_order', 'preparing', 'ready'].includes(o.status)).length}</strong></li>
              </ul>
            </div>`,
        })}`;
      root.querySelectorAll('[data-tab]').forEach((b) => b.addEventListener('click', () => { tab = b.getAttribute('data-tab'); page = 1; render(); }));
      root.querySelector('#apply')?.addEventListener('click', () => { q = root.querySelector('#q').value.trim(); page = 1; render(); });
      root.querySelector('#ex')?.addEventListener('click', () => U().downloadCsv('merchant-orders.csv', all));
      root.querySelector('[data-page-btn="prev"]')?.addEventListener('click', () => { page -= 1; render(); });
      root.querySelector('[data-page-btn="next"]')?.addEventListener('click', () => { page += 1; render(); });
      U().bindServerMore(root, () => { page += 1; render(); });
      HillGoMaps.mount('map-merchant-orders', {
        height: '300px',
        markers: HillGoMaps.markersFromOrders(all, 'store'),
        circles: [
          { ...HillGoMaps.HUBS.gulshan, radius: 1500, color: '#0047ab' },
          { ...HillGoMaps.HUBS.banani, radius: 1200, color: '#F59E0B' },
        ],
      });
    };
    render();
  };

  window.Pages.merchantPayouts = async function merchantPayouts(root) {
    let status = 'all';
    const render = () => {
      const rows = S().listMerchantPayouts({ status });
      root.innerHTML = `
        ${hdr('Merchant Payouts', ['Merchant Panel', 'Payouts'], '<button type="button" id="ex" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Export</button>')}
        <div class="flex gap-2 mb-4">
          ${['all', 'pending', 'processing', 'completed'].map((s) => `
            <button type="button" data-st="${s}" class="px-3 py-1.5 rounded-full text-xs font-semibold border ${status === s ? 'bg-primary-container text-white border-primary-container' : 'bg-white'}">${s}</button>`).join('')}
        </div>
        <div class="bg-white rounded-xl border overflow-hidden">
          <table class="w-full text-sm">
            <thead class="bg-slate-50 text-xs uppercase text-outline text-left"><tr>
              <th class="px-4 py-3">Payout</th><th class="px-4 py-3">Store</th><th class="px-4 py-3">Amount</th><th class="px-4 py-3">Method</th><th class="px-4 py-3">Status</th><th class="px-4 py-3">Actions</th>
            </tr></thead>
            <tbody class="divide-y">${rows.map((p) => `
              <tr>
                <td class="px-4 py-3 font-medium">${esc(p.id)}${p.earlyRequest ? '<p class="text-xs text-amber-700">Early request</p>' : ''}</td>
                <td class="px-4 py-3">${esc(p.store)}</td>
                <td class="px-4 py-3 font-semibold">${U().formatTk(p.amount)}</td>
                <td class="px-4 py-3">${esc(p.method)}</td>
                <td class="px-4 py-3">${U().badge(p.status)}</td>
                <td class="px-4 py-3 space-x-2">
                  ${p.status === 'pending' ? `<button type="button" data-act="processing" data-id="${esc(p.id)}" class="text-xs font-semibold text-amber-700">Approve</button>` : ''}
                  ${p.status === 'processing' || p.status === 'pending' ? `<button type="button" data-act="completed" data-id="${esc(p.id)}" class="text-xs font-semibold text-emerald-700">Mark paid</button>` : ''}
                  ${p.status === 'completed' ? '<span class="text-xs text-outline">Done</span>' : ''}
                </td>
              </tr>`).join('')}</tbody>
          </table>
        </div>`;
      root.querySelectorAll('[data-st]').forEach((b) => b.addEventListener('click', () => { status = b.getAttribute('data-st'); render(); }));
      root.querySelectorAll('[data-act]').forEach((b) => b.addEventListener('click', async () => {
        const act = b.getAttribute('data-act');
        const id = b.getAttribute('data-id');
        const ok = await U().confirmDialog({ title: act === 'completed' ? 'Mark paid' : 'Approve payout', message: `Set payout to ${act}?` });
        if (!ok) return;
        S().setMerchantPayoutStatus(id, act);
        U().notice(`Payout → ${act}`);
      }));
      root.querySelector('#ex')?.addEventListener('click', () => U().downloadCsv('merchant-payouts.csv', rows));
    };
    render();
    Router.onStore(() => { if (location.hash.includes('/merchant/payouts')) render(); });
  };

  window.Pages.merchantPricing = async function merchantPricing(root) {
    const render = () => {
      const p = S().getPricing('merchant');
      root.innerHTML = `
        ${hdr('Merchant Pricing', ['Merchant Panel', 'Pricing'])}
        <form id="mp-form" class="bg-white rounded-xl border p-6 grid grid-cols-1 md:grid-cols-2 gap-4 max-w-3xl">
          <label class="text-xs font-semibold text-outline">Platform commission %
            <input name="platformCommissionPct" type="number" step="any" value="${p.platformCommissionPct}" class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
          <label class="text-xs font-semibold text-outline">Order service fee ৳
            <input name="orderServiceFee" type="number" step="any" value="${p.orderServiceFee}" class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
          <label class="text-xs font-semibold text-outline">Tax / VAT %
            <input name="taxVatPct" type="number" step="any" value="${p.taxVatPct}" class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
          <label class="text-xs font-semibold text-outline">Early payout fee %
            <input name="earlyPayoutFeePct" type="number" step="any" value="${p.earlyPayoutFeePct}" class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
          <label class="text-xs font-semibold text-outline">Min payout ৳
            <input name="minPayoutAmount" type="number" step="any" value="${p.minPayoutAmount}" class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
          <label class="text-xs font-semibold text-outline">Settlement cycle
            <select name="settlementCycle" class="mt-1 w-full rounded-lg border-slate-200 text-sm">
              ${['daily', 'weekly', 'biweekly', 'monthly'].map((c) => `<option value="${c}" ${p.settlementCycle === c ? 'selected' : ''}>${c}</option>`).join('')}
            </select>
          </label>
          <div class="md:col-span-2 flex justify-end gap-2">
            <button type="button" id="disc" class="px-4 py-2 rounded-lg border text-sm font-semibold">Discard</button>
            <button type="submit" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Save</button>
          </div>
        </form>`;
      root.querySelector('#mp-form')?.addEventListener('submit', (e) => {
        e.preventDefault();
        const fd = new FormData(e.target);
        const values = { settlementCycle: fd.get('settlementCycle') };
        ['platformCommissionPct', 'orderServiceFee', 'taxVatPct', 'earlyPayoutFeePct', 'minPayoutAmount'].forEach((k) => { values[k] = Number(fd.get(k)); });
        S().savePricing('merchant', values);
        U().notice('Merchant pricing saved');
        render();
      });
      root.querySelector('#disc')?.addEventListener('click', render);
    };
    render();
  };
})();

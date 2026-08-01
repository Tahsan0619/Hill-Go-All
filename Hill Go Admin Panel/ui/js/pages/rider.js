window.Pages = window.Pages || {};

(function riderPages() {
  const S = () => AppStore;
  const U = () => UI;
  const esc = (s) => U().escapeHtml(s);
  const hdr = (title, crumbs, actions = '') => `
    <div class="mb-6 flex justify-between items-end flex-wrap gap-3">
      <div><nav class="flex items-center gap-2 text-xs text-outline mb-2">${U().breadcrumb(crumbs)}</nav><h2 class="text-3xl font-bold">${title}</h2></div>
      <div class="flex gap-2">${actions}</div>
    </div>`;

  window.Pages.riderDashboard = async function riderDashboard(root) {
    const riders = S().listRiders();
    const online = riders.filter((r) => r.online && r.status === 'active').length;
    const kyc = S().listRiderKyc().filter((k) => k.status !== 'verified').length;
    const pendingPay = S().listRiderPayouts({ status: 'pending' }).length;
    const trips = S().listTrips();
    root.innerHTML = `
      ${hdr('Rider Operations', ['Rider Panel', 'Dashboard'], '<a href="#/rider/pay" class="px-4 py-2 text-sm font-semibold rounded-lg bg-primary-container text-white">Pay salary</a>')}
      <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4 mb-6">
        ${U().kpiCard('Online riders', online, `${riders.length} total`)}
        ${U().kpiCard('Trips in store', trips.length, `${trips.filter((t) => t.status === 'completed').length} completed`)}
        ${U().kpiCard('KYC pending', kyc, '')}
        ${U().kpiCard('Pending payouts', pendingPay, '')}
      </div>
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <a href="#/rider/kyc" class="bg-white rounded-xl border p-5 hover:border-primary-container">
          <h3 class="font-semibold">KYC queue</h3>
          <p class="text-sm text-outline mt-1">${kyc} riders waiting for review</p>
        </a>
        <a href="#/rider/payouts" class="bg-white rounded-xl border p-5 hover:border-primary-container">
          <h3 class="font-semibold">Payout log</h3>
          <p class="text-sm text-outline mt-1">Track salary payments</p>
        </a>
      </div>`;
  };

  window.Pages.riderList = async function riderList(root) {
    let filter = { q: '', status: 'all' };
    let page = 1;
    const render = () => {
      const all = S().listRiders(filter);
      const pg = U().paginate(all, page, 8);
      page = pg.page;
      root.innerHTML = `
        ${hdr('Riders', ['Rider Panel', 'Riders'], '<button type="button" id="ex" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Export CSV</button>')}
        <div class="bg-white rounded-xl border p-4 mb-4 flex flex-wrap gap-3">
          <input id="q" value="${esc(filter.q)}" class="flex-1 rounded-lg border-slate-200 text-sm" placeholder="Search riders…" />
          <select id="st" class="rounded-lg border-slate-200 text-sm">
            <option value="all">All</option>
            <option value="active" ${filter.status === 'active' ? 'selected' : ''}>Active</option>
            <option value="suspended" ${filter.status === 'suspended' ? 'selected' : ''}>Suspended</option>
          </select>
          <button type="button" id="apply" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Apply</button>
        </div>
        <div class="bg-white rounded-xl border overflow-hidden">
          <table class="w-full text-sm">
            <thead class="bg-slate-50 text-xs uppercase text-outline text-left"><tr>
              <th class="px-4 py-3">Rider</th><th class="px-4 py-3">Vehicle</th><th class="px-4 py-3">Online</th><th class="px-4 py-3">Today</th><th class="px-4 py-3">Status</th><th class="px-4 py-3"></th>
            </tr></thead>
            <tbody class="divide-y">
              ${pg.rows.map((r) => `
                <tr>
                  <td class="px-4 py-3"><p class="font-medium">${esc(r.name)}</p><p class="text-xs text-outline">${esc(r.id)} · ${esc(r.district)}</p></td>
                  <td class="px-4 py-3 capitalize">${esc(r.vehicle)}<p class="text-xs text-outline">${esc(r.plate)}</p></td>
                  <td class="px-4 py-3">${r.online ? U().badge('active') : '<span class="text-xs text-outline">Offline</span>'}</td>
                  <td class="px-4 py-3">${U().formatTk(r.todayEarnings)} · ${r.tripsToday} trips</td>
                  <td class="px-4 py-3">${U().badge(r.status)}</td>
                  <td class="px-4 py-3 text-right">
                    <button type="button" data-toggle="${esc(r.id)}" class="text-xs font-semibold text-primary-container">${r.status === 'active' ? 'Suspend' : 'Activate'}</button>
                  </td>
                </tr>`).join('')}
            </tbody>
          </table>
          ${U().pagerHtml(pg.page, pg.pages, pg.total)}
        </div>
        ${HillGoMaps.mapShell({
          id: 'map-riders',
          title: 'Rider live positions',
          liveLabel: `${all.filter((r) => r.online).length} online`,
          height: '320px',
        })}`;
      root.querySelector('#apply')?.addEventListener('click', () => {
        filter.q = root.querySelector('#q').value.trim();
        filter.status = root.querySelector('#st').value;
        page = 1; render();
      });
      root.querySelector('#ex')?.addEventListener('click', () => U().downloadCsv('riders.csv', all));
      root.querySelectorAll('[data-toggle]').forEach((b) => b.addEventListener('click', async () => {
        const id = b.getAttribute('data-toggle');
        const r = S().listRiders().find((x) => x.id === id);
        const next = r.status === 'active' ? 'suspended' : 'active';
        const ok = await U().confirmDialog({ title: `${next} rider`, message: `${r.name} → ${next}`, danger: next === 'suspended', confirmLabel: next === 'suspended' ? 'Suspend' : 'Activate' });
        if (!ok) return;
        S().updateRider(id, { status: next, online: next === 'active' ? r.online : false });
        U().notice(`${r.name} is ${next}`);
      }));
      root.querySelector('[data-page-btn="prev"]')?.addEventListener('click', () => { page -= 1; render(); });
      root.querySelector('[data-page-btn="next"]')?.addEventListener('click', () => { page += 1; render(); });
      HillGoMaps.mount('map-riders', {
        height: '320px',
        markers: HillGoMaps.markersFromRiders(all),
      });
    };
    render();
    Router.onStore(() => { if (location.hash.includes('/rider/riders')) render(); });
  };

  window.Pages.riderLiveMap = async function riderLiveMap(root) {
    const riders = S().listRiders({ status: 'active' });
    const trips = S().listTrips().filter((t) => ['in_progress', 'accepted'].includes(t.status));
    root.innerHTML = `
      ${hdr('Live Map', ['Rider Panel', 'Live Map'], '<a href="#/rider/riders" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Riders list</a><a href="#/rider/trips" class="px-4 py-2 text-sm font-semibold rounded-lg bg-primary-container text-white">Trips</a>')}
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4">
        ${U().kpiCard('Online', riders.filter((r) => r.online).length, '')}
        ${U().kpiCard('Active jobs', trips.length, '')}
        ${U().kpiCard('Suspended', S().listRiders({ status: 'suspended' }).length, '')}
      </div>
      ${HillGoMaps.mapShell({
        id: 'map-rider-live',
        title: 'Live rider & trip map',
        liveLabel: 'Realtime positions from API',
        height: '520px',
        sideHtml: `
          <div class="bg-white rounded-xl border shadow-sm overflow-hidden h-[520px] flex flex-col">
            <div class="px-4 py-3 border-b font-semibold text-sm">Online riders</div>
            <ul class="flex-1 overflow-y-auto divide-y">
              ${riders.filter((r) => r.online).map((r) => `
                <li class="px-4 py-3 text-sm flex justify-between gap-2">
                  <div><p class="font-medium">${esc(r.name)}</p><p class="text-xs text-outline">${esc(r.vehicle)} · ${esc(r.district)}</p></div>
                  <span class="text-xs font-semibold text-emerald-600">Online</span>
                </li>`).join('') || '<li class="px-4 py-6 text-outline text-sm">No riders online</li>'}
            </ul>
          </div>`,
      })}`;
    HillGoMaps.mount('map-rider-live', {
      height: '520px',
      markers: [
        ...HillGoMaps.markersFromRiders(riders.filter((r) => r.online)),
        ...HillGoMaps.markersFromTrips(trips),
      ],
      circles: [
        { ...HillGoMaps.HUBS.gulshan, radius: 2000, color: '#0047ab' },
        { ...HillGoMaps.HUBS.mirpur, radius: 1800, color: '#10B981' },
      ],
    });
  };

  window.Pages.riderKyc = async function riderKyc(root) {
    let tab = 'all';
    let selected = new Set();
    const render = () => {
      const rows = S().listRiderKyc({ tab });
      root.innerHTML = `
        ${hdr('KYC Queue', ['Rider Panel', 'KYC'], `
          <button type="button" data-bulk="verified" class="px-3 py-2 rounded-lg bg-emerald-600 text-white text-sm font-semibold">Approve selected</button>
          <button type="button" data-bulk="action_required" class="px-3 py-2 rounded-lg border text-sm font-semibold">Request reupload</button>
          <button type="button" data-bulk="rejected" class="px-3 py-2 rounded-lg bg-error text-white text-sm font-semibold">Reject selected</button>
        `)}
        <div class="flex gap-2 mb-4">
          ${['all', 'priority', 'flagged'].map((t) => `
            <button type="button" data-tab="${t}" class="px-3 py-1.5 rounded-full text-xs font-semibold border ${tab === t ? 'bg-primary-container text-white border-primary-container' : 'bg-white'}">${t}</button>`).join('')}
        </div>
        <div class="bg-white rounded-xl border overflow-hidden">
          <table class="w-full text-sm">
            <thead class="bg-slate-50 text-xs uppercase text-outline text-left"><tr>
              <th class="px-4 py-3"><input type="checkbox" id="sel-all" /></th>
              <th class="px-4 py-3">Rider</th><th class="px-4 py-3">Docs</th><th class="px-4 py-3">Status</th><th class="px-4 py-3">Submitted</th><th class="px-4 py-3">Actions</th>
            </tr></thead>
            <tbody class="divide-y">
              ${rows.map((k) => `
                <tr class="${k.status === 'verified' ? 'opacity-60' : ''}">
                  <td class="px-4 py-3"><input type="checkbox" data-sel="${k.id}" ${selected.has(k.id) ? 'checked' : ''} ${k.status === 'verified' ? 'disabled' : ''} /></td>
                  <td class="px-4 py-3"><p class="font-medium">${esc(k.riderName)}</p><p class="text-xs text-outline">${esc(k.riderId)}${k.priority ? ' · Priority' : ''}${k.flagged ? ' · Flagged' : ''}</p></td>
                  <td class="px-4 py-3 text-xs">
                    <div class="flex flex-col gap-1">
                      ${(k.docDetails || []).map((d) => d.fileUrl
                        ? `<button type="button" data-doc-url="${esc(d.fileUrl)}" data-doc-name="${esc(d.title || d.key || 'document')}" class="text-left text-primary-container font-semibold hover:underline">${esc(d.title || d.key)}</button>`
                        : `<span>${esc(d.title || d.key || '')}</span>`).join('') || esc((k.docs || []).join(', '))}
                    </div>
                  </td>
                  <td class="px-4 py-3">${U().badge(k.status)}</td>
                  <td class="px-4 py-3 text-xs">${esc(k.submitted)}</td>
                  <td class="px-4 py-3 space-x-2 whitespace-nowrap">
                    <button type="button" data-act="verified" data-id="${k.id}" class="text-xs font-semibold text-emerald-700" ${k.status === 'verified' ? 'disabled' : ''}>Approve</button>
                    <button type="button" data-act="action_required" data-id="${k.id}" class="text-xs font-semibold text-amber-700">Reupload</button>
                    <button type="button" data-act="rejected" data-id="${k.id}" class="text-xs font-semibold text-error">Reject</button>
                  </td>
                </tr>`).join('') || '<tr><td colspan="6" class="px-4 py-8 text-center text-outline">Queue empty</td></tr>'}
            </tbody>
          </table>
        </div>`;
      root.querySelectorAll('[data-tab]').forEach((b) => b.addEventListener('click', () => { tab = b.getAttribute('data-tab'); selected.clear(); render(); }));
      root.querySelector('#sel-all')?.addEventListener('change', (e) => {
        selected.clear();
        if (e.target.checked) rows.filter((k) => k.status !== 'verified').forEach((k) => selected.add(k.id));
        render();
      });
      root.querySelectorAll('[data-sel]').forEach((c) => c.addEventListener('change', () => {
        const id = c.getAttribute('data-sel');
        if (c.checked) selected.add(id); else selected.delete(id);
      }));
      root.querySelectorAll('[data-act]').forEach((b) => b.addEventListener('click', async () => {
        const id = b.getAttribute('data-id');
        const act = b.getAttribute('data-act');
        const ok = await U().confirmDialog({ title: `Mark ${act.replace(/_/g, ' ')}`, message: 'Update this KYC application?', danger: act === 'rejected', confirmLabel: 'Confirm' });
        if (!ok) return;
        S().setRiderKycStatus(id, act);
        U().notice(`KYC → ${act}`);
      }));
      root.querySelectorAll('[data-bulk]').forEach((b) => b.addEventListener('click', async () => {
        const act = b.getAttribute('data-bulk');
        if (!selected.size) { U().notice('Select at least one row', 'error'); return; }
        const ok = await U().confirmDialog({ title: 'Bulk KYC update', message: `Apply ${act} to ${selected.size} applications?`, danger: act === 'rejected' });
        if (!ok) return;
        S().bulkRiderKyc([...selected], act);
        selected.clear();
        U().notice(`Updated ${act}`);
      }));
      root.querySelectorAll('[data-doc-url]').forEach((b) => b.addEventListener('click', async () => {
        try {
          await S().openAuthenticatedFile(b.getAttribute('data-doc-url'), b.getAttribute('data-doc-name') || 'document');
        } catch (e) {
          U().notice(e.message || 'Could not open document', 'error');
        }
      }));
    };
    render();
    Router.onStore(() => { if (location.hash.includes('/rider/kyc')) render(); });
  };

  window.Pages.riderTrips = async function riderTrips(root) {
    let type = 'all';
    let q = '';
    let page = 1;
    const render = () => {
      const all = S().listTrips({ type, q });
      const pg = U().paginate(all, page, 8);
      page = pg.page;
      root.innerHTML = `
        ${hdr('Trips / Jobs', ['Rider Panel', 'Trips'], `<button type="button" id="ex" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Export</button><a href="#/rider/payouts" class="px-4 py-2 text-sm font-semibold rounded-lg bg-primary-container text-white">Review payouts</a>`)}
        <div class="flex flex-wrap gap-2 mb-4">
          ${['all', 'ride', 'food', 'parcel'].map((t) => `
            <button type="button" data-type="${t}" class="px-3 py-1.5 rounded-full text-xs font-semibold border capitalize ${type === t ? 'bg-primary-container text-white border-primary-container' : 'bg-white'}">${t}</button>`).join('')}
          <input id="q" value="${esc(q)}" class="ml-auto rounded-lg border-slate-200 text-sm" placeholder="Search…" />
          <button type="button" id="apply" class="px-3 py-1.5 rounded-lg bg-slate-900 text-white text-xs font-semibold">Search</button>
        </div>
        <div class="bg-white rounded-xl border overflow-hidden">
          <table class="w-full text-sm">
            <thead class="bg-slate-50 text-xs uppercase text-outline text-left"><tr>
              <th class="px-4 py-3">Job</th><th class="px-4 py-3">Type</th><th class="px-4 py-3">Rider</th><th class="px-4 py-3">Route</th><th class="px-4 py-3">Earn</th><th class="px-4 py-3">Pay</th><th class="px-4 py-3">Status</th>
            </tr></thead>
            <tbody class="divide-y">${pg.rows.map((t) => `
              <tr>
                <td class="px-4 py-3 font-medium">${esc(t.id)}</td>
                <td class="px-4 py-3 capitalize">${esc(t.type)}${t.surge > 1 ? ` · ${t.surge}x` : ''}</td>
                <td class="px-4 py-3">${esc(t.rider)}</td>
                <td class="px-4 py-3">${esc(t.route)} <span class="text-xs text-outline">${t.km} km</span></td>
                <td class="px-4 py-3">${U().formatTk(t.earning)}${t.cod ? `<p class="text-xs text-outline">COD ${U().formatTk(t.cod)}</p>` : ''}</td>
                <td class="px-4 py-3 capitalize">${esc(t.payment)}</td>
                <td class="px-4 py-3">${U().badge(t.status)}</td>
              </tr>`).join('')}</tbody>
          </table>
          ${U().pagerHtml(pg.page, pg.pages, pg.total)}
        </div>`;
      root.querySelectorAll('[data-type]').forEach((b) => b.addEventListener('click', () => { type = b.getAttribute('data-type'); page = 1; render(); }));
      root.querySelector('#apply')?.addEventListener('click', () => { q = root.querySelector('#q').value.trim(); page = 1; render(); });
      root.querySelector('#ex')?.addEventListener('click', () => U().downloadCsv('trips.csv', all));
      root.querySelector('[data-page-btn="prev"]')?.addEventListener('click', () => { page -= 1; render(); });
      root.querySelector('[data-page-btn="next"]')?.addEventListener('click', () => { page += 1; render(); });
    };
    render();
  };

  window.Pages.riderPay = async function riderPay(root) {
    const riders = S().listRiders({ status: 'active' });
    const recent = S().listRiderPayouts().slice(0, 5);
    const today = new Date().toISOString().slice(0, 10);
    const weekAgo = new Date(Date.now() - 7 * 864e5).toISOString().slice(0, 10);
    root.innerHTML = `
      ${hdr('Pay Salary', ['Rider Panel', 'Pay Salary'], '<a href="#/rider/payouts" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Payout log</a>')}
      <div class="grid grid-cols-1 lg:grid-cols-5 gap-4">
        <form id="pay-form" class="lg:col-span-3 bg-white rounded-xl border shadow-sm p-6 space-y-4">
          <label class="block text-xs font-semibold text-outline">Rider
            <select name="riderId" required class="mt-1 w-full rounded-lg border-slate-200 text-sm">
              <option value="">Select rider…</option>
              ${riders.map((r) => `<option value="${esc(r.id)}" data-name="${esc(r.name)}">${esc(r.name)} (${esc(r.id)}) — today ${U().formatTk(r.todayEarnings)}</option>`).join('')}
            </select>
          </label>
          <div class="grid grid-cols-2 gap-3">
            <label class="text-xs font-semibold text-outline">From<input name="periodFrom" type="date" value="${weekAgo}" required class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
            <label class="text-xs font-semibold text-outline">To<input name="periodTo" type="date" value="${today}" required class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
          </div>
          <div class="grid grid-cols-2 gap-3">
            <label class="text-xs font-semibold text-outline">Gross earnings ৳<input name="gross" type="number" required class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
            <label class="text-xs font-semibold text-outline">Tips ৳<input name="tips" type="number" value="0" class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
            <label class="text-xs font-semibold text-outline">Surge bonuses ৳<input name="surge" type="number" value="0" class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
            <label class="text-xs font-semibold text-outline">Deductions ৳<input name="deductions" type="number" value="0" class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
          </div>
          <p class="text-sm">Net pay: <strong id="net-pay">৳0</strong></p>
          <fieldset>
            <legend class="text-xs font-semibold text-outline mb-2">Pay method</legend>
            <div class="flex gap-4 text-sm">
              ${['bKash', 'Nagad', 'Bank'].map((m, i) => `<label class="flex items-center gap-2"><input type="radio" name="method" value="${m}" ${i === 0 ? 'checked' : ''} />${m}</label>`).join('')}
            </div>
          </fieldset>
          <label class="block text-xs font-semibold text-outline">Transaction ref<input name="ref" class="mt-1 w-full rounded-lg border-slate-200 text-sm" placeholder="Optional" /></label>
          <label class="block text-xs font-semibold text-outline">Note<textarea name="note" rows="2" class="mt-1 w-full rounded-lg border-slate-200 text-sm"></textarea></label>
          <div class="flex justify-end gap-2 pt-2">
            <button type="reset" class="px-4 py-2 rounded-lg border text-sm font-semibold">Clear</button>
            <button type="submit" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Mark as paid</button>
          </div>
        </form>
        <div class="lg:col-span-2 bg-white rounded-xl border shadow-sm p-5">
          <h3 class="font-semibold mb-3">Recent payments</h3>
          <ul class="space-y-3 text-sm">
            ${recent.map((p) => `<li class="flex justify-between gap-2 border-b pb-2"><div><p class="font-medium">${esc(p.rider)}</p><p class="text-xs text-outline">${esc(p.method)} · ${esc(p.id)}</p></div><div class="text-right"><p class="font-semibold">${U().formatTk(p.amount)}</p>${U().badge(p.status)}</div></li>`).join('')}
          </ul>
        </div>
      </div>`;

    const form = root.querySelector('#pay-form');
    const recalc = () => {
      const gross = Number(form.gross.value || 0);
      const tips = Number(form.tips.value || 0);
      const surge = Number(form.surge.value || 0);
      const deductions = Number(form.deductions.value || 0);
      root.querySelector('#net-pay').textContent = U().formatTk(gross + tips + surge - deductions);
    };
    ['gross', 'tips', 'surge', 'deductions'].forEach((n) => form[n].addEventListener('input', recalc));
    form.riderId.addEventListener('change', () => {
      const r = riders.find((x) => x.id === form.riderId.value);
      if (r) { form.gross.value = r.todayEarnings; recalc(); }
    });
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      const riderId = form.riderId.value;
      const rider = riders.find((x) => x.id === riderId);
      if (!rider) { U().notice('Select a rider', 'error'); return; }
      const amount = Number(form.gross.value) + Number(form.tips.value || 0) + Number(form.surge.value || 0) - Number(form.deductions.value || 0);
      if (amount <= 0) { U().notice('Net pay must be positive', 'error'); return; }
      const ok = await U().confirmDialog({
        title: 'Confirm salary payment',
        message: `Pay ${U().formatTk(amount)} to ${rider.name} via ${form.method.value}? This appends a Paid row to the payout log.`,
        confirmLabel: 'Mark paid',
      });
      if (!ok) return;
      S().createRiderPayout({
        riderId, rider: rider.name, amount, method: form.method.value,
        periodFrom: form.periodFrom.value, periodTo: form.periodTo.value,
        ref: form.ref.value, tips: form.tips.value, surge: form.surge.value,
        deductions: form.deductions.value, note: form.note.value,
      });
      U().notice(`Paid ${rider.name} ${U().formatTk(amount)}`);
      Router.go('/rider/payouts');
    });
  };

  window.Pages.riderPayouts = async function riderPayouts(root) {
    let filter = { q: '', method: 'all', status: 'all' };
    let page = 1;
    const render = () => {
      const all = S().listRiderPayouts(filter);
      const pg = U().paginate(all, page, 8);
      page = pg.page;
      const paidSum = all.filter((p) => p.status === 'paid').reduce((s, p) => s + p.amount, 0);
      root.innerHTML = `
        ${hdr('Payout Log', ['Rider Panel', 'Payout Log'], '<a href="#/rider/pay" class="px-4 py-2 text-sm font-semibold rounded-lg bg-primary-container text-white">Pay salary</a><button type="button" id="ex" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Export</button>')}
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4">
          ${U().kpiCard('Paid (filtered)', U().formatTk(paidSum), `${all.length} rows`)}
          ${U().kpiCard('Pending', all.filter((p) => p.status === 'pending').length, '')}
          ${U().kpiCard('Failed', all.filter((p) => p.status === 'failed').length, '')}
        </div>
        <div class="bg-white rounded-xl border p-4 mb-4 flex flex-wrap gap-3">
          <input id="q" value="${esc(filter.q)}" class="flex-1 rounded-lg border-slate-200 text-sm" placeholder="Search…" />
          <select id="method" class="rounded-lg border-slate-200 text-sm">
            <option value="all">All methods</option>
            ${['bKash', 'Nagad', 'Bank'].map((m) => `<option ${filter.method === m ? 'selected' : ''}>${m}</option>`).join('')}
          </select>
          <select id="status" class="rounded-lg border-slate-200 text-sm">
            <option value="all">All statuses</option>
            ${['paid', 'pending', 'failed'].map((s) => `<option value="${s}" ${filter.status === s ? 'selected' : ''}>${s}</option>`).join('')}
          </select>
          <button type="button" id="apply" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Apply</button>
        </div>
        <div class="bg-white rounded-xl border overflow-hidden">
          <table class="w-full text-sm">
            <thead class="bg-slate-50 text-xs uppercase text-outline text-left"><tr>
              <th class="px-4 py-3">ID</th><th class="px-4 py-3">Rider</th><th class="px-4 py-3">Amount</th><th class="px-4 py-3">Method</th><th class="px-4 py-3">Period</th><th class="px-4 py-3">Status</th>
            </tr></thead>
            <tbody class="divide-y">${pg.rows.map((p) => `
              <tr>
                <td class="px-4 py-3 font-medium">${esc(p.id)}<p class="text-xs text-outline">${p.ref || '—'}</p></td>
                <td class="px-4 py-3">${esc(p.rider)}</td>
                <td class="px-4 py-3 font-semibold">${U().formatTk(p.amount)}</td>
                <td class="px-4 py-3">${esc(p.method)}</td>
                <td class="px-4 py-3 text-xs">${esc(p.periodFrom)} → ${esc(p.periodTo)}</td>
                <td class="px-4 py-3">${U().badge(p.status)}</td>
              </tr>`).join('')}</tbody>
          </table>
          ${U().pagerHtml(pg.page, pg.pages, pg.total)}
        </div>`;
      root.querySelector('#apply')?.addEventListener('click', () => {
        filter = { q: root.querySelector('#q').value.trim(), method: root.querySelector('#method').value, status: root.querySelector('#status').value };
        page = 1; render();
      });
      root.querySelector('#ex')?.addEventListener('click', () => U().downloadCsv('rider-payouts.csv', all));
      root.querySelector('[data-page-btn="prev"]')?.addEventListener('click', () => { page -= 1; render(); });
      root.querySelector('[data-page-btn="next"]')?.addEventListener('click', () => { page += 1; render(); });
    };
    render();
    Router.onStore(() => { if (location.hash.includes('/rider/payouts')) render(); });
  };

  window.Pages.riderPricing = async function riderPricing(root) {
    const render = () => {
      const p = S().getPricing('rider');
      const audit = S().listPricingAudit('rider').slice(0, 8);
      root.innerHTML = `
        ${hdr('Rider Pricing', ['Rider Panel', 'Pricing'])}
        <form id="rp-form" class="bg-white rounded-xl border p-6 grid grid-cols-1 md:grid-cols-3 gap-4 max-w-5xl">
          ${Object.entries({
            rideBase: 'Ride base', ridePerKm: 'Per km', ridePerMin: 'Per min', rideMinimum: 'Minimum',
            bikeMultiplier: 'Bike ×', carMultiplier: 'Car ×', xlMultiplier: 'XL ×',
            foodJobFee: 'Food job fee', parcelBase: 'Parcel base', parcelPerKm: 'Parcel / km',
            parcelPerKg: 'Parcel / kg', parcelMinimum: 'Parcel min', defaultSurge: 'Default surge',
            platformCommissionPct: 'Platform commission %',
          }).map(([k, label]) => `
            <label class="text-xs font-semibold text-outline">${label}
              <input name="${k}" type="number" step="any" value="${p[k]}" class="mt-1 w-full rounded-lg border-slate-200 text-sm" />
            </label>`).join('')}
          <div class="md:col-span-3 flex justify-end gap-2">
            <button type="button" id="disc" class="px-4 py-2 rounded-lg border text-sm font-semibold">Discard</button>
            <button type="submit" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Save</button>
          </div>
        </form>
        <div class="mt-6 bg-white rounded-xl border p-5 max-w-5xl">
          <h3 class="font-semibold mb-2">Audit</h3>
          <ul class="text-sm divide-y">${audit.map((a) => `<li class="py-2">${esc(a.field)}: ${esc(a.oldValue)} → ${esc(a.newValue)} <span class="text-xs text-outline">${U().formatDate(a.at)}</span></li>`).join('') || '<li class="text-outline">No changes</li>'}</ul>
        </div>`;
      root.querySelector('#rp-form')?.addEventListener('submit', (e) => {
        e.preventDefault();
        const fd = new FormData(e.target);
        const values = {};
        fd.forEach((v, k) => { values[k] = Number(v); });
        S().savePricing('rider', values);
        U().notice('Rider pricing saved');
        render();
      });
      root.querySelector('#disc')?.addEventListener('click', render);
    };
    render();
  };
})();

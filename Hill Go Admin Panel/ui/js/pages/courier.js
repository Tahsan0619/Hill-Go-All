window.Pages = window.Pages || {};

(function courierPages() {
  const S = () => AppStore;
  const U = () => UI;
  const hdr = (title, crumbs, actions = '') => `
    <div class="mb-6 flex justify-between items-end flex-wrap gap-3">
      <div><nav class="flex items-center gap-2 text-xs text-outline mb-2">${U().breadcrumb(crumbs)}</nav><h2 class="text-3xl font-bold">${title}</h2></div>
      <div class="flex gap-2">${actions}</div>
    </div>`;

  function openCourierKyc(id) {
    const k = S().listCourierKyc().find((x) => x.id === id);
    if (!k) return;
    U().openModal({
      title: `Verify docs — ${k.agentName}`,
      width: 'max-w-lg',
      bodyHtml: `
        <div class="space-y-3 text-sm">
          <p class="text-outline">${k.agentId} · submitted ${k.submitted}</p>
          <ul class="list-disc pl-5">${k.docs.map((d) => `<li>${d}</li>`).join('')}</ul>
          <label class="flex items-center gap-2"><input type="checkbox" id="ck-bank" ${k.bankVerified ? 'checked' : ''} class="rounded border-slate-300 text-primary-container" /> Bank verified</label>
          <p>Current: ${U().badge(k.status)}</p>
        </div>`,
      footerHtml: `
        <button type="button" id="ck-reject" class="px-4 py-2 rounded-lg bg-error text-white text-sm font-semibold">Reject</button>
        <button type="button" id="ck-approve" class="px-4 py-2 rounded-lg bg-emerald-600 text-white text-sm font-semibold">Approve</button>`,
    });
    document.getElementById('ck-approve')?.addEventListener('click', () => {
      S().setCourierKycStatus(id, 'verified', document.getElementById('ck-bank').checked);
      U().closeModal();
      U().notice(`${k.agentName} verified`);
      Router.navigate();
    });
    document.getElementById('ck-reject')?.addEventListener('click', async () => {
      const ok = await U().confirmDialog({ title: 'Reject KYC', message: `Reject ${k.agentName}?`, danger: true, confirmLabel: 'Reject' });
      if (!ok) return;
      S().setCourierKycStatus(id, 'rejected', false);
      U().closeModal();
      U().notice('KYC rejected');
      Router.navigate();
    });
  }

  window.Pages.courierDashboard = async function courierDashboard(root) {
    const agents = S().listAgents();
    const active = agents.filter((a) => a.status === 'active' && a.online).length;
    const parcels = S().listCourierParcels();
    const pendingWd = S().listWithdrawals({ status: 'pending' });
    const incentives = S().listIncentives().filter((i) => i.active).length;
    root.innerHTML = `
      ${hdr('Courier Operations', ['Courier Panel', 'Dashboard'], '<a href="#/courier/withdrawals" class="px-4 py-2 text-sm font-semibold rounded-lg bg-primary-container text-white">Withdrawals</a>')}
      <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4 mb-6">
        ${U().kpiCard('Active agents online', active, `${agents.length} total`)}
        ${U().kpiCard('Parcels in pipeline', parcels.filter((p) => !['delivered', 'failed'].includes(p.status)).length, '')}
        ${U().kpiCard('Pending withdrawals', pendingWd.length, U().formatTk(pendingWd.reduce((s, w) => s + w.amount, 0)))}
        ${U().kpiCard('Active incentives', incentives, '')}
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <a href="#/courier/kyc" class="bg-white rounded-xl border p-5 hover:border-primary-container"><h3 class="font-semibold">KYC / Docs</h3><p class="text-sm text-outline mt-1">Verify agent documents</p></a>
        <a href="#/courier/parcels" class="bg-white rounded-xl border p-5 hover:border-primary-container"><h3 class="font-semibold">Parcels</h3><p class="text-sm text-outline mt-1">Track assigned deliveries</p></a>
        <a href="#/courier/incentives" class="bg-white rounded-xl border p-5 hover:border-primary-container"><h3 class="font-semibold">Incentives</h3><p class="text-sm text-outline mt-1">Create campaigns</p></a>
      </div>`;
  };

  window.Pages.courierAgents = async function courierAgents(root) {
    let filter = { q: '', status: 'all' };
    let page = 1;
    const render = () => {
      const all = S().listAgents(filter);
      const pg = U().paginate(all, page, 8);
      page = pg.page;
      root.innerHTML = `
        ${hdr('Agents', ['Courier Panel', 'Agents'], '<button type="button" id="ex" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Export</button>')}
        <div class="bg-white rounded-xl border p-4 mb-4 flex flex-wrap gap-3">
          <input id="q" value="${filter.q}" class="flex-1 rounded-lg border-slate-200 text-sm" placeholder="Search…" />
          <select id="st" class="rounded-lg border-slate-200 text-sm">
            <option value="all">All</option>
            <option value="active" ${filter.status === 'active' ? 'selected' : ''}>Active</option>
            <option value="suspended" ${filter.status === 'suspended' ? 'selected' : ''}>Suspended</option>
          </select>
          <button type="button" id="apply" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Apply</button>
          <button type="button" id="reset" class="px-4 py-2 rounded-lg border text-sm font-semibold">Reset</button>
        </div>
        <div class="bg-white rounded-xl border overflow-hidden">
          <table class="w-full text-sm">
            <thead class="bg-slate-50 text-xs uppercase text-outline text-left"><tr>
              <th class="px-4 py-3">Agent</th><th class="px-4 py-3">Vehicle</th><th class="px-4 py-3">Verified</th><th class="px-4 py-3">Deliveries</th><th class="px-4 py-3">Status</th><th class="px-4 py-3"></th>
            </tr></thead>
            <tbody class="divide-y">${pg.rows.map((a) => `
              <tr>
                <td class="px-4 py-3"><p class="font-medium">${a.name}</p><p class="text-xs text-outline">${a.id} · ${a.district} · ${a.phone}</p></td>
                <td class="px-4 py-3">${a.vehicle}<p class="text-xs text-outline">${a.plate}</p></td>
                <td class="px-4 py-3">${a.verified ? U().badge('verified') : U().badge('pending')}</td>
                <td class="px-4 py-3">${a.deliveries} · ${a.rating}★</td>
                <td class="px-4 py-3">${U().badge(a.status)}</td>
                <td class="px-4 py-3 text-right"><button type="button" data-tog="${a.id}" class="text-xs font-semibold text-primary-container">${a.status === 'active' ? 'Suspend' : 'Activate'}</button></td>
              </tr>`).join('')}</tbody>
          </table>
          ${U().pagerHtml(pg.page, pg.pages, pg.total)}
        </div>`;
      root.querySelector('#apply')?.addEventListener('click', () => {
        filter = { q: root.querySelector('#q').value.trim(), status: root.querySelector('#st').value };
        page = 1; render();
      });
      root.querySelector('#reset')?.addEventListener('click', () => { filter = { q: '', status: 'all' }; page = 1; render(); });
      root.querySelector('#ex')?.addEventListener('click', () => U().downloadCsv('courier-agents.csv', all));
      root.querySelectorAll('[data-tog]').forEach((b) => b.addEventListener('click', async () => {
        const a = S().listAgents().find((x) => x.id === b.getAttribute('data-tog'));
        const next = a.status === 'active' ? 'suspended' : 'active';
        const ok = await U().confirmDialog({ title: `${next} agent`, message: `${a.name} → ${next}`, danger: next === 'suspended' });
        if (!ok) return;
        S().updateAgent(a.id, { status: next, online: next === 'active' ? a.online : false });
        U().notice(`${a.name} ${next}`);
      }));
      root.querySelector('[data-page-btn="prev"]')?.addEventListener('click', () => { page -= 1; render(); });
      root.querySelector('[data-page-btn="next"]')?.addEventListener('click', () => { page += 1; render(); });
    };
    render();
    Router.onStore(() => { if (location.hash.includes('/courier/agents')) render(); });
  };

  window.Pages.courierKyc = async function courierKyc(root) {
    const render = () => {
      const rows = S().listCourierKyc();
      root.innerHTML = `
        ${hdr('Courier KYC / Docs', ['Courier Panel', 'KYC'])}
        <div class="bg-white rounded-xl border overflow-hidden">
          <table class="w-full text-sm">
            <thead class="bg-slate-50 text-xs uppercase text-outline text-left"><tr>
              <th class="px-4 py-3">Agent</th><th class="px-4 py-3">Docs</th><th class="px-4 py-3">Bank</th><th class="px-4 py-3">Status</th><th class="px-4 py-3"></th>
            </tr></thead>
            <tbody class="divide-y">${rows.map((k) => `
              <tr>
                <td class="px-4 py-3"><p class="font-medium">${k.agentName}</p><p class="text-xs text-outline">${k.agentId}</p></td>
                <td class="px-4 py-3 text-xs">${k.docs.join(', ')}</td>
                <td class="px-4 py-3">${k.bankVerified ? U().badge('verified') : U().badge('pending')}</td>
                <td class="px-4 py-3">${U().badge(k.status)}</td>
                <td class="px-4 py-3 text-right"><button type="button" data-k="${k.id}" class="text-xs font-semibold text-primary-container">Review</button></td>
              </tr>`).join('')}</tbody>
          </table>
        </div>`;
      root.querySelectorAll('[data-k]').forEach((b) => b.addEventListener('click', () => openCourierKyc(b.getAttribute('data-k'))));
    };
    render();
    Router.onStore(() => { if (location.hash.includes('/courier/kyc')) render(); });
  };

  window.Pages.courierParcels = async function courierParcels(root) {
    let filter = { q: '', status: 'all' };
    let page = 1;
    const render = () => {
      const all = S().listCourierParcels(filter);
      const pg = U().paginate(all, page, 8);
      page = pg.page;
      root.innerHTML = `
        ${hdr('Parcels', ['Courier Panel', 'Parcels'], '<button type="button" id="ex" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Export</button>')}
        <div class="bg-white rounded-xl border p-4 mb-4 flex flex-wrap gap-3">
          <input id="q" value="${filter.q}" class="flex-1 rounded-lg border-slate-200 text-sm" placeholder="Search…" />
          <select id="st" class="rounded-lg border-slate-200 text-sm">
            <option value="all">All</option>
            ${['assigned', 'picked_up', 'in_transit', 'delivered', 'failed'].map((s) => `<option value="${s}" ${filter.status === s ? 'selected' : ''}>${s.replace(/_/g, ' ')}</option>`).join('')}
          </select>
          <button type="button" id="apply" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Apply</button>
        </div>
        <div class="bg-white rounded-xl border overflow-hidden">
          <table class="w-full text-sm">
            <thead class="bg-slate-50 text-xs uppercase text-outline text-left"><tr>
              <th class="px-4 py-3">Parcel</th><th class="px-4 py-3">Agent</th><th class="px-4 py-3">Route</th><th class="px-4 py-3">Earn</th><th class="px-4 py-3">Status</th>
            </tr></thead>
            <tbody class="divide-y">${pg.rows.map((p) => `
              <tr>
                <td class="px-4 py-3 font-medium">${p.id}<p class="text-xs text-outline capitalize">${p.priority}</p></td>
                <td class="px-4 py-3">${p.agent}</td>
                <td class="px-4 py-3">${p.pickup} → ${p.drop}<p class="text-xs text-outline">${p.distanceKm} km · ${p.weightKg} kg</p></td>
                <td class="px-4 py-3">${U().formatTk(p.earnings)}${p.surge ? ` + ${U().formatTk(p.surge)}` : ''}</td>
                <td class="px-4 py-3">${U().badge(p.status)}</td>
              </tr>`).join('')}</tbody>
          </table>
          ${U().pagerHtml(pg.page, pg.pages, pg.total)}
        </div>
        ${HillGoMaps.mapShell({
          id: 'map-courier-parcels',
          title: 'Live Agent Distribution',
          liveLabel: `${S().listAgents().filter((a) => a.online).length} active agents`,
          height: '360px',
          sideHtml: `
            <div class="bg-white rounded-xl border shadow-sm flex flex-col h-[400px]">
              <div class="px-4 py-3 border-b flex items-center justify-between">
                <h3 class="text-xs font-semibold uppercase tracking-wider">Security log (OTP)</h3>
                <span class="material-symbols-outlined text-outline text-[18px]">history</span>
              </div>
              <div class="flex-1 overflow-y-auto p-3 space-y-3 text-sm">
                ${all.slice(0, 4).map((p, i) => {
                  const kinds = [
                    { cls: 'bg-green-50 border-green-100 text-green-800', icon: 'verified_user', title: 'Verified', sub: 'Delivery OTP confirmed' },
                    { cls: 'bg-slate-50 border-slate-200 text-on-surface', icon: 'key', title: 'Generated', sub: 'Pickup OTP sent' },
                    { cls: 'bg-red-50 border-red-100 text-red-800', icon: 'error', title: 'Failed', sub: 'Incorrect OTP attempts' },
                    { cls: 'bg-green-50 border-green-100 text-green-800', icon: 'verified_user', title: 'Verified', sub: 'Pickup OTP confirmed' },
                  ];
                  const k = kinds[i % kinds.length];
                  return `<div class="flex items-start gap-3 p-3 rounded-lg border ${k.cls}">
                    <span class="material-symbols-outlined text-[20px]">${k.icon}</span>
                    <div><p class="font-semibold text-sm">#${p.id} ${k.title}</p><p class="text-[11px] opacity-80">${k.sub} · ${p.agent}</p></div>
                  </div>`;
                }).join('')}
              </div>
            </div>`,
        })}`;
      root.querySelector('#apply')?.addEventListener('click', () => {
        filter = { q: root.querySelector('#q').value.trim(), status: root.querySelector('#st').value };
        page = 1; render();
      });
      root.querySelector('#ex')?.addEventListener('click', () => U().downloadCsv('courier-parcels.csv', all));
      root.querySelector('[data-page-btn="prev"]')?.addEventListener('click', () => { page -= 1; render(); });
      root.querySelector('[data-page-btn="next"]')?.addEventListener('click', () => { page += 1; render(); });
      HillGoMaps.mount('map-courier-parcels', {
        height: '360px',
        markers: [
          ...HillGoMaps.markersFromAgents(S().listAgents().filter((a) => a.status === 'active')),
          ...HillGoMaps.markersFromParcels(all),
        ],
      });
    };
    render();
  };

  window.Pages.courierWithdrawals = async function courierWithdrawals(root) {
    let status = 'all';
    const render = () => {
      const rows = S().listWithdrawals({ status });
      root.innerHTML = `
        ${hdr('Earnings & Withdrawals', ['Courier Panel', 'Withdrawals'], '<button type="button" id="ex" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Export</button>')}
        <div class="flex gap-2 mb-4">
          ${['all', 'pending', 'approved', 'rejected'].map((s) => `
            <button type="button" data-st="${s}" class="px-3 py-1.5 rounded-full text-xs font-semibold border ${status === s ? 'bg-primary-container text-white border-primary-container' : 'bg-white'}">${s}</button>`).join('')}
        </div>
        <div class="bg-white rounded-xl border overflow-hidden">
          <table class="w-full text-sm">
            <thead class="bg-slate-50 text-xs uppercase text-outline text-left"><tr>
              <th class="px-4 py-3">Request</th><th class="px-4 py-3">Agent</th><th class="px-4 py-3">Amount</th><th class="px-4 py-3">Method</th><th class="px-4 py-3">Status</th><th class="px-4 py-3">Actions</th>
            </tr></thead>
            <tbody class="divide-y">${rows.map((w) => `
              <tr>
                <td class="px-4 py-3 font-medium">${w.id}<p class="text-xs text-outline">${w.date}</p></td>
                <td class="px-4 py-3">${w.agent}</td>
                <td class="px-4 py-3 font-semibold">${U().formatTk(w.amount)}</td>
                <td class="px-4 py-3">${w.method} ·••${w.bankLast4}</td>
                <td class="px-4 py-3">${U().badge(w.status)}</td>
                <td class="px-4 py-3 space-x-2">
                  ${w.status === 'pending' ? `
                    <button type="button" data-act="approved" data-id="${w.id}" class="text-xs font-semibold text-emerald-700">Approve</button>
                    <button type="button" data-act="rejected" data-id="${w.id}" class="text-xs font-semibold text-error">Reject</button>` : '<span class="text-xs text-outline">—</span>'}
                </td>
              </tr>`).join('')}</tbody>
          </table>
        </div>`;
      root.querySelectorAll('[data-st]').forEach((b) => b.addEventListener('click', () => { status = b.getAttribute('data-st'); render(); }));
      root.querySelectorAll('[data-act]').forEach((b) => b.addEventListener('click', async () => {
        const act = b.getAttribute('data-act');
        const id = b.getAttribute('data-id');
        const ok = await U().confirmDialog({ title: `${act} withdrawal`, message: `Mark withdrawal as <strong>${act}</strong>?`, danger: act === 'rejected' });
        if (!ok) return;
        S().setWithdrawalStatus(id, act);
        U().notice(`Withdrawal ${act}`);
      }));
      root.querySelector('#ex')?.addEventListener('click', () => U().downloadCsv('courier-withdrawals.csv', rows));
    };
    render();
    Router.onStore(() => { if (location.hash.includes('/courier/withdrawals')) render(); });
  };

  window.Pages.courierIncentives = async function courierIncentives(root) {
    const render = () => {
      const list = S().listIncentives();
      const districts = [...new Set(S().getState().regionDistricts.filter((d) => d.status === 'open').map((d) => d.name))];
      root.innerHTML = `
        ${hdr('Incentives', ['Courier Panel', 'Incentives'])}
        <div class="grid grid-cols-1 lg:grid-cols-5 gap-4">
          <form id="inc-form" class="lg:col-span-2 bg-white rounded-xl border p-5 space-y-3">
            <h3 class="font-semibold">Create incentive</h3>
            <label class="block text-xs font-semibold text-outline">Title<input name="title" required class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
            <label class="block text-xs font-semibold text-outline">Description<textarea name="description" rows="2" class="mt-1 w-full rounded-lg border-slate-200 text-sm"></textarea></label>
            <div class="grid grid-cols-2 gap-2">
              <label class="text-xs font-semibold text-outline">Multiplier<input name="multiplier" type="number" step="0.1" value="1.5" class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
              <label class="text-xs font-semibold text-outline">Bonus ৳<input name="bonusTk" type="number" value="1500" class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
              <label class="text-xs font-semibold text-outline">Goal deliveries<input name="goalDeliveries" type="number" value="8" class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
              <label class="text-xs font-semibold text-outline">Valid until<input name="validUntil" type="date" required class="mt-1 w-full rounded-lg border-slate-200 text-sm" /></label>
            </div>
            <label class="block text-xs font-semibold text-outline">District
              <select name="district" class="mt-1 w-full rounded-lg border-slate-200 text-sm">
                <option value="">Any</option>
                ${districts.map((d) => `<option>${d}</option>`).join('')}
              </select>
            </label>
            <label class="flex items-center gap-2 text-sm"><input type="checkbox" name="active" checked class="rounded border-slate-300 text-primary-container" /> Activate immediately</label>
            <button type="submit" class="w-full px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Create</button>
          </form>
          <div class="lg:col-span-3 space-y-3">
            ${list.map((i) => `
              <div class="bg-white rounded-xl border p-5 flex justify-between gap-4">
                <div>
                  <div class="flex items-center gap-2 mb-1">${U().badge(i.status)} <h3 class="font-semibold">${i.title}</h3></div>
                  <p class="text-sm text-outline">${i.description || '—'}</p>
                  <p class="text-xs text-outline mt-2">${i.multiplier}x · Goal ${i.goalDeliveries} · Bonus ${U().formatTk(i.bonusTk)} · ${i.district || 'All'} · until ${i.validUntil}</p>
                </div>
                <button type="button" data-tog="${i.id}" class="self-start text-xs font-semibold text-primary-container">${i.active ? 'Deactivate' : 'Activate'}</button>
              </div>`).join('') || '<p class="text-outline text-sm">No incentives yet</p>'}
          </div>
        </div>`;
      root.querySelector('#inc-form')?.addEventListener('submit', (e) => {
        e.preventDefault();
        const fd = new FormData(e.target);
        S().createIncentive({
          title: fd.get('title'),
          description: fd.get('description'),
          multiplier: fd.get('multiplier'),
          bonusTk: fd.get('bonusTk'),
          goalDeliveries: fd.get('goalDeliveries'),
          validUntil: fd.get('validUntil'),
          district: fd.get('district'),
          active: fd.get('active') === 'on',
        });
        U().notice('Incentive created');
        e.target.reset();
        render();
      });
      root.querySelectorAll('[data-tog]').forEach((b) => b.addEventListener('click', () => {
        const id = b.getAttribute('data-tog');
        const i = S().listIncentives().find((x) => x.id === id);
        S().toggleIncentive(id, !i.active);
        U().notice(`${i.title} ${!i.active ? 'activated' : 'deactivated'}`);
      }));
    };
    render();
    Router.onStore(() => { if (location.hash.includes('/courier/incentives')) render(); });
  };

  window.Pages.courierPricing = async function courierPricing(root) {
    const render = () => {
      const p = S().getPricing('courier');
      const sampleKm = 10;
      const sampleKg = 2;
      const est = p.parcelBase + sampleKm * p.perKm + sampleKg * p.perKg;
      root.innerHTML = `
        ${hdr('Courier Pricing', ['Courier Panel', 'Pricing'])}
        <form id="cpr-form" class="bg-white rounded-xl border p-6 grid grid-cols-1 md:grid-cols-3 gap-4 max-w-5xl">
          ${Object.entries({
            parcelBase: 'Parcel base ৳', perKm: 'Per km ৳', perKg: 'Per kg ৳',
            expressMultiplier: 'Express ×', priorityMultiplier: 'Priority ×', surgeCap: 'Surge cap ৳',
            platformCommissionPct: 'Platform commission %', weeklyGoalDeliveries: 'Weekly goal deliveries',
            topPerformerMultiplier: 'Top performer ×', withdrawalMin: 'Withdrawal min ৳',
          }).map(([k, label]) => `
            <label class="text-xs font-semibold text-outline">${label}
              <input name="${k}" type="number" step="any" value="${p[k]}" class="mt-1 w-full rounded-lg border-slate-200 text-sm" />
            </label>`).join('')}
          <div class="md:col-span-3 p-4 rounded-xl bg-slate-50 text-sm">
            Live estimate (10 km · 2 kg standard): <strong id="live-est">${U().formatTk(est)}</strong>
          </div>
          <div class="md:col-span-3 flex justify-end gap-2">
            <button type="button" id="disc" class="px-4 py-2 rounded-lg border text-sm font-semibold">Discard</button>
            <button type="submit" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Save parameters</button>
          </div>
        </form>`;
      const form = root.querySelector('#cpr-form');
      const updateEst = () => {
        const base = Number(form.parcelBase.value);
        const perKm = Number(form.perKm.value);
        const perKg = Number(form.perKg.value);
        root.querySelector('#live-est').textContent = U().formatTk(base + 10 * perKm + 2 * perKg);
      };
      form?.querySelectorAll('input').forEach((i) => i.addEventListener('input', updateEst));
      form?.addEventListener('submit', (e) => {
        e.preventDefault();
        const fd = new FormData(e.target);
        const values = {};
        fd.forEach((v, k) => { values[k] = Number(v); });
        S().savePricing('courier', values);
        U().notice('Courier pricing saved');
        render();
      });
      root.querySelector('#disc')?.addEventListener('click', render);
    };
    render();
  };
})();

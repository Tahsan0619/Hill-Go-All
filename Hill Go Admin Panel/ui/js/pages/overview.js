window.Pages = window.Pages || {};

window.Pages.overview = async function overview(root) {
  const S = AppStore;
  const U = UI;
  const k = S.overviewKpis();
  const divs = S.getDivisions();
  const logs = S.getState().activityLog.slice(0, 6);
  const pendingOnb = S.listOnboarding({ status: 'pending' }).length;
  const pendingKyc = S.listRiderKyc().filter((x) => x.status !== 'verified').length;

  root.innerHTML = `
    <div class="mb-8 flex justify-between items-end gap-4 flex-wrap">
      <div>
        <nav class="flex items-center gap-2 text-xs text-outline mb-2">${U.breadcrumb(['HillGo', 'Overview Dashboard'])}</nav>
        <h2 class="text-3xl font-bold text-on-surface tracking-tight">Global Operations Hub</h2>
        <p class="text-sm text-outline mt-1">Live aggregates from the admin store (mock / frontend).</p>
      </div>
      <div class="flex gap-2">
        <button type="button" id="ov-export" class="px-4 py-2 text-sm font-semibold rounded-lg border border-slate-200 bg-white hover:bg-slate-50">Export snapshot CSV</button>
        <a href="#/region" class="px-4 py-2 text-sm font-semibold rounded-lg bg-primary-container text-white hover:bg-primary">Region Lock</a>
      </div>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4 mb-6">
      ${U.kpiCard('Completed revenue (sample)', U.formatTk(k.revenue), 'Rides + food + merchant delivered')}
      ${U.kpiCard('Active trips', k.activeTrips, 'In progress / accepted')}
      ${U.kpiCard('Food orders', k.foodOrders, 'All statuses in store')}
      ${U.kpiCard('Open issues', k.issues, 'Pending KYC + suspended customers')}
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-6">
      <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5 lg:col-span-2">
        <div class="flex items-center justify-between mb-4">
          <h3 class="font-semibold">Service hubs</h3>
          <span class="text-xs text-outline">Click a hub to open panel</span>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <a href="#/customer" class="block p-4 rounded-xl border border-slate-200 hover:border-primary-container hover:bg-blue-50/40 transition">
            <p class="text-xs uppercase tracking-wide text-outline font-semibold">Customer</p>
            <p class="text-2xl font-bold mt-1">${k.customers}</p>
            <p class="text-xs text-outline mt-1">Active customers</p>
          </a>
          <a href="#/rider" class="block p-4 rounded-xl border border-slate-200 hover:border-primary-container hover:bg-blue-50/40 transition">
            <p class="text-xs uppercase tracking-wide text-outline font-semibold">Rider</p>
            <p class="text-2xl font-bold mt-1">${k.riders}</p>
            <p class="text-xs text-outline mt-1">Online now · ${pendingKyc} KYC pending</p>
          </a>
          <a href="#/merchant" class="block p-4 rounded-xl border border-slate-200 hover:border-primary-container hover:bg-blue-50/40 transition">
            <p class="text-xs uppercase tracking-wide text-outline font-semibold">Merchant</p>
            <p class="text-2xl font-bold mt-1">${k.stores}</p>
            <p class="text-xs text-outline mt-1">Active stores · ${pendingOnb} onboarding</p>
          </a>
          <a href="#/courier" class="block p-4 rounded-xl border border-slate-200 hover:border-primary-container hover:bg-blue-50/40 transition">
            <p class="text-xs uppercase tracking-wide text-outline font-semibold">Courier</p>
            <p class="text-2xl font-bold mt-1">${k.parcelsInTransit}</p>
            <p class="text-xs text-outline mt-1">Parcels in pipeline</p>
          </a>
        </div>
      </div>
      <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
        <div class="flex items-center justify-between mb-3">
          <h3 class="font-semibold">Region coverage</h3>
          <a href="#/region" class="text-xs font-semibold text-primary-container">Manage</a>
        </div>
        <p class="text-3xl font-bold">${k.openDistricts}<span class="text-lg text-outline font-medium"> / ${k.totalDistricts}</span></p>
        <p class="text-xs text-outline mb-4">Districts open for registration</p>
        <ul class="space-y-2 max-h-56 overflow-y-auto">
          ${divs.map((d) => `
            <li>
              <a href="#/region/${d.id}" class="flex items-center justify-between text-sm px-2 py-1.5 rounded-lg hover:bg-slate-50">
                <span>${d.name}</span>
                ${U.badge(d.status === 'open' ? 'open' : d.status === 'closed' ? 'closed' : 'partial')}
              </a>
            </li>`).join('')}
        </ul>
      </div>
    </div>

    <div class="bg-white rounded-xl border border-slate-200 shadow-sm">
      <div class="px-5 py-4 border-b border-slate-100 flex justify-between items-center">
        <h3 class="font-semibold">Recent activity</h3>
        <button type="button" id="ov-all-logs" class="text-xs font-semibold text-primary-container">View all</button>
      </div>
      <ul class="divide-y divide-slate-100">
        ${logs.map((l) => `
          <li class="px-5 py-3 flex justify-between gap-4 text-sm">
            <div>
              <p class="text-on-surface">${l.text}</p>
              <p class="text-xs text-outline mt-0.5">${l.by}</p>
            </div>
            <span class="text-xs text-outline whitespace-nowrap">${U.formatDate(l.at)}</span>
          </li>`).join('') || '<li class="px-5 py-6 text-sm text-outline">No activity yet</li>'}
      </ul>
    </div>

    ${HillGoMaps.mapShell({
      id: 'map-overview',
      title: 'Live Operational Map',
      liveLabel: `${k.riders} online riders · ${k.stores} stores`,
      height: '400px',
      sideHtml: `
        <div class="bg-white rounded-xl border border-slate-200 shadow-sm h-full flex flex-col">
          <div class="p-4 border-b border-slate-100 flex justify-between items-center">
            <h4 class="text-sm font-semibold">Map legend</h4>
            <a href="#/rider/map" class="text-xs font-semibold text-primary-container">Full live map</a>
          </div>
          <ul class="p-4 space-y-3 text-sm flex-1">
            <li class="flex items-center gap-2"><span class="w-3 h-3 rounded-full bg-emerald-500"></span> Online riders</li>
            <li class="flex items-center gap-2"><span class="w-3 h-3 rounded-full bg-primary-container"></span> Active trips</li>
            <li class="flex items-center gap-2"><span class="w-3 h-3 rounded-full bg-amber-500"></span> Food / merchant orders</li>
            <li class="flex items-center gap-2"><span class="w-3 h-3 rounded-full bg-blue-700"></span> Courier agents</li>
          </ul>
          <div class="p-4 border-t text-xs text-outline">Click markers for details. Zoom controls on the map.</div>
        </div>`,
    })}`;

  const riderMarks = HillGoMaps.markersFromRiders(S.listRiders().filter((r) => r.online));
  const tripMarks = HillGoMaps.markersFromTrips(S.listTrips().filter((t) => ['in_progress', 'accepted'].includes(t.status)));
  const agentMarks = HillGoMaps.markersFromAgents(S.listAgents().filter((a) => a.online));
  HillGoMaps.mount('map-overview', {
    height: '400px',
    zoom: 12,
    markers: [...riderMarks, ...tripMarks, ...agentMarks],
    circles: [
      { ...HillGoMaps.HUBS.gulshan, radius: 1800, color: '#0047ab' },
      { ...HillGoMaps.HUBS.dhanmondi, radius: 1400, color: '#10B981' },
    ],
  });

  root.querySelector('#ov-export')?.addEventListener('click', () => {
    U.downloadCsv('hillgo-overview-snapshot.csv', [
      { metric: 'revenue', value: k.revenue },
      { metric: 'activeTrips', value: k.activeTrips },
      { metric: 'customers', value: k.customers },
      { metric: 'onlineRiders', value: k.riders },
      { metric: 'stores', value: k.stores },
      { metric: 'openDistricts', value: k.openDistricts },
    ]);
  });

  root.querySelector('#ov-all-logs')?.addEventListener('click', () => {
    const all = S.getState().activityLog;
    U.openModal({
      title: 'Activity log',
      width: 'max-w-2xl',
      bodyHtml: `<ul class="divide-y divide-slate-100 max-h-96 overflow-y-auto">${all.map((l) => `
        <li class="py-2 text-sm"><p>${l.text}</p><p class="text-xs text-outline">${l.by} · ${U.formatDate(l.at)}</p></li>`).join('')}</ul>`,
      footerHtml: `<button type="button" id="close-logs" class="px-4 py-2 text-sm font-semibold rounded-lg bg-primary-container text-white">Close</button>`,
    });
    document.getElementById('close-logs')?.addEventListener('click', () => U.closeModal());
  });
};

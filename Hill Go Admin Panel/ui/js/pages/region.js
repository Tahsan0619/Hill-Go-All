window.Pages = window.Pages || {};

(function regionPages() {
  const S = () => AppStore;
  const U = () => UI;
  const esc = (s) => U().escapeHtml(s);

  function openDistrictEditor(districtId, onSaved) {
    const d = S().getDistrict(districtId);
    if (!d) return;
    U().openModal({
      title: `Edit district — ${d.name}`,
      width: 'max-w-xl',
      bodyHtml: `
        <div class="space-y-4 text-sm">
          <div class="grid grid-cols-2 gap-3">
            <div><p class="text-xs text-outline mb-1">Division</p><p class="font-semibold">${esc(d.divisionName)}</p></div>
            <div><p class="text-xs text-outline mb-1">District</p><p class="font-semibold">${esc(d.name)}</p></div>
          </div>
          <label class="block"><span class="text-xs font-semibold text-outline">Status</span>
            <select id="de-status" class="mt-1 w-full rounded-lg border-slate-200 text-sm">
              <option value="open" ${d.status === 'open' ? 'selected' : ''}>Open</option>
              <option value="closed" ${d.status === 'closed' ? 'selected' : ''}>Closed</option>
            </select>
          </label>
          <label class="block"><span class="text-xs font-semibold text-outline">Opened at</span>
            <input id="de-opened" type="datetime-local" class="mt-1 w-full rounded-lg border-slate-200 text-sm" value="${esc((d.openedAt || '').slice(0, 16))}" />
          </label>
          <fieldset class="space-y-2">
            <legend class="text-xs font-semibold text-outline mb-1">Allow registration</legend>
            ${['Customer', 'Rider', 'Merchant', 'Courier'].map((app) => {
              const key = `allow${app}`;
              return `<label class="flex items-center gap-2"><input type="checkbox" id="de-${key}" class="rounded border-slate-300 text-primary-container" ${d[key] ? 'checked' : ''}/><span>${app}</span></label>`;
            }).join('')}
          </fieldset>
          <label class="block"><span class="text-xs font-semibold text-outline">Internal note</span>
            <textarea id="de-note" rows="3" class="mt-1 w-full rounded-lg border-slate-200 text-sm">${esc(d.note || '')}</textarea>
          </label>
        </div>`,
      footerHtml: `
        <button type="button" id="de-cancel" class="px-4 py-2 text-sm font-semibold rounded-lg hover:bg-slate-100">Cancel</button>
        <button type="button" id="de-save" class="px-4 py-2 text-sm font-semibold rounded-lg bg-primary-container text-white">Save changes</button>`,
    });
    document.getElementById('de-cancel')?.addEventListener('click', () => U().closeModal());
    document.getElementById('de-save')?.addEventListener('click', () => {
      const status = document.getElementById('de-status').value;
      S().updateDistrict(districtId, {
        status,
        openedAt: document.getElementById('de-opened').value || null,
        allowCustomer: document.getElementById('de-allowCustomer').checked,
        allowRider: document.getElementById('de-allowRider').checked,
        allowMerchant: document.getElementById('de-allowMerchant').checked,
        allowCourier: document.getElementById('de-allowCourier').checked,
        note: document.getElementById('de-note').value.trim(),
      });
      U().closeModal();
      U().notice(`${d.name} saved as ${status}`);
      onSaved?.();
    });
  }

  window.Pages.regionOverview = async function regionOverview(root) {
    const render = () => {
      const divs = S().getDivisions();
      const open = divs.reduce((s, d) => s + d.open, 0);
      const total = divs.reduce((s, d) => s + d.total, 0);
      root.innerHTML = `
        <div class="mb-6 flex justify-between items-end flex-wrap gap-3">
          <div>
            <nav class="flex items-center gap-2 text-xs text-outline mb-2">${U().breadcrumb(['HillGo', 'Region Lock'])}</nav>
            <h2 class="text-3xl font-bold">Region Lock</h2>
            <p class="text-sm text-outline mt-1">Open a district to allow registration for that area.</p>
          </div>
          <button type="button" id="rl-export" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">Export districts CSV</button>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
          ${U().kpiCard('Divisions', '8', `${divs.filter((d) => d.status === 'open').length} fully open`)}
          ${U().kpiCard('Districts open', `${open} / ${total}`, '')}
          ${U().kpiCard('Districts closed', String(total - open), '')}
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
          ${divs.map((d) => `
            <a href="#/region/${d.id}" class="block bg-white rounded-xl border border-slate-200 shadow-sm p-5 hover:border-primary-container transition">
              <div class="flex justify-between items-start mb-3">
                <div>
                  <h3 class="font-semibold text-lg">${esc(d.name)}</h3>
                  <p class="text-xs text-outline">${esc(d.zone)}</p>
                </div>
                ${U().badge(d.status === 'open' ? 'open' : d.status === 'closed' ? 'closed' : 'partial')}
              </div>
              <div class="h-2 bg-slate-100 rounded-full overflow-hidden mb-2">
                <div class="h-full bg-primary-container" style="width:${Math.round((d.open / d.total) * 100)}%"></div>
              </div>
              <p class="text-sm text-outline">${d.open} / ${d.total} districts open</p>
            </a>`).join('')}
        </div>
        ${HillGoMaps.mapShell({
          id: 'map-region',
          title: 'Coverage map',
          liveLabel: `${open} districts open`,
          height: '380px',
          sideHtml: `
            <div class="bg-white rounded-xl border p-5 h-full">
              <h4 class="font-semibold mb-3">Division centers</h4>
              <ul class="space-y-2 text-sm">
                ${divs.map((d) => `<li class="flex justify-between"><a class="text-primary-container font-medium" href="#/region/${d.id}">${esc(d.name)}</a>${U().badge(d.status === 'open' ? 'open' : d.status === 'closed' ? 'closed' : 'partial')}</li>`).join('')}
              </ul>
              <p class="text-xs text-outline mt-4">Green = open district · Red = closed. Click a division card to manage toggles.</p>
            </div>`,
        })}`;
      root.querySelector('#rl-export')?.addEventListener('click', () => {
        U().downloadCsv('region-districts.csv', S().getState().regionDistricts.map((d) => ({
          division: d.divisionName, district: d.name, status: d.status,
          customer: d.allowCustomer, rider: d.allowRider, merchant: d.allowMerchant, courier: d.allowCourier, note: d.note,
        })));
      });
      const openDistricts = S().getState().regionDistricts.filter((d) => d.status === 'open');
      const closedDistricts = S().getState().regionDistricts.filter((d) => d.status === 'closed');
      HillGoMaps.mount('map-region', {
        center: [23.6, 90.3],
        zoom: 7,
        height: '380px',
        markers: [
          ...HillGoMaps.markersFromDistricts(openDistricts.slice(0, 40)),
          ...HillGoMaps.markersFromDistricts(closedDistricts.slice(0, 24)).map((m) => ({ ...m, color: '#EF4444' })),
        ],
        fit: true,
      });
    };
    render();
    Router.onStore(() => { if (location.hash === '#/region') render(); });
  };

  window.Pages.regionDivision = async function regionDivision(root, params) {
    const divisionId = params.divisionId;
    let page = 1;

    const render = () => {
      const div = S().getDivisions().find((d) => d.id === divisionId);
      if (!div) {
        root.innerHTML = `<p class="p-8">Division not found. <a class="text-primary-container underline" href="#/region">Back</a></p>`;
        return;
      }
      const districts = S().getDistrictsByDivision(divisionId);
      const pg = U().paginate(districts, page, 10);
      page = pg.page;
      const logs = S().getState().activityLog.filter((l) => l.text.includes(div.name) || districts.some((d) => l.text.includes(d.name))).slice(0, 8);

      root.innerHTML = `
        <div class="mb-6 flex justify-between items-end flex-wrap gap-3">
          <div>
            <nav class="flex items-center gap-2 text-xs text-outline mb-2">${U().breadcrumb(['Region Lock', div.name])}</nav>
            <h2 class="text-3xl font-bold">${esc(div.name)} Division</h2>
            <p class="text-sm text-outline mt-1">${div.open} open · ${div.closed} closed · ${esc(div.zone)}</p>
          </div>
          <div class="flex gap-2">
            <a href="#/region" class="px-4 py-2 text-sm font-semibold rounded-lg border bg-white">All divisions</a>
            <button type="button" data-bulk="open" class="px-4 py-2 text-sm font-semibold rounded-lg bg-emerald-600 text-white">Open all</button>
            <button type="button" data-bulk="closed" class="px-4 py-2 text-sm font-semibold rounded-lg bg-error text-white">Close all</button>
          </div>
        </div>
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
          <div class="lg:col-span-2 bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
            <table class="w-full text-sm">
              <thead class="bg-slate-50 text-left text-xs uppercase tracking-wide text-outline">
                <tr>
                  <th class="px-4 py-3">District</th>
                  <th class="px-4 py-3">Status</th>
                  <th class="px-4 py-3">Apps</th>
                  <th class="px-4 py-3">Updated</th>
                  <th class="px-4 py-3"></th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-100">
                ${pg.rows.map((d) => `
                  <tr class="hover:bg-slate-50/80">
                    <td class="px-4 py-3 font-medium">${esc(d.name)}</td>
                    <td class="px-4 py-3">
                      <button type="button" data-toggle="${d.id}" class="focus:outline-none">${U().badge(d.status)}</button>
                    </td>
                    <td class="px-4 py-3 text-xs text-outline">
                      ${[['C', d.allowCustomer], ['R', d.allowRider], ['M', d.allowMerchant], ['K', d.allowCourier]].map(([l, on]) =>
                        `<span class="inline-block w-5 h-5 leading-5 text-center rounded ${on ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-400'} mr-0.5">${l}</span>`).join('')}
                    </td>
                    <td class="px-4 py-3 text-xs text-outline">${U().formatDate(d.updatedAt)}</td>
                    <td class="px-4 py-3 text-right">
                      <button type="button" data-edit="${d.id}" class="text-primary-container font-semibold text-xs">Edit</button>
                    </td>
                  </tr>`).join('')}
              </tbody>
            </table>
            ${U().pagerHtml(pg.page, pg.pages, pg.total)}
          </div>
          <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
            <h3 class="font-semibold mb-3">Activity</h3>
            <ul class="space-y-3 text-sm">
              ${logs.map((l) => `<li><p>${esc(l.text)}</p><p class="text-xs text-outline">${U().formatDate(l.at)}</p></li>`).join('') || '<li class="text-outline">No related logs</li>'}
            </ul>
          </div>
        </div>
        <div class="mt-4">
          ${HillGoMaps.mapShell({
            id: 'map-division',
            title: `${div.name} district map`,
            liveLabel: `${div.open} open / ${div.closed} closed`,
            height: '320px',
          })}
        </div>`;

      root.querySelectorAll('[data-bulk]').forEach((btn) => {
        btn.addEventListener('click', async () => {
          const status = btn.getAttribute('data-bulk');
          const ok = await U().confirmDialog({
            title: `${status === 'open' ? 'Open' : 'Close'} all districts`,
            message: `Set every district in ${div.name} to ${status}?`,
            confirmLabel: status === 'open' ? 'Open all' : 'Close all',
            danger: status === 'closed',
          });
          if (!ok) return;
          S().setAllDistrictsInDivision(divisionId, status);
          U().notice(`${div.name}: all districts ${status}`);
        });
      });

      root.querySelectorAll('[data-toggle]').forEach((btn) => {
        btn.addEventListener('click', () => {
          const id = btn.getAttribute('data-toggle');
          const d = S().getDistrict(id);
          const next = d.status === 'open' ? 'closed' : 'open';
          S().updateDistrict(id, {
            status: next,
            allowCustomer: next === 'open',
            allowRider: next === 'open',
            allowMerchant: next === 'open',
            allowCourier: next === 'open',
          });
          U().notice(`${d.name} → ${next}`);
        });
      });

      root.querySelectorAll('[data-edit]').forEach((btn) => {
        btn.addEventListener('click', () => openDistrictEditor(btn.getAttribute('data-edit'), render));
      });

      root.querySelector('[data-page-btn="prev"]')?.addEventListener('click', () => { page -= 1; render(); });
      root.querySelector('[data-page-btn="next"]')?.addEventListener('click', () => { page += 1; render(); });

      const center = HillGoMaps.DIVISION_CENTERS[divisionId] || HillGoMaps.DHAKA;
      HillGoMaps.mount('map-division', {
        center,
        zoom: divisionId === 'dhaka' ? 10 : 9,
        height: '320px',
        markers: HillGoMaps.markersFromDistricts(districts),
      });
    };

    render();
    Router.onStore(() => {
      if (location.hash === `#/region/${divisionId}`) render();
    });
  };
})();

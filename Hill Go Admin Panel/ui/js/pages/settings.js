window.Pages = window.Pages || {};

window.Pages.settings = async function settings(root) {
  const S = AppStore;
  const U = UI;
  const render = () => {
    const s = S.getSettings();
    root.innerHTML = `
      <div class="mb-6">
        <nav class="flex items-center gap-2 text-xs text-outline mb-2">${U.breadcrumb(['HillGo', 'Settings'])}</nav>
        <h2 class="text-3xl font-bold">System Settings</h2>
        <p class="text-sm text-outline mt-1">Stored on the HillGo backend and applied across all apps.</p>
      </div>
      <form id="settings-form" class="bg-white rounded-xl border shadow-sm p-6 max-w-xl space-y-4">
        <label class="block text-xs font-semibold text-outline">Organization name
          <input name="orgName" value="${s.orgName}" required class="mt-1 w-full rounded-lg border-slate-200 text-sm" />
        </label>
        <label class="block text-xs font-semibold text-outline">Admin email
          <input name="orgEmail" type="email" value="${s.orgEmail}" required class="mt-1 w-full rounded-lg border-slate-200 text-sm" />
        </label>
        <label class="block text-xs font-semibold text-outline">Timezone
          <select name="timezone" class="mt-1 w-full rounded-lg border-slate-200 text-sm">
            ${['Asia/Dhaka', 'UTC', 'Asia/Kolkata'].map((t) => `<option value="${t}" ${s.timezone === t ? 'selected' : ''}>${t}</option>`).join('')}
          </select>
        </label>
        <label class="flex items-center gap-2 text-sm"><input type="checkbox" name="twoFactor" ${s.twoFactor ? 'checked' : ''} class="rounded border-slate-300 text-primary-container" /> Require 2FA for admins</label>
        <label class="flex items-center gap-2 text-sm"><input type="checkbox" name="emailAlerts" ${s.emailAlerts ? 'checked' : ''} class="rounded border-slate-300 text-primary-container" /> Email alerts</label>
        <label class="flex items-center gap-2 text-sm"><input type="checkbox" name="smsAlerts" ${s.smsAlerts ? 'checked' : ''} class="rounded border-slate-300 text-primary-container" /> SMS alerts</label>
        <div class="flex justify-end gap-2 pt-2">
          <button type="button" id="reset-store" class="px-4 py-2 rounded-lg border border-slate-200 text-sm font-semibold">Reload from server</button>
          <button type="submit" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Save settings</button>
        </div>
      </form>`;
    root.querySelector('#settings-form')?.addEventListener('submit', (e) => {
      e.preventDefault();
      const fd = new FormData(e.target);
      S.saveSettings({
        orgName: fd.get('orgName'),
        orgEmail: fd.get('orgEmail'),
        timezone: fd.get('timezone'),
        twoFactor: fd.get('twoFactor') === 'on',
        emailAlerts: fd.get('emailAlerts') === 'on',
        smsAlerts: fd.get('smsAlerts') === 'on',
      });
      U.notice('Settings saved');
      render();
    });
    root.querySelector('#reset-store')?.addEventListener('click', async () => {
      const ok = await U.confirmDialog({
        title: 'Reload data',
        message: 'Refetch all data from the backend?',
        confirmLabel: 'Reload',
      });
      if (!ok) return;
      S.resetData();
      Router.go('/overview');
    });
  };
  render();
};

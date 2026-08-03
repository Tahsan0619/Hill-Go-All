/**
 * Boot: authenticate against the Laravel API, hydrate the store,
 * register routes, wire chrome, start router.
 */
(function boot() {
  const R = Router;
  const P = Pages;

  R.register('/overview', P.overview);
  R.register('/region', P.regionOverview);
  R.register('/region/:divisionId', P.regionDivision);

  R.register('/customer', P.customerDashboard);
  R.register('/customer/customers', P.customerList);
  R.register('/customer/rides', P.customerRides);
  R.register('/customer/food', P.customerFood);
  R.register('/customer/parcels', P.customerParcels);
  R.register('/customer/pricing', P.customerPricing);

  R.register('/rider', P.riderDashboard);
  R.register('/rider/riders', P.riderList);
  R.register('/rider/kyc', P.riderKyc);
  R.register('/rider/trips', P.riderTrips);
  R.register('/rider/map', P.riderLiveMap);
  R.register('/rider/pay', P.riderPay);
  R.register('/rider/payouts', P.riderPayouts);
  R.register('/rider/pricing', P.riderPricing);

  R.register('/merchant', P.merchantDashboard);
  R.register('/merchant/stores', P.merchantStores);
  R.register('/merchant/onboarding', P.merchantOnboarding);
  R.register('/merchant/orders', P.merchantOrders);
  R.register('/merchant/payouts', P.merchantPayouts);
  R.register('/merchant/pricing', P.merchantPricing);

  R.register('/courier', P.courierDashboard);
  R.register('/courier/agents', P.courierAgents);
  R.register('/courier/kyc', P.courierKyc);
  R.register('/courier/parcels', P.courierParcels);
  R.register('/courier/withdrawals', P.courierWithdrawals);
  R.register('/courier/incentives', P.courierIncentives);
  R.register('/courier/pricing', P.courierPricing);

  R.register('/settings', P.settings);

  // —— Login screen ——

  function showLogin() {
    let overlay = document.getElementById('login-overlay');
    if (overlay) { overlay.classList.remove('hidden'); return; }

    overlay = document.createElement('div');
    overlay.id = 'login-overlay';
    overlay.className = 'fixed inset-0 z-[100] bg-on-primary-fixed flex items-center justify-center p-4';
    overlay.innerHTML = `
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-sm p-8">
        <div class="flex items-center gap-3 mb-6">
          <div class="w-10 h-10 bg-primary-container rounded-lg flex items-center justify-center text-white">
            <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 1;">mountain_flag</span>
          </div>
          <div>
            <h1 class="text-xl font-bold leading-none">HillGo</h1>
            <p class="text-[10px] text-outline uppercase tracking-widest mt-1">Super Admin</p>
          </div>
        </div>
        <form id="login-form" class="space-y-4">
          <label class="block text-xs font-semibold text-outline">Email
            <input name="email" type="email" required autocomplete="username"
              class="mt-1 w-full rounded-lg border-slate-200 text-sm" placeholder="admin@hillgo.app" />
          </label>
          <label class="block text-xs font-semibold text-outline">Password
            <input name="password" type="password" required autocomplete="current-password"
              class="mt-1 w-full rounded-lg border-slate-200 text-sm" placeholder="••••••••" />
          </label>
          <p id="login-error" class="hidden text-xs text-error font-medium"></p>
          <button type="submit" id="login-submit"
            class="w-full px-4 py-2.5 rounded-lg bg-primary-container text-white text-sm font-semibold">Sign in</button>
        </form>
      </div>`;
    document.body.appendChild(overlay);

    overlay.querySelector('#login-form').addEventListener('submit', async (e) => {
      e.preventDefault();
      const fd = new FormData(e.target);
      const btn = overlay.querySelector('#login-submit');
      const err = overlay.querySelector('#login-error');
      btn.disabled = true;
      btn.textContent = 'Signing in…';
      err.classList.add('hidden');
      try {
        await AppStore.login(fd.get('email'), fd.get('password'));
        overlay.remove();
        await startApp();
      } catch (ex) {
        err.textContent = ex.message || 'Login failed';
        err.classList.remove('hidden');
      } finally {
        btn.disabled = false;
        btn.textContent = 'Sign in';
      }
    });
  }

  async function startApp() {
    const content = document.getElementById('app-content');
    content.innerHTML = `
      <div class="h-full flex items-center justify-center">
        <div class="text-center">
          <div class="w-10 h-10 border-4 border-primary-container border-t-transparent rounded-full animate-spin mx-auto mb-3"></div>
          <p class="text-sm text-outline">Loading live data…</p>
        </div>
      </div>`;
    try {
      await AppStore.init();
    } catch (e) {
      content.innerHTML = `<div class="h-full flex items-center justify-center text-sm text-error">${UI.escapeHtml(e.message || 'Failed to load data from the API.')}</div>`;
      return;
    }
    const user = AppStore.currentUser();
    if (!user || (user.role && user.role !== 'admin')) {
      UI.notice('This panel requires an admin account.', 'error');
      await AppStore.logout();
      showLogin();
      return;
    }
    if (user) {
      const nameEl = document.getElementById('admin-name');
      if (nameEl) nameEl.textContent = user.name;
      const avatarEl = document.getElementById('admin-avatar');
      if (avatarEl) avatarEl.textContent = (user.name || 'A').split(' ').map((w) => w[0]).slice(0, 2).join('').toUpperCase();
      // Client role gate: non-admin roles never see the shell (server still enforces).
      document.getElementById('sidebar-nav')?.setAttribute('data-role', user.role || 'admin');
    }
    Router.start();
  }

  window.addEventListener('hillgo:unauthenticated', () => showLogin());

  window.addEventListener('error', (e) => {
    window.HillGoTelemetry?.captureError(e.error || e.message, { source: 'window.onerror' });
  });
  window.addEventListener('unhandledrejection', (e) => {
    window.HillGoTelemetry?.captureError(e.reason, { source: 'unhandledrejection' });
  });

  // Partial mitigation for sessionStorage token risk (see
  // docs/remediation/REMEDIATION_ADMIN_PANEL.md #5): if the tab sits hidden for a long
  // idle stretch, sign the admin out so a token left in a backgrounded
  // tab doesn't stay live indefinitely. Cancelled the moment the tab is
  // visible again — never fires while the admin is actively using it.
  const HIDDEN_IDLE_LOGOUT_MS = 15 * 60 * 1000;
  let hiddenIdleTimer = null;
  document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
      hiddenIdleTimer = setTimeout(() => {
        if (document.hidden && AppStore.isAuthed()) {
          AppStore.logout().then(() => showLogin());
        }
      }, HIDDEN_IDLE_LOGOUT_MS);
    } else if (hiddenIdleTimer) {
      clearTimeout(hiddenIdleTimer);
      hiddenIdleTimer = null;
    }
  });

  document.addEventListener('DOMContentLoaded', () => {
    UI.bindShellChrome();

    // Sidebar accordion groups
    document.querySelectorAll('.nav-group > button').forEach((btn) => {
      btn.addEventListener('click', () => {
        const group = btn.parentElement;
        const wasOpen = group.classList.contains('open');
        document.querySelectorAll('.nav-group').forEach((g) => g.classList.remove('open'));
        if (!wasOpen) group.classList.add('open');
      });
    });

    // Global search → jump to customer directory with query
    const search = document.getElementById('global-search');
    search?.addEventListener('keydown', (e) => {
      if (e.key !== 'Enter') return;
      const q = search.value.trim();
      if (!q) return;
      location.hash = `#/customer/customers`;
      sessionStorage.setItem('hillgo-search', q);
      UI.notice(`Searching customers for “${q}”`, 'info');
      setTimeout(() => {
        const input = document.querySelector('#cu-q');
        if (input) {
          input.value = q;
          document.getElementById('cu-apply')?.click();
        }
        sessionStorage.removeItem('hillgo-search');
      }, 50);
    });

    document.getElementById('btn-notifications')?.addEventListener('click', () => {
      const logs = AppStore.getState().activityLog.slice(0, 20);
      const esc = UI.escapeHtml;
      UI.openModal({
        title: 'Notifications / activity',
        width: 'max-w-xl',
        bodyHtml: `<ul class="divide-y max-h-96 overflow-y-auto text-sm">${logs.map((l) => `
          <li class="py-2"><p>${esc(l.text)}</p><p class="text-xs text-outline">${esc(l.by)} · ${UI.formatDate(l.at)}</p></li>`).join('') || '<li class="py-4 text-center text-outline">No activity yet</li>'}</ul>`,
        footerHtml: `<button type="button" id="n-close" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Close</button>`,
      });
      document.getElementById('n-close')?.addEventListener('click', () => UI.closeModal());
    });

    document.getElementById('btn-logout')?.addEventListener('click', async () => {
      const ok = await UI.confirmDialog({
        title: 'Sign out',
        message: 'End this admin session?',
        confirmLabel: 'Sign out',
      });
      if (!ok) return;
      await AppStore.logout();
      location.reload();
    });

    if (AppStore.isAuthed()) startApp();
    else showLogin();
  });
})();

/**
 * Boot: register routes, wire chrome, start router.
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
      // Apply after navigation by storing hint
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
      UI.openModal({
        title: 'Notifications / activity',
        width: 'max-w-xl',
        bodyHtml: `<ul class="divide-y max-h-96 overflow-y-auto text-sm">${logs.map((l) => `
          <li class="py-2"><p>${l.text}</p><p class="text-xs text-outline">${l.by} · ${UI.formatDate(l.at)}</p></li>`).join('')}</ul>`,
        footerHtml: `<button type="button" id="n-close" class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold">Close</button>`,
      });
      document.getElementById('n-close')?.addEventListener('click', () => UI.closeModal());
    });

    document.getElementById('btn-reset-data')?.addEventListener('click', async () => {
      const ok = await UI.confirmDialog({
        title: 'Reset mock data',
        message: 'Restore original seed data and clear local changes?',
        danger: true,
        confirmLabel: 'Reset',
      });
      if (!ok) return;
      AppStore.resetData();
      UI.notice('Mock data restored');
      Router.go('/overview');
    });

    Router.start();
  });
})();

(function () {
  'use strict';

  let currentPage = 'overview';
  let currentUserTab = 'customers';
  let currentContentTab = 'products';
  let revenueChart = null;
  let funnelChart = null;
  let forecastChart = null;
  let fleetMap = null;
  let trackingMap = null;
  let filteredUsers = [...HillGoData.users];

  const $ = (sel) => document.querySelector(sel);
  const $$ = (sel) => document.querySelectorAll(sel);

  // ── Init ──
  document.addEventListener('DOMContentLoaded', init);

  function init() {
    setupNavigation();
    setupTabs();
    setupFilters();
    setupButtons();
    setupModal();
    setupMobileToggle();
    renderAlerts();
    renderUsers();
    renderFleet();
    renderTransactions();
    renderClusters();
    renderHealthBars();
    renderProducts();
    renderPagination('usersPagination', 1, 5);
    renderPagination('txnPagination', 1, 3);
    renderPagination('productPagination', 1, 5, true);
    initCharts();
    initMaps();
  }

  // ── Navigation ──
  function setupNavigation() {
    $$('.nav-item').forEach((item) => {
      item.addEventListener('click', (e) => {
        e.preventDefault();
        const page = item.dataset.page;
        navigateTo(page);
        $('#sidebar').classList.remove('open');
      });
    });
  }

  function navigateTo(page) {
    currentPage = page;
    $$('.nav-item').forEach((n) => n.classList.toggle('active', n.dataset.page === page));
    $$('.page').forEach((p) => p.classList.toggle('active', p.id === `page-${page}`));

    const placeholder = HillGoData.searchPlaceholders[page] || 'Search...';
    $('#globalSearch').placeholder = placeholder;

    const role = HillGoData.userRoles[page] || 'System Manager';
    $('#userRole').textContent = role;

    if (page === 'overview' && fleetMap) setTimeout(() => fleetMap.invalidateSize(), 100);
    if (page === 'fleet' && trackingMap) setTimeout(() => trackingMap.invalidateSize(), 100);
  }

  // ── Tabs ──
  function setupTabs() {
    $('#userTabs').addEventListener('click', (e) => {
      const tab = e.target.closest('.tab');
      if (!tab) return;
      $$('#userTabs .tab').forEach((t) => t.classList.remove('active'));
      tab.classList.add('active');
      currentUserTab = tab.dataset.tab;
      filterUsers();
    });

    $('#contentTabs').addEventListener('click', (e) => {
      const tab = e.target.closest('.tab');
      if (!tab) return;
      $$('#contentTabs .tab').forEach((t) => t.classList.remove('active'));
      tab.classList.add('active');
      currentContentTab = tab.dataset.tab;
      renderProducts();
      showToast(`Switched to ${tab.textContent}`);
    });
  }

  // ── Filters ──
  function setupFilters() {
    $('#globalSearch').addEventListener('input', debounce(handleSearch, 250));
    $('#userStatusFilter').addEventListener('change', filterUsers);
    $('#userDateFilter').addEventListener('change', filterUsers);

    $('#revenueFilters').addEventListener('click', (e) => {
      const pill = e.target.closest('.pill');
      if (!pill) return;
      $$('#revenueFilters .pill').forEach((p) => p.classList.remove('active'));
      pill.classList.add('active');
      updateRevenueChart(pill.dataset.filter);
    });

    $('#selectAllUsers').addEventListener('change', (e) => {
      $$('#usersTable tbody input[type="checkbox"]').forEach((cb) => {
        cb.checked = e.target.checked;
      });
    });
  }

  function handleSearch() {
    const query = $('#globalSearch').value.toLowerCase().trim();
    if (currentPage === 'users') {
      filterUsers(query);
    } else if (currentPage === 'finance') {
      filterTransactions(query);
    } else if (currentPage === 'content') {
      filterProducts(query);
    } else {
      showToast(query ? `Searching for "${query}"...` : 'Search cleared');
    }
  }

  function filterUsers(query) {
    const status = $('#userStatusFilter').value;
    const dateOrder = $('#userDateFilter').value;
    const q = query !== undefined ? query : $('#globalSearch').value.toLowerCase().trim();

    filteredUsers = HillGoData.users.filter((u) => {
      const matchTab = currentUserTab === 'customers' ? u.type === 'customer' : u.type === 'partner';
      const matchStatus = status === 'all' || u.status === status;
      const matchSearch = !q || u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q);
      return matchTab && matchStatus && matchSearch;
    });

    if (dateOrder === 'oldest') {
      filteredUsers = [...filteredUsers].reverse();
    }

    renderUsers();
  }

  function filterTransactions(query) {
    const q = query.toLowerCase();
    const tbody = $('#transactionsTable tbody');
    const rows = HillGoData.transactions.filter((t) =>
      !q || t.id.toLowerCase().includes(q) || t.service.toLowerCase().includes(q)
    );
    tbody.innerHTML = rows.map(renderTransactionRow).join('');
  }

  function filterProducts(query) {
    const q = query.toLowerCase();
    const grid = $('#productGrid');
    const items = HillGoData.products.filter((p) =>
      !q || p.title.toLowerCase().includes(q) || p.sku.toLowerCase().includes(q)
    );
    grid.innerHTML = items.map(renderProductCard).join('');
  }

  // ── Render Tables ──
  function renderAlerts() {
    const tbody = $('#alertsTable tbody');
    tbody.innerHTML = HillGoData.alerts.map((a) => `
      <tr>
        <td><span class="alert-type ${a.type}"><i class="fa-solid ${a.icon}"></i> ${a.label}</span></td>
        <td>${a.description}</td>
        <td><span class="status-tag ${a.statusClass}">${a.status}</span></td>
        <td style="color:var(--text-muted);font-size:0.8rem">${a.time}</td>
      </tr>
    `).join('');
  }

  function renderUsers() {
    const tbody = $('#usersTable tbody');
    const users = filteredUsers.slice(0, 6);
    tbody.innerHTML = users.map((u) => `
      <tr>
        <td><input type="checkbox" data-id="${u.id}"></td>
        <td>
          <div class="user-cell">
            <div class="user-avatar" style="background:${u.color}">
              ${u.avatar ? `<img src="${u.avatar}" alt="">` : u.name.split(' ').map(n => n[0]).join('')}
            </div>
            <div>
              <div class="user-name">${u.name}</div>
              <div class="user-email">${u.email}</div>
            </div>
          </div>
        </td>
        <td><span class="tag ${u.type}">${u.type.charAt(0).toUpperCase() + u.type.slice(1)}</span></td>
        <td><span class="status-badge ${u.status}">${u.status.charAt(0).toUpperCase() + u.status.slice(1)}</span></td>
        <td>${u.joined}</td>
        <td>
          <div class="action-btns">
            <button class="action-btn" data-action="view-user" data-id="${u.id}" title="View"><i class="fa-solid fa-eye"></i></button>
            <button class="action-btn" data-action="edit-user" data-id="${u.id}" title="Edit"><i class="fa-solid fa-pen"></i></button>
          </div>
        </td>
      </tr>
    `).join('');

    const count = filteredUsers.length;
    $('#usersPaginationInfo').textContent = `Showing 1-${Math.min(6, count)} of ${count.toLocaleString()} users`;

    tbody.querySelectorAll('[data-action]').forEach((btn) => {
      btn.addEventListener('click', () => handleUserAction(btn.dataset.action, +btn.dataset.id));
    });
  }

  function renderFleet() {
    const tbody = $('#fleetTable tbody');
    tbody.innerHTML = HillGoData.fleet.map((v) => `
      <tr>
        <td><strong>${v.id}</strong></td>
        <td>
          <div class="vehicle-cell">
            <div class="vehicle-icon"><i class="fa-solid ${v.icon}"></i></div>
            <span>${v.type}</span>
          </div>
        </td>
        <td>${v.partner}</td>
        <td>${v.date}</td>
        <td><span class="status-tag pending-review">${v.status}</span></td>
        <td>
          <div class="action-btns">
            <button class="action-btn" data-action="approve-fleet" data-id="${v.id}" title="Approve"><i class="fa-solid fa-check"></i></button>
            <button class="action-btn" data-action="reject-fleet" data-id="${v.id}" title="Reject"><i class="fa-solid fa-xmark"></i></button>
          </div>
        </td>
      </tr>
    `).join('');

    tbody.querySelectorAll('[data-action]').forEach((btn) => {
      btn.addEventListener('click', () => handleFleetAction(btn.dataset.action, btn.dataset.id));
    });
  }

  function renderTransactions() {
    const tbody = $('#transactionsTable tbody');
    tbody.innerHTML = HillGoData.transactions.map(renderTransactionRow).join('');

    tbody.querySelectorAll('.txn-id').forEach((el) => {
      el.addEventListener('click', () => {
        const id = el.textContent;
        const txn = HillGoData.transactions.find((t) => t.id === id);
        if (txn) showTransactionDetail(txn);
      });
    });
  }

  function renderTransactionRow(t) {
    return `
      <tr>
        <td><span class="txn-id">${t.id}</span></td>
        <td>
          <div class="service-cell">
            <div class="service-icon ${t.serviceType}"><i class="fa-solid ${t.icon}"></i></div>
            ${t.service}
          </div>
        </td>
        <td><strong>${t.amount}</strong></td>
        <td><strong>${t.commission}</strong><span class="commission-badge">${t.commissionPct}</span></td>
        <td><span class="status-badge ${t.status}">${t.status.charAt(0).toUpperCase() + t.status.slice(1)}</span></td>
        <td class="date-cell"><span class="date">${t.date}</span><span class="time">${t.time}</span></td>
      </tr>
    `;
  }

  function renderClusters() {
    $('#clusterList').innerHTML = HillGoData.clusters.map((c) => `
      <div class="cluster-item">
        <div class="cluster-header">
          <strong>${c.name}</strong>
          <span>${c.vehicles} Vehicles Active · ${c.capacity}% Cap.</span>
        </div>
        <div class="progress-bar">
          <div class="progress-fill" style="width:${c.capacity}%;background:${c.color}"></div>
        </div>
      </div>
    `).join('');
  }

  function renderHealthBars() {
    $('#healthBars').innerHTML = HillGoData.healthItems.map((h) => `
      <div class="health-item">
        <div class="health-icon ${h.color}"><i class="fa-solid ${h.icon}"></i></div>
        <div class="health-bar-wrap"><strong>${h.label}</strong></div>
      </div>
    `).join('');
  }

  function renderProducts() {
    const tabLabels = { products: 'Marketplace Products', restaurants: 'Restaurant Listings', promotions: 'Promotions' };
    $('#productGrid').innerHTML = HillGoData.products.map(renderProductCard).join('');
    $('#productPaginationInfo').textContent = `Showing 4 of 2,481 items — ${tabLabels[currentContentTab]}`;

    $('#productGrid').querySelectorAll('[data-action]').forEach((btn) => {
      btn.addEventListener('click', () => {
        showToast(`${btn.textContent} — ${btn.dataset.title}`);
      });
    });
  }

  function renderProductCard(p) {
    const imageHtml = p.missing
      ? `<div class="product-image placeholder"><i class="fa-solid fa-image"></i> Missing Hero Image</div>`
      : `<div class="product-image"><img src="${p.image}" alt="${p.title}"></div>`;

    const actionBtns = p.actions.map((a, i) => {
      const cls = a === 'Fix Content' ? 'danger' : a === 'Restock' ? 'primary' : '';
      return `<button data-action="product" data-title="${p.title}">${a}</button>`;
    }).join('');

    return `
      <div class="product-card">
        ${imageHtml}
        <span class="product-badge ${p.badgeClass}">${p.badge}</span>
        <div class="product-info">
          <div class="product-title">${p.title} <i class="fa-solid fa-ellipsis-vertical" style="color:var(--text-muted);font-size:0.7rem"></i></div>
          <div class="product-sku">${p.sku}</div>
          <div class="product-meta">
            <div><span class="label">Stock</span><div class="value">${p.stock}</div></div>
            <div><span class="label">Status</span><div class="value ${p.stockClass}">${p.stockStatus}</div></div>
          </div>
          <div class="product-actions">${actionBtns}</div>
        </div>
      </div>
    `;
  }

  function renderPagination(containerId, current, total, extended) {
    const container = $(`#${containerId}`);
    if (!container) return;

    let html = `<button class="page-btn"><i class="fa-solid fa-chevron-left"></i></button>`;
    const pages = extended ? [1, 2, 3, '...', 621] : Array.from({ length: total }, (_, i) => i + 1);

    pages.forEach((p) => {
      if (p === '...') {
        html += `<span style="padding:0 4px;color:var(--text-muted)">...</span>`;
      } else {
        html += `<button class="page-btn ${p === current ? 'active' : ''}" data-page="${p}">${p}</button>`;
      }
    });

    html += `<button class="page-btn"><i class="fa-solid fa-chevron-right"></i></button>`;
    container.innerHTML = html;

    container.querySelectorAll('[data-page]').forEach((btn) => {
      btn.addEventListener('click', () => showToast(`Navigated to page ${btn.dataset.page}`));
    });
  }

  // ── Charts ──
  function initCharts() {
    initRevenueChart('ride');
    initFunnelChart();
    initForecastChart();
  }

  function initRevenueChart(filter) {
    const ctx = $('#revenueChart');
    if (!ctx) return;

    const data = HillGoData.revenueData[filter];
    if (revenueChart) revenueChart.destroy();

    revenueChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: data.labels,
        datasets: [
          {
            type: 'bar',
            label: 'Revenue',
            data: data.bars,
            backgroundColor: 'rgba(0, 71, 171, 0.15)',
            borderRadius: 4,
            barPercentage: 0.6,
            order: 2
          },
          {
            type: 'line',
            label: 'Trend',
            data: data.line,
            borderColor: '#0047AB',
            backgroundColor: 'transparent',
            borderWidth: 2.5,
            tension: 0.4,
            pointRadius: 0,
            order: 1
          },
          {
            type: 'line',
            label: 'Target',
            data: data.line.map((v) => v + 8),
            borderColor: '#F97316',
            borderDash: [6, 4],
            backgroundColor: 'transparent',
            borderWidth: 2,
            tension: 0.4,
            pointRadius: 0,
            order: 0
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: { mode: 'index', intersect: false },
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: '#1F2937',
            padding: 12,
            cornerRadius: 8,
            titleFont: { size: 13 },
            bodyFont: { size: 12 }
          }
        },
        scales: {
          x: { grid: { display: false }, ticks: { color: '#9CA3AF', font: { size: 11 } } },
          y: { grid: { color: '#F3F4F6' }, ticks: { color: '#9CA3AF', font: { size: 11 } }, beginAtZero: true }
        }
      }
    });
  }

  function updateRevenueChart(filter) {
    initRevenueChart(filter);
    showToast(`Showing ${filter.charAt(0).toUpperCase() + filter.slice(1)} revenue data`);
  }

  function initFunnelChart() {
    const ctx = $('#funnelChart');
    if (!ctx) return;

    funnelChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['Applied', 'Vetting', 'Docs', 'Approved'],
        datasets: [{
          data: [1200, 890, 620, 842],
          backgroundColor: '#0047AB',
          borderRadius: 4,
          barPercentage: 0.5,
          categoryPercentage: 0.7
        }, {
          data: [1200, 1200, 1200, 1200],
          backgroundColor: 'rgba(0, 71, 171, 0.1)',
          borderRadius: 4,
          barPercentage: 0.5,
          categoryPercentage: 0.7
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        indexAxis: 'y',
        plugins: { legend: { display: false } },
        scales: {
          x: { display: false, stacked: true },
          y: { grid: { display: false }, ticks: { font: { size: 11, weight: '600' }, color: '#6B7280' }, stacked: true }
        }
      }
    });
  }

  function initForecastChart() {
    const ctx = $('#forecastChart');
    if (!ctx) return;

    forecastChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
        datasets: [{
          data: [120, 135, 128, 155, 148, 170, 182],
          borderColor: '#0047AB',
          backgroundColor: 'rgba(0, 71, 171, 0.1)',
          fill: true,
          tension: 0.4,
          pointRadius: 0,
          borderWidth: 2
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: {
          x: { display: false },
          y: { display: false }
        }
      }
    });
  }

  // ── Maps ──
  function initMaps() {
    const nycCenter = [40.7128, -74.006];

    if ($('#fleetMap')) {
      fleetMap = L.map('fleetMap', { zoomControl: false }).setView(nycCenter, 12);
      L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; OpenStreetMap'
      }).addTo(fleetMap);
      addFleetMarkers(fleetMap);
      L.control.zoom({ position: 'bottomright' }).addTo(fleetMap);
    }

    if ($('#fleetTrackingMap')) {
      trackingMap = L.map('fleetTrackingMap', { zoomControl: false }).setView(nycCenter, 11);
      L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; OpenStreetMap'
      }).addTo(trackingMap);
      addFleetMarkers(trackingMap);
      L.control.zoom({ position: 'bottomright' }).addTo(trackingMap);
    }
  }

  function addFleetMarkers(map) {
    const locations = [
      [40.758, -73.985], [40.748, -73.987], [40.730, -73.995],
      [40.712, -74.005], [40.705, -74.010], [40.689, -73.985],
      [40.678, -73.944], [40.650, -73.949], [40.728, -73.794],
      [40.756, -73.830], [40.770, -73.920], [40.742, -73.988]
    ];

    locations.forEach(([lat, lng]) => {
      const icon = L.divIcon({
        className: 'fleet-marker',
        html: '<div style="width:10px;height:10px;background:#0047AB;border:2px solid white;border-radius:50%;box-shadow:0 1px 4px rgba(0,0,0,0.3)"></div>',
        iconSize: [10, 10],
        iconAnchor: [5, 5]
      });
      L.marker([lat, lng], { icon }).addTo(map);
    });
  }

  // ── Buttons & Actions ──
  function setupButtons() {
    $('#addUserBtn').addEventListener('click', showAddUserModal);
    $('#exportCsvBtn').addEventListener('click', exportCSV);
    $('#exportUsers').addEventListener('click', () => showToast('User data exported successfully', 'success'));
    $('#exportFleet').addEventListener('click', () => showToast('Fleet data exported successfully', 'success'));
    $('#exportReportBtn').addEventListener('click', () => showToast('Report exported successfully', 'success'));
    $('#createListingBtn').addEventListener('click', showCreateListingModal);
    $('#reviewFlaggedBtn').addEventListener('click', () => showToast('Opening flagged accounts review...'));
    $('#optimizeRoutingBtn').addEventListener('click', () => showToast('Route optimization initiated', 'success'));
    $('#safetyReportBtn').addEventListener('click', () => showToast('Opening safety report...'));
    $('#supportBtn').addEventListener('click', () => showToast('Connecting to Support Desk...'));
    $('#notifBtn').addEventListener('click', showNotifications);
    $('#helpBtn').addEventListener('click', () => showToast('Help documentation coming soon'));
    $('#logoutBtn').addEventListener('click', (e) => {
      e.preventDefault();
      showToast('Logged out successfully', 'success');
    });
    $('#addVehicleFab').addEventListener('click', showAddVehicleModal);
    $('#quickActionFab').addEventListener('click', () => showToast('Quick action triggered'));
    $('#orgForm').addEventListener('submit', (e) => {
      e.preventDefault();
      showToast('Settings saved successfully', 'success');
    });

    document.addEventListener('click', (e) => {
      const el = e.target.closest('[data-action="view-all-alerts"]');
      if (el) { e.preventDefault(); showToast('Loading all alerts...'); }
    });
  }

  function handleUserAction(action, id) {
    const user = HillGoData.users.find((u) => u.id === id);
    if (!user) return;

    if (action === 'view-user') {
      openModal('User Details', `
        <div class="detail-row"><span class="label">Name</span><span>${user.name}</span></div>
        <div class="detail-row"><span class="label">Email</span><span>${user.email}</span></div>
        <div class="detail-row"><span class="label">Type</span><span class="tag ${user.type}">${user.type}</span></div>
        <div class="detail-row"><span class="label">Status</span><span class="status-badge ${user.status}">${user.status}</span></div>
        <div class="detail-row"><span class="label">Joined</span><span>${user.joined}</span></div>
      `);
    } else {
      openModal('Edit User', `
        <form class="modal-form" id="editUserForm">
          <div class="form-group"><label>Name</label><input type="text" value="${user.name}"></div>
          <div class="form-group"><label>Email</label><input type="email" value="${user.email}"></div>
          <div class="form-group">
            <label>Status</label>
            <select>
              <option ${user.status === 'active' ? 'selected' : ''}>Active</option>
              <option ${user.status === 'pending' ? 'selected' : ''}>Pending</option>
              <option ${user.status === 'suspended' ? 'selected' : ''}>Suspended</option>
            </select>
          </div>
          <div class="modal-actions">
            <button type="button" class="btn-outline" onclick="document.getElementById('modalOverlay').classList.remove('open')">Cancel</button>
            <button type="submit" class="btn-primary">Save Changes</button>
          </div>
        </form>
      `);
      $('#editUserForm')?.addEventListener('submit', (e) => {
        e.preventDefault();
        closeModal();
        showToast('User updated successfully', 'success');
      });
    }
  }

  function handleFleetAction(action, id) {
    const vehicle = HillGoData.fleet.find((v) => v.id === id);
    if (!vehicle) return;

    if (action === 'approve-fleet') {
      showToast(`${id} approved successfully`, 'success');
      HillGoData.fleet = HillGoData.fleet.filter((v) => v.id !== id);
      renderFleet();
    } else {
      openModal('Reject Vehicle', `
        <p style="margin-bottom:16px;color:var(--text-secondary)">Are you sure you want to reject <strong>${id}</strong> (${vehicle.type})?</p>
        <div class="form-group"><label>Reason</label><input type="text" placeholder="Enter rejection reason..."></div>
        <div class="modal-actions">
          <button class="btn-outline" onclick="document.getElementById('modalOverlay').classList.remove('open')">Cancel</button>
          <button class="btn-primary" style="background:var(--red)" id="confirmReject">Reject</button>
        </div>
      `);
      $('#confirmReject')?.addEventListener('click', () => {
        HillGoData.fleet = HillGoData.fleet.filter((v) => v.id !== id);
        renderFleet();
        closeModal();
        showToast(`${id} rejected`, 'error');
      });
    }
  }

  function showTransactionDetail(txn) {
    openModal('Transaction Details', `
      <div class="detail-row"><span class="label">Transaction ID</span><span class="txn-id">${txn.id}</span></div>
      <div class="detail-row"><span class="label">Service</span><span>${txn.service}</span></div>
      <div class="detail-row"><span class="label">Amount</span><span><strong>${txn.amount}</strong></span></div>
      <div class="detail-row"><span class="label">Commission</span><span>${txn.commission} (${txn.commissionPct})</span></div>
      <div class="detail-row"><span class="label">Status</span><span class="status-badge ${txn.status}">${txn.status}</span></div>
      <div class="detail-row"><span class="label">Date</span><span>${txn.date} ${txn.time}</span></div>
    `);
  }

  function showNotifications() {
    openModal('Notifications', `
      <div style="display:flex;flex-direction:column;gap:12px">
        ${HillGoData.alerts.map((a) => `
          <div style="padding:12px;border:1px solid var(--border);border-radius:8px">
            <strong style="color:var(--${a.type === 'security' ? 'red' : a.type === 'market' ? 'orange' : 'primary'})">${a.label}</strong>
            <p style="font-size:0.85rem;color:var(--text-secondary);margin-top:4px">${a.description}</p>
            <span style="font-size:0.75rem;color:var(--text-muted)">${a.time}</span>
          </div>
        `).join('')}
      </div>
    `);
  }

  function showAddUserModal() {
    openModal('Add New User', `
      <form class="modal-form" id="addUserForm">
        <div class="form-group"><label>Full Name</label><input type="text" placeholder="Enter full name" required></div>
        <div class="form-group"><label>Email</label><input type="email" placeholder="Enter email address" required></div>
        <div class="form-group">
          <label>Account Type</label>
          <select><option value="customer">Customer</option><option value="partner">Partner</option></select>
        </div>
        <div class="modal-actions">
          <button type="button" class="btn-outline" onclick="document.getElementById('modalOverlay').classList.remove('open')">Cancel</button>
          <button type="submit" class="btn-primary">Create User</button>
        </div>
      </form>
    `);
    $('#addUserForm')?.addEventListener('submit', (e) => {
      e.preventDefault();
      closeModal();
      showToast('New user created successfully', 'success');
    });
  }

  function showCreateListingModal() {
    openModal('Create New Listing', `
      <form class="modal-form" id="createListingForm">
        <div class="form-group"><label>Product Title</label><input type="text" placeholder="Enter product name" required></div>
        <div class="form-group"><label>SKU</label><input type="text" placeholder="SKU-XXX-000" required></div>
        <div class="form-group"><label>Category</label><select><option>Groceries</option><option>Electronics</option><option>Food & Beverage</option></select></div>
        <div class="form-group"><label>Initial Stock</label><input type="number" placeholder="0" min="0"></div>
        <div class="modal-actions">
          <button type="button" class="btn-outline" onclick="document.getElementById('modalOverlay').classList.remove('open')">Cancel</button>
          <button type="submit" class="btn-primary">Create Listing</button>
        </div>
      </form>
    `);
    $('#createListingForm')?.addEventListener('submit', (e) => {
      e.preventDefault();
      closeModal();
      showToast('New listing created successfully', 'success');
    });
  }

  function showAddVehicleModal() {
    openModal('Add Vehicle', `
      <form class="modal-form" id="addVehicleForm">
        <div class="form-group"><label>Vehicle ID</label><input type="text" placeholder="HG-XXXXX-XXX" required></div>
        <div class="form-group"><label>Type / Model</label><input type="text" placeholder="e.g. Tesla Model 3" required></div>
        <div class="form-group"><label>Partner Name</label><input type="text" placeholder="Partner company name" required></div>
        <div class="modal-actions">
          <button type="button" class="btn-outline" onclick="document.getElementById('modalOverlay').classList.remove('open')">Cancel</button>
          <button type="submit" class="btn-primary">Submit for Review</button>
        </div>
      </form>
    `);
    $('#addVehicleForm')?.addEventListener('submit', (e) => {
      e.preventDefault();
      closeModal();
      showToast('Vehicle submitted for verification', 'success');
    });
  }

  function exportCSV() {
    const headers = ['Transaction ID', 'Service', 'Amount', 'Commission', 'Status', 'Date'];
    const rows = HillGoData.transactions.map((t) =>
      [t.id, t.service, t.amount, t.commission, t.status, `${t.date} ${t.time}`].join(',')
    );
    const csv = [headers.join(','), ...rows].join('\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'hillgo-transactions.csv';
    a.click();
    URL.revokeObjectURL(url);
    showToast('CSV exported successfully', 'success');
  }

  // ── Modal ──
  function setupModal() {
    $('#modalClose').addEventListener('click', closeModal);
    $('#modalOverlay').addEventListener('click', (e) => {
      if (e.target === $('#modalOverlay')) closeModal();
    });
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') closeModal();
    });
  }

  function openModal(title, body) {
    $('#modalTitle').textContent = title;
    $('#modalBody').innerHTML = body;
    $('#modalOverlay').classList.add('open');
  }

  function closeModal() {
    $('#modalOverlay').classList.remove('open');
  }

  // ── Mobile ──
  function setupMobileToggle() {
    $('#mobileToggle').addEventListener('click', () => {
      $('#sidebar').classList.toggle('open');
    });
  }

  // ── Toast ──
  function showToast(message, type) {
    const toast = document.createElement('div');
    toast.className = `toast ${type || ''}`;
    toast.textContent = message;
    $('#toastContainer').appendChild(toast);
    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transition = 'opacity 0.3s';
      setTimeout(() => toast.remove(), 300);
    }, 3000);
  }

  // ── Utils ──
  function debounce(fn, delay) {
    let timer;
    return function (...args) {
      clearTimeout(timer);
      timer = setTimeout(() => fn.apply(this, args), delay);
    };
  }
})();

/**
 * Shared UI helpers — modal, drawer, confirm, notice, CSV, money format.
 * Notices reflect real state changes (not fake placeholder toasts).
 */
window.UI = (() => {
  let noticeTimer = null;

  function $(sel, root = document) {
    return root.querySelector(sel);
  }

  function escapeHtml(s) {
    return String(s ?? '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }

  function el(html) {
    const t = document.createElement('template');
    t.innerHTML = html.trim();
    return t.content.firstElementChild;
  }

  function formatTk(n) {
    const v = Math.round(Number(n) || 0);
    return `৳${v.toLocaleString('en-BD')}`;
  }

  function formatDate(iso) {
    if (!iso) return '—';
    const d = new Date(iso);
    if (Number.isNaN(d.getTime())) return iso;
    return d.toLocaleString('en-BD', { dateStyle: 'medium', timeStyle: 'short' });
  }

  function badge(status) {
    const map = {
      open: 'bg-emerald-100 text-emerald-800',
      active: 'bg-emerald-100 text-emerald-800',
      paid: 'bg-emerald-100 text-emerald-800',
      completed: 'bg-emerald-100 text-emerald-800',
      delivered: 'bg-emerald-100 text-emerald-800',
      verified: 'bg-emerald-100 text-emerald-800',
      approved: 'bg-emerald-100 text-emerald-800',
      partial: 'bg-amber-100 text-amber-800',
      pending: 'bg-amber-100 text-amber-800',
      processing: 'bg-amber-100 text-amber-800',
      preparing: 'bg-amber-100 text-amber-800',
      uploaded: 'bg-amber-100 text-amber-800',
      in_progress: 'bg-blue-100 text-blue-800',
      in_transit: 'bg-blue-100 text-blue-800',
      on_the_way: 'bg-blue-100 text-blue-800',
      accepted: 'bg-blue-100 text-blue-800',
      picked_up: 'bg-blue-100 text-blue-800',
      assigned: 'bg-blue-100 text-blue-800',
      placed: 'bg-blue-100 text-blue-800',
      ready: 'bg-blue-100 text-blue-800',
      new_order: 'bg-blue-100 text-blue-800',
      booked: 'bg-blue-100 text-blue-800',
      closed: 'bg-red-100 text-red-800',
      suspended: 'bg-red-100 text-red-800',
      cancelled: 'bg-red-100 text-red-800',
      rejected: 'bg-red-100 text-red-800',
      failed: 'bg-red-100 text-red-800',
      action_required: 'bg-red-100 text-red-800',
      onboarding: 'bg-amber-100 text-amber-800',
      changes_requested: 'bg-amber-100 text-amber-800',
      scheduled: 'bg-slate-100 text-slate-700',
    };
    const cls = map[status] || 'bg-slate-100 text-slate-700';
    const label = escapeHtml(String(status || '').replace(/_/g, ' '));
    return `<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold capitalize ${cls}">${label}</span>`;
  }

  function notice(message, type = 'success') {
    const host = $('#global-notice');
    if (!host) return;
    const colors = type === 'error'
      ? 'bg-red-50 text-red-800 border-red-200'
      : type === 'info'
        ? 'bg-blue-50 text-blue-800 border-blue-200'
        : 'bg-emerald-50 text-emerald-800 border-emerald-200';
    host.className = `fixed bottom-6 left-1/2 -translate-x-1/2 z-[80] px-4 py-3 rounded-xl border shadow-lg text-sm font-medium ${colors}`;
    host.textContent = message;
    host.classList.remove('hidden');
    clearTimeout(noticeTimer);
    noticeTimer = setTimeout(() => host.classList.add('hidden'), 2800);
  }

  function openModal({ title, bodyHtml, footerHtml, width = 'max-w-lg' }) {
    const overlay = $('#modal-overlay');
    const box = $('#modal-box');
    $('#modal-title').textContent = title;
    $('#modal-body').innerHTML = bodyHtml;
    $('#modal-footer').innerHTML = footerHtml || '';
    box.className = `bg-white rounded-xl shadow-2xl w-full ${width} max-h-[90vh] overflow-hidden flex flex-col`;
    overlay.classList.remove('hidden');
    overlay.setAttribute('aria-hidden', 'false');
  }

  function closeModal() {
    const overlay = $('#modal-overlay');
    overlay.classList.add('hidden');
    overlay.setAttribute('aria-hidden', 'true');
    $('#modal-body').innerHTML = '';
    $('#modal-footer').innerHTML = '';
  }

  function openDrawer({ title, bodyHtml, width = 'max-w-md' }) {
    const overlay = $('#drawer-overlay');
    const panel = $('#drawer-panel');
    $('#drawer-title').textContent = title;
    $('#drawer-body').innerHTML = bodyHtml;
    panel.className = `ml-auto h-full w-full ${width} bg-white shadow-2xl flex flex-col`;
    overlay.classList.remove('hidden');
  }

  function closeDrawer() {
    $('#drawer-overlay').classList.add('hidden');
    $('#drawer-body').innerHTML = '';
  }

  function confirmDialog({ title, message, confirmLabel = 'Confirm', danger = false }) {
    return new Promise((resolve) => {
      openModal({
        title,
        bodyHtml: `<p class="text-sm text-on-surface-variant leading-relaxed">${escapeHtml(message)}</p>`,
        footerHtml: `
          <button type="button" data-act="cancel" class="px-4 py-2 text-sm font-semibold text-outline hover:bg-surface-container-low rounded-lg">Cancel</button>
          <button type="button" data-act="ok" class="px-4 py-2 text-sm font-semibold text-white rounded-lg ${danger ? 'bg-error hover:bg-red-700' : 'bg-primary-container hover:bg-primary'}">${escapeHtml(confirmLabel)}</button>
        `,
      });
      const footer = $('#modal-footer');
      const onClick = (e) => {
        const btn = e.target.closest('[data-act]');
        if (!btn) return;
        footer.removeEventListener('click', onClick);
        closeModal();
        resolve(btn.getAttribute('data-act') === 'ok');
      };
      footer.addEventListener('click', onClick);
    });
  }

  function downloadCsv(filename, rows) {
    if (!rows || !rows.length) {
      notice('Nothing to export for current filters', 'error');
      return;
    }
    const headers = Object.keys(rows[0]);
    const esc = (v) => `"${String(v ?? '').replace(/"/g, '""')}"`;
    const csv = [headers.join(','), ...rows.map((r) => headers.map((h) => esc(r[h])).join(','))].join('\n');
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    a.click();
    URL.revokeObjectURL(url);
    notice(`Exported ${rows.length} rows → ${filename}`);
  }

  function paginate(items, page, pageSize = 8) {
    const total = items.length;
    const pages = Math.max(1, Math.ceil(total / pageSize));
    const p = Math.min(Math.max(1, page), pages);
    const start = (p - 1) * pageSize;
    return { page: p, pages, total, rows: items.slice(start, start + pageSize), pageSize };
  }

  /**
   * `serverMore` (optional): { collection, hasMore } — when the client has
   * paged to the end of what's loaded AND the server has more rows (per_page
   * capped collections), render a "Load more from server" button so pages
   * aren't stuck at whatever the first server page returned.
   */
  function pagerHtml(page, pages, total, serverMore) {
    const showServerMore = serverMore && serverMore.hasMore && page >= pages;
    return `
      <div class="flex items-center justify-between px-4 py-3 border-t border-slate-100 flex-wrap gap-2">
        <p class="text-xs text-outline">${total} records loaded · Page ${page} of ${pages}</p>
        <div class="flex gap-2">
          ${showServerMore ? `<button type="button" data-server-more="${escapeHtml(serverMore.collection)}" class="px-3 py-1.5 text-xs font-semibold rounded-lg border border-primary-container text-primary-container hover:bg-blue-50">Load more from server</button>` : ''}
          <button type="button" data-page-btn="prev" class="px-3 py-1.5 text-xs font-semibold rounded-lg border border-slate-200 hover:bg-slate-50 disabled:opacity-40" ${page <= 1 ? 'disabled' : ''}>Previous</button>
          <button type="button" data-page-btn="next" class="px-3 py-1.5 text-xs font-semibold rounded-lg border border-slate-200 hover:bg-slate-50 disabled:opacity-40" ${page >= pages ? 'disabled' : ''}>Next</button>
        </div>
      </div>`;
  }

  /** Wires the `[data-server-more]` button rendered by pagerHtml() to AppStore.loadMore(). */
  function bindServerMore(root, onLoaded) {
    const btn = root.querySelector('[data-server-more]');
    if (!btn) return;
    btn.addEventListener('click', async () => {
      const collection = btn.getAttribute('data-server-more');
      btn.disabled = true;
      btn.textContent = 'Loading…';
      try {
        await AppStore.loadMore(collection);
      } catch (e) {
        notice(e.message || 'Could not load more rows', 'error');
      }
      onLoaded?.();
    });
  }

  function kpiCard(label, value, hint = '') {
    return `
      <div class="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
        <p class="text-[11px] font-semibold uppercase tracking-wider text-outline">${escapeHtml(label)}</p>
        <p class="text-2xl font-bold text-on-surface mt-1">${escapeHtml(value)}</p>
        ${hint ? `<p class="text-xs text-outline mt-1">${escapeHtml(hint)}</p>` : ''}
      </div>`;
  }

  function breadcrumb(parts) {
    return parts.map((p, i) => {
      if (i === parts.length - 1) return `<span class="text-primary">${escapeHtml(p)}</span>`;
      return `<span>${escapeHtml(p)}</span><span class="material-symbols-outlined text-[14px]">chevron_right</span>`;
    }).join('');
  }

  function bindShellChrome() {
    $('#modal-close')?.addEventListener('click', closeModal);
    $('#modal-overlay')?.addEventListener('click', (e) => {
      if (e.target.id === 'modal-overlay') closeModal();
    });
    $('#drawer-close')?.addEventListener('click', closeDrawer);
    $('#drawer-overlay')?.addEventListener('click', (e) => {
      if (e.target.id === 'drawer-overlay') closeDrawer();
    });
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        closeModal();
        closeDrawer();
      }
    });
  }

  return {
    $, el, escapeHtml, formatTk, formatDate, badge, notice, openModal, closeModal,
    openDrawer, closeDrawer, confirmDialog, downloadCsv, paginate, pagerHtml, bindServerMore,
    kpiCard, breadcrumb, bindShellChrome,
  };
})();

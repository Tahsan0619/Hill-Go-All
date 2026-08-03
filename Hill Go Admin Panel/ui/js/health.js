/**
 * Sidebar health indicator — replaces the old static "System Active" markup
 * with a real probe of the backend, polled every 30s.
 *
 * Tries `${API_BASE}/health` (i.e. `/api/health`); Backend ticket 7.4.24
 * will add this endpoint. Until then every poll 404s and the indicator
 * correctly shows "API unreachable" in amber instead of a fake green dot.
 */
(function healthIndicator() {
  const POLL_MS = 30000;
  const Helpers = window.HillGoStoreHelpers;

  function apiBase() {
    return window.HILLGO_API_BASE || 'http://127.0.0.1:8000/api';
  }

  function paint(state) {
    const dot = document.getElementById('health-dot');
    const label = document.getElementById('health-label');
    if (!dot || !label) return;
    if (state === 'active') {
      dot.className = 'w-2 h-2 rounded-full bg-green-400 animate-pulse';
      label.textContent = 'System Active';
    } else if (state === 'unreachable') {
      dot.className = 'w-2 h-2 rounded-full bg-amber-400';
      label.textContent = 'API unreachable';
    } else {
      dot.className = 'w-2 h-2 rounded-full bg-amber-400 animate-pulse';
      label.textContent = 'Degraded';
    }
  }

  async function probeOnce() {
    try {
      const res = await fetch(`${apiBase()}/health`, {
        headers: { Accept: 'application/json' },
        cache: 'no-store',
      });
      const state = Helpers.deriveHealthState({ ok: res.ok, status: res.status, errored: false });
      paint(state);
    } catch (err) {
      paint(Helpers.deriveHealthState({ ok: false, status: 0, errored: true }));
      window.HillGoTelemetry?.captureError(err, { source: 'health.probeOnce' });
    }
  }

  function start() {
    probeOnce();
    setInterval(probeOnce, POLL_MS);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start);
  } else {
    start();
  }
})();

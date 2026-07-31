window.Router = (() => {
  const routes = {};
  let pageCleanup = null;

  function register(path, handler) {
    routes[path] = handler;
  }

  function parseHash() {
    const raw = (location.hash || '#/overview').replace(/^#/, '') || '/overview';
    const path = raw.startsWith('/') ? raw : `/${raw}`;
    const [pathname, query = ''] = path.split('?');
    const params = Object.fromEntries(new URLSearchParams(query));
    const parts = pathname.split('/').filter(Boolean);
    return { path: pathname, parts, params };
  }

  function match(pathname) {
    if (routes[pathname]) return { handler: routes[pathname], params: {} };
    for (const key of Object.keys(routes)) {
      const keys = key.split('/').filter(Boolean);
      const vals = pathname.split('/').filter(Boolean);
      if (keys.length !== vals.length) continue;
      const params = {};
      let ok = true;
      for (let i = 0; i < keys.length; i++) {
        if (keys[i].startsWith(':')) params[keys[i].slice(1)] = decodeURIComponent(vals[i]);
        else if (keys[i] !== vals[i]) { ok = false; break; }
      }
      if (ok) return { handler: routes[key], params };
    }
    return null;
  }

  function setActiveNav(pathname) {
    document.querySelectorAll('.nav-link').forEach((a) => a.classList.remove('active'));
    document.querySelectorAll('.nav-sub a').forEach((a) => {
      a.classList.remove('active', 'text-white');
      a.classList.add('text-outline-variant');
    });
    document.querySelectorAll('.nav-group').forEach((g) => {
      if (!pathname.startsWith(`/${g.dataset.group}`)) g.classList.remove('open');
    });

    const top = pathname.split('/')[1];
    const topLink = document.querySelector(`.nav-link[data-route="${top}"]`);
    if (topLink) topLink.classList.add('active');

    const group = document.querySelector(`.nav-group[data-group="${top}"]`);
    if (group) {
      group.classList.add('open');
      const exact = group.querySelector(`a[href="#${pathname}"]`);
      if (exact) {
        exact.classList.add('active', 'text-white');
        exact.classList.remove('text-outline-variant');
      }
    }
  }

  function runCleanup() {
    if (typeof pageCleanup === 'function') {
      try { pageCleanup(); } catch (e) { console.warn('page cleanup', e); }
    }
    pageCleanup = null;
    if (window.HillGoMaps) {
      try { window.HillGoMaps.destroyAll(); } catch (e) { console.warn('map cleanup', e); }
    }
  }

  async function navigate() {
    const root = document.getElementById('app-content');
    if (!root) return;

    const { path, params: q } = parseHash();
    const matched = match(path) || match('/overview');
    setActiveNav(path);
    runCleanup();

    if (!matched || typeof matched.handler !== 'function') {
      root.innerHTML = `<div class="p-8"><h2 class="text-xl font-bold">Page not found</h2><p class="text-sm text-outline mt-2">${path}</p><a class="text-primary-container underline mt-4 inline-block" href="#/overview">Back to overview</a></div>`;
      return;
    }

    root.innerHTML = `<div class="flex items-center justify-center py-24 text-outline text-sm">Loading…</div>`;
    root.scrollTop = 0;

    try {
      const maybeCleanup = await matched.handler(root, { ...matched.params, ...q });
      if (typeof maybeCleanup === 'function') pageCleanup = maybeCleanup;
      // If handler forgot to replace Loading content, recover
      if (root.textContent.trim() === 'Loading…') {
        root.innerHTML = `<div class="p-8"><h2 class="text-xl font-bold">Nothing rendered</h2><a class="text-primary-container underline" href="#/overview">Overview</a></div>`;
      }
    } catch (err) {
      console.error('Route error', path, err);
      root.innerHTML = `
        <div class="p-8 max-w-xl">
          <h2 class="text-xl font-bold text-error mb-2">Screen failed to load</h2>
          <p class="text-sm text-outline mb-1">${path}</p>
          <pre class="text-xs bg-red-50 border border-red-100 rounded-lg p-3 overflow-auto mb-4">${String(err && err.message ? err.message : err)}</pre>
          <a class="px-4 py-2 rounded-lg bg-primary-container text-white text-sm font-semibold inline-block" href="#/overview">Back to overview</a>
        </div>`;
    }
  }

  function start() {
    window.addEventListener('hashchange', navigate);
    if (!location.hash) location.hash = '#/overview';
    else navigate();
  }

  function go(path) {
    location.hash = path.startsWith('#') ? path : `#${path}`;
  }

  /** Register a store subscription that auto-clears on next navigation */
  function onStore(fn) {
    const unsub = AppStore.subscribe(fn);
    const prev = pageCleanup;
    pageCleanup = () => {
      unsub();
      if (typeof prev === 'function') prev();
    };
    return unsub;
  }

  return { register, start, go, navigate, parseHash, onStore };
})();

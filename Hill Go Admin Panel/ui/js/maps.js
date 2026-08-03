/**
 * Leaflet map helpers — Dhaka-centric operational maps.
 * Mount into a container after the page HTML is in the DOM.
 * Never throws into the router — map failures are logged only.
 */
window.HillGoMaps = (() => {
  const DHAKA = [23.8103, 90.4125];
  const instances = new Map();

  const HUBS = {
    gulshan: { name: 'Gulshan', lat: 23.7808, lng: 90.4142 },
    banani: { name: 'Banani', lat: 23.7937, lng: 90.4066 },
    dhanmondi: { name: 'Dhanmondi', lat: 23.7461, lng: 90.3742 },
    mirpur: { name: 'Mirpur', lat: 23.8223, lng: 90.3654 },
    uttara: { name: 'Uttara', lat: 23.8759, lng: 90.3795 },
    motijheel: { name: 'Motijheel', lat: 23.7330, lng: 90.4172 },
    bashundhara: { name: 'Bashundhara', lat: 23.8151, lng: 90.4265 },
    badda: { name: 'Badda', lat: 23.7805, lng: 90.4267 },
    airport: { name: 'Airport', lat: 23.8433, lng: 90.3978 },
    agrabad: { name: 'Agrabad', lat: 22.3235, lng: 91.8117 },
    gec: { name: 'GEC', lat: 22.3591, lng: 91.8215 },
    zindabazar: { name: 'Zindabazar', lat: 24.8990, lng: 91.8687 },
    khulna: { name: 'Khulna City', lat: 22.8456, lng: 89.5403 },
  };

  const DIVISION_CENTERS = {
    dhaka: [23.8103, 90.4125],
    chattogram: [22.3569, 91.7832],
    rajshahi: [24.3745, 88.6042],
    khulna: [22.8456, 89.5403],
    barishal: [22.7010, 90.3535],
    sylhet: [24.8949, 91.8687],
    rangpur: [25.7439, 89.2752],
    mymensingh: [24.7471, 90.4203],
  };

  function resolvePlace(text) {
    if (!text) return null;
    const t = String(text).toLowerCase();
    for (const [key, hub] of Object.entries(HUBS)) {
      if (t.includes(key) || t.includes(hub.name.toLowerCase())) return hub;
    }
    if (t.includes('dhaka')) return HUBS.gulshan;
    if (t.includes('chattogram') || t.includes('chittagong')) return HUBS.agrabad;
    if (t.includes('sylhet')) return HUBS.zindabazar;
    if (t.includes('khulna')) return HUBS.khulna;
    return null;
  }

  function jitter(lat, lng, i = 0) {
    const a = ((i * 37) % 10) / 500;
    const b = ((i * 53) % 10) / 500;
    return [lat + a - 0.01, lng + b - 0.01];
  }

  // De-duplicated: uses UI.escapeHtml (ui.js loads before maps.js in index.html).
  const escapeHtml = (s) => UI.escapeHtml(s);

  function divIcon(color, label) {
    const safeLabel = escapeHtml(label);
    const safeColor = escapeHtml(color);
    const html = label
      ? `<div style="display:flex;align-items:center;gap:4px;background:#fff;border:1px solid ${safeColor};border-radius:8px;padding:2px 6px;box-shadow:0 1px 4px rgba(0,0,0,.2);font:600 10px Inter,sans-serif;color:#191c1e;white-space:nowrap">
           <span style="width:8px;height:8px;border-radius:50%;background:${safeColor}"></span>${safeLabel}
         </div>`
      : `<div style="width:12px;height:12px;background:${safeColor};border:2px solid #fff;border-radius:50%;box-shadow:0 1px 4px rgba(0,0,0,.35)"></div>`;
    return L.divIcon({
      className: 'hg-marker',
      html,
      iconSize: label ? [80, 24] : [12, 12],
      iconAnchor: label ? [12, 12] : [6, 6],
    });
  }

  function destroy(id) {
    const m = instances.get(id);
    if (!m) return;
    try {
      m.off();
      m.remove();
    } catch (e) {
      console.warn('map destroy', id, e);
    }
    instances.delete(id);
    const el = document.getElementById(id);
    if (el) {
      el._leaflet_id = null;
      el.innerHTML = '';
    }
  }

  function destroyAll() {
    [...instances.keys()].forEach(destroy);
  }

  function validMarker(mk) {
    return mk && Number.isFinite(mk.lat) && Number.isFinite(mk.lng);
  }

  function mount(id, opts = {}) {
    try {
      if (typeof L === 'undefined') {
        console.warn('Leaflet not loaded');
        return null;
      }
      destroy(id);
      const el = document.getElementById(id);
      if (!el) return null;

      el.style.height = opts.height || '360px';
      el.style.width = '100%';
      el.style.zIndex = '0';
      el.innerHTML = '';

      const map = L.map(el, {
        zoomControl: false,
        scrollWheelZoom: true,
      }).setView(opts.center || DHAKA, opts.zoom || 12);

      L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; OpenStreetMap &copy; CARTO',
        maxZoom: 19,
      }).addTo(map);

      L.control.zoom({ position: 'bottomright' }).addTo(map);

      const layerPoints = [];
      (opts.markers || []).filter(validMarker).forEach((mk) => {
        const latlng = [mk.lat, mk.lng];
        layerPoints.push(latlng);
        const marker = L.marker(latlng, {
          icon: divIcon(mk.color || '#0047ab', mk.label || ''),
        }).addTo(map);
        if (mk.popup) marker.bindPopup(mk.popup);
      });

      (opts.circles || []).forEach((c) => {
        if (!Number.isFinite(c.lat) || !Number.isFinite(c.lng)) return;
        L.circle([c.lat, c.lng], {
          radius: c.radius || 1200,
          color: c.color || '#0047ab',
          fillColor: c.color || '#0047ab',
          fillOpacity: 0.12,
          weight: 1,
        }).addTo(map);
      });

      if (opts.fit && layerPoints.length > 1) {
        try {
          map.fitBounds(layerPoints, { padding: [40, 40], maxZoom: 13 });
        } catch (_) { /* ignore */ }
      }

      const wrap = el.closest('[data-map-shell]');
      if (wrap && !wrap._hgMapBound) {
        wrap._hgMapBound = true;
        wrap.addEventListener('click', (e) => {
          const btn = e.target.closest('[data-map-zoom], [data-map-locate]');
          if (!btn) return;
          const live = instances.get(id);
          if (!live) return;
          if (btn.hasAttribute('data-map-locate')) {
            live.setView(opts.center || DHAKA, opts.zoom || 13);
          } else if (btn.getAttribute('data-map-zoom') === 'in') live.zoomIn();
          else if (btn.getAttribute('data-map-zoom') === 'out') live.zoomOut();
        });
      }

      instances.set(id, map);
      requestAnimationFrame(() => {
        try { map.invalidateSize(); } catch (_) { /* ignore */ }
      });
      setTimeout(() => {
        try { map.invalidateSize(); } catch (_) { /* ignore */ }
      }, 200);
      return map;
    } catch (err) {
      console.error('HillGoMaps.mount failed', id, err);
      const el = document.getElementById(id);
      if (el) {
        el.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:#737784;font-size:13px;padding:16px;text-align:center">Map unavailable — refresh the page</div>';
      }
      return null;
    }
  }

  function markersFromRiders(riders) {
    return (riders || [])
      .filter((r) => r.online || r.status === 'active')
      .map((r, i) => {
        const hub = resolvePlace(r.district) || HUBS.gulshan;
        const [lat, lng] = jitter(hub.lat, hub.lng, i + 3);
        const name = escapeHtml(r.name);
        const vehicle = escapeHtml(r.vehicle);
        const district = escapeHtml(r.district);
        return {
          lat, lng,
          color: r.online ? '#10B981' : '#F59E0B',
          label: String(r.name || '').split(' ')[0],
          popup: `<strong>${name}</strong><br>${vehicle} · ${district}<br>${r.online ? 'Online' : 'Offline'}`,
        };
      });
  }

  function markersFromAgents(agents) {
    return (agents || []).map((a, i) => {
      const hub = resolvePlace(a.district) || HUBS.gulshan;
      const [lat, lng] = jitter(hub.lat, hub.lng, i + 11);
      return {
        lat, lng,
        color: a.online ? '#0047ab' : '#9CA3AF',
        label: String(a.id || '').replace('CG-', ''),
        popup: `<strong>${escapeHtml(a.name)}</strong><br>${escapeHtml(a.vehicle)}<br>${escapeHtml(a.status)}`,
      };
    });
  }

  function markersFromTrips(trips) {
    return (trips || []).slice(0, 20).map((t, i) => {
      const place = (t.route || '').split('→')[0] || t.route;
      const hub = resolvePlace(place) || HUBS.gulshan;
      const [lat, lng] = jitter(hub.lat, hub.lng, i + 7);
      const color = t.status === 'completed' ? '#10B981'
        : t.status === 'cancelled' || t.status === 'failed' ? '#EF4444'
          : '#0047ab';
      return {
        lat, lng, color,
        label: t.type || t.id,
        popup: `<strong>${escapeHtml(t.id || '')}</strong><br>${escapeHtml(t.route || '')}<br>${escapeHtml(t.status)}`,
      };
    });
  }

  function markersFromOrders(orders, pickupKey = 'restaurant') {
    return (orders || []).slice(0, 20).map((o, i) => {
      const hub = resolvePlace(o.district || o[pickupKey] || o.store) || HUBS.dhanmondi;
      const [lat, lng] = jitter(hub.lat, hub.lng, i + 5);
      return {
        lat, lng,
        color: '#F59E0B',
        label: (o.id || '').slice(-4),
        popup: `<strong>${escapeHtml(o.id)}</strong><br>${escapeHtml(o[pickupKey] || o.store || '')}<br>${escapeHtml(o.status)}`,
      };
    });
  }

  function markersFromParcels(parcels) {
    return (parcels || []).slice(0, 20).map((p, i) => {
      const hub = resolvePlace(p.pickup || p.destination) || HUBS.banani;
      const [lat, lng] = jitter(hub.lat, hub.lng, i + 9);
      return {
        lat, lng,
        color: p.status === 'delivered' ? '#10B981' : '#0047ab',
        label: (p.id || '').replace(/\D/g, '').slice(-3),
        popup: `<strong>${escapeHtml(p.id)}</strong><br>${escapeHtml(p.pickup || '')} → ${escapeHtml(p.drop || p.destination || '')}<br>${escapeHtml(p.status)}`,
      };
    });
  }

  function markersFromDistricts(districts) {
    return (districts || []).map((d, i) => {
      const center = DIVISION_CENTERS[d.divisionId] || DHAKA;
      const [lat, lng] = jitter(center[0], center[1], i);
      return {
        lat, lng,
        color: d.status === 'open' ? '#10B981' : '#EF4444',
        label: '',
        popup: `<strong>${escapeHtml(d.name)}</strong><br>${escapeHtml(d.divisionName)}<br>Status: ${escapeHtml(d.status)}`,
      };
    });
  }

  function mapShell({ id, title, liveLabel, height = '360px', sideHtml = '' }) {
    const cols = sideHtml ? 'lg:grid-cols-3' : 'grid-cols-1';
    const mapSpan = sideHtml ? 'lg:col-span-2' : '';
    const safeId = escapeHtml(id);
    const safeTitle = escapeHtml(title);
    const safeLive = liveLabel ? escapeHtml(liveLabel) : '';
    return `
      <div class="grid grid-cols-1 ${cols} gap-4 mt-6" data-map-shell>
        <div class="${mapSpan} bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden relative">
          <div class="px-4 py-3 border-b border-slate-100 flex items-center justify-between">
            <h3 class="text-sm font-semibold uppercase tracking-wider text-on-surface">${safeTitle}</h3>
            ${liveLabel ? `<span class="flex items-center gap-2 text-xs font-semibold text-emerald-600"><span class="w-2 h-2 bg-emerald-500 rounded-full animate-pulse"></span>${safeLive}</span>` : ''}
          </div>
          <div class="relative">
            <div id="${safeId}" class="bg-slate-100" style="height:${escapeHtml(height)}"></div>
            <div class="absolute top-3 left-3 z-[400] pointer-events-none">
              <div class="bg-white/95 backdrop-blur px-3 py-1.5 rounded-full border border-slate-200 text-[10px] font-bold text-primary uppercase shadow-sm">
                Live · Dhaka Metropolitan
              </div>
            </div>
            <div class="absolute bottom-4 right-14 z-[400] flex flex-col gap-2">
              <button type="button" data-map-zoom="in" class="w-9 h-9 bg-white shadow-lg rounded-full flex items-center justify-center hover:bg-slate-50" title="Zoom in"><span class="material-symbols-outlined text-[20px]">add</span></button>
              <button type="button" data-map-zoom="out" class="w-9 h-9 bg-white shadow-lg rounded-full flex items-center justify-center hover:bg-slate-50" title="Zoom out"><span class="material-symbols-outlined text-[20px]">remove</span></button>
              <button type="button" data-map-locate class="w-9 h-9 bg-primary-container text-white shadow-lg rounded-full flex items-center justify-center hover:brightness-110" title="Recenter"><span class="material-symbols-outlined text-[20px]">my_location</span></button>
            </div>
          </div>
        </div>
        ${sideHtml ? `<div>${sideHtml}</div>` : ''}
      </div>`;
  }

  return {
    DHAKA, HUBS, DIVISION_CENTERS,
    mount, destroy, destroyAll, resolvePlace, jitter,
    markersFromRiders, markersFromAgents, markersFromTrips,
    markersFromOrders, markersFromParcels, markersFromDistricts,
    mapShell,
  };
})();

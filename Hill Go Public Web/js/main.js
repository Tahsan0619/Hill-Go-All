// HillGo Public Website - Main JavaScript
// API base is resolved by js/api.js from window.HILLGO_API_BASE, which js/config.js
// sets (empty by default) and which deploys should override — see deploy/README.md.
// Load order on every page: config.js -> api.js -> main.js.
const HG_API = window.HillGoApi.resolveApiBase(window);

// XSS strategy: all dynamic/user/API-sourced content is inserted via textContent or
// createElement (see initTrackForm, initQuoteCalculator, showToast, etc.) — never via
// innerHTML — so no HTML-escaping helper is needed in this file.

function assertApiReachableConfig() {
  if (!HG_API) return null;
  try {
    const api = new URL(HG_API, window.location.href);
    // Same-site or explicitly configured cross-origin — both OK; warn on file:// pages.
    if (window.location.protocol === 'file:') {
      console.info('HillGo: open via http(s) host for CORS; file:// pages cannot call the API.');
    }
    return api.origin;
  } catch (_) {
    return null;
  }
}
assertApiReachableConfig();

function hgApi(method, path, body) {
  return window.HillGoApi.hgApi(HG_API, method, path, body);
}

/** Retries up to 3 times with backoff, but only on network failures (see js/api.js). */
function hgApiRetry(method, path, body) {
  return window.HillGoApi.hgApiWithRetry(HG_API, method, path, body);
}

function warnIfApiBaseUnset() {
  if (!HG_API) {
    showToast('This deployment has no API configured yet — some features are unavailable.');
  }
}

document.addEventListener('DOMContentLoaded', () => {
  warnIfApiBaseUnset();
  initHeader();
  initMobileNav();
  initFaq();
  initPricingTabs();
  initTrackForm();
  initTestimonials();
  initQuoteCalculator();
  initContactForm();
  initAvailabilityForms();
  initNewsletterForms();
  initFaqSearch();
  initFaqCategories();
  initCounterAnimation();
});

/* Header scroll effect */
function initHeader() {
  const header = document.querySelector('.header');
  if (!header) return;
  window.addEventListener('scroll', () => {
    header.classList.toggle('scrolled', window.scrollY > 20);
  }, { passive: true });
}

/* Mobile navigation */
function initMobileNav() {
  const hamburger = document.querySelector('.hamburger');
  const mobileNav = document.querySelector('.mobile-nav');
  if (!hamburger || !mobileNav) return;

  hamburger.addEventListener('click', () => {
    hamburger.classList.toggle('active');
    mobileNav.classList.toggle('open');
    document.body.style.overflow = mobileNav.classList.contains('open') ? 'hidden' : '';
  });

  mobileNav.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
      hamburger.classList.remove('active');
      mobileNav.classList.remove('open');
      document.body.style.overflow = '';
    });
  });
}

/* FAQ accordion */
function initFaq() {
  document.querySelectorAll('.faq-question').forEach(btn => {
    btn.addEventListener('click', () => {
      const item = btn.closest('.faq-item');
      const answer = item.querySelector('.faq-answer');
      const isOpen = item.classList.contains('open');

      document.querySelectorAll('.faq-item.open').forEach(openItem => {
        if (openItem !== item) {
          openItem.classList.remove('open');
          openItem.querySelector('.faq-answer').style.maxHeight = null;
        }
      });

      item.classList.toggle('open', !isOpen);
      answer.style.maxHeight = !isOpen ? answer.scrollHeight + 'px' : null;
    });
  });
}

/* Pricing tabs */
function initPricingTabs() {
  const tabs = document.querySelectorAll('.pricing-tab');
  const panels = document.querySelectorAll('.pricing-panel');
  if (!tabs.length) return;

  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      const target = tab.dataset.tab;
      tabs.forEach(t => t.classList.remove('active'));
      panels.forEach(p => p.classList.remove('active'));
      tab.classList.add('active');
      document.getElementById(target)?.classList.add('active');
    });
  });
}

/* Track order form — live lookup against the HillGo backend */
function initTrackForm() {
  const form = document.getElementById('trackForm');
  if (!form) return;

  form.addEventListener('submit', async e => {
    e.preventDefault();
    const trackingId = form.querySelector('input').value.trim();
    if (!trackingId) {
      showToast('Please enter a tracking number.');
      return;
    }
    const btn = form.querySelector('button[type="submit"]');
    if (btn) btn.disabled = true;
    try {
      const res = await hgApi('GET', `/public/track/${encodeURIComponent(trackingId)}`);
      const statusLabel = String(res.status || '').replace(/_/g, ' ');
      showToast(`${res.code} (${res.kind}): ${statusLabel} — ${res.from || '?'} → ${res.to || '?'}`);
      form.reset();
    } catch (err) {
      showToast(err.message || 'No shipment found for this tracking number.');
    } finally {
      if (btn) btn.disabled = false;
    }
  });
}

/* Testimonial carousel */
function initTestimonials() {
  const grid = document.querySelector('.testimonials-grid');
  const prevBtn = document.querySelector('.testimonial-prev');
  const nextBtn = document.querySelector('.testimonial-next');
  if (!grid || !prevBtn || !nextBtn) return;

  const cards = Array.from(grid.children);
  let currentIndex = 0;

  function getVisibleCount() {
    if (window.innerWidth <= 768) return 1;
    if (window.innerWidth <= 1024) return 2;
    return 3;
  }

  function updateCarousel() {
    const visible = getVisibleCount();
    const maxIndex = Math.max(0, cards.length - visible);
    currentIndex = Math.min(currentIndex, maxIndex);

    cards.forEach((card, i) => {
      card.style.display = (i >= currentIndex && i < currentIndex + visible) ? 'block' : 'none';
    });
  }

  prevBtn.addEventListener('click', () => {
    currentIndex = Math.max(0, currentIndex - 1);
    updateCarousel();
  });

  nextBtn.addEventListener('click', () => {
    const visible = getVisibleCount();
    const maxIndex = Math.max(0, cards.length - visible);
    currentIndex = Math.min(maxIndex, currentIndex + 1);
    updateCarousel();
  });

  window.addEventListener('resize', updateCarousel);
  updateCarousel();
}

/* Parcel quote calculator */
function initQuoteCalculator() {
  const form = document.getElementById('quoteForm');
  if (!form) return;

  const weightSlider = form.querySelector('#weight');
  const weightDisplay = form.querySelector('#weightValue');
  const resultEl = form.querySelector('#quoteResult');

  if (weightSlider && weightDisplay) {
    weightSlider.addEventListener('input', () => {
      weightDisplay.textContent = weightSlider.value;
    });
  }

  // Range slider → parcel quote page; hidden weight input → ride estimate page.
  const type = weightSlider && weightSlider.type === 'range' ? 'parcel' : 'ride';

  form.addEventListener('submit', async e => {
    e.preventDefault();
    const origin = form.querySelector('#origin').value.trim();
    const dest = form.querySelector('#destination').value.trim();
    const weight = parseFloat(weightSlider?.value || 1);

    if (!origin || !dest) {
      showToast('Please enter both origin and destination.');
      return;
    }

    try {
      const payload = { type, origin, destination: dest };
      if (type === 'parcel') payload.weight_kg = weight;
      const res = await hgApiRetry('POST', '/public/quotes', payload);
      const q = res.quote;
      if (resultEl) {
        resultEl.style.display = '';
        resultEl.textContent = '';
        const lead = document.createTextNode('Estimated Total: ');
        const strong = document.createElement('strong');
        strong.textContent = `৳${q.fare}`;
        resultEl.appendChild(lead);
        resultEl.appendChild(strong);
        const hint = document.createElement('span');
        hint.style.display = 'block';
        hint.style.fontSize = '0.75rem';
        hint.style.opacity = '0.7';
        hint.textContent = (res.estimated ? 'Based on an estimated distance — ' : '') + 'live rates from HillGo pricing';
        resultEl.appendChild(hint);
      } else {
        showToast(`Estimated fare: ৳${q.fare}`);
      }
    } catch (err) {
      showToast(err.message || 'Could not fetch a quote right now.');
    }
  });
}

/* City availability (Region Lock) forms */
function initAvailabilityForms() {
  document.querySelectorAll('.availability-form').forEach(form => {
    form.addEventListener('submit', async e => {
      e.preventDefault();
      const city = form.querySelector('input').value.trim();
      if (!city) return;
      try {
        const res = await hgApi('GET', `/public/availability?city=${encodeURIComponent(city)}`);
        if (res.available) {
          showToast(`Good news! HillGo is live in ${res.district} (${res.division}). Download the app to get started.`);
        } else {
          showToast(res.message || `HillGo hasn't launched in ${res.district || city} yet — we're expanding fast!`);
        }
      } catch (err) {
        showToast(err.message || 'Could not check availability right now.');
      }
    });
  });
}

/* Newsletter forms */
function initNewsletterForms() {
  document.querySelectorAll('.newsletter-form').forEach(form => {
    form.addEventListener('submit', async e => {
      e.preventDefault();
      const email = form.querySelector('input[type="email"]').value.trim();
      if (!email) return;
      try {
        const res = await hgApiRetry('POST', '/public/newsletter', { email });
        showToast(res.already ? 'You are already subscribed — thanks!' : 'Thanks for subscribing!');
        form.reset();
      } catch (err) {
        showToast(err.message || 'Subscription failed. Try again.');
      }
    });
  });
}

/* Contact + partner application forms */
function initContactForm() {
  const form = document.getElementById('contactForm');
  if (!form) return;

  const isContact = !!form.querySelector('#service'); // contact.html has a service select with an id

  form.addEventListener('submit', async e => {
    e.preventDefault();
    const btn = form.querySelector('button[type="submit"]');
    if (btn) btn.disabled = true;

    try {
      if (isContact) {
        const res = await hgApiRetry('POST', '/public/contact', {
          first_name: form.querySelector('#firstName').value.trim(),
          last_name: form.querySelector('#lastName').value.trim(),
          email: form.querySelector('#email').value.trim(),
          service_interest: form.querySelector('#service').value,
          message: form.querySelector('#message').value.trim(),
        });
        showToast(res.message || 'Thank you! Your message has been sent.');
      } else {
        // register.html partner application — prefer named fields
        const fullName = form.elements.full_name || form.querySelector('[name="full_name"]');
        const phone = form.elements.phone || form.querySelector('[name="phone"]');
        const email = form.elements.email || form.querySelector('[name="email"]');
        const vehicle = form.elements.vehicle_type || form.querySelector('[name="vehicle_type"]');
        const city = form.elements.city || form.querySelector('[name="city"]');
        const res = await hgApiRetry('POST', '/public/partner-applications', {
          full_name: fullName.value.trim(),
          phone: phone.value.trim(),
          email: email.value.trim(),
          vehicle_type: vehicle.value,
          city: city.value.trim(),
        });
        showToast(res.message || 'Application received. Our onboarding team will contact you.');
      }
      form.reset();
    } catch (err) {
      showToast(err.message || 'Submission failed. Please try again.');
    } finally {
      if (btn) btn.disabled = false;
    }
  });
}

/* FAQ search */
function initFaqSearch() {
  const searchInput = document.getElementById('faqSearch');
  if (!searchInput) return;

  searchInput.addEventListener('input', () => {
    const query = searchInput.value.toLowerCase();
    document.querySelectorAll('.faq-item').forEach(item => {
      const text = item.textContent.toLowerCase();
      item.style.display = text.includes(query) ? 'block' : 'none';
    });
  });
}

/* FAQ category filter */
function initFaqCategories() {
  const catBtns = document.querySelectorAll('.faq-cat-btn');
  if (!catBtns.length) return;

  catBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const category = btn.dataset.category;
      catBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      document.querySelectorAll('.faq-group').forEach(group => {
        group.style.display = (category === 'all' || group.dataset.category === category) ? 'block' : 'none';
      });
    });
  });
}

/* Animated counters */
function initCounterAnimation() {
  const counters = document.querySelectorAll('[data-count]');
  if (!counters.length) return;

  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        animateCounter(entry.target);
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.5 });

  counters.forEach(counter => observer.observe(counter));
}

function animateCounter(el) {
  const target = parseInt(el.dataset.count, 10);
  const suffix = el.dataset.suffix || '';
  const duration = 2000;
  const start = performance.now();

  function update(now) {
    const progress = Math.min((now - start) / duration, 1);
    const eased = 1 - Math.pow(1 - progress, 3);
    const current = Math.floor(eased * target);
    el.textContent = current.toLocaleString() + suffix;
    if (progress < 1) requestAnimationFrame(update);
  }

  requestAnimationFrame(update);
}

/* Toast notification (global for inline handlers) */
window.showToast = showToast;
function showToast(message) {
  let toast = document.querySelector('.toast');
  if (!toast) {
    toast = document.createElement('div');
    toast.className = 'toast';
    document.body.appendChild(toast);
  }
  toast.textContent = message;
  toast.classList.add('show');
  setTimeout(() => toast.classList.remove('show'), 4000);
}

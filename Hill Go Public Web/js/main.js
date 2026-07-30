// HillGo Public Website - Main JavaScript

document.addEventListener('DOMContentLoaded', () => {
  initHeader();
  initMobileNav();
  initFaq();
  initPricingTabs();
  initTrackForm();
  initTestimonials();
  initQuoteCalculator();
  initContactForm();
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
  });
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

/* Track order form */
function initTrackForm() {
  const form = document.getElementById('trackForm');
  if (!form) return;

  form.addEventListener('submit', e => {
    e.preventDefault();
    const trackingId = form.querySelector('input').value.trim();
    if (!trackingId) {
      showToast('Please enter a tracking number.');
      return;
    }
    showToast(`Tracking ${trackingId}: Your parcel is in transit. Estimated delivery within 24-48 hours.`);
    form.reset();
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

  form.addEventListener('submit', e => {
    e.preventDefault();
    const origin = form.querySelector('#origin').value.trim();
    const dest = form.querySelector('#destination').value.trim();
    const weight = parseFloat(weightSlider?.value || 1);

    if (!origin || !dest) {
      showToast('Please enter both origin and destination.');
      return;
    }

    const baseRate = 12.5;
    const weightRate = weight * 0.35;
    const distanceFactor = origin !== dest ? 1.4 : 1;
    const total = ((baseRate + weightRate) * distanceFactor).toFixed(2);

    if (resultEl) {
      resultEl.innerHTML = `Estimated Total: <strong>$${total}</strong>`;
    }
  });
}

/* Contact form */
function initContactForm() {
  const form = document.getElementById('contactForm');
  if (!form) return;

  form.addEventListener('submit', e => {
    e.preventDefault();
    showToast('Thank you! Your message has been sent. We\'ll get back to you within 24 hours.');
    form.reset();
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

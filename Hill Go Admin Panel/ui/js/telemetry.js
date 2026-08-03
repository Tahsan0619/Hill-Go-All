/**
 * HillGoTelemetry — thin error-tracking shim.
 *
 * captureError(err, context) sends the error to Sentry when
 * `window.SENTRY_DSN` is configured (see js/config.js) and the Sentry
 * browser SDK has loaded successfully; otherwise it falls back to
 * `console.error` so behavior is unchanged in local/dev environments
 * that don't set a DSN.
 *
 * This module never throws: a telemetry failure must never break the
 * admin UI it's trying to instrument.
 */
window.HillGoTelemetry = (() => {
  let sentryLoadAttempted = false;

  function loadSentryOnce() {
    if (sentryLoadAttempted || !window.SENTRY_DSN || window.Sentry) return;
    sentryLoadAttempted = true;
    try {
      const script = document.createElement('script');
      script.src = 'https://browser.sentry-cdn.com/7.120.0/bundle.min.js';
      script.crossOrigin = 'anonymous';
      script.onload = () => {
        try {
          if (window.Sentry && typeof window.Sentry.init === 'function') {
            window.Sentry.init({ dsn: window.SENTRY_DSN });
          }
        } catch (_) { /* Sentry init failed — captureError keeps using console.error */ }
      };
      document.head.appendChild(script);
    } catch (_) { /* CSP or DOM restriction — fall back to console.error */ }
  }

  function captureError(err, context) {
    const error = err instanceof Error ? err : new Error(String(err));
    try {
      loadSentryOnce();
      if (window.SENTRY_DSN && window.Sentry && typeof window.Sentry.captureException === 'function') {
        window.Sentry.captureException(error, context ? { extra: { context } } : undefined);
        return;
      }
    } catch (_) { /* fall through to console.error below */ }
    console.error('[HillGoTelemetry]', context || '', error);
  }

  return { captureError };
})();

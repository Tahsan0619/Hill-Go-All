/**
 * Runtime configuration. Extracted out of index.html so the page's CSP
 * script-src can drop 'unsafe-inline' (see docs/remediation/REMEDIATION_ADMIN_PANEL.md #6).
 *
 * Production deployments should set these via a server-templated value
 * (or replace this file at deploy time) BEFORE store.js loads:
 *   window.HILLGO_API_BASE = 'https://api.hillgo.app/api';
 *   window.SENTRY_DSN = 'https://<key>@o0.ingest.sentry.io/0';
 */
window.HILLGO_API_BASE = window.HILLGO_API_BASE || 'http://127.0.0.1:8000/api';
window.SENTRY_DSN = window.SENTRY_DSN || '';

/**
 * Tailwind Play CDN theme config. Extracted out of index.html so the
 * page's CSP script-src can drop 'unsafe-inline' (see
 * REMEDIATION_ADMIN_PANEL.md #6). Must load AFTER the Tailwind CDN
 * <script> tag and BEFORE any markup that relies on these classes.
 */
tailwind.config = {
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: '#00327d',
        'primary-container': '#0047ab',
        'on-primary': '#ffffff',
        'on-primary-fixed': '#001946',
        'on-surface': '#191c1e',
        'on-surface-variant': '#434653',
        'surface-container-low': '#f3f4f6',
        'surface-container-lowest': '#ffffff',
        'surface-container-highest': '#e1e2e4',
        'surface-bright': '#f8f9fb',
        'surface-variant': '#e1e2e4',
        outline: '#737784',
        'outline-variant': '#c3c6d5',
        'secondary-container': '#d0e1fb',
        error: '#ba1a1a',
        background: '#f8f9fb',
      },
      spacing: {
        sidebar_width: '240px',
        header_height: '64px',
        container_padding: '24px',
      },
      fontFamily: { sans: ['system-ui', 'Segoe UI', 'sans-serif'] },
    },
  },
};

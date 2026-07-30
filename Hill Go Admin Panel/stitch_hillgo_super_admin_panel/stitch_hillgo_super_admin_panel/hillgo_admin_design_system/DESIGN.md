---
name: HillGo Admin Design System
colors:
  surface: '#f8f9fb'
  surface-dim: '#d9dadc'
  surface-bright: '#f8f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f6'
  surface-container: '#edeef0'
  surface-container-high: '#e7e8ea'
  surface-container-highest: '#e1e2e4'
  on-surface: '#191c1e'
  on-surface-variant: '#434653'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f3'
  outline: '#737784'
  outline-variant: '#c3c6d5'
  surface-tint: '#2559bd'
  primary: '#00327d'
  on-primary: '#ffffff'
  primary-container: '#0047ab'
  on-primary-container: '#a5bdff'
  inverse-primary: '#b1c5ff'
  secondary: '#505f76'
  on-secondary: '#ffffff'
  secondary-container: '#d0e1fb'
  on-secondary-container: '#54647a'
  tertiary: '#651f00'
  on-tertiary: '#ffffff'
  tertiary-container: '#8b2e01'
  on-tertiary-container: '#ffaa8a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2ff'
  primary-fixed-dim: '#b1c5ff'
  on-primary-fixed: '#001946'
  on-primary-fixed-variant: '#00419e'
  secondary-fixed: '#d3e4fe'
  secondary-fixed-dim: '#b7c8e1'
  on-secondary-fixed: '#0b1c30'
  on-secondary-fixed-variant: '#38485d'
  tertiary-fixed: '#ffdbcf'
  tertiary-fixed-dim: '#ffb59a'
  on-tertiary-fixed: '#380d00'
  on-tertiary-fixed-variant: '#802900'
  background: '#f8f9fb'
  on-background: '#191c1e'
  surface-variant: '#e1e2e4'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  title-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
  data-mono:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  sidebar_width: 240px
  header_height: 64px
  container_padding: 24px
  gutter: 16px
  card_gap: 20px
  base_unit: 4px
---

## Brand & Style
The design system is engineered for high-utility logistics management, balancing information density with visual clarity. The personality is industrious, reliable, and systematic, catering to operations managers handling complex supply chains in Bangladesh. 

The visual style follows a **Modern Corporate** aesthetic. It utilizes a layered approach where a cool gray canvas provides a neutral foundation for elevated white containers. This clear distinction between the workspace and the content area reduces cognitive load during prolonged usage. The interface prioritizes functional precision, using high-contrast typography and clear status indicators to ensure critical data is digestible at a glance.

## Colors
The palette is anchored by **Cobalt Blue (#0047AB)**, signaling stability and professional trust. This is used exclusively for primary actions and active navigational states.

- **Canvas:** The global background uses `#F3F4F6` (Gray 100) to define the workspace boundaries.
- **Surface:** All interactive content and data containers reside on pure `#FFFFFF` white surfaces to maximize legibility.
- **Status:** Semantic colors are strictly enforced for logistics tracking:
  - **Success (#10B981):** Completed deliveries, active drivers, paid invoices.
  - **Warning (#F59E0B):** Delayed shipments, low fuel, pending verification.
  - **Danger (#EF4444):** Canceled orders, emergency alerts, critical stock-outs.

## Typography
**Inter** is the sole typeface for this design system, chosen for its exceptional legibility in data-heavy environments. 

- **Weight Usage:** Use **700 (Bold)** for primary page headers, **600 (SemiBold)** for sub-sections and UI labels, **500 (Medium)** for table headers and interactive components, and **400 (Regular)** for long-form data and body text.
- **Numeric Data:** For currency (৳ BDT) and tracking IDs, ensure tabular figures are utilized to maintain vertical alignment in lists and tables.
- **Hierarchy:** Maintain a clear distinction between "Labels" (metadata descriptions) and "Body" (actual data values). Labels should typically use the `label-sm` or `label-md` roles in a muted secondary gray.

## Layout & Spacing
The layout follows a rigid structural grid to accommodate complex administrative workflows.

- **Sidebar:** A fixed **240px** left-hand navigation bar. Use a dark or high-contrast theme within the sidebar to separate navigation from the primary work area.
- **Header:** A **64px** persistent top bar containing breadcrumbs, search, and profile actions.
- **Canvas Padding:** The main content area utilizes a **24px (1.5rem)** internal padding from the edges of the viewport.
- **Grid System:** Components align to an 8px square grid. Vertical spacing between related elements should be 8px or 16px, while spacing between distinct sections or cards should be 24px.
- **Density:** Tables and lists should utilize a "Compact" density model (vertical cell padding of 12px) to ensure maximum data visibility without scrolling.

## Elevation & Depth
Depth is used functionally to indicate hierarchy and interactivity. 

- **Level 0 (Canvas):** `#F3F4F6` background. No shadow.
- **Level 1 (Cards/Tables):** Pure white background with a 1px border (`#E2E8F0`) and a soft ambient shadow (0px 1px 3px rgba(0,0,0,0.1)).
- **Level 2 (Popovers/Dropdowns):** Elevated surfaces for temporary actions. Use a more pronounced shadow: 0px 10px 15px -3px rgba(0,0,0,0.1), 0px 4px 6px -2px rgba(0,0,0,0.05).
- **Level 3 (Modals):** Centered overlays with a 40% opacity black backdrop blur to focus the user's attention.

## Shapes
The shape language is professional and modern, using "Rounded" corners to soften the density of the data.

- **Primary Containers:** Large cards, modals, and main content areas use a **12px** corner radius.
- **UI Elements:** Buttons, input fields, and smaller components use an **8px** (0.5rem) radius.
- **Badges:** Status badges (e.g., "In Transit") use a semi-rounded or pill-shaped style (**24px**) to distinguish them from interactive buttons.
- **Icons:** Use a consistent 24px bounding box with a 2px stroke weight to match the Inter typography.

## Components
- **Buttons:** 
  - **Primary:** Cobalt background, white text, 8px radius.
  - **Secondary:** White background, Cobalt border, Cobalt text.
  - **Ghost:** No background/border, used for "Cancel" or low-priority actions.
- **KPI Cards:** White cards featuring a `label-sm` title, a `headline-md` value, and a small trend indicator (using semantic success/danger colors).
- **Data Tables:**
  - Headers: Sticky at the top, light gray background (`#F8FAFC`), `label-md` typography.
  - Rows: Alternating zebra striping is not required; use a subtle 1px bottom border (`#F1F5F9`) instead.
- **Status Badges:** Small containers with 10% opacity of the semantic color for the background and 100% opacity for the text (e.g., Success badge: Light green bg, dark green text).
- **Input Fields:** 1px border (`#D1D5DB`), transitions to Cobalt 2px border on focus. Include a ৳ prefix for BDT currency inputs.
- **Sidebar Nav:** High-contrast icons, 14px font size, with a vertical 4px blue "active" indicator on the left edge of the selected item.
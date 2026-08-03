# HillGo Super Admin — Stitch Screen Spec

> **Runtime note (updated in REMEDIATION_ADMIN_PANEL.md):** the live admin
> panel (`ui/`) runs against the real Laravel API via `js/store.js` — it is
> **not** frontend-only / mock data. The "frontend-only" / "mock data"
> language below describes the **design-only Stitch mock HTML** in
> `stitch_hillgo_super_admin_panel/` (used purely to generate visual specs
> for new screens), not the shipped runtime. When implementing any screen
> from this spec, wire it to `AppStore`/`store.js` exactly like the existing
> screens — do not reintroduce `seed.js` or `localStorage` mock storage.
>
> Frontend-only expansion of the existing `Hill Go Admin Panel`.  
> Source of truth for fields: actual code in Customer / Rider / Vendor / Courier apps.  
> Use this MD in **Google Stitch** to generate the missing screens. Keep the same design set as the current admin UI.

---

## 1. Goal

The super admin controls everything from one panel. The shipped admin panel (`ui/`) runs against the live Laravel API (see runtime note above) — new screens generated from this spec should be wired the same way, not left as static/mock data.

When the admin opens the panel they must clearly see:

| Hub | Maps to app |
|-----|-------------|
| **Customer Panel** | Hill Go Main Customer App |
| **Rider Panel** | Rider Driver App |
| **Merchant Panel** | Vendor Marchant App |
| **Courier Panel** | Courier Agent App |

**Outside those four panels** (global, top-level):

| Hub | Purpose |
|-----|---------|
| **Region Lock** | Open / close Bangladesh divisions & districts for registration & ops |
| Overview / Settings | Keep existing screens; extend lightly |

---

## 2. Current admin vs what to add

### Already exists (keep / reuse layout)

| Screen | Status |
|--------|--------|
| Overview | Keep |
| Users | Keep as base; later split into panel-specific user lists |
| Fleet | Keep; Rider/Courier vehicle pieces move under panels |
| Finance | Keep as global ledger; panel payouts also live inside each panel |
| Marketplace & Content | Keep; Customer + Merchant catalog pieces deepen under panels |
| System Settings | Keep |

### New sidebar information architecture (target)

```
HillGo Admin
├── Overview syn (existing)
├── Region Lock                    ← NEW (global)
├── Customer Panel                 ← NEW hub
│   ├── Dashboard
│   ├── Customers
│   ├── Rides
│   ├── Food Orders
│   ├── Parcels
│   ├── Marketplace
│   ├── Hotels & Rentals
│   ├── Wallet & Loyalty
│   ├── Promos & Vouchers
│   └── Pricing Parameters
├── Rider Panel                    ← NEW hub
│   ├── Dashboard
│   ├── Riders
│   ├── KYC Queue
│   ├── Trips / Jobs
│   ├── Earnings & Salary Pay
│   ├── Payout Log
│   └── Pricing Parameters
├── Merchant Panel                 ← NEW hub
│   ├── Dashboard
│   ├── Merchants / Stores
│   ├── Onboarding Queue
│   ├── Orders
│   ├── Catalog Oversight
│   ├── Payouts
│   └── Pricing Parameters
├── Courier Panel                  ← NEW hub
│   ├── Dashboard
│   ├── Agents
│   ├── KYC / Docs
│   ├── Parcels
│   ├── Earnings & Withdrawals
│   ├── Incentives
│   └── Pricing Parameters
├── Finance (existing global)
├── Content (existing)
└── Settings (existing)
```

Stitch only needs the **new** screens listed in **Section 8**. Reuse existing chrome (sidebar, header, cards, tables, pills, modals).

---

## 3. Region Lock (global — outside the four panels)

### Purpose

Admin opens a **district** → from that moment vendors / riders / couriers / customers in that district can register and operate. Closed district = registration blocked for that area.

### Structure

1. **8 Divisions** (Bangladesh)
2. Under each division → **Districts** (64 official)
3. Each district has: `Open` | `Closed` (+ optional open date, note)

### Screen A — Region Lock Overview

- KPI row: Divisions open count · Districts open · Districts closed · Last change
- Grid/list of **8 division cards**
  - Division name
  - X / Y districts open
  - Quick status: Fully open / Partial / Closed
  - Click → Division detail

### Screen B — Division Detail

- Header: division name + “Open all” / “Close all”
- Table of districts in that division:
  - District name
  - Status toggle (Open / Closed)
  - Opened at (date)
  - Note (optional text)
  - Affected apps checkboxes (optional, default all four): Customer · Rider · Merchant · Courier

### Screen C — District Drawer / Modal (edit one district)

Fields:

| Field | Type |
|-------|------|
| Division | read-only |
| District | read-only |
| Status | Open / Closed |
| Opened at | date-time |
| Allow Customer registration | toggle |
| Allow Rider registration | toggle |
| Allow Merchant registration | toggle |
| Allow Courier registration | toggle |
| Internal note | textarea |
| Save | primary button |

### Division → District master list (for mock data / Stitch labels)

**Dhaka:** Dhaka, Faridpur, Gazipur, Gopalganj, Kishoreganj, Madaripur, Manikganj, Munshiganj, Narayanganj, Narsingdi, Rajbari, Shariatpur, Tangail  

**Chattogram:** Bandarban, Brahmanbaria, Chandpur, Chattogram, Cumilla, Cox's Bazar, Feni, Khagrachhari, Lakshmipur, Noakhali, Rangamati  

**Rajshahi:** Bogura, Chapainawabganj, Joypurhat, Naogaon, Natore, Pabna, Rajshahi, Sirajganj  

**Khulna:** Bagerhat, Chuadanga, Jashore, Jhenaidah, Khulna, Kushtia, Magura, Meherpur, Narail, Satkhira  

**Barishal:** Barguna, Barishal, Bhola, Jhalokathi, Patuakhali, Pirojpur  

**Sylhet:** Habiganj, Moulvibazar, Sunamganj, Sylhet  

**Rangpur:** Dinajpur, Gaibandha, Kurigram, Lalmonirhat, Nilphamari, Panchagarh, Rangpur, Thakurgaon  

**Mymensingh:** Jamalpur, Mymensingh, Netrokona, Sherpur  

*(64 districts total.)*

---

## 4. Customer Panel

Based on Customer app routes + `FareConfig` + dummy entities (rides, food, parcel, market, hotel, rental, wallet, SOS).

### 4.1 Dashboard

KPIs: Active customers · Rides today · Food orders · Parcels · Wallet volume · Open SOS alerts  

Simple charts: rides vs food vs parcel (reuse existing chart style).

### 4.2 Customers

Table: Name · Phone · Email · Wallet ৳ · Loyalty pts · Status · District · Actions (view / suspend)

Detail drawer: addresses count · payment methods · last ride · loyalty tier

### 4.3 Rides

Table: Ride ID · Customer · Driver · Pickup → Drop · Fare ৳ · Status · Date  

Statuses from app: Searching / Assigned / In progress / Completed / Cancelled

### 4.4 Food Orders

Table: Order ID · Restaurant · Customer · Items total · Delivery fee · Status · Date  

Statuses: Placed → Preparing → On the way → Delivered

### 4.5 Parcels (customer-booked)

Table: Tracking ID · Type · Pickup → Destination · Weight · Distance · Fare · Status

### 4.6 Marketplace

Tabs: Products · Categories  

Fields per product: name · category · price · status (active/hidden)

### 4.7 Hotels & Rentals

Two tabs:

- Hotels: name · location · stars · price/night · status  
- Rentals: vehicle · category · price/day · with-driver fee · insurance fee · status

### 4.8 Wallet & Loyalty

- Wallet top-up / adjust balance (mock form)  
- Transaction list: title · amount · credit/debit · date  
- Loyalty tiers: Bronze / Silver / Gold / Platinum (edit point thresholds)  
- Redeemable rewards list (CRUD mock)

### 4.9 Promos & Vouchers

Fields: title · description · code (e.g. HILLGO30) · type (ride % / free delivery / wallet cashback) · min order ৳ · expiry · active

### 4.10 Pricing Parameters (Customer)

Editable form cards (values from code — admin can change mock defaults):

| Parameter | Current code value | Notes |
|-----------|-------------------|--------|
| Ride base fare | ৳30 | `FareConfig.baseFare` |
| Ride per km | ৳15 | `ratePerKm` |
| Ride per minute | ৳1 | `ratePerMin` |
| Ride minimum fare | ৳50 | `minimumFare` |
| Food delivery fee (customer) | ৳30 | cart/checkout |
| Free delivery threshold | ৳300 | notification/voucher logic |
| Parcel base | unify to ৳ (admin) | customer demo was USD-like — **set BDT here** |
| Parcel per km | ৳12 suggested | align with rider |
| Parcel per kg | ৳8 suggested | align with rider |
| Parcel minimum | ৳50 | |
| Marketplace delivery fee | set ৳ (replace $3.99) | |
| Hotel service fee % | 5% | |
| Rental driver fee / day | ৳1500 | |
| Rental insurance / day | ৳300 | |

Currency everywhere in admin: **৳ BDT**.

---

## 5. Rider Panel

Based on Rider app models + `RiderFareConfig` + onboarding/KYC + payouts.

### 5.1 Dashboard

KPIs: Online riders · Trips today · Today earnings pool · Pending KYC · Pending salary/payouts

### 5.2 Riders

Table: Name · Phone · Vehicle (Bike/Car/XL) · Plate · Rating · Online · District · Status (Active / Suspended / Onboarding)

Detail: personal info · vehicle · docs summary · today’s earnings

### 5.3 KYC Queue

Docs from code: Driver’s License **or Token** · NID · Vehicle Registration (blue book) · Rider Photo  

Table: Rider · Doc type · Status (pending / actionRequired / uploaded / verified) · Submitted · Actions (Approve / Reject / Request reupload)

### 5.4 Trips / Jobs

Filters: Ride · Food · Parcel  

Columns: Job ID · Type · Rider · Route · km · Earning ৳ · Payment (Cash/Digital) · Surge × · Status · COD amount (if any)

Statuses follow app machines (requested → accepted → … → completed / cancelled).

### 5.5 Earnings & Salary Pay  ★ required

Super admin **pays rider salary / settlement** from here, then logs it so the site tracks who was paid.

**Pay Salary form**

| Field | Type |
|-------|------|
| Rider | search select |
| Period | From – To dates (or “This week”) |
| Gross earnings | auto from mock trips |
| Tips | number |
| Surge bonuses | number |
| Deductions | number |
| Net pay | auto |
| Pay method | bKash / Nagad / Bank |
| Transaction ref | text |
| Note | textarea |
| Mark as Paid | primary button |

After pay → row appears in **Payout Log** with status `Paid`.

### 5.6 Payout Log

Table: Payout ID · Rider · Amount ৳ · Method · Period · Ref · Paid at · Status (Paid / Failed / Pending)

### 5.7 Pricing Parameters (Rider)

| Parameter | Current code value |
|-----------|-------------------|
| Ride base | ৳30 |
| Per km | ৳15 |
| Per min | ৳1 |
| Minimum fare | ৳50 |
| Bike multiplier | 0.7 |
| Car multiplier | 1.0 |
| XL multiplier | 1.5 |
| Food job fee (rider earn) | ৳30 flat |
| Parcel base | ৳40 |
| Parcel per km | ৳12 |
| Parcel per kg | ৳8 |
| Parcel minimum | ৳50 |
| Default surge multiplier | 1.8 (home mock) |
| Platform commission % on rider job | **add** (not in app yet — admin-owned, e.g. 15%) |

---

## 6. Merchant Panel

Based on Vendor app: store, products, orders, revenue, payouts, reviews, onboarding.

### 6.1 Dashboard

KPIs: Active stores · Orders today · GMV · Pending payouts · Avg rating · Stores in closed districts (blocked)

### 6.2 Merchants / Stores

Table: Store name · Owner · Category · City/District · Open · Accepting orders · Status · Actions

Detail: address · hours · branding · specialties · profile strength

Business categories from onboarding code: Restaurant & Cafe · Grocery & Market · Bakery · Electronics · Fashion & Apparel · Home & Lifestyle · Health & Beauty · Other

### 6.3 Onboarding Queue

Fields from `OnboardingData`: businessName · description · logo · storefront · category · subcategories · contact · phone · email · address · city · zip · district (tie to Region Lock)

Actions: Approve · Reject · Request changes

### 6.4 Orders

Table: Order ID · Store · Customer · Priority (standard/priority/express/scheduled) · Status · Items · Totals · Date  

Statuses: newOrder → preparing → ready → delivered / rejected

### 6.5 Catalog Oversight

Read-only-ish admin view: products across stores · low stock alerts · hidden categories (`isVisible`)

### 6.6 Payouts

Table: Store · Amount · Method · Status (completed / pending / processing) · Early payout request? · Actions (Approve early payout / Mark paid)

### 6.7 Pricing Parameters (Merchant)

| Parameter | Current / proposed |
|-----------|-------------------|
| Platform commission % on order | **add** (e.g. 15%) — main app take |
| Order service fee | was $2.50 → set **৳** amount |
| Tax / VAT % | was 9.4% → set BD VAT if needed (e.g. 5%) or 0 for mock |
| Settlement cycle | Weekly / Daily |
| Early payout fee % | **add** |
| Min payout amount ৳ | **add** |

---

## 7. Courier Panel

Based on Courier Agent app: parcels, OTP pickup/delivery, earnings, withdraw, incentives.

### 7.1 Dashboard

KPIs: Active agents · Parcels in transit · Delivered today · Pending withdrawals · Active incentives

### 7.2 Agents

Table: Name · Phone · Vehicle · Plate · Rating · Total deliveries · Verified · District · Status

### 7.3 KYC / Docs

Docs: License · NID · Vehicle registration (+ expiry)  

Approve / Reject / Mark bank verified

### 7.4 Parcels

Table: Order ID · Priority · Agent · Pickup → Drop · Weight · Distance · Est. earnings · Surge bonus · Status  

Statuses: assigned → pickedUp → inTransit → delivered / failed  

Optional: OTP confirmation log (pickup OTP / delivery OTP — demo `123456`)

### 7.5 Earnings & Withdrawals

- Earnings list: base pay · tips · surges · date  
- Withdrawal queue: agent · amount · bank last4 · status  
- Admin: Approve withdrawal / Reject / Mark paid (same salary-tracking idea as riders)

### 7.6 Incentives

CRUD from app patterns:

| Field | Example |
|-------|---------|
| Title | Weekend 1.5x |
| Description | … |
| Multiplier | 1.5 |
| Zone / district | optional (Region Lock link) |
| Goal (e.g. 8 deliveries) | number |
| Bonus ৳ | flat bonus |
| Valid until | date |
| Active | toggle |

### 7.7 Pricing Parameters (Courier)

App has precomputed parcel earnings — admin defines the rules:

| Parameter | Suggested admin fields |
|-----------|------------------------|
| Parcel base pay | ৳ amount |
| Per km rate | ৳ / km |
| Per kg rate | ৳ / kg |
| Express / priority multipliers | numbers |
| Surge bonus cap | ৳ |
| Platform commission % (main app take) | **%** — user-requested |
| Weekly goal deliveries | number |
| Top performer bonus multiplier | e.g. 1.2x |
| Withdrawal min amount | ৳ |

---

## 8. Screens to generate in Google Stitch

Generate **only these** (match existing admin chrome). One frame per screen unless noted.

### Global

| # | Screen name | Priority |
|---|-------------|----------|
| G1 | Region Lock — Overview (8 division cards) | High |
| G2 | Region Lock — Division Detail (district table + toggles) | High |
| G3 | Region Lock — District Edit Modal | High |
| G4 | Main shell update — sidebar with 4 Panel hubs + Region Lock | High |

### Customer Panel

| # | Screen name | Priority |
|---|-------------|----------|
| C1 | Customer Panel — Dashboard | High |
| C2 | Customers — List | High |
| C3 | Customer — Detail Drawer | Medium |
| C4 | Rides — List | High |
| C5 | Food Orders — List | Medium |
| C6 | Customer Parcels — List | Medium |
| C7 | Marketplace — Products | Medium |
| C8 | Hotels & Rentals — Tabs | Low |
| C9 | Wallet & Loyalty | Medium |
| C10 | Promos & Vouchers | Medium |
| C11 | Customer Pricing Parameters | High |

### Rider Panel

| # | Screen name | Priority |
|---|-------------|----------|
| R1 | Rider Panel — Dashboard | High |
| R2 | Riders — List | High |
| R3 | KYC Queue | High |
| R4 | Trips / Jobs — List | High |
| R5 | Pay Salary — Form + confirm | High |
| R6 | Payout Log | High |
| R7 | Rider Pricing Parameters | High |

### Merchant Panel

| # | Screen name | Priority |
|---|-------------|----------|
| M1 | Merchant Panel — Dashboard | High |
| M2 | Merchants / Stores — List | High |
| M3 | Onboarding Queue | High |
| M4 | Orders — List | High |
| M5 | Catalog Oversight | Low |
| M6 | Merchant Payouts | High |
| M7 | Merchant Pricing Parameters | High |

### Courier Panel

| # | Screen name | Priority |
|---|-------------|----------|
| K1 | Courier Panel — Dashboard | High |
| K2 | Agents — List | High |
| K3 | Courier KYC / Docs | High |
| K4 | Parcels — List | High |
| K5 | Withdrawals / Pay Agent | High |
| K6 | Incentives — List + Form | Medium |
| K7 | Courier Pricing Parameters | High |

**Stitch count (recommended first batch):** G1–G4, C1–C2, C11, R1–R7, M1–M4, M6–M7, K1–K5, K7 → **~28 screens**. Rest can be phase 2.

---

## 9. Shared UI patterns (do not reinvent)

Copy from existing admin:

- Left sidebar 240px, white, active item = light blue bg + cobalt text + 3px right bar  
- Top header 64px: search pill · notifications · avatar  
- Page title `h2` + short subtitle + right-side primary button  
- KPI cards in a responsive row  
- White content cards, 12px radius, light shadow  
- Tables with uppercase muted headers  
- Status badges with colored dots  
- Filter pills + underline tabs  
- Modal max-width ~520px (wide forms can be 640–720px)  
- Toast bottom-center for success/error  
- Primary actions = cobalt button; destructive = red text/button; Support accent orange only for FAB/support (existing)

**Do not** use Public Web navy/`#2563eb` tokens. Admin brand is Cobalt.

---

## 10. Design tokens & combination (for Stitch)

Paste these into Stitch as the design system.

### Colors

| Token | Hex | Use |
|-------|-----|-----|
| Primary | `#0047AB` | Brand, active nav, primary buttons, links |
| Primary dark | `#003580` | Button hover / pressed |
| Primary light | `#E8F0FE` | Active nav bg, soft highlights |
| Blue soft | `#DBEAFE` | Info chips / icon wells |
| Background | `#F3F4F6` | App canvas |
| Card | `#FFFFFF` | Sidebar, cards, header |
| Text | `#1F2937` | Primary text, dark buttons |
| Text secondary | `#6B7280` | Subtitles, labels |
| Text muted | `#9CA3AF` | Hints, table headers |
| Border | `#E5E7EB` | Dividers, inputs, sidebar edge |
| Success | `#10B981` | Open district, Paid, Active |
| Success bg | `#D1FAE5` | Success badge fill |
| Warning | `#F59E0B` | Pending, processing |
| Warning bg | `#FEF3C7` | Warning badge fill |
| Danger | `#EF4444` | Closed district, Reject, Suspended |
| Danger bg | `#FEE2E2` | Danger badge fill |
| Accent orange | `#F97316` | Support / FAB only (existing) |
| Accent orange hover | `#EA580C` | |

### Typography

- Font: **Inter** (400, 500, 600, 700)  
- Page title: 1.5rem / 700  
- Card title: 1rem / 600  
- Nav: 0.9rem / 500 (active 600)  
- KPI value: 1.75rem / 700  
- Table header: 0.7rem / 600 / uppercase / tracking 0.04em  
- Body line-height: 1.5  

### Layout & shape

| Token | Value |
|-------|--------|
| Sidebar width | 240px |
| Header height | 64px |
| Radius | 12px (cards) / 8px (inputs, small) |
| Pill radius | 20px |
| Content padding | 24px 28px |
| Card padding | 20px 24px |
| Shadow | `0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)` |
| Transition | 0.2s ease |

### Design combination (one-liner for Stitch)

> Light enterprise admin: gray canvas `#F3F4F6`, white cards, **Cobalt `#0047AB`** primary, Inter font, 12px rounded cards, soft shadows, status colors green/amber/red, 240px left sidebar, dense but clean data tables — same visual language as current HillGo Admin, Bangladesh ops (৳, divisions/districts).

---

## 11. After Stitch

1. Export / save Stitch frames into a folder (e.g. `Hill Go Admin Panel/stitch-exports/`).  
2. Hand that folder back in chat.  
3. Implementation pass will rebuild those screens into the existing vanilla HTML/CSS/JS admin (`ui/index.html`, `js/app.js`, `js/store.js`, `js/pages/*.js`) wired to the live Laravel API via `store.js`, matching every other screen — no mock data / no `seed.js`.

---

## 12. Out of scope (for this Stitch pack)

- Real API / auth / database  
- Connecting the four Flutter apps  
- Redesigning Public Web  
- Changing mobile app UI  
- Over-building analytics or AI features  

Keep screens practical: lists, forms, toggles, KPI cards, parameters.

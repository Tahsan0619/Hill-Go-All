# HillGo — Laravel + MySQL Backend Build Prompt

> **How this file is built:** Context was added **incrementally** (passes 1–5). All six surfaces are **COVERED**.  
> **Stack:** Laravel (monolith API + admin auth) · MySQL · REST JSON · BDT (৳) · timezone `Asia/Dhaka`.  
> **Non-negotiables:** No placeholders · no stubbed “TODO later” business logic · no scoped-down features · **no mock data** · **no localStorage / SharedPreferences business state** · **no toast-only fake success** · everything **fully dynamic** from MySQL via Laravel · **real-time** where ops require it · **working notification system** · **fully responsive** UI on every surface · **security & hardening** per companion docs.  
> **Security companions (mandatory):** `SECURITY.md` (policy) · `SECURITY_PATCH.md` (actionable patches). Soft wording here is overridden by those files for auth, secrets, BOLA, money integrity, rate limits, and audit.

---

## Progress tracker (incremental context)

| Surface | Repo folder | Status in this prompt |
|---------|-------------|------------------------|
| Public website | `Hill Go Public Web` | **COVERED** (pass 1) |
| Super Admin Panel | `Hill Go Admin Panel` | **COVERED** (pass 1) |
| Customer App | `Hill Go Main Customer App` | **COVERED** (pass 2) |
| Rider / Driver App | `Rider Driver App` | **COVERED** (pass 3) |
| Vendor / Merchant App | `Vendor Marchant App` | **COVERED** (pass 4) |
| Courier Agent App | `Courier Agent App` | **COVERED** (pass 5) |

**Six interconnect targets:** Public Web · Admin Panel · Customer · Rider · Merchant · Courier — one shared Laravel + MySQL backend.

---

## 0. Mission

Build one **monolithic Laravel + MySQL backend** that is the **only** system of record for HillGo. Wire the Super Admin Panel, Public Web, and all four Flutter apps so every screen reads/writes live database state. After wiring: **delete every mock/demo/dummy path** so not a single client-side fake dataset remains.

### Hard rules for the implementer

1. **Source of truth for admin behavior** = current Admin Panel JS contracts (`js/store.js` method names / field shapes). Replace bodies with HTTP → Laravel → MySQL. Keep UI routes; **remove** `localStorage` persistence and `resetData` mock restore.  
2. **Currency / locale:** Bangladesh, BDT (৳), phone `+880…`, districts = official 64 under 8 divisions.  
3. **Zero mock / zero local business storage** — see **§0A** (mandatory for all six surfaces).  
4. **Region Lock is global:** Closed district blocks registration/ops for Customer / Rider / Merchant / Courier per `allow_*` flags.  
5. **All six surfaces COVERED** — implement full interconnect; no invented extra apps.  
6. **Notifications are real** — persist in MySQL, deliver to in-app notification centers (+ FCM/Web push where applicable). Do not use toast/snackbar as a substitute for the notification system.  
7. **Responsive UI** — Admin, Public Web, and all Flutter apps must work correctly on mobile and desktop viewports; no broken overflow/clipped critical actions.  
8. **Database is mandatory** — every list, KPI, form submit, status change, payout, and track query hits MySQL. If MySQL is empty (except allowed structural seed), UIs show empty states — never fabricated rows.  
9. **Security is mandatory** — follow `SECURITY.md` + `SECURITY_PATCH.md`. Opaque hashed tokens (no PII/balances in token strings); secrets only in `.env`; role middleware on route groups; BOLA/ownership checks; server-side money math; throttle auth/OTP; private KYC + signed URLs; append-only audit on wallet/payout/KYC/pricing/region; `APP_DEBUG=false` in production; CORS allow-list. Security must **not** skip indexes/cache/queues/pagination (see security §Perf).

---

## 0A. ZERO MOCK DATA · FULLY DYNAMIC · REAL-TIME MANDATE

This section overrides any softer wording elsewhere in this file (e.g. “demo credentials”, “seed sample rides”, “toast mocks”).

### A. Delete all client mock traces (required)

For **each** of the following, remove mock/demo data sources so **no file remains that fabricates business entities** at runtime. Replace with API clients that only display server responses.

| Surface | Must delete / stop using (non-exhaustive — purge every equivalent) |
|---------|---------------------------------------------------------------------|
| **Admin Panel** | `localStorage` key `hillgo-admin-v1`; client-side `HillGoSeed` as live data; `AppStore.resetData()` restoring mocks; any in-browser mutable “database” |
| **Public Web** | Toast-only handlers in `js/main.js` that fake track/contact/quote/availability/newsletter/partner apply without `fetch` |
| **Customer App** | `lib/data/dummy_data.dart` as data source; `DemoAuthService` / demo login banner; in-memory `FoodCartStore`/`MarketplaceCartStore` as sole persistence (cart may be session until checkout, but checkout + history must hit API); `NotificationService` hard-coded list; `SosService` in-memory-only |
| **Rider App** | `MockAuthRepository`, `MockTripRepository`, `MockDocumentRepository`; SharedPreferences session that invents a full rider without API; hard-coded offer builders |
| **Merchant App** | `MockAuthRepository`, `MockOrderRepository`, `MockProductRepository`, `MockStoreRepository`; SharedPreferences fake user/store |
| **Courier App** | `MockData`, `MockAuthRepository`, `MockParcelRepository`, `MockEarningsRepository`, `MockProfileRepository`, `MockNotificationRepository`; hard-coded OTP always-accept without server |

**Rule:** After cleanup, a grep for `dummy_`, `Mock`, `DemoAuth`, `localStorage`, `hillgo-admin-v1`, `showToast('Thank you`, hard-coded trip/order arrays used as production data must find **zero** production paths.

### B. What the backend may seed (only this)

MySQL seeders may insert **structural / config** data only:

1. **8 divisions + 64 districts** (Region Lock master list) — statuses may default open/closed as product requires.  
2. **Default pricing** rows for customer / rider / merchant / courier panels.  
3. **One `super_admin` account** (credentials documented for ops).  
4. Optional: default loyalty tier thresholds, empty promo table, settings row (`orgName`, timezone `Asia/Dhaka`).

**Do not** seed fleets of fake customers, riders, merchants, courier agents, rides, food orders, parcels, payouts, reviews, or wallets as “demo content.” Operational tables start **empty**.

**Single optional smoke row:** At most **one** of each entity type may exist **only if created through the backend** (seeder calling the same services/factories as production, or Admin UI after login). Clients must **never** create that row locally. Prefer empty + empty-state UI.

### C. Fully dynamic (every surface)

- Lists, KPIs, maps, balances, catalogs, queues = **API → MySQL** only.  
- Creating/updating/deleting in any app must persist in MySQL and appear in Admin (and sibling apps) without refresh hacks that re-inject mocks.  
- Pricing, Region Lock, incentives, promos, commissions = Admin-changed values apply to the next calculation immediately (read from DB on each quote/dispatch).  
- Auth tokens via Sanctum; session restore from API/`/me`, not from inventing a preset user in SharedPreferences.

### D. No localStorage / no local business DB

Forbidden for business state:

- Browser `localStorage` / `sessionStorage` for entities, wallets, orders, region locks, pricing.  
- Flutter `SharedPreferences` / Hive / files as source of truth for users, trips, catalogs, notifications, earnings.  

Allowed local-only: ephemeral UI (theme, last tab index, draft form text not yet submitted), secure token storage for Sanctum **opaque** access token (never KYC/finance blobs in localStorage).

### E. No toast-as-success / no fake confirmations

- **Forbidden:** `showToast` / `SnackBar` that claims “Sent / Tracked / Paid / Applied” without a successful API response.  
- Public Web, Admin, and apps: show **inline validation errors** and **API error messages**; on success, update UI from response body and/or push into the **notification center**.  
- Transient SnackBar/toast is allowed **only** as secondary echo of a real API success (optional), never as the sole “persistence.” Prefer dedicated success panels / status badges / notification inbox.

### F. Notification system (required, all apps + Admin)

Implement a real `notifications` table (user_id/role polymorphic, title, body, type, data JSON, read_at, created_at).

| Event examples | Recipients |
|----------------|------------|
| New ride/food/parcel status | Customer |
| New job offer / payout paid | Rider |
| New order / payout / review | Merchant |
| New assignment / withdraw approved | Courier |
| KYC decision, SOS open, contact inquiry | Admin (activity + notification) |
| Promo / incentive | Relevant app users |

- Each app: notifications screen + unread badge fed by `GET /api/{role}/notifications`.  
- Admin: notifications/activity from DB (replace mock activity-only list).  
- Prefer FCM (mobile) + optional Web Push/SSE/polling (Admin/Public) so updates feel **real-time**; polling ≤ few seconds acceptable for Admin queues if websockets deferred, but data must still be live from MySQL.

### G. Real-time interconnect

When status changes in one surface, others see DB truth without mock lag:

- Customer order status ↔ Merchant kitchen ↔ Rider job ↔ Admin lists.  
- Parcel OTP progress ↔ Customer tracking ↔ Public track ↔ Admin courier parcels.  
- Online rider/courier GPS ↔ Admin live map.  
- Wallet adjust / payout approve ↔ balances on next fetch.

### H. Responsive design (required)

- **Admin Panel:** usable from ~375px to wide desktop; tables scroll/stack; drawers/modals fit viewport; sidebar collapses.  
- **Public Web:** existing pages must remain usable on mobile (forms, track, nav).  
- **Flutter apps:** existing layouts must not depend on mock fixed data lengths; empty/loading/error states for all lists; no overflow on common phone sizes.

### I. Database health / interconnect proof

Implementer must verify:

1. Migrations run clean on empty MySQL.  
2. Foreign keys link customers↔rides↔riders, merchants↔orders↔items, parcels↔agents↔OTP logs, wallets↔ledger, etc.  
3. Deleting/suspending a user blocks dependent actions.  
4. Admin KPI queries match the same tables apps write.  
5. No dual sources of truth (no JS seed merge over API).

---

## 0B. SECURITY MANDATE (see companions)

This section points implementers at the security docs. **Full policy:** `SECURITY.md`. **Patches/verify:** `SECURITY_PATCH.md`.

| Priority | Must implement |
|----------|----------------|
| Secrets | All API keys / DB / payment / SMS / FCM in `.env` only — never in Admin JS or Flutter |
| Tokens | Opaque Sanctum (or equivalent) tokens; **hash at rest**; no PII/wallet/KYC inside token string; role from DB + `EnsureRole` on route groups |
| Abuse | Throttle login + OTP; exponential backoff / cooldown per phone |
| Authz | BOLA: every resource scoped to owner or admin policy — never trust URL ID alone |
| Money | Server recalculates fares/fees/wallets; client totals never persisted as fact |
| Mass assign | Explicit `$fillable`; never `role` / `wallet_balance` |
| SQL | Eloquent / bound queries only |
| Prod | `APP_DEBUG=false`; CORS allow-list (no `*`); HTTPS |
| KYC files | MIME/size allow-list; private disk; signed expiring URLs |
| Audit | Append-only log on wallet/payout/KYC/pricing/region/role |
| Admin data | No KYC/finance in `localStorage` — API only |
| Scale | Redis cache/throttle/queues; eager load; pagination; indexes — security must not skip these |

**Admin-first example:** Decoding Admin JS or a Flutter APK must not reveal MySQL password, payment secrets, or SMS keys. An attacker may hold only a restricted Maps *client* key and their own opaque Bearer token — which still cannot call `/api/admin/*` without an admin role, and cannot read another user’s wallet without failing ownership checks.

---

## 1. System map (target after implementation)

| Piece | Must become | Rules |
|-------|-------------|--------|
| `Hill Go Public Web` | API-backed static/CMS site | No toast-only mocks; responsive |
| `Hill Go Admin Panel` | Sanctum SPA → Laravel → MySQL | No `localStorage` entity DB; responsive |
| `Hill Go Main Customer App` | Flutter → `/api/customer/*` | Delete dummy/DemoAuth; notifications real |
| `Rider Driver App` | Flutter → `/api/rider/*` | Delete Mock* repos; live dispatch |
| `Vendor Marchant App` | Flutter → `/api/merchant/*` | Delete Mock* repos; live kitchen/catalog |
| `Courier Agent App` | Flutter → `/api/courier/*` | Delete MockData; server OTPs |

Remote monorepo reference: Hill-Go-All.

---

## 2. Auth & roles (baseline from Admin + Public Web)

Implement now (pass 1):

| Role | Used by | Notes |
|------|---------|--------|
| `super_admin` | Admin Panel | Full access; activity log attribution — **only** structural seed user allowed |
| `admin` | Admin Panel | Same ops capabilities unless finer RBAC later |
| `customer` | Customer App | Phone OTP + email/password; Sanctum; Region Lock `allow_customer` — **no** client demo auto-login user |
| `rider` | Rider Driver App | Phone OTP + email/password; Sanctum; Region Lock `allow_rider`; KYC-verified to go online |
| `merchant` | Vendor Merchant App | Email/password (+ optional phone); Sanctum; Region Lock `allow_merchant`; Admin-approved to accept orders |
| `courier_agent` | Courier Agent App | Email/phone + password/OTP; Sanctum; Region Lock `allow_courier`; KYC + bank verified to withdraw |
| Public (guest) | Public Web | Contact, newsletter, partner application, track, quote, city availability |
| Partner applicant | Public Web `register.html` | Pending rider application → Rider KYC/onboarding queue |

Use Laravel Sanctum (or equivalent **opaque hashed** personal access tokens) for Admin SPA + all four Flutter apps. Tokens are identifiers only — **role, PII, balances, KYC status live in MySQL**, not inside the token string. Enforce roles with middleware on `/api/admin/*`, `/api/customer/*`, `/api/rider/*`, `/api/merchant/*`, `/api/courier/*` route groups. Public endpoints mostly unauthenticated + rate-limited. **OTP in production = real SMS (or configured provider); never hard-code always-valid OTP in client.** Full auth/secrets/BOLA/money rules: `SECURITY.md` + `SECURITY_PATCH.md`.


---

# PASS 1A — Hill Go Public Web

## 3. Public site inventory

### Pages (static content — CMS optional but recommended)

| Page | Purpose | Backend need |
|------|---------|--------------|
| `index.html` | Home: hero, services, track, pricing tabs, FAQ, testimonials, contact strip | Availability check, track, CMS for FAQ/pricing/testimonials preferred |
| `services.html` | Services overview | CMS content |
| `ride.html` | Ride marketing + fare quote form (`#quoteForm`) | Fare estimate API |
| `food.html` | Food marketing + address input | Optional address/serviceability check |
| `parcel.html` | Parcel + quote (`#quoteForm`: origin, destination, weight) | Parcel quote API (must use Admin **customer/courier pricing**, not hard-coded `$`) |
| `merchant.html` | Merchant partner landing | Lead → merchant interest / onboarding lead |
| `driver.html` | Driver/partner landing → `register.html` | Link only |
| `register.html` | Partner application form | **Persist application** |
| `about.html` | About | CMS |
| `blog.html` | Blog + newsletter | Newsletter subscribe; blog posts ideally CMS |
| `faq.html` | FAQ + search/categories | FAQ CMS or seeded content API |
| `contact.html` | Contact inquiry form | **Persist inquiry** |
| `privacy.html` / `terms.html` | Legal | CMS or static OK |

### Public interactive flows that MUST hit Laravel (remove all toast-only mocks)

Every form below: `fetch` → Laravel → MySQL. On failure show inline error. On success update UI from JSON **and** (where relevant) create an Admin/public notification record. **Do not** call `showToast` as the only outcome.


#### 3.1 Contact inquiry — `contact.html` / `#contactForm`

Fields:

- `first_name`, `last_name`
- `email` (corporate email)
- `service_interest` enum: `Ride-Hailing` | `Food Delivery` | `Parcel Logistics` | `Merchant Partnership` | `Consulting`
- `message`

**API:** `POST /api/public/contact`  
**Admin:** list/read/status (new / read / replied / archived) under Settings or a Public Web inbox (add screen if missing — data must not be lost).

#### 3.2 Partner / driver application — `register.html` (reuses `#contactForm` id)

Fields:

- `full_name`, `phone`, `email`
- `vehicle_type`: `Car` | `Bike` | `Scooter`
- `city`

**API:** `POST /api/public/partner-applications`  
**Rules:** Validate city/district against Region Lock — if district closed or `allow_rider = false`, reject with clear error.  
**Admin:** Appear in Rider onboarding/KYC pipeline as `pending` application (link to create rider profile on approve).

#### 3.3 Parcel / ride quote — `parcel.html` + `ride.html` `#quoteForm`

Inputs: `origin`, `destination`, optional `weight_kg` (parcel).  
**API:** `POST /api/public/quotes` with `type: ride|parcel`  
**Must compute from** Admin pricing (`pricing.customer` / `pricing.rider` / `pricing.courier` as appropriate), return BDT amount + breakdown. Replace current JS hard-coded USD formula.

#### 3.4 Track order — `index.html` `#trackForm`

Input: tracking number / consignment id.  
**API:** `GET /api/public/track/{code}`  
Resolve against **customer parcels** and **courier parcels** (and food/ride if codes exist). Return status timeline: booked → picked_up → in_transit → delivered (and failed/cancelled). Public response: sanitized (no internal notes).

#### 3.5 City availability — home availability form

Input: city name.  
**API:** `GET /api/public/availability?city=` or `POST`  
Map city → district → Region Lock status + which apps allowed. Return `{ available, district, division, allow_customer, allow_rider, allow_merchant, allow_courier }`.

#### 3.6 Newsletter — `blog.html`

**API:** `POST /api/public/newsletter` `{ email }` — unique emails, Admin export list.

#### 3.7 Food address check (optional but implement)

Food page address box → reuse availability / serviceable area check.

### Public CMS / content (recommended for “admin for public web”)

Admin Settings (or dedicated **Public Web** section) should manage:

- FAQ entries (category, question, answer, sort)
- Blog posts (title, slug, body, author, published_at)
- Homepage testimonials
- Public pricing display panels (or mirror live quote params)
- Contact org phone/email/HQ address shown on site
- Legal pages content

If you keep legal as static files, still allow Admin to update contact/org settings used by the site via API.

---

# PASS 1B — Hill Go Super Admin Panel (monolithic)

## 4. Frontend architecture to preserve

| File | Role |
|------|------|
| `index.html` | Shell: sidebar, header, modal, drawer |
| `js/data/seed.js` | **Schema reference only** — field shapes for migrations. Must **not** power the live Admin UI after wiring. Delete or stop importing for runtime. |
| `js/store.js` | HTTP façade to Laravel; keep method names; **no** `localStorage` persist of full state |
| `js/ui.js` | Modal, drawer, confirm, CSV export, notices (notices only after real API success) |
| `js/router.js` | Hash routes |
| `js/pages/*.js` | Screens — empty/loading/error from API |
| `js/maps.js` | Rider live map from live GPS API |
| `js/app.js` | Route registration |

Storage key `hillgo-admin-v1`: **delete entirely**. No offline mock cache of entities.



### Registered admin routes (must all work on API)

```
/overview
/region
/region/:divisionId
/customer
/customer/customers
/customer/rides
/customer/food
/customer/parcels
/customer/pricing
/rider
/rider/riders
/rider/kyc
/rider/trips
/rider/map
/rider/pay
/rider/payouts
/rider/pricing
/merchant
/merchant/stores
/merchant/onboarding
/merchant/orders
/merchant/payouts
/merchant/pricing
/courier
/courier/agents
/courier/kyc
/courier/parcels
/courier/withdrawals
/courier/incentives
/courier/pricing
/settings
```

Global chrome: sidebar accordion, global search → customer directory, notifications = activity log, reset data (dev-only; production disable or protect).

---

## 5. Domain model (from `seed.js` + `store.js`)

Implement MySQL tables (names suggestive — normalize properly in Laravel).

### 5.1 Region Lock (global)

- **divisions** (8): `id` slug, `name`, `zone`
- **districts** (64): `division_id`, `name`, `status` (`open`|`closed`), `opened_at`, `allow_customer`, `allow_rider`, `allow_merchant`, `allow_courier`, `note`, `updated_by`, timestamps

**Store methods → API:**

| Store | Suggested API |
|-------|----------------|
| `getDivisions()` | `GET /api/admin/regions/divisions` (with open/closed/partial counts) |
| `getDistrictsByDivision(id)` | `GET /api/admin/regions/divisions/{id}/districts` |
| `getDistrict(id)` | `GET /api/admin/regions/districts/{id}` |
| `updateDistrict(id, patch)` | `PATCH /api/admin/regions/districts/{id}` |
| `setAllDistrictsInDivision(id, status)` | `POST /api/admin/regions/divisions/{id}/bulk-status` |

**Business rules (already in store):**

- Closing a district forces all four `allow_*` flags to `false`.
- Opening all in division sets status open + all allow flags true + sets `opened_at` if missing.
- Every change writes **activity_log**.

**Master list (exact):**

- **Dhaka:** Dhaka, Faridpur, Gazipur, Gopalganj, Kishoreganj, Madaripur, Manikganj, Munshiganj, Narayanganj, Narsingdi, Rajbari, Shariatpur, Tangail  
- **Chattogram:** Bandarban, Brahmanbaria, Chandpur, Chattogram, Cumilla, Cox's Bazar, Feni, Khagrachhari, Lakshmipur, Noakhali, Rangamati  
- **Rajshahi:** Bogura, Chapainawabganj, Joypurhat, Naogaon, Natore, Pabna, Rajshahi, Sirajganj  
- **Khulna:** Bagerhat, Chuadanga, Jashore, Jhenaidah, Khulna, Kushtia, Magura, Meherpur, Narail, Satkhira  
- **Barishal:** Barguna, Barishal, Bhola, Jhalokathi, Patuakhali, Pirojpur  
- **Sylhet:** Habiganj, Moulvibazar, Sunamganj, Sylhet  
- **Rangpur:** Dinajpur, Gaibandha, Kurigram, Lalmonirhat, Nilphamari, Panchagarh, Rangpur, Thakurgaon  
- **Mymensingh:** Jamalpur, Mymensingh, Netrokona, Sherpur  

### 5.2 Customers (Customer Panel)

Entity fields (seed): `id`, `name`, `phone`, `email`, `district`, `status` (`active`|`suspended`), `tier`, `wallet`, `loyalty_points`, `orders`, `rating`, `joined`.

| Store | API |
|-------|-----|
| `listCustomers(filter)` | `GET /api/admin/customers?q=&status=` |
| `getCustomer(id)` | `GET /api/admin/customers/{id}` |
| `updateCustomer(id, patch)` | `PATCH /api/admin/customers/{id}` (incl. suspend) |
| `adjustWallet(id, delta, note)` | `POST /api/admin/customers/{id}/wallet` |

Related lists:

- **Rides:** id, customer, rider, pickup, drop, fare, status (`searching`|`assigned`|`in_progress`|`completed`|`cancelled` — align with seed: completed/in_progress/cancelled), date, distanceKm → `listRides`
- **Food orders:** id, restaurant, customer, total, deliveryFee, status (`placed`|`preparing`|`on_the_way`|`delivered`), date, district → `listFoodOrders`
- **Customer parcels:** id, type, pickup, destination, weightKg, distanceKm, fare, status (`booked`|`picked_up`|`in_transit`|`delivered`|`cancelled`), customer, date → `listCustomerParcels`

Customer dashboard KPIs: active customers, rides today, food orders, parcels, wallet volume, open SOS (see PASS 2 — SOS table required).

**Admin Customer Panel gaps filled in PASS 2:** Marketplace, Hotels, Rentals, Wallet & Loyalty, Promos, SOS (routes + store methods beyond the six currently registered customer routes).

Customer pricing panel → `getPricing('customer')` / `savePricing('customer', values)` with audit.

**Customer pricing fields:**  
`rideBase`, `ridePerKm`, `ridePerMin`, `rideMinimum`, `foodDeliveryFee`, `freeDeliveryThreshold`, `parcelBase`, `parcelPerKm`, `parcelPerKg`, `parcelMinimum`, `marketplaceDelivery`, `hotelServiceFeePct`, `rentalDriverPerDay`, `rentalInsurancePerDay`

### 5.3 Riders (Rider Panel)

Rider: id, name, phone, vehicle (`bike`|`car`|`xl`), plate, rating, online, district, status (`active`|`suspended`|`onboarding`), todayEarnings, tripsToday.

KYC: docs[], status (`pending`|`action_required`|`uploaded`|`verified`), priority, flagged, submitted.  
Approving KYC (`verified`) promotes rider from `onboarding` → `active`.

Trips/jobs: type `ride`|`food`|`parcel`, route, km, earning, payment, surge, status, cod, date.

Payouts (pay salary form): amount, method (`bKash`|`Nagad`|`Bank`), periodFrom/To, ref, tips, surge, deductions, note → creates payout log row `status: paid`.

Live map: online riders with last known coords (seed may lack coords — add `lat`/`lng` columns; **PASS 3** requires GPS heartbeats from Rider App).

Rider cash-out requests from app appear in payout log alongside Admin “Pay salary” (`PASS 3`).

| Store | API |
|-------|-----|
| `listRiders` / `updateRider` | CRUD-ish admin riders |
| `listRiderKyc` / `setRiderKycStatus` / `bulkRiderKyc` | KYC queue (+ file URLs / token numbers from Rider App) |
| `listTrips` | trips/jobs (live dispatch records) |
| `createRiderPayout` / `listRiderPayouts` | salary + payout log (+ cash-out approve) |
| pricing `rider` | see fields below |

**Rider pricing:**  
`rideBase`, `ridePerKm`, `ridePerMin`, `rideMinimum`, `bikeMultiplier`, `carMultiplier`, `xlMultiplier`, `foodJobFee`, `parcelBase`, `parcelPerKm`, `parcelPerKg`, `parcelMinimum`, `defaultSurge`, `platformCommissionPct`

### 5.4 Merchants (Merchant Panel)

Store: id, name, owner, category, district, isOpen, acceptingOrders, status (`active`|`pending`|`onboarding`), rating, gmvToday.

**PASS 4 expands** store with: description, specialties, bio, address, lat/lng, hours map, banner/logo, profileStrength, subcategories.

Onboarding queue: businessName, owner, category, phone, email, address, city, district, zip, docs[], status (`pending`|`changes_requested`|`approved`|…).  
**Approve** creates/activates merchant (`isOpen`, `acceptingOrders` true).

Orders: store, customer, priority (`standard`|`express`|`priority`|`scheduled`), status (`new_order`|`preparing`|`ready`|`delivered`|`rejected`), total, date. Tabs: active / scheduled / completed. **Items line-level** required (PASS 4).

Payouts: amount, method, status (`pending`|`processing`|`completed`), earlyRequest flag. Admin sets status via `setMerchantPayoutStatus`.

**Admin ADD (pass 4):** `#/merchant/catalog` — cross-store products, low-stock, hidden categories.

**Merchant pricing:**  
`platformCommissionPct`, `orderServiceFee`, `taxVatPct`, `settlementCycle`, `earlyPayoutFeePct`, `minPayoutAmount`

### 5.5 Courier (Courier Panel)

Agents: id, name, phone, vehicle (`Motorbike`|`Bicycle`|`Van`), plate, rating, deliveries, verified, district, status, online, bankLast4, bankVerified.

KYC: docs (License, NID, Vehicle Registration), status, bankVerified; verified → agent.verified = true.

Parcels: priority, agent, pickup, drop, weightKg, distanceKm, earnings, surge, status (`assigned`|`picked_up`|`in_transit`|`delivered`|`failed`) + **pickup/delivery OTP codes** + OTP confirmation log (PASS 5).

Withdrawals: amount, method, bankLast4, status (`pending`|`approved`|`rejected`).

Incentives: title, description, multiplier, district, goalDeliveries, bonusTk, validUntil, active/status (`active`|`scheduled`). Create + toggle; agents can list/accept active offers.

**Courier pricing:**  
`parcelBase`, `perKm`, `perKg`, `expressMultiplier`, `priorityMultiplier`, `surgeCap`, `platformCommissionPct`, `weeklyGoalDeliveries`, `topPerformerMultiplier`, `withdrawalMin`

### 5.6 Pricing audit & settings

- `pricing` JSON or normalized `pricing_parameters` per panel + `pricing_audits` (panel, field, old, new, by, at)
- `settings`: orgName, orgEmail, timezone, twoFactor, emailAlerts, smsAlerts
- `activity_log`: text, by, at (cap ~100 recent in UI; store all in DB)

### 5.7 Overview KPIs (`overviewKpis`)

Compute server-side:

- revenue (completed rides fares + delivered food totals + delivered merchant order totals)
- activeTrips, foodOrders count, issues (pending KYC + suspended customers)
- customers (active), riders (online active), stores (active)
- parcelsInTransit, openDistricts / totalDistricts

---

## 6. Admin API surface (complete for pass 1)

Prefix: `/api/admin/*` — Sanctum auth, `super_admin`/`admin` only.

Mirror every `AppStore` method:

- Region: divisions, districts, update, bulk status  
- Customers: list, get, update, wallet adjust  
- Rides, food orders, customer parcels: list + filters + CSV export support  
- Riders: list, update, KYC list/status/bulk, trips, payouts create/list, live map points  
- Merchants: list, update, onboarding list/status, orders, payouts status  
- Courier: agents, KYC, parcels, withdrawals status, incentives CRUD/toggle  
- Pricing: get/save per panel, audit list  
- Settings: get/save  
- Overview: KPIs  
- Activity log: list (notifications)  
- **Public Web admin:** contact inquiries, partner applications, newsletter subscribers, FAQ/blog CMS (if implemented)

CSV export: keep client-side from API JSON **or** provide `Accept: text/csv` — both OK; must export real filtered rows.

---

## 7. Public API surface (pass 1)

Prefix: `/api/public/*` — rate limited.

| Endpoint | Purpose |
|----------|---------|
| `POST /contact` | Contact form |
| `POST /partner-applications` | Driver/partner register |
| `POST /quotes` | Ride/parcel estimate from live pricing |
| `GET /track/{code}` | Tracking |
| `GET /availability` | City/district Region Lock |
| `POST /newsletter` | Subscribe |
| `GET /faq` | FAQ content |
| `GET /blog` / `GET /blog/{slug}` | Blog |
| `GET /content/home` | Testimonials / pricing display / contact strip (optional aggregate) |

Respect Region Lock on partner application and availability.

---

## 8. Seeding (structural only — see §0A.B)

Allowed Laravel seeders:

1. 8 divisions + 64 districts (Region Lock).  
2. Default `pricing` for customer / rider / merchant / courier.  
3. One `super_admin` (+ settings row).  
4. Optional loyalty tier threshold config.

**Forbidden in seeders:** bulk fake customers, riders, merchants, agents, rides, orders, parcels, payouts, reviews, wallet transactions, SOS alerts, incentives as “demo content.”

`HillGoSeed` / `dummy_data` / `MockData` are **shape references for migrations**, not datasets to copy wholesale into MySQL.

Empty Admin lists are correct until real users/apps create rows. UI must handle empty states.

---

## 9. Wiring the Admin SPA (fully dynamic)

1. Replace `AppStore` with API module (`fetch` + Sanctum token). Keep method names as façade over HTTP.  
2. **Remove** `localStorage` load/persist, `cloneSeed`, `resetData` (or Admin-only “dangerous reset DB” that calls a protected Laravel artisan endpoint — never re-inject JS seed).  
3. Login page; Bearer token; 401 → login.  
4. All pages: loading / empty / error from API.  
5. Notifications bell = `GET` notifications + activity from MySQL.  
6. Responsive: sidebar collapse, tables horizontal scroll, modals fit mobile.  
7. Public Web: same purge of toast-only handlers; responsive forms.


---

## 10. Explicitly out of scope

Do **not** invent additional apps or panels. SMS / payment gateway / FCM providers may be swapped behind interfaces, but:

- Business flows must persist and read **real MySQL state** even in local/dev.  
- Dev may log OTP codes to logs/mailtrap — **never** ship client hard-coded always-valid OTP.  
- Do not reintroduce mock repositories “for offline demo.”

---

## 11. Acceptance criteria

### Global (applies to all six surfaces — §0A + §0B)

- [ ] Grep/audit: zero production use of mock repos, `dummy_data`, `DemoAuth`, `MockData`, `localStorage` entity store, toast-only fake success.  
- [ ] MySQL is sole source of business truth; structural seed only (§0A.B); operational tables empty until real creates.  
- [ ] Opaque Sanctum (hashed) tokens for Admin + 4 apps; `/me` restores session — no invented preset users; no PII/balances in token string.  
- [ ] Notification system: DB-backed inbox + unread badges on Customer, Rider, Merchant, Courier, Admin; events on status/payout/KYC/order/SOS/contact.  
- [ ] No toast/SnackBar as sole confirmation of persistence.  
- [ ] Responsive Admin + Public Web + Flutter apps (empty/loading/error states).  
- [ ] Cross-app status changes visible via API refetch/realtime from same MySQL rows.  
- [ ] Migrations + foreign keys verified; Admin KPIs match app-written tables.  
- [ ] **Security:** `SECURITY.md` / `SECURITY_PATCH.md` ship-gate satisfied (secrets, throttle, BOLA, server money, role groups, audit, private KYC, CORS, `APP_DEBUG=false`, pagination/indexes/cache/queues).

### Pass 1 (Admin + Public)

- [ ] Laravel + MySQL boots; structural seed only (districts, pricing, super_admin).  
- [ ] Admin login; every hash route loads from API; **no** `localStorage` / `resetData` mock restore.  
- [ ] Region Lock persists; Public availability + partner apply enforce flags.  
- [ ] All Admin panel actions mutate MySQL (KYC, wallet, pay salary, onboarding, payouts, withdrawals, incentives, pricing + audit).  
- [ ] Overview KPIs + notifications from DB.  
- [ ] Public: contact, partner apply, newsletter, track, quote, availability — real API, no toast-only path.  
- [ ] CSV from live filtered API data.  
- [ ] No placeholder controllers.

### Pass 2 (Customer App)

- [ ] **Deleted** `dummy_data` runtime usage + `DemoAuthService`; all screens API-driven.  
- [ ] Register / OTP / email login; Region Lock; profile/addresses/payments from DB.  
- [ ] Ride/food/parcel/marketplace/hotel/rental lifecycles write MySQL; Admin lists update.  
- [ ] Wallet ledger + loyalty + promos + SOS from API; notifications inbox real.  
- [ ] Responsive; empty states when no bookings.  
- [ ] BDT everywhere.

### Pass 3 (Rider App)

- [ ] **Deleted** all `Mock*Repository` usage; trips/offers/earnings/docs from API.  
- [ ] Online + GPS → Admin map; offer accept/decline/expiry real.  
- [ ] Status machines sync Customer + Admin; payouts/cash-out in MySQL.  
- [ ] Fare from Admin pricing DB; notifications for offers/payouts.  
- [ ] No SharedPreferences business fabrication.

### Pass 4 (Merchant App)

- [ ] **Deleted** mock order/product/store/auth repos; catalog + kitchen from API.  
- [ ] Onboarding → Admin queue; orders sync Customer tracking + Rider dispatch.  
- [ ] Revenue/payouts/reviews/notifications from MySQL; BDT fees from pricing.  
- [ ] Empty catalog/orders OK until merchant creates / customers order.

### Pass 5 (Courier App)

- [ ] **Deleted** `MockData` + mock repos; parcels/OTP/earnings/withdraw/incentives from API.  
- [ ] Server-generated OTPs (not client always-`1234`); status → Customer + Public track + Admin.  
- [ ] Withdrawals → Admin queue; notifications real.  
- [ ] BDT from courier pricing DB.

---

# PASS 2 — Hill Go Main Customer App

> Source shapes: `Hill Go Main Customer App/lib` routes/models (**delete runtime mocks**).  
> Maps to Admin **Customer Panel**.  
> **§0A applies:** remove `dummy_data.dart` as data source, `DemoAuthService`, in-memory notification/SOS-only stores; wire Sanctum + API; empty lists until MySQL has rows.

## 12. Customer App map

### Mock purge (Customer) — mandatory

- Delete or gut: `DemoAuthService`, demo login banner, hard-coded `dummyProducts` / restaurants / hotels / rentals / rides / vouchers used as live lists.  
- Replace with API repositories. Cart may stay ephemeral until checkout; checkout persists order in MySQL.  
- Notifications screen ← API only. SOS ← API + Admin queue.  
- No SnackBar “success” without `response.ok`.

### Shell & discovery

| Area | Routes / screens | Backend |
|------|------------------|---------|
| Splash / onboarding | `/splash`, onboarding | Remote config optional; no fake logged-in skip |

| Auth | `/login`, `/email-login`, `/otp`, `/register` | Customer auth APIs |
| Home shell | `/home` (`MainShellScreen`) | Home feed: services availability by district, promos, nearby, recommended |
| Search / notifications / chatbot / categories / nearby / recommended | `/search`, notifications, chatbot, `/categories`, nearby, recommended | Search index; notifications API; chatbot can be FAQ-backed or simple canned + ticket create; nearby POIs |

Home service entry points (must respect Region Lock + feature flags): **Ride · Food · Parcel · Marketplace · Hotel · Rental · SOS**.

### Auth & profile (replace `DemoAuthService`)

**Register fields:** name, phone, email, agree terms → OTP from **server**.  
**Login:** phone → OTP; or email + password — all via Laravel.  
**No client preset user.** Do not ship `demo@hillgo.com` auto-login. Ops may create one customer via Admin/API if needed for QA.


**Profile:** name, email, phone, avatar URL, wallet balance, loyalty points, district.  
**Saved addresses:** label, address text, optional lat/lng, `is_default`.  
**Languages:** English, Bengali, Hindi, Chakma (store preference).  
**Payment methods:** Hill Wallet, Visa/Card, bKash, Nagad (saved instruments + default).  
**Settings:** theme (local OK), logout, edit profile, addresses, language, payment methods, wallet, rewards, SOS contacts.

**Region Lock:** Registration and home services require customer's district `status=open` and `allow_customer=true`.

### Role token

`POST /api/customer/auth/register`  
`POST /api/customer/auth/login` (email)  
`POST /api/customer/auth/otp/request`  
`POST /api/customer/auth/otp/verify`  
`POST /api/customer/auth/logout`  
`GET/PATCH /api/customer/me`  
`CRUD /api/customer/addresses`  
`CRUD /api/customer/payment-methods`  
`PATCH /api/customer/preferences` (language, etc.)

---

## 13. Ride module

**Flow:** Pickup/Drop (Nominatim/OSRM client-side OK for geocode/route) → Vehicle select (Bike / Car / XL) → Fare estimate → Driver searching → Driver assigned → Live tracking → Details → Rating · History.

**Fare (must be server-authoritative):**

```
fare = max(minimumFare, baseFare + km×ratePerKm + min×ratePerMin)
vehicleFare = max(50, round(fare × multiplier))
```

From app: `FareConfig` base 30, perKm 15, perMin 1, minimum 50; multipliers Bike **0.7**, Car **1.0**, XL **1.5**. These must equal Admin `pricing.customer` (+ rider vehicle multipliers). Client may preview; **create ride** recalculates on server.

**Statuses:** `searching` → `assigned` → `in_progress` → `completed` | `cancelled`  
(UI also shows Completed/Cancelled in history.)

**Entities:** ride id, customer_id, rider_id (nullable until assigned), vehicle_type, pickup/drop text + lat/lng, distance_km, duration_min, fare, status, rating, timestamps.

**Customer APIs:**

| Method | Path | Notes |
|--------|------|-------|
| POST | `/api/customer/rides/quote` | distance/duration or coords → breakdown |
| POST | `/api/customer/rides` | create → searching; dispatch to available riders (Rider pass deepens matching) |
| GET | `/api/customer/rides` | history |
| GET | `/api/customer/rides/{id}` | details + driver info when assigned |
| POST | `/api/customer/rides/{id}/cancel` | |
| POST | `/api/customer/rides/{id}/rate` | stars + optional comment |

**Admin:** existing `/customer/rides` list; ensure all statuses + cancel from admin if needed; live map later shares rider GPS.

---

## 14. Food module

**Flow:** Restaurant list (cuisine chips: All, Fast Food, Bengali, Chinese, Pizza, Desserts) → Restaurant details + menu categories/items → Item details → Cart (`FoodCartStore`) → Checkout → Order tracking · (history via orders).

**Checkout payments:** Cash on Delivery · HillGo Wallet · Card.  
**Delivery fee:** ৳30 default (`pricing.customer.foodDeliveryFee`); free when subtotal ≥ `freeDeliveryThreshold` (৳300) if restaurant allows free delivery flag.

**Restaurant fields:** name, cuisine, rating, eta label, fee, image, freeDelivery, menu[{name, items[{name, description, price, image}]}].  
Restaurants are merchant stores with category Restaurant/Cafe (link to Merchant entities when Merchant pass lands; until then Admin can manage food restaurants under Customer/Marketplace or Merchant stores).

**Order statuses:** `placed` → `preparing` → `on_the_way` → `delivered` (+ cancelled/rejected).

**Customer APIs:** list restaurants, get restaurant+menu, cart optional server-side or client until checkout, `POST /api/customer/food/orders`, `GET` orders + tracking.

**Admin:** existing food orders list; add restaurant/menu CRUD if not covered by Merchant panel (minimum: Admin can see every order with items, fees, payment method).

---

## 15. Parcel module (customer-booked)

**Types:** Document · Box · Fragile.  
**Flow:** Type → Pickup details (address, contact, phone) → Receiver details → Price estimate → Summary → Tracking · History.

**Fare:** Replace app’s USD-like `ParcelBooking` constants with Admin BDT:  
`parcelBase + perKm×km + perKg×kg`, apply `parcelMinimum`. Priority/express multipliers from courier pricing when selected.

**Statuses:** `booked` → `picked_up` → `in_transit` → `delivered` | `cancelled` (align Admin `customerParcels`).

**Customer APIs:** quote, create booking, list history, get tracking (same public track codes).

**Admin:** existing `/customer/parcels`.

---

## 16. Marketplace module

**Categories:** Electronics, Fashion, Home, Beauty, Groceries, Sports.  
**Products:** id, name, category, price (BDT), rating, description, image, status active/hidden.  
**Flow:** Categories → Listing → Details → Cart → Checkout (apply `marketplaceDelivery` fee from pricing).

**Customer APIs:** categories, products (filter), product detail, place order (items, address, payment, delivery fee).

**Admin (ADD routes — gap vs current SPA):**

- `#/customer/marketplace` — tabs Products · Categories  
- Product CRUD: name, category, price, status (active/hidden), image  
- Marketplace orders list (customer, total, status, date)

Wire into `js/app.js` + `store.js` + page module. Catalog rows come from Merchant/Admin APIs (MySQL) — **do not** seed Admin marketplace from `dummyProducts`.


---

## 17. Hotels module

**List filters/chips:** All, Dhaka, Sylhet, Cox's Bazar, Chittagong.  
**Hotel:** id, name, location, rating, stars, pricePerNight, amenities[], description, image, reviews count.  
**Booking:** check-in/out, nights, guests, rooms, guestName, guestPhone.  
**Totals:** `roomTotal = pricePerNight × nights × rooms`; `serviceFee = roomTotal × hotelServiceFeePct/100` (default 5%); `total = roomTotal + serviceFee`.  
**Booking statuses:** Upcoming · Completed · Cancelled.

**Customer APIs:** list/filter hotels, detail, create booking, list my bookings.

**Admin (ADD):** `#/customer/hotels` — hotels CRUD + bookings table (id, hotel, customer, dates, amount, status).

---

## 18. Rentals module

**Chips:** All, Car, SUV, Bike, Scooter, Van.  
**Vehicle:** id, name, category, pricePerDay, seats, transmission, fuel, rating, description, image, features[].  
**Booking:** pickup/dropoff locations, start/end, days, withDriver, renterName, renterPhone.  
**Totals:** vehicleTotal + driverFee (`rentalDriverPerDay` × days if withDriver) + insuranceFee (`rentalInsurancePerDay` × days). Defaults ৳1500 / ৳300.  
**History statuses:** Upcoming · Completed · Cancelled.

**Customer APIs:** list/filter, detail, book, history.

**Admin (ADD):** `#/customer/rentals` — fleet CRUD + bookings table.

---

## 19. Wallet, loyalty, promos

### Wallet

- Balance on customer; **ledger** of transactions: title, amount, credit/debit, date, related ref (ride/food/parcel/top-up).  
- Actions: Add Money (payment gateway or Admin-approved top-up — must credit MySQL ledger), Send if UI requires (real transfer), pay by debiting wallet. **No mock credit.**
  
- Admin already has `adjustWallet`; extend with full transaction list in Admin Customer drawer + **Wallet & Loyalty** screen.

### Loyalty

**Tiers (from Rewards Center):** Bronze 0 · Silver 1000 · Gold 2000 · Platinum 5000 (Admin-editable thresholds).  
**Redeemables (examples):** Delivery voucher 500pts · Free delivery pass 800 · Marketplace coupon 1200 · Priority support 1500.  
Redeem deducts points and issues voucher/entitlement.

**Admin (ADD):** `#/customer/wallet` — top-up/adjust, transactions, tier thresholds CRUD, redeemable rewards CRUD.

### Promos & vouchers

App home vouchers examples: 30% Off Ride, Free Delivery (orders above ৳500), 10% Cashback (Hill Wallet). Notifications reference code **HILLGO30**.

**Fields:** title, description, code, type (`ride_percent` | `free_delivery` | `wallet_cashback` | …), min_order_tk, expiry, active, usage limits.

**Admin (ADD):** `#/customer/promos` — full CRUD; customer can list applicable vouchers and apply at checkout where relevant.

---

## 20. SOS

**Contacts:** id, name, phone, relation — customer CRUD.  
**Trigger types:** primary SOS (or context e.g. `Ride SOS`), `Police call request`, `Ambulance request`, `Location shared`.  
**Alert:** id, customer_id, type, location label/lat/lng, status (`Active` → `Resolved`), timestamps. Notify emergency contacts (SMS/push when integrations exist; at minimum persist + Admin notification).

**Customer APIs:** contacts CRUD, `POST /api/customer/sos/alerts`, list my alerts.

**Admin (ADD):** open SOS on Customer dashboard KPI; `#/customer/sos` or drawer — list Active/Resolved, resolve action, link to customer + location.

---

## 21. Notifications & misc

- Server-generated notifications for ride/food/parcel/wallet/promo/SOS events → Customer notification inbox (DB).  
- `GET /api/customer/notifications`, mark read, mark all, delete — **replace** hard-coded `NotificationService` list.  
- Chatbot: FAQ API + support tickets in MySQL.  
- Nearby services: from DB POIs (Admin-managed or merchant locations) — **not** hard-coded `dummy` arrays; empty OK.


---

## 22. Admin Customer Panel — required expansions (pass 2)

Current Admin implements: Dashboard, Customers, Rides, Food, Parcels, Pricing.  
**Must add (monolithic admin completeness for Customer App):**

| Route | Purpose |
|-------|---------|
| `#/customer/marketplace` | Products + categories CRUD; orders |
| `#/customer/hotels` | Hotels CRUD + bookings |
| `#/customer/rentals` | Rental fleet CRUD + bookings |
| `#/customer/wallet` | Wallet ledger, loyalty tiers/rewards |
| `#/customer/promos` | Vouchers/promos CRUD |
| `#/customer/sos` | SOS alert queue |

Update Customer dashboard KPIs: Active customers · Rides today · Food orders · Parcels · Wallet volume · **Open SOS alerts**.  
Customer detail drawer: addresses count · payment methods · last ride · loyalty tier · wallet.

Register routes in `app.js`, implement `store.js` HTTP methods, pages with empty states. **No** client seed of marketplace/hotels/rentals/SOS demo rows.


---

## 23. Customer ↔ shared backend rules

1. All money **BDT**; unify parcel/marketplace demo USD leftovers in API.  
2. Pricing always read from Admin-saved `pricing.customer` (and related).  
3. Food restaurants / marketplace merchants **share** `merchants` + catalog tables (PASS 4 owns merchant-side CRUD).  
4. Ride assignment uses Rider online pool (PASS 3) — customer create → offer to eligible online riders.  
5. Parcel bookings must appear in Admin customer parcels and be trackable via Public `/api/public/track/{code}`.  
6. Suspended customers (`status=suspended`) cannot create new rides/orders (Admin suspend must enforce).  
7. Food checkout creates merchant kitchen order (`newOrder`) for the restaurant store; marketplace checkout creates merchant order for that store.

---

# PASS 3 — Rider Driver App

> Source shapes: `Rider Driver App/lib` + `featurelist.md`.  
> Maps to Admin **Rider Panel**.  
> **§0A applies:** delete `MockAuthRepository`, `MockTripRepository`, `MockDocumentRepository`; no SharedPreferences-invented rider; no hard-coded `_buildRideOffer` as production dispatch.

## 24. Rider App map

### Mock purge (Rider) — mandatory

- All repositories → Laravel HTTP.  
- Incoming offers only from dispatch API (Customer-created jobs), never random local generators.  
- Earnings/payouts/history from MySQL.  
- Documents uploaded to storage + Admin KYC queue.  
- Notifications for new offers / payout status from API.

### Shell tabs

| Tab | Route | Backend |
|-----|-------|---------|
| Home | `/home` | Online toggle, today’s earnings KPIs, open incoming offer |
| Earnings | `/earnings` | Summary + cash-out |
| Activity | `/activity` | Trip history filters/search |
| Account | `/account` | Profile, vehicle, settings |

Extra: `/earnings/payouts`, `/trip/offer`, `/trip/navigation`, `/trip/completed`, `/trip/details/:id`, `/account/edit|settings|vehicle`.

### Auth

- Phone OTP (server-sent) · Email + password · Register · Forgot/reset — all Laravel.  
- **No** hard-coded demo OTP/password in the app binary for production builds.  
- Session = Sanctum token + `GET /api/rider/me`.


**APIs:** `POST /api/rider/auth/{register,login,otp/request,otp/verify,password/forgot,password/reset,logout}` · `GET/PATCH /api/rider/me`

**Region Lock:** district must be open + `allow_rider=true`. Public partner applications (`register.html`) create the same rider row in `onboarding` status.

---

## 25. Onboarding & KYC

**Steps (app):** registration → personal info → vehicle → documents → verification status.

**Personal info fields:** legal full name, home address, city/district (**Bangladesh districts**, not foreign demo cities), DOB, NID reference (`nid_last4` / full NID).


**Vehicle (`VehicleInfo`):** make, model, year, plate, category (`bike`|`car`|`xl`), optional photo. Must match Admin rider vehicle enum.

**Documents (`DocumentItem`) — required set:**

| id | Title | Notes |
|----|-------|-------|
| `id_proof` | Driver's License or Token | `allowsTokenAlternative`: upload license **or** token number + token photo |
| `nid` | National ID (NID) | Required |
| `registration` | Vehicle Registration | Blue book |
| `photo` | Rider Photo | Face photo |

**Doc statuses:** `pending` → `actionRequired` → `uploaded` → `verified` (Admin). Sequential unlock after each upload (app behavior).

**Admin:** existing `#/rider/kyc` — approve / reject / request reupload / bulk; verifying promotes rider `onboarding` → `active`. Store uploaded files (S3/local disk) and token numbers. Public web partner apply feeds this queue.

**APIs:**

- `PATCH /api/rider/onboarding/personal`  
- `PUT /api/rider/vehicle`  
- `GET /api/rider/documents`  
- `POST /api/rider/documents/{id}/upload` (multipart)  
- `POST /api/rider/documents/id_proof/token` `{ token_number, photo }`  
- `GET /api/rider/onboarding/status`  
- `POST /api/rider/onboarding/complete` (submit for review; online blocked until Admin verifies unless product chooses OTP-skip — **production: require verified KYC to go online**)

---

## 26. Online presence & live map

- `POST /api/rider/presence` `{ online: bool }` — going online requires `status=active`, KYC verified, not suspended, district open.  
- `POST /api/rider/location` `{ lat, lng }` heartbeat while online (every N seconds from app).  
- Admin `#/rider/map` reads online riders with last lat/lng.  
- Track `online_duration` for earnings summary (session accumulate).

---

## 27. Jobs / trips — status machines (source of truth)

**JobType:** `ride` | `food` | `parcel`  
**PaymentMethod:** `cash` (COD) | `digital`  
**TripStatus:** `requested` → accept → then:

| Type | After accept | Then | Then | Then |
|------|--------------|------|------|------|
| Ride | `arriving` | `arrived` | `inProgress` | `completed` |
| Food | `accepted` | `pickedUp` | `completed` (Delivered) | |
| Parcel | `accepted` | `pickedUp` | `inTransit` | `completed` |

Also: `cancelled`.

**Offer fields (IncomingOfferScreen):** type, pickup/drop names+addresses+lat/lng, distanceKm, durationMin, earning ৳, tip, vehicleRequired (rides), paymentMethod, COD note, weightKg/packageLabel (parcel), customer name/phone/rating/tier, surgeMultiplier, createdAt.

**Accept window:** ~30 seconds; timeout = auto-decline; then server may offer to next rider.

**Rider actions:**

| API | Behavior |
|-----|----------|
| `GET /api/rider/offers/current` | Poll or WS; single pending offer |
| `POST /api/rider/offers/{id}/accept` | Bind rider; set status per type; notify customer |
| `POST /api/rider/offers/{id}/decline` | Release offer; try next rider |
| `GET /api/rider/trips/active` | Active job |
| `POST /api/rider/trips/{id}/advance` | Move to `nextStatus` per machine |
| `POST /api/rider/trips/{id}/status` | Explicit status if needed |
| `GET /api/rider/trips` | History `?q=&filter=all\|completed\|cancelled\|cod\|ride\|food\|parcel` |
| `GET /api/rider/trips/{id}` | Details |

Navigation/OSRM can stay client-side; server stores coords for tracking.

---

## 28. Dispatch / matching (Customer ↔ Rider)

When Customer creates:

- **Ride** (`searching`) → find online riders with matching vehicle category, same/open district, not busy → create `trip` offer `requested` with earning from `pricing.rider` (+ surge).  
- **Food order** ready for delivery → offer `food` job; earning = `foodJobFee` (৳30 default). COD note = order total + fee when cash.  
- **Customer parcel** booked → offer `parcel` job; earning from parcel formula; may also assign courier agents later (Courier pass) — for now Rider parcel jobs are valid.

**Surge:** Admin `defaultSurge` / dynamic surge factor on offer (`surgeMultiplier`); earning = base × surge when applicable; Admin trips show surge + COD.

**Platform commission:** `platformCommissionPct` on rider pricing — deduct from rider balance or show net earning (implement net earning on complete).

On complete: credit rider balance (earning + tip − commission); update Customer ride/food/parcel status; write Admin `trips` row.

---

## 29. Fares (must match Admin `pricing.rider`)

From `RiderFareConfig` (replace hard-code with API-loaded params):

| Key | Default |
|-----|---------|
| rideBase / ridePerKm / ridePerMin / rideMinimum | 30 / 15 / 1 / 50 |
| bikeMultiplier / carMultiplier / xlMultiplier | 0.7 / 1.0 / 1.5 |
| foodJobFee | 30 |
| parcelBase / parcelPerKm / parcelPerKg / parcelMinimum | 40 / 12 / 8 / 50 |
| defaultSurge / platformCommissionPct | 1.8 / 15 |

Ride: `max(min, round(base+km*r+min*t))` then × vehicle multiplier, then floor at minimum.  
Food: flat `foodJobFee`.  
Parcel: `max(parcelMinimum, round(base+km*perKm+kg*perKg))`.

---

## 30. Earnings & payouts

**EarningsSummary fields:** todayTotal, todayTrips, onlineDuration, todayTrendPercent, currentBalance, weekTrendPercent, baseFare, tips, surgeBonuses, dailyTotals[7].

**Cash-out (`requestCashOut`):** rider requests amount ≤ balance → creates payout row `status: pending|processing` (method bKash/Nagad/Bank from profile). Insufficient balance → error.

**Admin duality:**

- `#/rider/pay` — Admin **pays salary** (creates paid payout log) — keep.  
- `#/rider/payouts` — list all; include **rider-initiated cash-outs**; Admin approve/complete/reject (extend `setRiderPayoutStatus` if missing).  
When Admin marks paid, debit rider balance if not already reserved on request.

**APIs:** `GET /api/rider/earnings` · `GET /api/rider/payouts` · `POST /api/rider/payouts/cash-out` `{ amount, method }` · payout method profile on rider.

---

## 31. Profile & settings

- Edit name, phone, email, avatar  
- View/update vehicle  
- Settings: logout, notification prefs (optional), simulate flags removed in production  
- Rating displayed from aggregate customer ratings

---

## 32. Admin Rider Panel — deepen (pass 3)

Already registered: Dashboard, Riders, KYC, Trips, Map, Pay, Payouts, Pricing.

**Required backend depth:**

1. Riders list reflects real online, vehicle, plate, district, status, todayEarnings, tripsToday.  
2. KYC shows real uploaded docs + token numbers; actions mutate rider eligibility.  
3. Trips/jobs = live dispatch records (type, route, km, earning, payment, surge, COD, status).  
4. Live map = presence heartbeats.  
5. Pay salary + cash-out queue both in payout log.  
6. Pricing edits instantly affect new offers.  
7. Dashboard KPIs: online riders, trips today, earnings pool, pending KYC, pending payouts.  
8. Suspend rider → force offline + reject new offers.

Public Web partner applications appear here as onboarding riders.

---

## 33. Rider ↔ Customer sync rules

1. Customer ride `searching` until a rider accepts → then `assigned`/`in_progress` aligned with rider statuses (map: arriving/arrived → customer sees assigned; inProgress → in_progress; completed/cancelled shared).  
2. Food order tracking advances when rider hits pickedUp / completed.  
3. Customer parcel tracking advances on rider parcel statuses.  
4. Customer rating of driver updates rider.rating.  
5. One active trip per rider; busy riders excluded from dispatch.  
6. Offer expiry / decline requeues to next eligible rider; if none, customer stays searching / gets cancel option.

---

# PASS 4 — Vendor Merchant App

> Source shapes: `Vendor Marchant App/lib` + `featurelist.md`.  
> Maps to Admin **Merchant Panel**. **BDT only.**  
> **§0A applies:** delete all `Mock*Repository` / SharedPreferences fake store; kitchen & catalog empty until real data exists in MySQL.

## 34. Merchant App map

### Mock purge (Merchant) — mandatory

- Remove mock orders/products/reviews/payouts arrays.  
- Home KPIs from API aggregates (zeros when empty).  
- Onboarding images → storage + Admin queue.  
- Status changes persist and notify Customer/Rider/Admin.  
- No success SnackBar without API confirmation.

### Shell tabs

| Tab | Routes | Backend |
|-----|--------|---------|
| Home | `/home` | Sales summary, orders overview KPIs |
| Orders | `/orders`, `/orders/:id` | Kitchen board + details |
| Products | `/products`, categories, new/edit | Catalog CRUD |
| Store hub | `/store/*` | Info, branding, revenue, payouts, reviews, settings |

### Auth

- Login email/password · Register → onboarding — Laravel only.  
- **No** baked-in `demo@hillgo.com` auto-complete merchant.  
- **APIs:** `POST /api/merchant/auth/{register,login,logout}` · `GET/PATCH /api/merchant/me`


**Region Lock:** registration/onboarding requires district open + `allow_merchant=true`.

---

## 35. Onboarding (`OnboardingData`)

Multi-step; on complete → Admin **onboarding queue** (`pending`).

| Field | Notes |
|-------|-------|
| businessName, description | Required |
| logoPath, storefrontPath | Image uploads |
| category | See list below |
| subcategories[] | Per-category options |
| contactName, phone, email | |
| address, city, zip | Map city → district for Region Lock |
| district | Explicit or derived |

**Categories:** Restaurant & Cafe · Grocery & Market · Bakery · Electronics · Fashion & Apparel · Home & Lifestyle · Health & Beauty · Other  

**Subcategory examples:** Fast Casual/Fine Dining/Coffee…; Organic/Produce…; etc. (preserve app maps).

**Docs for Admin queue:** Trade License, NID, Storefront Photo (align Admin seed onboarding docs).

Merchant stays `onboarding`/`pending` until Admin `approved` → store `active`. Reject / `changes_requested` must notify merchant app.

**APIs:** `POST /api/merchant/onboarding` (multipart) · `GET /api/merchant/onboarding/status`

---

## 36. Store profile

`StoreModel` fields: name, description, address, specialties, bio, lat/lng, isOpen, acceptingOrders, hours{day → open/close/isClosed}, banner, logo, profileStrength.

**APIs:**

- `GET/PUT /api/merchant/store`  
- `PATCH /api/merchant/store/status` `{ is_open, accepting_orders }`  
- `POST /api/merchant/store/branding` banner/logo upload  
- Hours nested in store update  

Closed district or Admin suspend → force `acceptingOrders=false`.

---

## 37. Catalog (categories + products)

**CategoryModel:** id, name, icon/color metadata (or icon key), itemCount, isVisible, sortOrder.  
**ProductModel:** id, name, description, category, price (BDT), sku, stock, lowStockAlert, imageUrls[], trackStock.

**Merchant APIs:**

- Categories: list, create, update, reorder, toggle visibility, delete  
- Products: list, create, update, delete, image upload  
- Low-stock: `stock <= lowStockAlert` when trackStock

**Customer sync:**

- Restaurant & Cafe (+ Bakery food items) → Customer food restaurant menus  
- Other retail categories → Customer marketplace products (or both where applicable)  
- Hidden categories (`isVisible=false`) excluded from Customer browse  

**Admin:** `#/merchant/catalog` oversight — all stores’ products, filter low stock / hidden; optional force-hide product.

---

## 38. Orders / kitchen status machine

**Statuses:** `newOrder` → `preparing` → `ready` → `delivered` | `rejected`  
(Admin seed uses `new_order` — normalize to one enum in API, map in Admin UI.)

**Priorities:** `standard` | `priority` | `express` | `scheduled` (+ `scheduledFor` datetime).

**Order fields:** id, customerName/phone/rating/orderCount, items[{name, qty, price, image, notes}], customerNote, status, createdAt, priority, deliveredAt, rating, serviceFee, taxRate.

**Totals:**  
`subtotal = Σ line`  
`tax = subtotal × taxVatPct` (from Admin merchant pricing; replace demo 9.4%)  
`serviceFee = orderServiceFee` (BDT from pricing; replace $2.50)  
`total = subtotal + serviceFee + tax`  
Platform commission on settlement: `platformCommissionPct`.

**Merchant actions:**

| Action | Transition |
|--------|------------|
| Accept / start preparing | new → preparing |
| Mark ready | preparing → ready |
| Mark delivered | ready → delivered (or rider completion may set this) |
| Reject | → rejected |

Filters: New (All/Priority/Express), Preparing, Ready, Delivered history with date range + search.

**APIs:** `GET /api/merchant/orders?status=` · `GET .../{id}` · `POST .../{id}/accept|ready|deliver|reject`

**Sync:**

1. Customer food/marketplace place order → merchant `newOrder` + Admin merchantOrders + Customer food order `placed`.  
2. Merchant preparing → Customer `preparing`.  
3. Merchant ready → Customer `on_the_way` prep + **dispatch Rider food job** (PASS 3).  
4. Rider/customer delivered → merchant `delivered`.  
5. Reject → Customer cancelled/rejected notification.

---

## 39. Revenue, payouts, transactions

**Revenue summary keys (from API aggregates over MySQL):** totalRevenue, pendingPayout, orders count, growthPercent, nextPayoutDate, totalWithdrawn, lastPayoutDate, todaySales, todayOrders, rating, reviewCount + trend series Daily/Weekly/Monthly. Return zeros/empty arrays when no data — **never** hard-coded showcase numbers.


**PayoutModel:** id, amount, date, status (`completed`|`pending`|`processing`), method (Bank/bKash/Nagad).  
**Early payout:** `POST /api/merchant/payouts/early-request` — sets `earlyRequest=true`, may apply `earlyPayoutFeePct`; blocked if amount < `minPayoutAmount`; Admin must approve.

**TransactionModel:** order credits + payout debits ledger.

**Settlement cycle:** from pricing (`weekly` default).

**Admin:** existing merchant payouts screen — approve early, mark processing/completed.

---

## 40. Reviews

`ReviewModel`: customerName, avatar, rating, comment, createdAt, verified, reply, repliedAt, imageUrls.

**APIs:** `GET /api/merchant/reviews?filter=all|unreplied|positive` · `POST /api/merchant/reviews/{id}/reply`  
Customer post-order ratings write into this table. Admin may moderate (optional hide).

---

## 41. Settings & notifications

Merchant prefs: notifyNewOrders, notifyPayouts, notifyReviews, language — persist server-side.  
Push/in-app when new order / payout / review (wire notification service).

---

## 42. Admin Merchant Panel — deepen (pass 4)

Already: Dashboard, Stores, Onboarding, Orders, Payouts, Pricing.

**Add/complete:**

| Item | Detail |
|------|--------|
| `#/merchant/catalog` | Products across stores; low stock; hide/unhide |
| Onboarding | Full `OnboardingData` + images; approve creates store with hours defaults |
| Orders | Show line items, priority, fees in BDT |
| Stores detail | Hours, branding, accepting flags, GMV |
| Pricing | Enforce BDT service fee + VAT 5% (or configured) on all new orders |

Dashboard KPIs: Active stores · Orders today · GMV · Pending payouts · Avg rating · Stores in closed districts.

---

## 43. Merchant ↔ shared rules

1. One merchant user owns one or more stores (v1: one store per account OK; schema allow store_id).  
2. Catalog is source for Customer food menus and marketplace SKUs — no separate orphan dummy catalogs in production.  
3. Commission + fees computed server-side from Admin pricing.  
4. Early payout and settlement visible in Admin payout log.  
5. Suspended / pending merchants cannot accept orders.  
6. Public Web merchant interest leads may create draft onboarding records (optional link to contact form `Merchant Partnership`).

---

# PASS 5 — Courier Agent App

> Source shapes: `Courier Agent App/lib` + `featurelist.md`.  
> Maps to Admin **Courier Panel**. **BDT only.**  
> **§0A applies:** delete `MockData` and all mock repos; OTPs server-issued; no client always-valid `1234` in production.

## 44. Courier App map

### Mock purge (Courier) — mandatory

- Assigned/history parcels only from API.  
- Earnings/withdraw/incentives/notifications from MySQL.  
- Registration docs → storage + Admin KYC.  
- Fail/deliver/pickup only after successful API.  
- Empty dashboard when no assignments.

### Shell tabs

| Tab | Route | Backend |
|-----|-------|---------|
| Dashboard | `/dashboard` | Assigned parcels + today stats + online toggle |
| History | `/history` | Delivered/failed history search + period |
| Earnings | `/earnings` | Weekly/daily breakdown → payout / withdraw / incentives |
| Profile | `/profile` | Vehicle, documents, notification prefs, language, support |

Delivery flow routes: `/parcel/:id` → pickup-otp → navigate → delivery-otp → success.

### Auth

- Login email/phone + password; OTP login; forgot password — Laravel.  
- Register 4 steps (profile → docs License/NID/Vehicle Reg → verification → review) → pending KYC in MySQL.  
- Vehicle types: `Motorbike` | `Bicycle` | `Van`.  
- **No** client demo account shortcut. Sanctum + `/api/courier/me`.  
- Biometrics: device-local unlock of stored token only.  
- **APIs:** `POST /api/courier/auth/{register,login,otp/*,password/*,logout}` · `GET/PATCH /api/courier/me`  
- **Region Lock:** `allow_courier` + district open.


---

## 45. Agent profile & KYC

**UserModel fields:** name, email, phone, vehicleType, vehicleName, vehiclePlate, partnerSince, rating, totalDeliveries, avatar, nid, isVerified.

**Docs (Admin courier KYC):** License · NID · Vehicle Registration (+ expiry reminder in notifications).  
Admin: approve/reject + **bankVerified** flag (required for withdrawals).

**APIs:** profile update, vehicle update, documents list/upload, notification prefs, language.

Online toggle: `PATCH /api/courier/presence` `{ online }` — only if verified + active + district open.

---

## 46. Parcels & OTP delivery machine

**ParcelModel fields:** id, orderId (tracking code e.g. `HG-…` / `HL-…`), type (Electronics/Documents/Food/Apparel/Pharmacy/…), priority (`standard`|`express`|`priority`), status, sender/receiver name+address+phone, pickup/dropoff latlng, weightKg, estimatedEarnings, surgeBonus, distanceKm, etaMinutes, notes, fragile, customerName, payout, timestamps.

**Statuses:**

```
assigned → pickedUp → inTransit → delivered
                      ↘ failed
```

| Step | Trigger | Status |
|------|---------|--------|
| Assigned | Admin/system dispatch to agent | `assigned` |
| Pickup OTP | 4-digit OTP from **server** (shown to sender via Customer app/SMS) | → `pickedUp` |
| Start navigation | Agent opens navigate | → `inTransit` |
| Delivery OTP | 4-digit OTP from **server** (shown to receiver) | → `delivered`; credit payout = earnings + surge (− commission) |
| Fail | Agent marks failed + reason | → `failed`; payout 0 |

**Alternatives (implement):** photo of package, signature confirmation — store as proof media if OTP unavailable (Admin can audit).

**OTP rules:** Server generates separate pickup_otp + delivery_otp per parcel; validate on confirm; log attempts; **never** hard-code always-valid client OTP; never expose full OTP in Public track API.


**APIs:**

| Method | Path |
|--------|------|
| GET | `/api/courier/parcels/assigned` |
| GET | `/api/courier/parcels/history?q=&period=` |
| GET | `/api/courier/parcels/{id}` |
| POST | `/api/courier/parcels/{id}/pickup-otp` `{ otp }` |
| POST | `/api/courier/parcels/{id}/start-transit` |
| POST | `/api/courier/parcels/{id}/delivery-otp` `{ otp }` |
| POST | `/api/courier/parcels/{id}/fail` `{ reason }` |
| POST | `/api/courier/parcels/{id}/proof` multipart (photo/signature) |

Navigation/map may use client OSRM; store last GPS optionally.

---

## 47. Earnings, payouts, withdrawals

**DashboardStats:** todayEarnings, distanceKm, performanceRank, bonusMultiplier, earningsTrend[], trendPercent.  
**WeeklySummary:** total, percentChange, totalDeliveries, activeHours, avgPerHour.  
**DailyEarning:** date, total, basePay, tips, surges, deliveries.  
**PayoutSummary:** nextPayoutDate, totalProcessed, bankLastFour, isVerified, deliveriesCompleted, weeklyGoalPercent, transactions[].

**Withdraw:** `POST /api/courier/withdrawals` `{ amount, method }`  
- Require bankVerified  
- amount ≥ `pricing.courier.withdrawalMin`  
- amount ≤ available balance  
- Creates Admin withdrawal `pending` (bKash/Nagad/Bank)

**Admin:** existing `#/courier/withdrawals` — approve / reject / mark paid.

Earnings computed from Admin courier pricing:

```
base = parcelBase + perKm×km + perKg×kg
× expressMultiplier | priorityMultiplier
+ surge (capped by surgeCap)
− platformCommissionPct
× incentive multipliers when enrolled
```

Weekly goal / top performer multiplier from pricing + Admin incentives.

---

## 48. Incentives

Agent sees Admin-created incentives (`IncentiveOffer`: title, description, multiplier, validUntil, isActive + optional district/goal/bonusTk).

**APIs:** `GET /api/courier/incentives` · `POST /api/courier/incentives/{id}/accept`  
Accepted incentives apply to subsequent eligible deliveries in zone/time window.

Admin CRUD already in `#/courier/incentives`.

---

## 49. Notifications & support

- Assignment, payout scheduled, document expiry, incentive unlock — **DB notifications** + FCM where available.  
- `GET /api/courier/notifications` mark read/all — replace any hard-coded notification list.  
- Support/help: FAQ + ticket in MySQL (Admin-visible).

---

## 50. Admin Courier Panel — deepen (pass 5)

Already: Dashboard, Agents, KYC, Parcels, Withdrawals, Incentives, Pricing.

**Required depth:**

1. Agents reflect online, vehicle type, plate, district, verified, bankVerified, deliveries, rating.  
2. KYC shows uploaded License/NID/Registration; approve unlocks assignments.  
3. Parcels show live statuses + OTP confirmation log (who/when/success).  
4. Manual reassign / unassign parcel when failed or agent suspended.  
5. Withdrawals queue settles agent balance.  
6. Incentives CRUD pushes to agent app.  
7. Pricing drives all new parcel earning quotes.  
8. Dashboard KPIs: Active agents · In transit · Delivered today · Pending withdrawals · Active incentives.

---

## 51. Courier ↔ Customer / Rider / Public sync

1. Customer books parcel → create `customer_parcels` + tracking code → **assign to online courier** in open district (preferred for Document/Box/Fragile courier network). Rider parcel jobs remain valid for last-mile when configured — use a clear `fulfillment_channel` = `courier` | `rider`.  
2. Status mapping to Customer tracking / Public `/api/public/track/{code}`:  
   `assigned`/`booked` → `picked_up` → `in_transit` → `delivered` | `cancelled`/`failed`.  
3. Pickup/delivery OTPs issued to sender/receiver (Customer notifications).  
4. Completed delivery credits courier balance; Admin parcels list updates.  
5. Failed delivery notifies customer; Admin may reassign.  
6. Same tracking ID works on Public Web track form.

---

## 52. End-to-end interconnect checklist (all passes)

Use this as the final integration definition of done — **every cell is live MySQL**, no mocks:

| Flow | Surfaces |
|------|----------|
| Region Lock | Admin → blocks Customer/Rider/Merchant/Courier register + Public availability |
| Ride | Customer → Rider dispatch → Admin rides/trips |
| Food | Customer → Merchant kitchen → Rider delivery → Admin food + merchant orders |
| Marketplace | Merchant catalog → Customer shop → Merchant order → Admin |
| Customer parcel | Customer book → Courier (OTP) and/or Rider → Public track → Admin parcels |
| Payouts | Rider salary/cash-out · Merchant payout/early · Courier withdraw → Admin finance actions |
| Pricing | Admin panels → all fare/fee/earning calculations |
| KYC | Rider/Courier/Merchant onboarding → Admin queues |
| Wallet/SOS/Promos | Customer ↔ Admin Customer Panel |
| Contact/Partner/Newsletter | Public Web ↔ Admin inbox / rider onboarding |
| Notifications | Every status/payout/KYC/order event → role inboxes (Customer/Rider/Merchant/Courier/Admin) |
| Empty state | New install: only structural seed; apps show empty until real creates |

### Final purge verification (ship gate)

Before calling the build done, run these checks:

1. No `localStorage.setItem` for admin entity state.  
2. No Flutter `Mock*Repository` registered in `main.dart` / DI.  
3. No `dummy_data` / `MockData` imported by production screens.  
4. No toast/SnackBar success without preceding successful HTTP 2xx.  
5. Creating a customer ride appears in Admin + Rider offer without refreshing mocks.  
6. Admin pricing change alters next quote/earning from apps.  
7. Notification rows created in MySQL for key events; unread badges update.  
8. Layouts usable on mobile width for Admin + Public Web; Flutter empty states OK.

---

## Changelog of this prompt file

| Pass | Date | What was added |
|------|------|----------------|
| 1 | 2026-07-31 | Repo map; Public Web; Super Admin; Region Lock; APIs. |
| 2 | 2026-07-31 | Customer App full scope + Admin Customer gaps. |
| 3 | 2026-07-31 | Rider App full scope + dispatch sync. |
| 4 | 2026-07-31 | Merchant App full scope + kitchen/catalog sync. |
| 5 | 2026-07-31 | Courier App full scope; all six surfaces COVERED. |
| 5b | 2026-07-31 | **§0A Zero-mock mandate:** delete all mock/localStorage; structural seed only; real notifications; no toast-only success; fully dynamic/real-time; responsive; DB interconnect proof; per-app purge + global acceptance. |
| 5c | 2026-07-31 | **§0B Security mandate** + hard rule 9: link `SECURITY.md` / `SECURITY_PATCH.md`; opaque hashed tokens; secrets/BOLA/money/audit/throttle/CORS; Admin-first example; perf coexistence. |

---

*All incremental passes complete. This file is the single build prompt for the monolithic Laravel + MySQL backend powering the Super Admin Panel and interconnecting Public Web + four Flutter apps. Implement with **zero mock data**, **zero localStorage business state**, **working notifications**, **responsive UI**, **full MySQL interconnect**, and **security per SECURITY.md / SECURITY_PATCH.md** — no placeholders, no scoped-down features, no invented surfaces.*

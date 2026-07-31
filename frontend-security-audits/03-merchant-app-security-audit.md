# HillGo Merchant (Vendor) App — Frontend Security & Scalability Audit

**App path:** `Vendor Marchant App/`  
**Package name:** `vendor_marchant_app`  
**Stack:** Flutter (Dart)  
**Scan date:** 2026-08-01  
**Method:** Static code evidence only (`lib/`, `pubspec.yaml`, `android/`, `ios/`).

---

## Catalog mapping (frontend-adapted)

| # | Catalog item | Verdict |
|---|--------------|---------|
| 1 | Hardcoded secrets & API keys | **CLEAN** |
| 2 | Auth / OTP client controls | **FINDING** — OTP non-empty only; no resend cooldown |
| 3 | BOLA / IDOR client patterns | **FINDING** — product/order/review IDs in path |
| 4 | Client-side price / money trust | **FINDING** — product price + early payout amount POSTed |
| 5 | Role checks | **N/A** — merchant-only app |
| 6–7 | Mass assignment / SQLi | **N/A** |
| 8 | Debug / verbose errors | **MIXED** — no print; `e.toString()` / API messages in UI; debug signing |
| 9 | CORS | **N/A**; HTTP API default present |
| 10 | Sensitive data in tokens | **CLEAN** — opaque Sanctum token |
| 11 | File upload validation | **FINDING** — product/onboarding images unconstrained |
| 12 | Audit logging | **N/A** |
| 13 | Dependencies | **INFO** — no secure-storage package |
| 14 | Mock data in local storage | **CLEAN** — token + notify prefs only |
| S4 | Pagination | **FINDING** — full products/orders/reviews/payouts lists |

---

## Findings (evidence)

### F1 — HIGH — Sanctum token in SharedPreferences

**File:** `lib/services/api/api_client.dart`  
**Key:** `hillgo_merchant_token`  
**Evidence:** `saveToken` → SharedPreferences. `pubspec.yaml` has `shared_preferences` only (no `flutter_secure_storage`).

---

### F2 — HIGH — Default cleartext API base URL

**File:** `lib/services/api/api_client.dart`

```dart
defaultValue: 'http://localhost:8000/api',
```

---

### F3 — HIGH — Client-trusted product `price`

**Files:**
- `lib/screens/products/product_form_screen.dart` — `price: double.tryParse(_price.text) ?? 0`
- Validator allows any parseable number (including negatives; `"-1"` passes)
- `lib/services/api/api_product_repository.dart` — create/update send `'price': product.price`

---

### F4 — HIGH — Client-trusted early payout `amount`

**Files:**
- `lib/screens/revenue/revenue_screens.dart` — parses amount from text field
- `lib/services/api/api_store_repository.dart` — `POST /merchant/payouts/early-request` with `{ amount, method }`

**Evidence:** UI shows available balance but does not compare `amount` to pending balance before POST.

---

### F5 — HIGH — Release signed with debug keys

**File:** `android/app/build.gradle.kts` — release uses `signingConfigs.getByName("debug")`.

---

### F6 — MEDIUM — Weak OTP client validation / no cooldown

**Files:**
- `lib/screens/auth/login_screen.dart` — OTP validator only checks non-empty (`maxLength: 6` does not enforce length == 6)
- `lib/services/api/api_auth_repository.dart` — register re-POSTs password + optional OTP; no client resend throttle

**Evidence:** Login path is password-only (`auth.login`); OTP UI is register-only.

---

### F7 — MEDIUM — IDOR-enabling client patterns

**Evidence:**

| Call | File |
|------|------|
| `DELETE /merchant/products/$id` | `api_product_repository.dart` |
| `POST /merchant/orders/$orderId/$action` | `api_order_repository.dart` |
| Review reply by `reviewId` from route | `reviews_screens.dart` + `api_store_repository.dart` |

Router passes raw path params (`app_router.dart`). Repositories accept any `String` id with no client ownership check.

---

### F8 — MEDIUM — Unvalidated image uploads

**Evidence:**
- `product_form_screen.dart` — `pickImage` → `readAsBytes()` with no max size / MIME / `imageQuality`
- Onboarding / branding pickers pass path only
- `api_client.dart` multipart helpers attach bytes/path with no size guard

---

### F9 — MEDIUM — Unbounded list fetches

**Evidence:** No `page` / `per_page` / cursor in merchant list GETs:
- `GET /merchant/products`
- `GET /merchant/orders`
- `GET /merchant/reviews`
- `GET /merchant/payouts`
- `GET /merchant/transactions`

Providers hold full lists in memory.

---

### F10 — LOW — Preference flags also in SharedPreferences

**File:** `lib/providers/store_provider.dart` — keys `notify_orders`, `notify_payouts`, `notify_reviews`, `language` (non-secret, same plaintext store as token).

---

## CLEAN (verified)

| Item | Evidence |
|------|----------|
| No hardcoded secrets | Grep under Merchant app → no `AIza` / `sk_` / embedded Bearer |
| Order totals not POSTed by merchant | Order mutations are status actions only (`accept`/`ready`/`deliver`/`reject`) |
| Order money fields primarily API-sourced | `order_model.dart` parses JSON; local getters are display fallbacks |
| No `print` / `debugPrint` in `lib/` | Grep clean |
| Manifests do not enable cleartext traffic flags | No `usesCleartextTraffic` / ATS arbitrary loads |
| No KYC/financial mock dump in localStorage | Token + notify prefs only |

---

## Severity summary

| Severity | Count |
|----------|-------|
| High | 5 |
| Medium | 4 |
| Low | 1 |

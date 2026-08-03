# Merchant App — Frontend Fix Results

**App:** `Vendor Marchant App/`  
**Date:** 2026-08-01  
**Rule:** Claims only with code evidence + analyzer checks.

---

## Verification commands (actual)

```text
flutter analyze lib/services/api/api_client.dart
  lib/screens/products/product_form_screen.dart
  lib/screens/revenue/revenue_screens.dart
→ No issues found! (ran in 6.5s)

node --check not applicable (Dart).
```

Also fixed SDK API mismatch on touched dropdowns: `initialValue:` → `value:` (confirmed by grep: zero `initialValue:` left in Dart trees).

---

## Fixes implemented (evidence)

| Audit ID | Fix | Evidence |
|----------|-----|----------|
| F1 HIGH | Secure token | `api_client.dart` `FlutterSecureStorage`; `main.dart` `loadToken()` |
| F2 HIGH | Release API base | `kReleaseMode` throws without dart-define; debug `127.0.0.1:8000` |
| F3 HIGH | Price ≥ 0 and ≤ 1e7 | `product_form_screen.dart` validator `price < 0 \|\| price > 1e7` |
| F4 HIGH | Early payout ≤ pending | `revenue_screens.dart` lines 88–106: `amount > available` blocked |
| F5 HIGH | Optional release signing | `build.gradle.kts` + `allowBackup="false"` |
| F6 MED | OTP exactly 6 digits + 45s resend | `login_screen.dart` `RegExp(r'^\d{6}$')`, `_resendSeconds` |
| F8 MED | Image quality/size | product/onboarding/branding: `imageQuality: 80`, maxWidth 1600, 5MB reject |
| F9 MED | List `per_page=50` | `api_product_repository`, `api_order_repository`, `api_store_repository` |
| Errors | Prefer `ApiException.message` | auth/orders/products providers |

---

## Not claimed

- Server re-validation of product price / payout amount (backend).
- Order totals still not POSTed by merchant (was already CLEAN).

## Follow-up LOW closed (2026-08-01)

Preference flags no longer persisted in SharedPreferences — server `/merchant/me` + PATCH settings (see `08-remaining-low-fixes.md`).

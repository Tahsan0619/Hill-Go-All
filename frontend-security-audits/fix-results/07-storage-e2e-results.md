# Storage E2E — Frontend ↔ Backend ↔ Database

**Date:** 2026-08-01  
**Script:** `hillgo-backend/scripts/e2e_storage_verify.php`  
**Result:** **43 passed, 0 failed**

---

## Root causes fixed

| Issue | Fix |
|-------|-----|
| `public/storage` was a **plain directory**, not a junction to `storage/app/public` | Removed fake dir; created Windows junction so uploads and HTTP `/storage/...` share one tree |
| Product/branding paths inconsistent; onboarding logos stored without `/storage/` prefix | `App\Support\StoredFiles` + `Media::url` normalize bare keys |
| Re-upload left orphan files | `replacePublic` / `replacePrivate` delete previous objects |
| Product delete left files on disk | `deleteProduct` removes public images |
| Merchant storefront KYC path served from wrong disk | Private KYC copy + public branding; admin `onboardingDoc` uses `StoredFiles::absolute` |
| Admin UI listed KYC titles but never opened files (Bearer required) | `AppStore.openAuthenticatedFile` + Open buttons on rider/courier/merchant KYC |

---

## Coverage matrix

| Client | Upload | Read | Modify/replace | Delete |
|--------|--------|------|----------------|--------|
| Rider app → private KYC | PASS | Admin authenticated read PASS; anonymous 401 PASS | Replace + old file removed PASS | N/A (replace cleans) |
| Courier app → KYC | PASS | Admin read PASS | (same replace path) | — |
| Courier app → parcel proof | PASS | Admin proof read PASS | — | — |
| Merchant app → product image | PASS | Public HTTP + Customer marketplace PASS | Replace + old deleted PASS | Product delete removes file PASS |
| Merchant app → branding logo/banner | PASS | Public HTTP PASS | — | — |
| Merchant onboarding → private docs + public logo/storefront | PASS | Admin docFiles + read PASS | — | — |
| Customer app | (no KYC upload) | Marketplace/media URLs PASS | — | — |
| Admin panel | (serves private files) | Authenticated blob open wired | — | — |
| Public web | (no upload) | Home content + public `/storage` PASS | — | — |

---

## Verification command

```text
php scripts/e2e_storage_verify.php
→ 43 passed, 0 failed, 43 total
```

Also: `public/storage` → junction to `storage/app/public` (confirmed by realpath equality).

**Deploy note:** After clone on Windows/Linux, run `php artisan storage:link` (or recreate the junction). Never leave a real folder at `public/storage`.

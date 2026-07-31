# HillGo Frontend Security Audits — Index

**Date:** 2026-08-01  
**Scope:** 4 Flutter apps + 2 webs (frontend only; backend already audited separately)  
**Rule:** Findings listed only with file/path evidence from source. Items marked CLEAN were grepped/read and found absent or correctly handled in that frontend.

| # | Surface | Report |
|---|---------|--------|
| 1 | Customer App (`Hill Go Main Customer App`) | [01-customer-app-security-audit.md](./01-customer-app-security-audit.md) |
| 2 | Rider App (`Rider Driver App`) | [02-rider-app-security-audit.md](./02-rider-app-security-audit.md) |
| 3 | Merchant App (`Vendor Marchant App`) | [03-merchant-app-security-audit.md](./03-merchant-app-security-audit.md) |
| 4 | Courier App (`Courier Agent App`) | [04-courier-app-security-audit.md](./04-courier-app-security-audit.md) |
| 5 | Admin Panel (`Hill Go Admin Panel/ui`) | [05-admin-panel-security-audit.md](./05-admin-panel-security-audit.md) |
| 6 | Public Web (`Hill Go Public Web`) | [06-public-web-security-audit.md](./06-public-web-security-audit.md) |

## Cross-cutting findings (all evidence-backed)

| Issue | Present in |
|-------|------------|
| Sanctum/admin token in plaintext SharedPreferences / localStorage | Customer, Rider, Merchant, Courier, Admin |
| Default API base `http://localhost:8000/api` | All 4 apps + Admin + Public Web |
| Release APK signed with debug keystore | Customer, Rider, Merchant, Courier |
| Client-posted money-related amounts | Customer (distance/weight), Rider (cash-out), Merchant (price/payout), Courier (withdraw), Admin (pricing/wallet/payout) |
| XSS via `innerHTML` with API strings | Admin (widespread), Public Web (parcel quote fare) |
| Catalog #14: KYC/financial mock in localStorage | **Not found** in Admin (token only) or apps (token/prefs only) |
| Hardcoded payment gateway / Google API secrets in frontend source | **Not found** in any of the 6 |

## Not claimed without frontend evidence

- Backend rate limits, BOLA ownership checks, fillable, SQL, APP_DEBUG, CORS allow-list, DB indexes — backend scope (already covered separately).
- CVE IDs for packages — no `composer audit` / OSV run was executed on frontends in this pass; only package presence and insecure patterns are reported.

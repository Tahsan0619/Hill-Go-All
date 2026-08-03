# HillGo — Laravel + MySQL Backend Build Progress

> Companion to `LARAVEL_BACKEND_PROMPT.md`. Updated as the build advances.
> **Stack:** Laravel 12 (PHP 8.5) · MariaDB/MySQL (`hillgo` DB) · Sanctum opaque tokens · BDT · `Asia/Dhaka`.
> **Backend location:** `hillgo-backend/`
> **Production runbook:** `PRODUCTION.md`

## Status legend

- ✅ Done and verified
- 🔨 In progress
- ⬜ Not started

---

## How to run (local)

```bash
# API
cd hillgo-backend && php artisan serve          # http://localhost:8000

# Admin Panel
cd "Hill Go Admin Panel/ui" && php -S localhost:5500

# Public Web
cd "Hill Go Public Web" && php -S localhost:3000

# Flutter apps (use LAN IP on a physical device)
flutter run --dart-define=HILLGO_API_BASE=http://localhost:8000/api
```

Allowed browser origins: `CORS_ALLOWED_ORIGINS` in `hillgo-backend/.env`.

### Seeded super admin

- Email: `admin@hillgo.app`
- Password: `HillGo@2026!` (override with `SEED_ADMIN_PASSWORD` before seeding)
- Dev OTPs: `storage/logs/laravel.log`

---

## Foundation

| Item | Status | Notes |
|------|--------|-------|
| Laravel scaffold + MySQL + Sanctum + CORS allow-list | ✅ | |
| `EnsureRole` + Force-JSON middleware | ✅ | |
| Full domain migrations + Eloquent models | ✅ | includes nullable `users.email` |
| Structural seeders only (no demo entities) | ✅ | |
| Shared services (Pricing, Wallet, Dispatch, OTP, Notifier, Audit, RegionLock) | ✅ | |
| Named per-endpoint rate limiters | ✅ | |
| Public `GET /api/public/districts` | ✅ | registration pickers |

---

## Pass status

| Pass | Status |
|------|--------|
| 1A Public Web API + frontend wiring | ✅ |
| 1B Admin API + SPA wiring (no localStorage mocks) | ✅ |
| 2 Customer App API + Flutter rewire | ✅ |
| 3 Rider App API + Flutter rewire | ✅ |
| 4 Merchant App API + Flutter rewire | ✅ |
| 5 Courier App API + Flutter rewire | ✅ |

---

## Flutter / web clients

| Surface | Status | Notes |
|---------|--------|-------|
| Admin Panel SPA | ✅ | Login + live `store.js`; seed.js deleted |
| Public Web | ✅ | Contact, quotes, track, availability, newsletter, partner apps |
| Customer App | ✅ | ApiClient + domain APIs; `dummy_data` / `DemoAuth` deleted; carts in-memory only |
| Rider App | ✅ | ApiAuth/Trip/Document; mocks deleted; presence/KYC/offers live |
| Merchant App | ✅ | ApiAuth/Order/Product/Store; mocks deleted; onboarding multipart |
| Courier App | ✅ | ApiAuth/Parcel/Earnings/Profile/Notification; mocks deleted |

All Flutter apps use `--dart-define=HILLGO_API_BASE=...` (default `http://localhost:8000/api`). Currency displayed as ৳.

### Analyze snapshot (2026-07-31)

| App | Errors | Notes |
|-----|--------|-------|
| Customer | 0 | 19 pre-existing Radio deprecation infos |
| Rider | 0 | clean |
| Merchant | 0 | 1 onReorder deprecation info |
| Courier | 0 | clean |

---

## Security checklist (§0B)

| Item | Status |
|------|--------|
| Secrets only in `.env` | ✅ |
| Opaque Sanctum tokens, hashed at rest | ✅ |
| Role middleware on route groups | ✅ |
| BOLA / ownership scoping | ✅ |
| Server-side money math | ✅ |
| Explicit `$fillable` | ✅ |
| Auth/OTP throttling (per-endpoint) | ✅ |
| Private KYC disk + admin-only document routes | ✅ |
| Append-only audit / wallet / pricing / OTP logs | ✅ |
| CORS allow-list (no `*`) | ✅ |
| `APP_DEBUG=false` for production | ✅ template in `.env.production.example` (deploy step) |

---

## Verification log

| When | Check | Result |
|------|-------|--------|
| 2026-07-31 | `migrate:fresh --seed` | ✅ structural only |
| 2026-07-31 | 45 admin GETs + public endpoints | ✅ |
| 2026-07-31 | E2E: customer OTP → ride → admin trip + notification + wallet | ✅ |
| 2026-07-31 | Region Lock rejects closed-district register | ✅ |
| 2026-07-31 | Rider live smoke: register → onboarding → presence KYC gate | ✅ |
| 2026-07-31 | All four Flutter apps: mock grep clean + analyze 0 errors | ✅ |

---

## Known production follow-ups (ops, not code gaps)

- Wire a real SMS provider into `OtpService` (dev logs OTPs).
- Optional FCM push on top of the DB notification inbox.
- Deploy with `PRODUCTION.md` checklist (HTTPS, caches, password rotate).

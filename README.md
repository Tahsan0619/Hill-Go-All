# Hill Go All

Monorepo for the **HillGo** platform Bangladesh multi-service logistics & lifestyle apps (customer, rider, merchant, courier), plus public web and super-admin panel.

Remote: [https://github.com/Tahsan0619/Hill-Go-All](https://github.com/Tahsan0619/Hill-Go-All)

---

## What’s in this repository

| Folder | What it is |
|--------|------------|
| **hillgo-backend** | Laravel + MySQL/MariaDB API (Sanctum). Source of truth for auth, rides, orders, parcels, wallets, KYC, admin, public web. |
| **Hill Go Main Customer App** | Flutter customer super-app: rides, food, parcels, marketplace, hotels, rentals, wallet, loyalty, SOS. |
| **Rider Driver App** | Flutter partner/driver app: Ride / Food / Parcel jobs, online toggle, earnings, payouts (৳). |
| **Vendor Marchant App** | Flutter merchant app: store onboarding, catalog, orders kitchen flow, revenue & payouts, reviews. |
| **Courier Agent App** | Flutter courier agent app: assigned parcels, pickup/delivery OTP, navigation, earnings, withdrawals, incentives. |
| **Hill Go Admin Panel** | Super-admin web SPA (`ui/`): live Laravel API client. Region Lock, KYC, pricing, payouts. |
| **Hill Go Public Web** | Public marketing / web frontend for HillGo (Laravel `/api/public/*`). |
| **Dist Apks** | Prebuilt **release APKs** for the four Flutter apps (also published on the GitHub **Releases** page). |
| **frontend-security-audits** | Evidence-based frontend security audit reports (4 apps + 2 webs). |

---

## Dist Apks (installable builds)

| File | App |
|------|-----|
| `Courier-Agent-App.apk` | Courier Agent App |
| `HillGo-Main-Customer-App.apk` | Hill Go Main Customer App |
| `Rider-Driver-App.apk` | Rider Driver App |
| `Vendor-Marchant-App.apk` | Vendor Marchant App |

Download the same binaries from **[Releases](https://github.com/Tahsan0619/Hill-Go-All/releases)** for a clean install package.

---

## Quick start

### Backend API

```bash
cd hillgo-backend
cp .env.example .env   # set DB_*, APP_KEY, CORS_ALLOWED_ORIGINS
composer install
php artisan key:generate
php artisan migrate --seed
php artisan serve --host=0.0.0.0 --port=8000
```

See `PRODUCTION.md` for the full runbook.

### Flutter apps

```bash
cd "Hill Go Main Customer App"   # or Rider / Vendor / Courier
flutter pub get
flutter run --dart-define=HILLGO_API_BASE=http://127.0.0.1:8000/api
```

Build release APK:

```bash
flutter build apk --release --dart-define=HILLGO_API_BASE=https://api.<your-domain>/api
```

### Admin panel

Static HTML/CSS/JS + Tailwind CDN. From `Hill Go Admin Panel/ui`:

```bash
python -m http.server 8765
# open http://127.0.0.1:8765
```

Set `window.HILLGO_API_BASE` (or rely on default `http://localhost:8000/api`). Auth token is stored in `localStorage`; KYC/financial data comes from the Laravel API (in-memory cache only).

### Public web

Serve `Hill Go Public Web` with any static file server; it calls `/api/public/*`.

---

## Notes

- All four Flutter apps + Admin + Public Web are wired to **`hillgo-backend`** (Laravel Sanctum).
- Currency / ops framing is **Bangladesh (৳ BDT)**.
- Do not commit `.env` — use `.env.example` / `.env.production.example`.

---

## License

Private / project use unless otherwise stated by the repository owner.

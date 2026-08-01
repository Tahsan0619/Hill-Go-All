# Hill Go All

Monorepo for the **HillGo** platform — Bangladesh multi-service logistics & lifestyle apps (customer, rider, merchant, courier), plus public web and super-admin panel, backed by a Laravel API.

Remote: [https://github.com/Tahsan0619/Hill-Go-All](https://github.com/Tahsan0619/Hill-Go-All)

---

## Source line counts

Counts are **physical lines** (including blanks/comments) of application source only:

- **Flutter apps:** `lib/**/*.dart`
- **Admin Panel:** `ui/**/*.{html,js,css}`
- **Public Web:** `**/*.{html,js,css,svg}`
- **Backend:** `app/`, `routes/`, `config/`, `database/`, `resources/`, `scripts/`, `tests/`, `bootstrap/`, plus `artisan` and `public/index.php` (excludes `vendor/`, `node_modules/`, `storage/`)

Build folders, platform scaffolding, `node_modules`, Composer vendor, and generated plugin registrants are excluded. Measured **2026-08-01**.

### Four apps (separately)

| Client | Folder | Files | Lines |
|--------|--------|------:|------:|
| Customer App | `Hill Go Main Customer App` | 126 | **24,113** |
| Rider App | `Rider Driver App` | 44 | **8,358** |
| Merchant App | `Vendor Marchant App` | 37 | **9,408** |
| Courier App | `Courier Agent App` | 51 | **7,084** |
| **Apps subtotal** | | **258** | **48,963** |

### Two webs (separately)

| Client | Folder | Files | Lines |
|--------|--------|------:|------:|
| Admin Panel | `Hill Go Admin Panel/ui` | 13 | **3,817** |
| Public Web | `Hill Go Public Web` | 22 | **4,253** |
| **Webs subtotal** | | **35** | **8,070** |

### Backend (full API)

| Component | Folder | Files | Lines |
|-----------|--------|------:|------:|
| Application code | `hillgo-backend/app` | 101 | 8,143 |
| E2E / utility scripts | `hillgo-backend/scripts` | 8 | 2,389 |
| Migrations & seeders | `hillgo-backend/database` | 16 | 1,784 |
| Config | `hillgo-backend/config` | 12 | 1,417 |
| Routes | `hillgo-backend/routes` | 3 | 399 |
| Resources / tests / bootstrap / entry | other | 10 | 350 |
| **Backend total** | `hillgo-backend` | **150** | **14,482** |

### Combined totals

| Scope | Files | Lines |
|-------|------:|------:|
| 4 Flutter apps | 258 | 48,963 |
| 2 webs | 35 | 8,070 |
| **All 4 apps + 2 webs** | **293** | **57,033** |
| 1 full backend | 150 | 14,482 |
| **Grand total (apps + webs + backend)** | **443** | **71,515** |

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
| **frontend-security-audits** | Evidence-based frontend security audits + fix results (4 apps + 2 webs, storage E2E). |
| **HillGo-Last.sql** / **hillgo-final.sql** | Database dumps for local restore. |

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
php artisan storage:link   # required so /storage/... media works
php artisan serve --host=0.0.0.0 --port=8000
```

See `PRODUCTION.md` for the full runbook. Storage E2E: `php scripts/e2e_storage_verify.php`.

### Flutter apps

```bash
cd "Hill Go Main Customer App"   # or Rider / Vendor / Courier
flutter pub get
flutter run --dart-define=HILLGO_API_BASE=http://127.0.0.1:8000/api
```

Build release APK (API base is **required** in release):

```bash
flutter build apk --release --dart-define=HILLGO_API_BASE=https://api.<your-domain>/api
```

Optional TLS pinning (Customer): `--dart-define=HILLGO_SSL_PINS=sha256/<base64>,...`

### Admin panel

Static HTML/CSS/JS + Tailwind CDN. From `Hill Go Admin Panel/ui`:

```bash
python -m http.server 8765
# open http://127.0.0.1:8765
```

Set `window.HILLGO_API_BASE` (default `http://127.0.0.1:8000/api`). Auth token is kept in **sessionStorage** (migrated off localStorage). KYC/financial data comes from the Laravel API (in-memory cache only). Private KYC files open via authenticated fetch.

### Public web

Serve `Hill Go Public Web` with any static file server; it calls `/api/public/*`. Images are local assets under `assets/img/` (no Unsplash CDN).

---

## Demo credentials (local)

| Role | Login | Password |
|------|-------|----------|
| Admin | `admin@hillgo.app` | `HillGo@2026!` |
| Demo users | `*@demo.hillgo.app` | `HillGoDemo@2026!` |

OTP demo flows often accept `1234` when configured for local demo phones.

---

## Notes

- All four Flutter apps + Admin + Public Web talk to **`hillgo-backend`** (Laravel Sanctum).
- Currency / ops framing is **Bangladesh (৳ BDT)**.
- Do not commit `.env` — use `.env.example` / `.env.production.example`.
- After clone, always run `php artisan storage:link` so public media URLs resolve.
- Frontend security fix evidence: `frontend-security-audits/fix-results/`.

---

## License

Private / project use unless otherwise stated by the repository owner.

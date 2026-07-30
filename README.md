# Hill Go All

Monorepo for the **HillGo** platform Bangladesh multi-service logistics & lifestyle apps (customer, rider, merchant, courier), plus public web and super-admin panel.

Remote: [https://github.com/Tahsan0619/Hill-Go-All](https://github.com/Tahsan0619/Hill-Go-All)

---

## What’s in this repository

| Folder | What it is |
|--------|------------|
| **Hill Go Main Customer App** | Flutter customer super-app: rides, food, parcels, marketplace, hotels, rentals, wallet, loyalty, SOS. |
| **Rider Driver App** | Flutter partner/driver app: Ride / Food / Parcel jobs, online toggle, earnings, payouts (৳). |
| **Vendor Marchant App** | Flutter merchant app: store onboarding, catalog, orders kitchen flow, revenue & payouts, reviews. |
| **Courier Agent App** | Flutter courier agent app: assigned parcels, pickup/delivery OTP, navigation, earnings, withdrawals, incentives. |
| **Hill Go Admin Panel** | Super-admin web SPA (`ui/`): Region Lock (64 districts / 8 divisions), Customer / Rider / Merchant / Courier panels, pricing, KYC, salary/payouts. Includes Stitch design references under `stitch_hillgo_super_admin_panel/`. |
| **Hill Go Public Web** | Public marketing / web frontend for HillGo. |
| **Dist Apks** | Prebuilt **release APKs** for the four Flutter apps (also published on the GitHub **Releases** page). |

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

### Flutter apps

```bash
cd "Hill Go Main Customer App"   # or Rider / Vendor / Courier
flutter pub get
flutter run
```

Build release APK:

```bash
flutter build apk --release
```

### Admin panel

Static HTML/CSS/JS + Tailwind CDN. From `Hill Go Admin Panel/ui`:

```bash
python -m http.server 8765
# open http://127.0.0.1:8765
```

Mock data is stored in the browser (`localStorage`). No backend required for the current frontend.

### Public web

Open / serve `Hill Go Public Web` with any static file server.

---

## Notes

- Mobile apps currently use **mock / demo data** (no live production API wired in this repo snapshot).
- Admin panel is **frontend-only** with a mutable mock store; designed so APIs can replace store methods later.
- Currency / ops framing is **Bangladesh (৳ BDT)** for customer/rider flows; some older vendor/courier mocks may still show mixed currency labels in UI.

---

## License

Private / project use unless otherwise stated by the repository owner.

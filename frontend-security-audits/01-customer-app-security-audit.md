# HillGo Customer App — Frontend Security & Scalability Audit

**App path:** `Hill Go Main Customer App/`  
**Stack:** Flutter (Dart)  
**Scan date:** 2026-08-01  
**Method:** Static code evidence only (`lib/`, `pubspec.yaml`, `android/`, `ios/`). No hypotheses about unverified backend behavior.

---

## Catalog mapping (frontend-adapted)

| # | Catalog item | Verdict |
|---|--------------|---------|
| 1 | Hardcoded secrets & API keys | **CLEAN** — no payment/API secret literals |
| 2 | Auth / OTP rate limiting (client) | **FINDING** — no client OTP cooldown/resend backoff |
| 3 | BOLA / IDOR (client patterns) | **CLEAN** (client) — no deep links / untrusted ID entry |
| 4 | Client-side trust for price / wallet | **FINDING** — ride/parcel distance & weight POSTed |
| 5 | Weak role checks | **N/A** — single-role customer app; server must enforce |
| 6 | Mass assignment | **N/A** — Eloquent concern; client does not set `role`/`wallet_balance` |
| 7 | SQL injection | **N/A** — no SQL in frontend |
| 8 | Debug / verbose errors | **FINDING** — `e.toString()` shown in UI |
| 9 | Overly permissive CORS | **N/A** — CORS is backend; client uses HTTP API default |
| 10 | Sensitive data in tokens | **CLEAN** — opaque Sanctum string; not client-built JWT PII |
| 11 | KYC / file upload validation | **N/A** — no KYC upload code in Customer app |
| 12 | Audit logging on money | **N/A** — backend concern |
| 13 | Outdated dependencies | **INFO** — recent locks; no CVE claim without audit run |
| 14 | Mock data in local storage | **CLEAN** — only auth token in SharedPreferences |
| S1 | N+1 / chatty calls | **FINDING** — vehicle quote fan-out; 1s ride poll |
| S2 | Caching hot paths | **INFO** — client has no pricing/zone cache layer |
| S3 | Sync work that should be async | **N/A** — mobile UI awaits API (expected) |
| S4 | No pagination on lists | **FINDING** — list APIs fetch full collections |
| S5 | DB indexing | **N/A** — backend |
| S6 | SPOF | **N/A** — backend/infra |

---

## Findings (evidence)

### F1 — HIGH — Sanctum token stored in plaintext SharedPreferences

**File:** `lib/services/api/api_client.dart` (lines 52–72)

```dart
static const String _tokenKey = 'hillgo_customer_token';
// ...
await prefs.setString(_tokenKey, token);
```

**Evidence:** `shared_preferences` is used; `flutter_secure_storage` is absent from `pubspec.yaml`. Token is readable from app prefs on compromised/rooted devices and may be included in backups depending on Android backup defaults.

---

### F2 — HIGH — Client sends ride `distance_km` / `duration_min` used for pricing inputs

**Files:**
- `lib/services/api/rides_api.dart` (body includes `distance_km`, `duration_min`)
- `lib/screens/ride/driver_searching_screen.dart` (passes `ride.distanceKm`, `ride.durationMin`)

**Evidence:** Booking POST includes client-chosen distance/duration. Values originate from client OSRM routing (`lib/services/osrm_service.dart`), not a server-authoritative route at submit time.

---

### F3 — HIGH — Parcel `distance_km` / `weight_kg` defaulted client-side and POSTed

**Files:**
- `lib/models/catalog_models.dart` lines 1053–1054 — defaults `distanceKm = 5.0`, `weightKg = 2.0`
- `lib/services/api/parcels_api.dart` — POST body includes `weight_kg` and `distance_km`

**Evidence:** Parcel flow screens do not expose UI to edit these; defaults are still sent on quote/create.

---

### F4 — MEDIUM — No client OTP request/resend cooldown

**Files:**
- `lib/screens/login_screen.dart` — OTP request on Continue
- `lib/screens/otp_verification_screen.dart` — `_resend()` with no timer/disable

**Evidence:** Resend path calls `AuthService.requestLoginOtp` with no client-side delay or attempt counter. (Server throttle is separate.)

---

### F5 — MEDIUM — Default API base URL is cleartext HTTP localhost

**File:** `lib/services/api/api_client.dart` lines 34–37

```dart
defaultValue: 'http://localhost:8000/api',
```

**Evidence:** Builds without `--dart-define=HILLGO_API_BASE=https://...` use HTTP.

---

### F6 — MEDIUM — Release APK signed with debug keystore

**File:** `android/app/build.gradle.kts` lines 33–38 — `signingConfig = signingConfigs.getByName("debug")` under `release`.

---

### F7 — MEDIUM — Client-side fare rate tables (display)

**Files:** `lib/config/fare_config.dart`, `lib/services/fare_service.dart`  
**Evidence:** Static rates used for local UI estimates. Actual booking still posts distance/duration (F2).

---

### F8 — MEDIUM — Unbounded list fetches (no client pagination params)

**Evidence:** API wrappers call list endpoints without `page` / `per_page`:
- `rides_api.dart` — `RidesApi.list()`
- `food_api.dart` — `restaurants()`
- `hotels_api.dart` / `rentals_api.dart` / `marketplace_api.dart`
- `notifications_api.dart`, `wallet_api.dart` — transactions/inbox

`nearby_services_screen.dart` loads food + hotels + rentals in one `Future.wait`.

---

### F9 — LOW — Exception text dumped into UI

**Evidence:** Multiple screens assign `_error = e.toString()` / `snapshot.error.toString()` (e.g. vehicle selection, restaurant list, wallet, ride history).

---

### F10 — LOW — Wallet top-up amount client-supplied

**Files:** `lib/services/api/wallet_api.dart`, `lib/screens/wallet_screen.dart`  
**Evidence:** POST `/customer/wallet/top-up` with `amount` + `method` from UI. Client only checks `amount > 0`.

---

### F11 — OBSERVATION — No TLS certificate pinning

**Evidence:** Grep of `lib/` for pinning / `SecurityContext` / `badCertificateCallback` → zero matches. Uses `http` package + system CAs.

---

### F12 — LOW — Ride quote fan-out + 1s polling

**Evidence:**
- `vehicle_selection_screen.dart` — `Future.wait` of one quote per vehicle option
- `driver_searching_screen.dart` — `Timer.periodic(Duration(seconds: 1), ...)`

---

## CLEAN (verified)

| Item | Evidence |
|------|----------|
| No hardcoded payment/API secrets | Grep `lib/` for `AIza`, `sk_`, `apiKey`, `secret` literals → no matches; no `print`/`debugPrint` |
| Food/marketplace checkout does not send unit price/total | `food_api.dart` sends `product_id` + `qty` only |
| Hotel/rental book without client `total` | `hotels_api.dart` / `rentals_api.dart` send ids/dates/guests |
| OTP not stored/logged | Controllers only; no print of OTP |
| Token is opaque from API | `auth_service.dart` stores server `token` string |
| No KYC upload surface | No `image_picker` / multipart KYC in Customer `lib/` |
| No WebView / custom deeplink schemes found | No `webview_flutter` / app_links usage in Customer app |
| Mock KYC/financial not in prefs | Only `hillgo_customer_token` in SharedPreferences |

---

## Severity summary

| Severity | Count |
|----------|-------|
| High | 3 |
| Medium | 5 |
| Low / Observation | 4 |

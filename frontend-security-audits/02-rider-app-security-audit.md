# HillGo Rider Driver App — Frontend Security & Scalability Audit

**App path:** `Rider Driver App/`  
**Stack:** Flutter (Dart)  
**Scan date:** 2026-08-01  
**Method:** Static code evidence only (`lib/`, `pubspec.yaml`, `android/`, `ios/`).

---

## Catalog mapping (frontend-adapted)

| # | Catalog item | Verdict |
|---|--------------|---------|
| 1 | Hardcoded secrets & API keys | **CLEAN** |
| 2 | Auth / OTP client throttling | **MIXED** — login OTP has 45s resend UI; no verify attempt limit; forgot-password weaker |
| 3 | BOLA / IDOR client patterns | **FINDING** — trip details fetch any `:id` |
| 4 | Client-side price / money trust | **FINDING** — cash-out amount POSTed; trip fares display-only from API |
| 5 | Role checks | **N/A** — rider-only app |
| 6–7 | Mass assignment / SQLi | **N/A** |
| 8 | Debug / verbose errors | **CLEAN** for `print`/`debugPrint` (none in `lib/`) |
| 9 | CORS | **N/A** (backend); HTTP API default present |
| 10 | Sensitive data in tokens | **CLEAN** — opaque Sanctum token |
| 11 | KYC / file upload validation | **FINDING** — gallery pick with no size/MIME limits |
| 12 | Audit logging | **N/A** |
| 13 | Dependencies | **INFO** — recent caret pins; no secure-storage package |
| 14 | Mock/sensitive data in local storage | **CLEAN** for KYC/money — token only in prefs |
| S1 | Chatty / N+1 style calls | **FINDING** — 2s polling loops |
| S4 | Pagination | **FINDING** — trip history / payouts full list |

---

## Findings (evidence)

### F1 — HIGH — Auth token in SharedPreferences

**File:** `lib/services/api/api_client.dart`  
**Key:** `hillgo_rider_token`  
**Evidence:** `saveToken` → `_prefs.setString(_tokenKey, value)`. No `flutter_secure_storage` in `pubspec.yaml`.  
**Also:** `android/app/src/main/AndroidManifest.xml` does not set `android:allowBackup="false"`.

---

### F2 — HIGH — Default API URL is `http://localhost:8000/api`

**File:** `lib/services/api/api_client.dart`

```dart
static const String baseUrl = String.fromEnvironment(
  'HILLGO_API_BASE',
  defaultValue: 'http://localhost:8000/api',
);
```

---

### F3 — HIGH — Client-trusted cash-out amount

**Files:**
- `lib/services/api/api_trip_repository.dart` — `POST /rider/payouts/cash-out` with `{ amount, method }`
- `lib/screens/earnings/earnings_screen.dart` — `double.tryParse(amountCtrl.text) ?? 0` then `cashOut`

**Evidence:** UI mentions minimum ৳100 but client does not enforce minimum before POST.

**Contrast (CLEAN for trip pricing):** `fare_config.dart` calculators have zero call sites; trip `earning` is parsed from API JSON only. Accept/advance POSTs do not send fare amounts.

---

### F4 — MEDIUM — KYC upload validation gaps

**Files:**
- `lib/screens/onboarding/upload_documents_screen.dart` — `ImagePicker().pickImage(source: gallery)` with no `imageQuality` / size limits
- `lib/services/api/api_document_repository.dart` — multipart upload of local path

**Evidence:** Token number only checks length ≥ 4; NID length ≥ 8 in personal info screen. No MIME allow-list on client.

---

### F5 — MEDIUM — Chatty polling + unbounded lists

| Location | Evidence |
|----------|----------|
| `home_dashboard_screen.dart` | `Timer.periodic(Duration(seconds: 2), ...)` → refresh offer |
| `trip_navigation_screen.dart` | 2s poll → `syncActiveTripCancel` |
| `api_trip_repository.dart` | `getTripHistory` / `getPayouts` — no page/cursor params |

---

### F6 — MEDIUM — Trip-by-ID fetch with no client ownership check

**Files:**
- `lib/router/app_router.dart` — `/trip/details/:id`
- `lib/screens/trip/trip_details_screen.dart` — `getTrip(widget.tripId)`
- `lib/services/api/api_trip_repository.dart` — `GET /rider/trips/$id`

**Evidence:** Any string ID from the route is requested. Server ownership checks are required for safety (not asserted here).

---

### F7 — MEDIUM — Location shared to backend + public OSRM

**Files:**
- `trip_navigation_screen.dart` — GPS stream posts to `/rider/location` (throttled)
- `lib/services/routing_service.dart` — `https://router.project-osrm.org` with exact lat/lng

---

### F8 — LOW–MEDIUM — OTP gaps

| Evidence | File |
|----------|------|
| Login OTP 45s resend cooldown present | `auth_provider.dart`, `otp_screen.dart` |
| No client verify-attempt lockout | `verifyOtp` posts without attempt counter |
| Forgot-password path has no resendSeconds UI | `forgot_password_screen.dart` |
| OTP value not logged | No `print`/`debugPrint` of OTP in `lib/` |

---

### F9 — MEDIUM — Release signed with debug keys

**File:** `android/app/build.gradle.kts` — release `signingConfig` = debug.

---

## CLEAN (verified)

| Item | Evidence |
|------|----------|
| No hardcoded API secrets | Grep under Rider app for `AIza`, `sk_live`, hardcoded Bearer → no matches |
| No debug prints of secrets | No `print(` / `debugPrint(` in `lib/` |
| Trip earnings not client-invented on mutate | Status-only advance/accept bodies |
| Manifests do not set `usesCleartextTraffic=true` | No NSC / `NSAllowsArbitraryLoads` |
| KYC/NID not written to SharedPreferences | Only token key found |
| No WebView | No webview package / widgets |
| No custom deeplink intent filters | Android MAIN/LAUNCHER only |

---

## Severity summary

| Severity | Count |
|----------|-------|
| High | 3 |
| Medium | 5 |
| Low / Mixed | 1 |

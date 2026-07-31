# HillGo Courier Agent App — Frontend Security & Scalability Audit

**App path:** `Courier Agent App/`  
**Stack:** Flutter (Dart)  
**Scan date:** 2026-08-01  
**Method:** Static code evidence only (`lib/`, `pubspec.yaml`, `android/`, `ios/`).

---

## Catalog mapping (frontend-adapted)

| # | Catalog item | Verdict |
|---|--------------|---------|
| 1 | Hardcoded secrets & API keys | **CLEAN** |
| 2 | Auth / OTP client controls | **FINDING** — 4-digit OTP; no client attempt lockout |
| 3 | BOLA / IDOR client patterns | **FINDING** — `/parcel/:id` drives API calls |
| 4 | Client-side money trust | **FINDING** — withdrawal amount POSTed; history payout math client-side |
| 5 | Role checks | **N/A** — courier_agent app |
| 6–7 | Mass assignment / SQLi | **N/A** |
| 8 | Debug / verbose errors | **CLEAN** for print of tokens (none found) |
| 9 | CORS | **N/A**; HTTP API default present |
| 10 | Sensitive data in tokens | **CLEAN** — opaque Sanctum token |
| 11 | KYC / file upload validation | **FINDING** — multipart with no size/MIME checks |
| 12 | Audit logging | **N/A** |
| 13 | Dependencies | **INFO** — shared_preferences only for auth storage |
| 14 | Sensitive local storage | **FINDING** — token in prefs; password/NID held in memory after register |
| S4 | Pagination | **MIXED** — history paginated; assigned/notifications unbounded |

---

## Findings (evidence)

### F1 — HIGH — Sanctum token in SharedPreferences

**File:** `lib/services/api/api_client.dart`  
**Key:** `hillgo_courier_token`  
**Evidence:** `saveToken` / `getString(tokenKey)`. No secure-storage package in `pubspec.yaml`.  
**Also:** `_storeSession` in `api_auth_repository.dart` always saves token (even when “keep logged in” is false for restore).

---

### F2 — HIGH — Default API URL `http://localhost:8000/api`

**File:** `lib/services/api/api_client.dart` — `String.fromEnvironment('HILLGO_API_BASE', defaultValue: 'http://localhost:8000/api')`.

---

### F3 — HIGH — Release signed with debug keys

**File:** `android/app/build.gradle.kts` — release `signingConfig` = debug.

---

### F4 — HIGH — Withdrawal amount client-supplied without local balance/min/verified gates

**Files:**
- `lib/screens/earnings/withdraw_sheet.dart` — `_confirm` only rejects `entered <= 0`
- `lib/providers/earnings_provider.dart` — `withdraw(amount:, method:)`
- `lib/services/api/api_earnings_repository.dart` — `POST /courier/withdrawals` with `{ amount, method }`

**Evidence:** UI displays `payout.balance`, `payout.withdrawalMin`, `payout.isVerified` but `_confirm` does not enforce them before POST.

---

### F5 — MEDIUM — Android backup can include prefs token

**File:** `android/app/src/main/AndroidManifest.xml`  
**Evidence:** `<application>` has no `android:allowBackup="false"` (platform default allows backup).

---

### F6 — MEDIUM — Parcel IDOR client surface

**Files:**
- `lib/router/app_router.dart` — `/parcel/:id`, `/parcel/:id/pickup-otp`, etc.
- `lib/services/api/api_parcel_repository.dart` — `GET /courier/parcels/$id`, OTP/proof/fail by `parcelId`

**Evidence:** No client check that `id` is in the assigned list before API calls.

---

### F7 — MEDIUM — Client-computed delivered payout for history display

**Files:**
- `lib/models/parcel_model.dart` — `payout: status == delivered ? earnings + surge : null`
- `lib/providers/parcel_provider.dart` — `historyTotal` sums client-derived `payout`

**Evidence:** “TOTAL EARNINGS” on history is arithmetic over loaded rows, not a dedicated server total field.

---

### F8 — MEDIUM — Registration password + NID retained in memory after register

**File:** `lib/providers/auth_provider.dart`  
**Evidence:** Fields `regPassword`, `regNid`, doc paths set during registration; `logout()` / `completeRegistration()` do not clear password/NID from the notifier.

---

### F9 — MEDIUM — KYC / proof uploads without client size/type limits

**Files:**
- `lib/services/api/api_client.dart` — `multipart(... MultipartFile.fromPath ...)`
- `lib/services/api/api_profile_repository.dart` — `/courier/documents/$docKey/upload`
- Document / OTP proof screens use `ImagePicker.pickImage` without compression/size caps

---

### F10 — MEDIUM — 4-digit OTP; no client lockout

**Evidence:** `otp_input.dart` length 4; login/pickup/delivery verify paths show SnackBar on failure only — no attempt counter.

---

### F11 — LOW — Unbounded assigned + notifications lists

**Evidence:**
- Assigned: `api_parcel_repository.dart` returns full list; dashboard maps all
- Notifications: single GET, no page
- History: has `page` + `loadMoreHistory` (mitigated)

---

## CLEAN (verified)

| Item | Evidence |
|------|----------|
| No hardcoded API secrets / google-services / JKS in app tree | Grep clean |
| No `print` / `debugPrint` of tokens in `lib/` | Grep clean |
| No `usesCleartextTraffic=true` / ATS arbitrary loads | Manifests/plist clean |
| Photo proof upload does not itself call delivery confirm | Upload path separate from `confirmDelivery` |
| Trip/parcel fare invent on mutate | Delivery OTP / transit POSTs do not send invented fare totals |

---

## Severity summary

| Severity | Count |
|----------|-------|
| High | 4 |
| Medium | 6 |
| Low | 1 |

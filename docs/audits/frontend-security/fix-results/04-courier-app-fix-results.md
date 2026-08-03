# Courier App — Frontend Fix Results

**App:** `Courier Agent App/`  
**Date:** 2026-08-01  
**Rule:** Claims only with code evidence + analyzer checks.

---

## Verification commands (actual)

```text
flutter analyze lib/services/api/api_client.dart
  lib/screens/earnings/withdraw_sheet.dart
  lib/screens/auth/login_otp_screen.dart
  lib/providers/auth_provider.dart
→ No issues found! (ran in 3.9s)
```

---

## Fixes implemented (evidence)

| Audit ID | Fix | Evidence |
|----------|-----|----------|
| F1 HIGH | Secure token | `api_client.dart` `FlutterSecureStorage`; migrate from prefs |
| F2 HIGH | Release API base | Debug `127.0.0.1:8000`; release requires dart-define |
| F3 HIGH | Release signing optional + backup off | `build.gradle.kts`, `allowBackup="false"` |
| F4 HIGH | Withdraw gates | `withdraw_sheet.dart`: `isVerified`, `withdrawalMin`, `balance`, `entered > 0` before POST |
| F5 MED | Backup false | AndroidManifest |
| F6 MED | Parcel ID client check | Assigned/history membership + 403/404 messaging |
| F7 MED | Prefer server earnings total | `api_parcel_repository.dart` reads `total_earnings` / `payout_total` |
| F8 MED | Clear reg password/NID | `auth_provider.dart` clears `regPassword` (and related) after register/logout |
| F9 MED | Upload limits | `imageQuality: 80`, `maxWidth: 1600`; `maxUploadBytes = 5 * 1024 * 1024` in multipart |
| F10 MED | OTP lockout | `login_otp_screen.dart`: `_failedAttempts` ≥ 5 → temporary disable |

---

## Not claimed

- Changing OTP length from 4 digits (matches backend parcel/login OTP contract).

## Follow-up LOW closed (2026-08-01)

Assigned/history/notifications send `per_page=50`; backend caps lists (see `08-remaining-low-fixes.md`).

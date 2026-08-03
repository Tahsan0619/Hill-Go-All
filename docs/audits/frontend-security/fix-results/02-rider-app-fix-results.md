# Rider App — Frontend Fix Results

**App:** `Rider Driver App/`  
**Date:** 2026-08-01  
**Rule:** Claims only with code evidence + analyzer checks.

---

## Verification commands (actual)

```text
flutter analyze lib/services/api/api_client.dart
  lib/screens/earnings/earnings_screen.dart
  lib/screens/onboarding/upload_documents_screen.dart
→ No issues found! (ran in 4.0s)
```

---

## Fixes implemented (evidence)

| Audit ID | Fix | Evidence |
|----------|-----|----------|
| F1 HIGH | Secure token | `api_client.dart` uses `FlutterSecureStorage`; `_secure.write`; prefs migration then remove |
| F2 HIGH | Release API base | Debug `http://127.0.0.1:8000/api`; release requires `HILLGO_API_BASE` |
| F3 HIGH | Cash-out client gates | `earnings_screen.dart`: reject `amount < 100`; reject `amount > balance` before `cashOut` |
| F4 MED | KYC image limits | `upload_documents_screen.dart`: `imageQuality: 80`, `maxWidth: 1600`, >5MB rejected |
| F5 MED | Polling 5s | `home_dashboard_screen.dart` and `trip_navigation_screen.dart`: `Duration(seconds: 5)` |
| F6 MED | Trip IDOR client guard | `trip_details_screen.dart` + `api_trip_repository.dart` treat 403/404; known-trip checks |
| F8 | Forgot-password 45s cooldown | `forgot_password_screen.dart` / `auth_provider.dart` |
| F9 | Backup off + optional signing | `allowBackup="false"`; `key.properties` optional |
| S4 | Pagination | `getTripHistory` / `getPayouts` send `per_page: '50'` |

---

## Not claimed

- Server ownership of `/rider/trips/:id` (backend). Client guard is defense-in-depth only.

## Follow-up LOW closed (2026-08-01)

OSRM no longer called from the app — routing goes through `GET /api/public/route` (see `08-remaining-low-fixes.md`).

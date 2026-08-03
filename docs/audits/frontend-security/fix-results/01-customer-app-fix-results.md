# Customer App — Frontend Fix Results

**App:** `Hill Go Main Customer App/`  
**Date:** 2026-08-01  
**Rule:** Only claims backed by code evidence + analyzer/JS checks below.

---

## Verification commands (actual)

```text
flutter analyze lib/services/api/api_client.dart lib/services/api/rides_api.dart
  lib/services/api/parcels_api.dart lib/screens/otp_verification_screen.dart
  lib/utils/user_facing_error.dart
→ No issues found! (ran in 4.2s)
```

Grep: no `prefs.setString(_tokenKey` remaining for token writes; token uses `FlutterSecureStorage.write`.

---

## Fixes implemented (evidence)

| Audit ID | Fix | Evidence in code |
|----------|-----|------------------|
| F1 HIGH | Token in secure storage | `api_client.dart`: `_secureStorage.write/read/delete`; migrates legacy SharedPreferences then `prefs.remove` |
| F5 MED | Release requires API base | `baseUrl` getter: empty + `kReleaseMode` → `StateError`; debug → `http://127.0.0.1:8000/api` |
| F4 MED | OTP 45s resend cooldown | `otp_verification_screen.dart`: `_resendSecondsLeft`, button disabled while > 0 |
| F2/F3 HIGH | Clamp ride distance/duration; parcel weight/distance required + clamped | `rides_api.dart` `_clampDistance`/`_clampDuration`; `parcels_api.dart` clamps 0.1–50 kg / 0.1–500 km; receiver screen requires weight |
| F6 MED | Backup off; optional release keystore | `AndroidManifest.xml` `allowBackup="false"`; `build.gradle.kts` reads `key.properties` or warns + debug |
| F8/F9 | `per_page=50` lists; safe errors; 3s poll | food/hotels/rentals/marketplace/wallet/notifications/rides list queries; `userFacingError`; `driver_searching_screen` 3s timer |

---

## Intentionally not claimed “fixed”

| Item | Why |
|------|-----|
| Server-side fare authority | Backend already recalculates; client still sends distance (clamped) because API contract requires it |
| Real Play Store signing keys | No secrets committed; only optional `key.properties` path |

## Follow-up LOW/OBS closed (2026-08-01)

See `08-remaining-low-fixes.md`: wallet amount gate, optional TLS pinning (`HILLGO_SSL_PINS`).


---

## Dependency evidence

`pubspec.yaml` includes `flutter_secure_storage: ^9.2.4` (resolved via `flutter pub get`).

# NEW_FINDINGS.md

Findings noticed during remediation that are **outside** the remediation checklists. Do not treat these as fixed by the remediation pass.

## Customer App
- `lib/screens/rental/rental_booking_screen.dart` (~L127): compile error — `SwitchListTile` missing required `onChanged` / broken parentheses; blocks `flutter test` when loading `main.dart` via `test/widget_test.dart`. Observed 2026-08-03 during baseline test run.

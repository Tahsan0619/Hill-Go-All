import 'package:flutter/material.dart';

/// Tracks the app's active [Locale] and rebuilds `MaterialApp.router` when
/// it changes. Seeded from the courier's saved language preference
/// (`UserModel.language`, backed by `PATCH /courier/settings`) at startup,
/// and updated whenever the courier picks a language in
/// `screens/profile/language_screen.dart`.
///
/// String translation is out of scope for this pass beyond wiring
/// `flutter_localizations` + `supportedLocales` — see
/// `REMEDIATION_COURIER_AGENT_APP.md` item 8 for what is/isn't translated.
class LocaleController extends ChangeNotifier {
  static const supportedLocales = [Locale('en'), Locale('bn')];
  static const _supportedCodes = {'en', 'bn'};

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  /// Applies a language code from the backend (`en` / `bn`), defaulting to
  /// English for anything unrecognized or null.
  void setFromLanguageCode(String? code) {
    final normalized = _supportedCodes.contains(code) ? code! : 'en';
    if (_locale.languageCode == normalized) return;
    _locale = Locale(normalized);
    notifyListeners();
  }
}

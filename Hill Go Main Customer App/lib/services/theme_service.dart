import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_log.dart';

/// App-wide light / dark theme toggle.
class ThemeService extends ChangeNotifier {
  ThemeService._();

  static final ThemeService instance = ThemeService._();

  static const String _prefsKey = 'hillgo_customer_dark';

  bool _isDark = false;
  bool _loaded = false;

  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  /// Reads persisted theme before first paint.
  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDark = prefs.getBool(_prefsKey) ?? false;
      _loaded = true;
      notifyListeners();
    } catch (e) {
      AppLog.w('Failed to load theme preference', tag: 'ThemeService', error: e);
      _loaded = true;
    }
  }

  void setDark(bool value) {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
    _persist(value);
  }

  void toggle() => setDark(!_isDark);

  void _persist(bool value) {
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(_prefsKey, value))
        .catchError((Object e) {
      AppLog.w('Failed to save theme preference', tag: 'ThemeService', error: e);
    });
  }
}

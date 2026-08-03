import 'package:flutter/foundation.dart';

/// Lightweight structured logger (no bare `print` in app code).
class AppLog {
  AppLog._();

  static void d(String message, {String tag = 'HillGoRider'}) {
    debugPrint('[$tag] $message');
  }

  static void i(String message, {String tag = 'HillGoRider'}) {
    debugPrint('[$tag] INFO: $message');
  }

  static void w(String message, {String tag = 'HillGoRider', Object? error}) {
    debugPrint('[$tag] WARN: $message${error != null ? ' ($error)' : ''}');
  }

  static void e(String message, {String tag = 'HillGoRider', Object? error, StackTrace? stackTrace}) {
    debugPrint('[$tag] ERROR: $message${error != null ? ' ($error)' : ''}');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}

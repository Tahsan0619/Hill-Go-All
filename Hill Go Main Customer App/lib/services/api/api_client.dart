import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_log.dart';
import 'pinned_http.dart';

/// Error thrown for any non-2xx API response. Carries the server-provided
/// message (e.g. Laravel validation messages) so screens can surface it.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.errors});

  final String message;
  final int? statusCode;

  /// Laravel 422 field errors: {field: [messages]}.
  final Map<String, dynamic>? errors;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// Thin JSON HTTP client for the HillGo Laravel backend.
///
/// - Base URL comes from `--dart-define=HILLGO_API_BASE=...`
///   (required in release; debug falls back to local).
/// - Persists the Sanctum bearer token in FlutterSecureStorage.
/// - Clears the stored token automatically on a 401 response.
/// - Retries transient network failures with exponential backoff.
class ApiClient {
  ApiClient._();

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('HILLGO_API_BASE');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kReleaseMode) {
      throw StateError(
        'HILLGO_API_BASE must be set via --dart-define in release builds.',
      );
    }
    return 'http://127.0.0.1:8000/api';
  }

  /// API origin without the `/api` suffix (used for `/storage/...` media).
  static String get origin {
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.authority}';
  }

  /// Turn relative media paths into absolute URLs. Leaves http(s) unchanged.
  static String? absoluteUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$origin${path.startsWith('/') ? '' : '/'}$path';
  }

  static const String _tokenKey = 'hillgo_customer_token';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static String? _token;
  static bool _tokenLoaded = false;

  /// Max attempts for transient network failures (1 initial + retries).
  static const int maxAttempts = 3;

  static String? get token => _token;
  static bool get hasToken => _token != null && _token!.isNotEmpty;

  /// Loads the persisted token into memory. Safe to call multiple times.
  /// Migrates a legacy SharedPreferences token into secure storage once.
  static Future<void> loadToken() async {
    if (_tokenLoaded) return;
    _token = await _secureStorage.read(key: _tokenKey);
    if (_token == null || _token!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final legacy = prefs.getString(_tokenKey);
      if (legacy != null && legacy.isNotEmpty) {
        _token = legacy;
        await _secureStorage.write(key: _tokenKey, value: legacy);
        await prefs.remove(_tokenKey);
        AppLog.i('Migrated legacy token into secure storage', tag: 'ApiClient');
      }
    }
    _tokenLoaded = true;
  }

  static Future<void> setToken(String token) async {
    _token = token;
    _tokenLoaded = true;
    await _secureStorage.write(key: _tokenKey, value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    AppLog.d('Token saved', tag: 'ApiClient');
  }

  static Future<void> clearToken() async {
    _token = null;
    _tokenLoaded = true;
    await _secureStorage.delete(key: _tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    AppLog.i('Token cleared', tag: 'ApiClient');
  }

  /// Generates a client idempotency key (UUID v4-ish) for write endpoints.
  /// Backend `EnsureIdempotency` middleware (7.4.21) dedupes on this header.
  static String newIdempotencyKey() {
    final r = Random.secure();
    String hex(int n) => n.toRadixString(16).padLeft(2, '0');
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-'
        '${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  static Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  static Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    String? idempotencyKey,
  }) =>
      _send('POST', path, body: body, idempotencyKey: idempotencyKey);

  static Future<dynamic> patch(String path, {Map<String, dynamic>? body}) =>
      _send('PATCH', path, body: body);

  static Future<dynamic> delete(String path) => _send('DELETE', path);

  static Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    String? idempotencyKey,
  }) async {
    await loadToken();

    var uri = Uri.parse('$baseUrl$path');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: {...uri.queryParameters, ...query});
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (hasToken) 'Authorization': 'Bearer $_token',
      if (idempotencyKey != null && idempotencyKey.isNotEmpty)
        'Idempotency-Key': idempotencyKey,
    };

    Object? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final client = PinnedHttp.client();
        final request = http.Request(method, uri)..headers.addAll(headers);
        if (body != null) request.body = jsonEncode(body);
        final streamed =
            await client.send(request).timeout(const Duration(seconds: 25));
        final response = await http.Response.fromStream(streamed);
        return await _decodeResponse(response);
      } on TimeoutException catch (e) {
        lastError = e;
        AppLog.w('Timeout attempt $attempt/$maxAttempts for $method $path',
            tag: 'ApiClient');
      } on SocketException catch (e) {
        lastError = e;
        AppLog.w('Socket error attempt $attempt/$maxAttempts for $method $path',
            tag: 'ApiClient', error: e);
      } on http.ClientException catch (e) {
        lastError = e;
        AppLog.w('Client error attempt $attempt/$maxAttempts for $method $path',
            tag: 'ApiClient', error: e);
      }

      if (attempt < maxAttempts) {
        final delayMs = 300 * (1 << (attempt - 1)); // 300, 600
        await Future<void>.delayed(Duration(milliseconds: delayMs));
      }
    }

    AppLog.e('Giving up after $maxAttempts attempts for $method $path',
        tag: 'ApiClient', error: lastError);
    if (lastError is TimeoutException) {
      throw const ApiException('Request timed out. Please try again.');
    }
    throw const ApiException(
        'Could not reach the server. Check your connection.');
  }

  static Future<dynamic> _decodeResponse(http.Response response) async {
    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    if (response.statusCode == 401) {
      AppLog.w('401 received — clearing token', tag: 'ApiClient');
      await clearToken();
    }

    String message = 'Something went wrong (${response.statusCode}).';
    Map<String, dynamic>? errors;
    if (decoded is Map<String, dynamic>) {
      if (decoded['message'] is String &&
          (decoded['message'] as String).isNotEmpty) {
        message = decoded['message'] as String;
      }
      if (decoded['errors'] is Map<String, dynamic>) {
        errors = decoded['errors'] as Map<String, dynamic>;
        final first = errors.values
            .whereType<List>()
            .expand((list) => list)
            .whereType<String>()
            .cast<String?>()
            .firstWhere((m) => m != null && m.isNotEmpty, orElse: () => null);
        if (first != null) message = first;
      }
    }

    throw ApiException(message, statusCode: response.statusCode, errors: errors);
  }
}

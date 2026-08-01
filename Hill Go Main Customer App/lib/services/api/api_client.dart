import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  }

  static Future<void> clearToken() async {
    _token = null;
    _tokenLoaded = true;
    await _secureStorage.delete(key: _tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  static Future<dynamic> post(String path, {Map<String, dynamic>? body}) =>
      _send('POST', path, body: body);

  static Future<dynamic> patch(String path, {Map<String, dynamic>? body}) =>
      _send('PATCH', path, body: body);

  static Future<dynamic> delete(String path) => _send('DELETE', path);

  static Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
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
    };

    http.Response response;
    try {
      final client = PinnedHttp.client();
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final streamed =
          await client.send(request).timeout(const Duration(seconds: 25));
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const ApiException('Request timed out. Please try again.');
    } on SocketException {
      throw const ApiException(
          'Could not reach the server. Check your connection.');
    } on http.ClientException {
      throw const ApiException(
          'Could not reach the server. Check your connection.');
    }

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
        // Prefer the first concrete field error over the generic message.
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

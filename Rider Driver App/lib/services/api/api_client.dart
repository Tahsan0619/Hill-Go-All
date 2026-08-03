import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_log.dart';
import 'pinned_http.dart';

/// Error thrown for any non-2xx HillGo API response.
///
/// [message] carries the server `message` (or the first validation error),
/// [errors] the flattened Laravel validation errors keyed by field.
///
/// [statusCode] is `0` for transport-level failures (timeout / no
/// connection) that exhausted all retry attempts before a response was ever
/// received.
class ApiException implements Exception {
  ApiException(this.statusCode, this.message, {this.errors});

  final int statusCode;
  final String message;
  final Map<String, List<String>>? errors;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// Thin JSON + multipart HTTP client for the HillGo Laravel backend.
///
/// - Persists the Sanctum bearer token in [FlutterSecureStorage] (with a
///   one-time migration from legacy SharedPreferences) and clears it
///   automatically when the server responds 401.
/// - Routes every request through [PinnedHttp] so release builds can pin the
///   backend's TLS certificate via `--dart-define=HILLGO_SSL_PINS`.
/// - Retries transient network failures (timeout / socket / client errors)
///   up to [maxAttempts] times with exponential backoff before surfacing an
///   [ApiException] to the caller (e.g. before an `ErrorView` is shown).
class ApiClient {
  ApiClient({http.Client? httpClient, FlutterSecureStorage? secureStorage})
      : _http = httpClient ?? PinnedHttp.client(),
        _secure = secureStorage ?? const FlutterSecureStorage();

  /// Release builds require `--dart-define=HILLGO_API_BASE=...`.
  /// Debug defaults to the local Laravel API.
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('HILLGO_API_BASE');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kDebugMode) return 'http://127.0.0.1:8000/api';
    throw StateError(
      'HILLGO_API_BASE must be set via --dart-define for release builds.',
    );
  }

  static const String _tokenKey = 'hillgo_rider_token';

  /// Max attempts for transient network failures (1 initial + retries).
  static const int maxAttempts = 3;

  final FlutterSecureStorage _secure;
  final http.Client _http;

  /// In-memory cache of the bearer token (loaded by [loadToken]).
  String? _token;

  String? get token => _token;

  bool get hasToken => _token != null && _token!.isNotEmpty;

  /// Loads the token from secure storage into memory.
  /// Migrates a legacy SharedPreferences token once, then deletes it.
  Future<void> loadToken() async {
    var value = await _secure.read(key: _tokenKey);
    if (value == null || value.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final legacy = prefs.getString(_tokenKey);
      if (legacy != null && legacy.isNotEmpty) {
        await _secure.write(key: _tokenKey, value: legacy);
        await prefs.remove(_tokenKey);
        value = legacy;
        AppLog.i('Migrated legacy token into secure storage', tag: 'ApiClient');
      }
    }
    _token = (value != null && value.isNotEmpty) ? value : null;
  }

  Future<void> saveToken(String value) async {
    _token = value;
    await _secure.write(key: _tokenKey, value: value);
    AppLog.d('Token saved', tag: 'ApiClient');
  }

  Future<void> clearToken() async {
    _token = null;
    await _secure.delete(key: _tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    AppLog.i('Token cleared', tag: 'ApiClient');
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalized')
        .replace(queryParameters: (query?.isEmpty ?? true) ? null : query);
  }

  Map<String, String> _headers({bool json = true}) {
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (hasToken) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final res = await _sendWithRetry(
      () => http.Request('GET', _uri(path, query))..headers.addAll(_headers(json: false)),
    );
    return _decode(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final res = await _sendWithRetry(
      () => http.Request('POST', _uri(path))
        ..headers.addAll(_headers())
        ..body = jsonEncode(body ?? const {}),
    );
    return _decode(res);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final res = await _sendWithRetry(
      () => http.Request('PATCH', _uri(path))
        ..headers.addAll(_headers())
        ..body = jsonEncode(body ?? const {}),
    );
    return _decode(res);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final res = await _sendWithRetry(
      () => http.Request('PUT', _uri(path))
        ..headers.addAll(_headers())
        ..body = jsonEncode(body ?? const {}),
    );
    return _decode(res);
  }

  /// Multipart POST. [files] maps a form field name to a local file path.
  Future<dynamic> upload(
    String path, {
    Map<String, String> fields = const {},
    Map<String, String> files = const {},
  }) async {
    final res = await _sendWithRetry(() async {
      final request = http.MultipartRequest('POST', _uri(path))
        ..headers.addAll(_headers(json: false))
        ..fields.addAll(fields);
      for (final entry in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
      }
      return request;
    });
    return _decode(res);
  }

  /// Sends the request built by [buildRequest], retrying transient network
  /// failures (timeout / socket / client errors) up to [maxAttempts] times
  /// with exponential backoff (300ms, 600ms, …) before giving up.
  ///
  /// [buildRequest] is invoked fresh on every attempt so multipart file
  /// streams (which can only be read once) are rebuilt for each retry.
  Future<http.Response> _sendWithRetry(
    FutureOr<http.BaseRequest> Function() buildRequest,
  ) async {
    Object? lastError;
    String method = 'REQUEST';
    String path = '';
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final request = await buildRequest();
        method = request.method;
        path = request.url.path;
        final streamed = await _http.send(request).timeout(const Duration(seconds: 25));
        return await http.Response.fromStream(streamed);
      } on TimeoutException catch (e) {
        lastError = e;
        AppLog.w('Timeout attempt $attempt/$maxAttempts for $method $path', tag: 'ApiClient');
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
      throw ApiException(0, 'Request timed out. Please try again.');
    }
    throw ApiException(0, 'Could not reach the server. Check your connection.');
  }

  Future<dynamic> _decode(http.Response res) async {
    dynamic body;
    if (res.body.isNotEmpty) {
      try {
        body = jsonDecode(res.body);
      } catch (_) {
        body = null;
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }

    if (res.statusCode == 401) {
      AppLog.w('401 received — clearing token', tag: 'ApiClient');
      await clearToken();
    }

    Map<String, List<String>>? errors;
    String? message;
    if (body is Map<String, dynamic>) {
      message = body['message'] as String?;
      final rawErrors = body['errors'];
      if (rawErrors is Map<String, dynamic>) {
        errors = rawErrors.map(
          (key, value) => MapEntry(
            key,
            value is List
                ? value.map((e) => e.toString()).toList()
                : [value.toString()],
          ),
        );
        // Prefer the concrete field error over Laravel's generic message.
        final first = errors.values.expand((e) => e).firstOrNull;
        if (first != null && first.isNotEmpty) {
          message = first;
        }
      }
    }

    throw ApiException(
      res.statusCode,
      message ?? 'Request failed (${res.statusCode}). Please try again.',
      errors: errors,
    );
  }
}

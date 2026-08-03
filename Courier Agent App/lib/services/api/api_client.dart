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

/// Thrown for any non-2xx API response. [message] is the server-provided
/// message (e.g. Laravel validation errors), suitable for showing to the user.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// Thin HTTP client for the HillGo Laravel backend.
///
/// - Base URL comes from `--dart-define=HILLGO_API_BASE=...`.
///   Release builds require the define; debug defaults to `http://127.0.0.1:8000/api`.
/// - The Sanctum bearer token is stored in [FlutterSecureStorage] under
///   [tokenKey], cached in memory, and cleared on 401.
/// - Requests go through [PinnedHttp] (optional certificate pinning) and are
///   retried with exponential backoff on transient network failures.
class ApiClient {
  ApiClient(this._prefs, {FlutterSecureStorage? secureStorage})
      : _secure = secureStorage ?? const FlutterSecureStorage();

  static const String tokenKey = 'hillgo_courier_token';
  static const int maxUploadBytes = 5 * 1024 * 1024;

  /// Max attempts for transient network failures (1 initial + retries).
  static const int maxAttempts = 3;

  /// Resolved API base. Release builds must pass `--dart-define=HILLGO_API_BASE=...`.
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('HILLGO_API_BASE');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kReleaseMode) {
      throw StateError(
        'HILLGO_API_BASE must be set via --dart-define for release builds.',
      );
    }
    return 'http://127.0.0.1:8000/api';
  }

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;
  final http.Client _http = PinnedHttp.client();

  String? _token;
  bool _tokenLoaded = false;

  /// Invoked when the backend rejects the stored token (401).
  void Function()? onUnauthorized;

  String? get token => _token;

  bool get hasToken => (_token ?? '').isNotEmpty;

  /// Generates a client idempotency key (UUID v4-ish) for write endpoints.
  /// The backend does not yet implement request-level dedupe for this
  /// header — see item 7 of `REMEDIATION_COURIER_AGENT_APP.md` — but the
  /// client always sends one so dedupe can be turned on server-side later
  /// without another client release.
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

  /// Loads the token from secure storage into the memory cache.
  /// Migrates a legacy SharedPreferences value when present.
  Future<void> loadToken() async {
    if (_tokenLoaded) return;
    _token = await _secure.read(key: tokenKey);
    final legacy = _prefs.getString(tokenKey);
    if ((_token == null || _token!.isEmpty) && legacy != null && legacy.isNotEmpty) {
      _token = legacy;
      await _secure.write(key: tokenKey, value: legacy);
      await _prefs.remove(tokenKey);
    } else if (legacy != null) {
      await _prefs.remove(tokenKey);
    }
    _tokenLoaded = true;
  }

  Future<void> saveToken(String value) async {
    _token = value;
    _tokenLoaded = true;
    await _secure.write(key: tokenKey, value: value);
    await _prefs.remove(tokenKey);
  }

  Future<void> clearToken() async {
    _token = null;
    _tokenLoaded = true;
    await _secure.delete(key: tokenKey);
    await _prefs.remove(tokenKey);
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final url = Uri.parse('$baseUrl$path');
    if (query == null || query.isEmpty) return url;
    return url.replace(queryParameters: {...url.queryParameters, ...query});
  }

  Map<String, String> _headers({bool json = true, String? idempotencyKey}) => {
    'Accept': 'application/json',
    if (json) 'Content-Type': 'application/json',
    if (hasToken) 'Authorization': 'Bearer $token',
    if (idempotencyKey != null && idempotencyKey.isNotEmpty)
      'Idempotency-Key': idempotencyKey,
  };

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _run(() => _http.get(_uri(path, query), headers: _headers(json: false)));

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    String? idempotencyKey,
  }) => _run(
    () => _http.post(
      _uri(path),
      headers: _headers(idempotencyKey: idempotencyKey),
      body: jsonEncode(body ?? const {}),
    ),
  );

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) => _run(
    () => _http.patch(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? const {}),
    ),
  );

  /// Multipart POST used for KYC document and delivery proof uploads.
  /// Rejects files larger than [maxUploadBytes] (5 MB) before upload.
  Future<dynamic> multipart(
    String path, {
    required String filePath,
    String fileField = 'file',
    Map<String, String> fields = const {},
    String? idempotencyKey,
  }) async {
    final length = await File(filePath).length();
    if (length > maxUploadBytes) {
      throw const ApiException(0, 'File is too large. Maximum size is 5 MB.');
    }
    return _run(() async {
      final request = http.MultipartRequest('POST', _uri(path))
        ..headers.addAll(_headers(json: false, idempotencyKey: idempotencyKey))
        ..fields.addAll(fields)
        ..files.add(await http.MultipartFile.fromPath(fileField, filePath));
      final streamed = await _http.send(request);
      return http.Response.fromStream(streamed);
    });
  }

  /// Sends [send], retrying transient network failures (timeouts, socket
  /// errors, client errors) up to [maxAttempts] times with exponential
  /// backoff (300ms, 600ms, ...) before surfacing an [ApiException] that the
  /// UI turns into an `ErrorView`. HTTP error *responses* (4xx/5xx) are
  /// decoded and thrown immediately without retrying.
  Future<dynamic> _run(Future<http.Response> Function() send) async {
    Object? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      http.Response response;
      try {
        response = await send().timeout(const Duration(seconds: 25));
      } on TimeoutException catch (e) {
        lastError = e;
        AppLog.w('Timeout on attempt $attempt/$maxAttempts', tag: 'ApiClient', error: e);
        await _backoff(attempt);
        continue;
      } on SocketException catch (e) {
        lastError = e;
        AppLog.w('Socket error on attempt $attempt/$maxAttempts', tag: 'ApiClient', error: e);
        await _backoff(attempt);
        continue;
      } on http.ClientException catch (e) {
        lastError = e;
        AppLog.w('Client error on attempt $attempt/$maxAttempts', tag: 'ApiClient', error: e);
        await _backoff(attempt);
        continue;
      }
      return _decode(response);
    }
    AppLog.e('Giving up after $maxAttempts attempts', tag: 'ApiClient', error: lastError);
    throw const ApiException(0, 'Cannot reach the HillGo server. Check your connection.');
  }

  Future<void> _backoff(int attempt) async {
    if (attempt >= maxAttempts) return;
    final delayMs = 300 * (1 << (attempt - 1)); // 300, 600
    await Future<void>.delayed(Duration(milliseconds: delayMs));
  }

  Future<dynamic> _decode(http.Response response) async {
    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (response.statusCode == 401) {
      await clearToken();
      onUnauthorized?.call();
      throw ApiException(401, _message(body) ?? 'Your session has expired. Please log in again.');
    }

    throw ApiException(
      response.statusCode,
      _message(body) ?? 'Request failed (${response.statusCode}). Please try again.',
    );
  }

  /// Prefers the first Laravel validation error, falls back to `message`.
  String? _message(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    final errors = body['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return '${first.first}';
      if (first is String) return first;
    }
    final message = body['message'];
    return message is String && message.isNotEmpty ? message : null;
  }
}

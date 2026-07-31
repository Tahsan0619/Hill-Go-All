import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
/// - Base URL comes from `--dart-define=HILLGO_API_BASE=...`
///   (default `http://localhost:8000/api`).
/// - The Sanctum bearer token is persisted in SharedPreferences under
///   [tokenKey]; it is attached to every request and cleared on 401.
class ApiClient {
  ApiClient(this._prefs);

  static const String tokenKey = 'hillgo_courier_token';
  static const String baseUrl = String.fromEnvironment(
    'HILLGO_API_BASE',
    defaultValue: 'http://localhost:8000/api',
  );

  final SharedPreferences _prefs;
  final http.Client _http = http.Client();

  /// Invoked when the backend rejects the stored token (401).
  void Function()? onUnauthorized;

  String? get token => _prefs.getString(tokenKey);

  bool get hasToken => (token ?? '').isNotEmpty;

  Future<void> saveToken(String value) => _prefs.setString(tokenKey, value);

  Future<void> clearToken() async => _prefs.remove(tokenKey);

  Uri _uri(String path, [Map<String, String>? query]) {
    final url = Uri.parse('$baseUrl$path');
    if (query == null || query.isEmpty) return url;
    return url.replace(queryParameters: {...url.queryParameters, ...query});
  }

  Map<String, String> _headers({bool json = true}) => {
    'Accept': 'application/json',
    if (json) 'Content-Type': 'application/json',
    if (hasToken) 'Authorization': 'Bearer $token',
  };

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _run(() => _http.get(_uri(path, query), headers: _headers(json: false)));

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) => _run(
    () => _http.post(
      _uri(path),
      headers: _headers(),
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
  Future<dynamic> multipart(
    String path, {
    required String filePath,
    String fileField = 'file',
    Map<String, String> fields = const {},
  }) {
    return _run(() async {
      final request = http.MultipartRequest('POST', _uri(path))
        ..headers.addAll(_headers(json: false))
        ..fields.addAll(fields)
        ..files.add(await http.MultipartFile.fromPath(fileField, filePath));
      final streamed = await _http.send(request);
      return http.Response.fromStream(streamed);
    });
  }

  Future<dynamic> _run(Future<http.Response> Function() send) async {
    http.Response response;
    try {
      response = await send();
    } on SocketException {
      throw const ApiException(0, 'Cannot reach the HillGo server. Check your connection.');
    } on http.ClientException {
      throw const ApiException(0, 'Cannot reach the HillGo server. Check your connection.');
    }
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
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
      clearToken();
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

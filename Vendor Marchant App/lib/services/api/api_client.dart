import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Error thrown for any non-2xx API response, carrying the server message.
class ApiException implements Exception {
  ApiException(this.statusCode, this.message, {this.errors});

  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => message;
}

/// Thin JSON/multipart HTTP client for the HillGo Laravel API.
///
/// Persists the Sanctum bearer token in SharedPreferences and clears it
/// automatically when the server responds with 401.
class ApiClient {
  ApiClient(this._prefs);

  static const String baseUrl = String.fromEnvironment(
    'HILLGO_API_BASE',
    defaultValue: 'http://localhost:8000/api',
  );

  static const _tokenKey = 'hillgo_merchant_token';

  final SharedPreferences _prefs;

  String? get token => _prefs.getString(_tokenKey);
  bool get hasToken => token != null && token!.isNotEmpty;

  Future<void> saveToken(String token) => _prefs.setString(_tokenKey, token);
  Future<void> clearToken() async => _prefs.remove(_tokenKey);

  /// Origin of the API server (base URL without the `/api` suffix), used to
  /// resolve relative asset paths like `/storage/...`.
  static String get origin {
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.authority}';
  }

  /// Converts a server-relative media path into an absolute URL.
  static String? absoluteUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$origin${path.startsWith('/') ? '' : '/'}$path';
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$normalized');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: {...uri.queryParameters, ...query});
  }

  Map<String, String> _headers({bool json = true}) => {
        'Accept': 'application/json',
        if (json) 'Content-Type': 'application/json',
        if (hasToken) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send(() => http.get(_uri(path, query), headers: _headers(json: false)));

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) =>
      _send(() => http.post(
            _uri(path),
            headers: _headers(),
            body: jsonEncode(body ?? const {}),
          ));

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) =>
      _send(() => http.patch(
            _uri(path),
            headers: _headers(),
            body: jsonEncode(body ?? const {}),
          ));

  Future<dynamic> put(String path, [Map<String, dynamic>? body]) =>
      _send(() => http.put(
            _uri(path),
            headers: _headers(),
            body: jsonEncode(body ?? const {}),
          ));

  Future<dynamic> delete(String path) =>
      _send(() => http.delete(_uri(path), headers: _headers()));

  /// Sends a multipart request (default POST) with text [fields] and local
  /// [files] keyed by their form field name.
  ///
  /// Prefer [fileBytes] on Flutter Web — [MultipartFile.fromPath] is unsupported
  /// there. Each [fileBytes] entry is `fieldName -> (bytes, filename)`.
  Future<dynamic> multipart(
    String path, {
    Map<String, String> fields = const {},
    Map<String, String> files = const {},
    Map<String, (List<int> bytes, String filename)> fileBytes = const {},
    String method = 'POST',
  }) {
    return _send(() async {
      final request = http.MultipartRequest(method, _uri(path))
        ..headers.addAll(_headers(json: false))
        ..fields.addAll(fields);
      for (final entry in fileBytes.entries) {
        request.files.add(http.MultipartFile.fromBytes(
          entry.key,
          entry.value.$1,
          filename: entry.value.$2,
        ));
      }
      for (final entry in files.entries) {
        if (fileBytes.containsKey(entry.key)) continue;
        if (kIsWeb) {
          throw ApiException(
            0,
            'Image upload on web requires image bytes. Please re-select the image.',
          );
        }
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value),
        );
      }
      final streamed = await request.send();
      return http.Response.fromStream(streamed);
    });
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    http.Response response;
    try {
      response = await request();
    } on http.ClientException catch (e) {
      throw ApiException(0, 'Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(0, 'Cannot reach the HillGo server. Check your connection.');
    }

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
    }

    String message = 'Request failed (${response.statusCode}).';
    Map<String, dynamic>? errors;
    if (body is Map<String, dynamic>) {
      if (body['message'] is String && (body['message'] as String).isNotEmpty) {
        message = body['message'] as String;
      }
      if (body['errors'] is Map<String, dynamic>) {
        errors = body['errors'] as Map<String, dynamic>;
        final first = errors.values.firstOrNull;
        if (first is List && first.isNotEmpty) {
          message = first.first.toString();
        }
      }
    }
    throw ApiException(response.statusCode, message, errors: errors);
  }
}

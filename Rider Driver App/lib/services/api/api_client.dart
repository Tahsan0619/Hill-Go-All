import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Error thrown for any non-2xx HillGo API response.
///
/// [message] carries the server `message` (or the first validation error),
/// [errors] the flattened Laravel validation errors keyed by field.
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
/// Persists the Sanctum bearer token in SharedPreferences and clears it
/// automatically when the server responds 401.
class ApiClient {
  ApiClient(this._prefs, {http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  static const String baseUrl = String.fromEnvironment(
    'HILLGO_API_BASE',
    defaultValue: 'http://localhost:8000/api',
  );

  static const String _tokenKey = 'hillgo_rider_token';

  final SharedPreferences _prefs;
  final http.Client _http;

  String? get token => _prefs.getString(_tokenKey);

  bool get hasToken => token != null && token!.isNotEmpty;

  Future<void> saveToken(String value) => _prefs.setString(_tokenKey, value);

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
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
    final res = await _http.get(_uri(path, query), headers: _headers(json: false));
    return _decode(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final res = await _http.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? const {}),
    );
    return _decode(res);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final res = await _http.patch(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? const {}),
    );
    return _decode(res);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final res = await _http.put(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? const {}),
    );
    return _decode(res);
  }

  Future<dynamic> delete(String path, {Object? body}) async {
    final res = await _http.delete(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? const {}),
    );
    return _decode(res);
  }

  /// Multipart POST. [files] maps a form field name to a local file path.
  Future<dynamic> upload(
    String path, {
    Map<String, String> fields = const {},
    Map<String, String> files = const {},
  }) async {
    final request = http.MultipartRequest('POST', _uri(path))
      ..headers.addAll(_headers(json: false))
      ..fields.addAll(fields);
    for (final entry in files.entries) {
      request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
    }
    final streamed = await _http.send(request);
    final res = await http.Response.fromStream(streamed);
    return _decode(res);
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

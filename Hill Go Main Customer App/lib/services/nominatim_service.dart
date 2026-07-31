import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/place_result.dart';

/// Nominatim (OpenStreetMap) geocoding — free address search & reverse lookup.
///
/// Usage policy: https://operations.osmfoundation.org/policies/nominatim/
/// - Always send a descriptive User-Agent
/// - Max ~1 request/second (we debounce in the UI)
class NominatimService {
  NominatimService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _baseUrl = 'https://nominatim.openstreetmap.org';

  /// Required by Nominatim — identify your app (do not use a generic agent).
  static const _userAgent = 'HillgoRideApp/1.0 (contact: support@hillgo.app)';

  Map<String, String> get _headers => {
        'User-Agent': _userAgent,
        'Accept': 'application/json',
      };

  /// STEP: Address autocomplete ("Where to?" / pickup search).
  ///
  /// GET https://nominatim.openstreetmap.org/search?q=...&format=json&limit=5
  Future<List<PlaceResult>> searchPlaces(
    String query, {
    String countryCodes = 'bd',
    int limit = 5,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
      'q': trimmed,
      'format': 'json',
      'addressdetails': '1',
      'limit': '$limit',
      'countrycodes': countryCodes,
    });

    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Nominatim search failed (${response.statusCode})');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map(PlaceResult.fromNominatimJson)
        .toList();
  }

  /// STEP: Reverse geocode — turn GPS lat/lng into a human-readable address.
  ///
  /// GET https://nominatim.openstreetmap.org/reverse?lat=...&lon=...&format=json
  Future<PlaceResult> reverseGeocode(double lat, double lon) async {
    final uri = Uri.parse('$_baseUrl/reverse').replace(queryParameters: {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'format': 'json',
      'addressdetails': '1',
    });

    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Nominatim reverse failed (${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PlaceResult.fromNominatimJson(json);
  }
}

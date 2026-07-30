import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/route_result.dart';

/// OSRM (Open Source Routing Machine) — free road routing.
///
/// Public demo server: https://router.project-osrm.org
/// Note: demo server is rate-limited; for production host your own OSRM.
class OsrmService {
  OsrmService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _baseUrl = 'https://router.project-osrm.org';

  /// STEP: Get road route + distance + duration between two points.
  ///
  /// GET .../route/v1/driving/{lon1},{lat1};{lon2},{lat2}?overview=full&geometries=geojson
  ///
  /// OSRM uses **longitude,latitude** order (opposite of LatLng).
  Future<RouteResult> getRoute({
    required double pickupLat,
    required double pickupLon,
    required double destLat,
    required double destLon,
  }) async {
    final coords =
        '$pickupLon,$pickupLat;$destLon,$destLat'; // lon,lat ; lon,lat
    final uri = Uri.parse('$_baseUrl/route/v1/driving/$coords').replace(
      queryParameters: {
        'overview': 'full',
        'geometries': 'geojson',
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('OSRM route failed (${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['code'] != 'Ok') {
      throw Exception('OSRM error: ${json['code']}');
    }

    final routes = json['routes'] as List<dynamic>;
    if (routes.isEmpty) {
      throw Exception('OSRM returned no routes');
    }

    final route = routes.first as Map<String, dynamic>;
    final distanceMeters = (route['distance'] as num).toDouble();
    final durationSeconds = (route['duration'] as num).toDouble();

    final geometry = route['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;

    // GeoJSON coordinates are [lon, lat] — convert to LatLng(lat, lon).
    final points = coordinates.map((c) {
      final pair = c as List<dynamic>;
      return LatLng(
        (pair[1] as num).toDouble(),
        (pair[0] as num).toDouble(),
      );
    }).toList();

    return RouteResult(
      distanceKm: distanceMeters / 1000.0,
      durationMin: durationSeconds / 60.0,
      points: points,
    );
  }
}

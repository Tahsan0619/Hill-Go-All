import 'package:latlong2/latlong.dart';

import 'place_result.dart';

/// Road route returned by OSRM (distance, duration, polyline points).
class RouteResult {
  const RouteResult({
    required this.distanceKm,
    required this.durationMin,
    required this.points,
  });

  /// Road distance in kilometres.
  final double distanceKm;

  /// Estimated travel time in minutes.
  final double durationMin;

  /// Ordered lat/lng points that form the route polyline on the map.
  final List<LatLng> points;
}

/// Snapshot passed to later ride screens after Confirm Location.
class RideLocationArgs {
  const RideLocationArgs({
    required this.pickup,
    required this.destination,
    required this.distanceKm,
    required this.durationMin,
    required this.fareTaka,
    required this.routePoints,
  });

  final PlaceResult pickup;
  final PlaceResult destination;
  final double distanceKm;
  final double durationMin;
  final double fareTaka;
  final List<LatLng> routePoints;
}

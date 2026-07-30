import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteStep {
  const RouteStep({
    required this.instruction,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.maneuverType,
    required this.modifier,
    required this.location,
  });

  final String instruction;
  final double distanceMeters;
  final double durationSeconds;
  final String maneuverType;
  final String modifier;
  final LatLng location;

  IconHint get iconHint {
    final m = modifier.toLowerCase();
    if (maneuverType == 'arrive') return IconHint.arrive;
    if (maneuverType == 'depart') return IconHint.depart;
    if (m.contains('left')) return IconHint.turnLeft;
    if (m.contains('right')) return IconHint.turnRight;
    if (m.contains('uturn') || m.contains('u-turn')) return IconHint.uTurn;
    if (m.contains('straight') || maneuverType == 'new name') {
      return IconHint.straight;
    }
    return IconHint.straight;
  }
}

enum IconHint { turnLeft, turnRight, straight, uTurn, arrive, depart }

class NavRoute {
  const NavRoute({
    required this.points,
    required this.steps,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<LatLng> points;
  final List<RouteStep> steps;
  final double distanceMeters;
  final double durationSeconds;

  int get etaMinutes => math.max(1, (durationSeconds / 60).round());
}

class RoutingService {
  RoutingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _base = 'https://router.project-osrm.org';

  Future<NavRoute?> getDrivingRoute(LatLng from, LatLng to) async {
    final uri = Uri.parse(
      '$_base/route/v1/driving/'
      '${from.longitude},${from.latitude};'
      '${to.longitude},${to.latitude}'
      '?overview=full&geometries=geojson&steps=true&annotations=false',
    );

    try {
      final res = await _client.get(
        uri,
        headers: const {'User-Agent': 'HillGoRider/1.0'},
      );
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['code'] != 'Ok') return null;

      final routes = data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return null;

      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coords = geometry['coordinates'] as List<dynamic>;
      final points = coords
          .map((c) {
            final pair = c as List<dynamic>;
            return LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble());
          })
          .toList();

      final steps = <RouteStep>[];
      final legs = route['legs'] as List<dynamic>? ?? const [];
      for (final leg in legs) {
        final legMap = leg as Map<String, dynamic>;
        final legSteps = legMap['steps'] as List<dynamic>? ?? const [];
        for (final raw in legSteps) {
          final step = raw as Map<String, dynamic>;
          final maneuver = step['maneuver'] as Map<String, dynamic>? ?? {};
          final loc = maneuver['location'] as List<dynamic>? ?? const [0, 0];
          final type = (maneuver['type'] as String?) ?? '';
          final modifier = (maneuver['modifier'] as String?) ?? '';
          final name = (step['name'] as String?)?.trim() ?? '';
          final instruction = _buildInstruction(type, modifier, name);

          steps.add(
            RouteStep(
              instruction: instruction,
              distanceMeters: (step['distance'] as num?)?.toDouble() ?? 0,
              durationSeconds: (step['duration'] as num?)?.toDouble() ?? 0,
              maneuverType: type,
              modifier: modifier,
              location: LatLng(
                (loc.length > 1 ? loc[1] as num : 0).toDouble(),
                (loc.isNotEmpty ? loc[0] as num : 0).toDouble(),
              ),
            ),
          );
        }
      }

      return NavRoute(
        points: points,
        steps: steps,
        distanceMeters: (route['distance'] as num?)?.toDouble() ?? 0,
        durationSeconds: (route['duration'] as num?)?.toDouble() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  static String _buildInstruction(String type, String modifier, String name) {
    if (type == 'arrive') {
      return name.isEmpty ? 'You have arrived' : 'Arrive at $name';
    }
    if (type == 'depart') {
      return name.isEmpty ? 'Head out' : 'Head onto $name';
    }

    final turn = switch (modifier) {
      'left' || 'slight left' || 'sharp left' => 'Turn left',
      'right' || 'slight right' || 'sharp right' => 'Turn right',
      'uturn' || 'u-turn' => 'Make a U-turn',
      'straight' => 'Continue straight',
      _ => type == 'new name' ? 'Continue' : 'Continue',
    };

    if (name.isEmpty) return turn;
    return '$turn onto $name';
  }

  static String formatDistance(double meters) {
    if (meters < 1000) {
      final feet = meters * 3.28084;
      if (feet < 1000) return '${feet.round()} ft';
      return '${(feet / 5280).toStringAsFixed(1)} mi';
    }
    final miles = meters / 1609.344;
    return '${miles.toStringAsFixed(miles < 10 ? 1 : 0)} mi';
  }

  /// Remaining distance/time along [route] from [position].
  static ({double meters, double seconds, RouteStep? nextStep}) progressAlong(
    NavRoute route,
    LatLng position,
  ) {
    if (route.points.isEmpty) {
      return (meters: route.distanceMeters, seconds: route.durationSeconds, nextStep: null);
    }

    var closestIdx = 0;
    var closestDist = double.infinity;
    for (var i = 0; i < route.points.length; i++) {
      final d = const Distance().as(LengthUnit.Meter, position, route.points[i]);
      if (d < closestDist) {
        closestDist = d;
        closestIdx = i;
      }
    }

    var remainingMeters = 0.0;
    for (var i = closestIdx; i < route.points.length - 1; i++) {
      remainingMeters += const Distance().as(
        LengthUnit.Meter,
        route.points[i],
        route.points[i + 1],
      );
    }

    final ratio = route.distanceMeters <= 0
        ? 0.0
        : (remainingMeters / route.distanceMeters).clamp(0.0, 1.0);
    final remainingSeconds = route.durationSeconds * ratio;

    RouteStep? next;
    for (final step in route.steps) {
      if (step.maneuverType == 'depart') continue;
      final stepIdx = _nearestIndex(route.points, step.location);
      if (stepIdx >= closestIdx) {
        next = step;
        break;
      }
    }
    next ??= route.steps.isEmpty ? null : route.steps.last;

    return (meters: remainingMeters, seconds: remainingSeconds, nextStep: next);
  }

  static int _nearestIndex(List<LatLng> points, LatLng target) {
    var best = 0;
    var bestD = double.infinity;
    for (var i = 0; i < points.length; i++) {
      final d = const Distance().as(LengthUnit.Meter, target, points[i]);
      if (d < bestD) {
        bestD = d;
        best = i;
      }
    }
    return best;
  }
}

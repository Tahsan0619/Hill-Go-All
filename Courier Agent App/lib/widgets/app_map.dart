import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

class AppMapView extends StatelessWidget {
  const AppMapView({
    super.key,
    required this.center,
    this.markers = const [],
    this.route = const [],
    this.height = 200,
    this.zoom = 13,
    this.mapController,
    this.children = const [],
    this.borderRadius,
  });

  final LatLng center;
  final List<Marker> markers;
  final List<LatLng> route;
  final double height;
  final double zoom;
  final MapController? mapController;
  final List<Widget> children;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: zoom,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.babuntoo.courieragentapp',
                ),
                if (route.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: route,
                        color: AppColors.primary,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                MarkerLayer(markers: markers),
              ],
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

Marker pinMarker(LatLng point, {Color color = AppColors.accent, IconData icon = Icons.location_on}) {
  return Marker(
    point: point,
    width: 40,
    height: 40,
    child: Icon(icon, color: color, size: 36),
  );
}

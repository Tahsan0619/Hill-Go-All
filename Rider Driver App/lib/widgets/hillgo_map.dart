import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/colors.dart';

class HillGoMap extends StatelessWidget {
  const HillGoMap({
    super.key,
    this.center = const LatLng(23.8103, 90.4125),
    this.zoom = 13,
    this.markers = const [],
    this.polylines = const [],
    this.mapController,
    this.onPositionChanged,
    this.interactionFlags = InteractiveFlag.all,
  });

  final LatLng center;
  final double zoom;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final MapController? mapController;
  final void Function(MapCamera, bool)? onPositionChanged;
  final int interactionFlags;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        onPositionChanged: onPositionChanged,
        interactionOptions: InteractionOptions(flags: interactionFlags),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.babuntoo.riderdriverapp',
        ),
        if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
        if (markers.isNotEmpty) MarkerLayer(markers: markers),
      ],
    );
  }

  static Marker driverMarker(LatLng point, {double? heading}) {
    return Marker(
      point: point,
      width: 44,
      height: 44,
      alignment: Alignment.center,
      child: Transform.rotate(
        angle: ((heading ?? 0) * 3.1415926535) / 180,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(Icons.navigation, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  static Marker destinationMarker(LatLng point, {required bool isDropoff}) {
    return Marker(
      point: point,
      width: 42,
      height: 42,
      child: Icon(
        isDropoff ? Icons.flag : Icons.location_on,
        color: isDropoff ? AppColors.orange : AppColors.primary,
        size: 40,
      ),
    );
  }
}

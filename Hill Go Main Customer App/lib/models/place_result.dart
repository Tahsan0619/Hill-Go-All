import 'package:latlong2/latlong.dart';

/// A place returned by Nominatim (search or reverse geocode).
class PlaceResult {
  const PlaceResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  final String displayName;
  final double latitude;
  final double longitude;

  LatLng get latLng => LatLng(latitude, longitude);

  factory PlaceResult.fromNominatimJson(Map<String, dynamic> json) {
    return PlaceResult(
      displayName: (json['display_name'] as String?) ?? 'Unknown place',
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
    );
  }
}

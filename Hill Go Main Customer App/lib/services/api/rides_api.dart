import '../../models/catalog_models.dart';
import 'api_client.dart';

/// Customer ride endpoints.
class RidesApi {
  RidesApi._();

  static Future<RideQuote> quote({
    required String vehicleType,
    required double distanceKm,
    required double durationMin,
  }) async {
    final data = await ApiClient.post('/customer/rides/quote', body: {
      'vehicle_type': vehicleType,
      'distance_km': distanceKm,
      'duration_min': durationMin,
    });
    return RideQuote.fromJson(data as Map<String, dynamic>);
  }

  static Future<RideEntry> create({
    required String vehicleType,
    required String pickup,
    required String drop,
    double? pickupLat,
    double? pickupLng,
    double? dropLat,
    double? dropLng,
    required double distanceKm,
    required double durationMin,
    required String paymentMethod,
  }) async {
    final data = await ApiClient.post('/customer/rides', body: {
      'vehicle_type': vehicleType,
      'pickup': pickup,
      'drop': drop,
      if (pickupLat != null) 'pickup_lat': pickupLat,
      if (pickupLng != null) 'pickup_lng': pickupLng,
      if (dropLat != null) 'drop_lat': dropLat,
      if (dropLng != null) 'drop_lng': dropLng,
      'distance_km': distanceKm,
      'duration_min': durationMin,
      'payment_method': paymentMethod,
    });
    return RideEntry.fromJson(data as Map<String, dynamic>);
  }

  static Future<List<RideEntry>> list() async {
    final data = await ApiClient.get('/customer/rides');
    final rows = (data as Map<String, dynamic>)['data'] as List? ?? [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(RideEntry.fromJson)
        .toList();
  }

  static Future<RideEntry> show(int id) async {
    final data = await ApiClient.get('/customer/rides/$id');
    return RideEntry.fromJson(data as Map<String, dynamic>);
  }

  static Future<RideEntry> cancel(int id, {String? reason}) async {
    final data = await ApiClient.post('/customer/rides/$id/cancel', body: {
      if (reason != null) 'reason': reason,
    });
    return RideEntry.fromJson(data as Map<String, dynamic>);
  }

  static Future<RideEntry> rate(int id,
      {required int rating, String? comment}) async {
    final data = await ApiClient.post('/customer/rides/$id/rate', body: {
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
    return RideEntry.fromJson(data as Map<String, dynamic>);
  }
}

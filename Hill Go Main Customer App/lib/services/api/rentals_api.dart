import '../../models/catalog_models.dart';
import 'api_client.dart';

/// Customer vehicle rental endpoints.
class RentalsApi {
  RentalsApi._();

  static Future<List<RentalVehicle>> list(
      {String? category, String? query}) async {
    final data = await ApiClient.get('/customer/rentals', query: {
      'per_page': '50',
      if (category != null && category != 'All') 'category': category,
      if (query != null && query.isNotEmpty) 'q': query,
    });
    final rows = (data as Map<String, dynamic>)['data'] as List? ?? [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(RentalVehicle.fromJson)
        .toList();
  }

  static Future<RentalVehicle> show(int id) async {
    final data = await ApiClient.get('/customer/rentals/$id');
    return RentalVehicle.fromJson(data as Map<String, dynamic>);
  }

  /// Books a rental; returns the raw booking row (code, totals, status).
  static Future<Map<String, dynamic>> book(RentalBooking booking) async {
    String d(DateTime t) =>
        '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
    final data = await ApiClient.post('/customer/rentals/bookings', body: {
      'vehicle_id': booking.vehicle.id,
      'pickup_location': booking.pickupLocation,
      'dropoff_location': booking.dropoffLocation,
      'start_date': d(booking.startDate),
      'end_date': d(booking.endDate),
      'with_driver': booking.withDriver,
      'renter_name': booking.renterName,
      'renter_phone': booking.renterPhone,
    });
    return data as Map<String, dynamic>;
  }

  static Future<List<RentalHistoryEntry>> bookings() async {
    final data = await ApiClient.get('/customer/rentals/bookings/list');
    final rows = (data as Map<String, dynamic>)['data'] as List? ?? [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(RentalHistoryEntry.fromJson)
        .toList();
  }

  static Future<void> cancelBooking(int id) async {
    await ApiClient.post('/customer/rentals/bookings/$id/cancel');
  }
}

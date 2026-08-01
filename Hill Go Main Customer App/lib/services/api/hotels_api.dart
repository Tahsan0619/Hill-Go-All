import '../../models/catalog_models.dart';
import 'api_client.dart';

/// Customer hotel endpoints.
class HotelsApi {
  HotelsApi._();

  static Future<List<HotelInfo>> list({String? location, String? query}) async {
    final data = await ApiClient.get('/customer/hotels', query: {
      'per_page': '50',
      if (location != null && location != 'All') 'location': location,
      if (query != null && query.isNotEmpty) 'q': query,
    });
    final rows = (data as Map<String, dynamic>)['data'] as List? ?? [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(HotelInfo.fromJson)
        .toList();
  }

  static Future<HotelInfo> show(int id) async {
    final data = await ApiClient.get('/customer/hotels/$id');
    return HotelInfo.fromJson(data as Map<String, dynamic>);
  }

  /// Books a stay; returns the raw booking row (code, totals, status).
  static Future<Map<String, dynamic>> book(HotelBooking booking) async {
    String d(DateTime t) =>
        '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
    final data = await ApiClient.post('/customer/hotels/bookings', body: {
      'hotel_id': booking.hotel.id,
      'check_in': d(booking.checkIn),
      'check_out': d(booking.checkOut),
      'guests': booking.guests,
      'rooms': booking.rooms,
      'guest_name': booking.guestName,
      'guest_phone': booking.guestPhone,
    });
    return data as Map<String, dynamic>;
  }

  static Future<List<HotelBookingEntry>> bookings() async {
    final data = await ApiClient.get('/customer/hotels/bookings/list');
    final rows = (data as Map<String, dynamic>)['data'] as List? ?? [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(HotelBookingEntry.fromJson)
        .toList();
  }

  static Future<void> cancelBooking(int id) async {
    await ApiClient.post('/customer/hotels/bookings/$id/cancel');
  }
}

import '../../models/catalog_models.dart';
import 'api_client.dart';

/// Customer parcel endpoints.
class ParcelsApi {
  ParcelsApi._();

  static Future<ParcelQuote> quote({
    required double distanceKm,
    required double weightKg,
    String priority = 'standard',
  }) async {
    final data = await ApiClient.post('/customer/parcels/quote', body: {
      'distance_km': distanceKm,
      'weight_kg': weightKg,
      'priority': priority,
    });
    return ParcelQuote.fromJson(data as Map<String, dynamic>);
  }

  static Future<ParcelEntry> create(ParcelBooking booking) async {
    final data = await ApiClient.post('/customer/parcels', body: {
      'type': booking.parcelType ?? 'Box',
      'priority': booking.priority,
      'pickup_address': booking.pickupAddress,
      'sender_name': booking.pickupContact,
      'sender_phone': booking.pickupPhone,
      'receiver_name': booking.receiverContact,
      'receiver_phone': booking.receiverPhone,
      'drop_address': booking.receiverAddress,
      'weight_kg': booking.weightKg,
      'distance_km': booking.distanceKm,
      'payment_method': booking.paymentMethod,
    });
    return ParcelEntry.fromJson(data as Map<String, dynamic>);
  }

  static Future<List<ParcelEntry>> list() async {
    final data = await ApiClient.get('/customer/parcels');
    final rows = (data as Map<String, dynamic>)['data'] as List? ?? [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(ParcelEntry.fromJson)
        .toList();
  }

  static Future<ParcelEntry> show(int id) async {
    final data = await ApiClient.get('/customer/parcels/$id');
    return ParcelEntry.fromJson(data as Map<String, dynamic>);
  }

  static Future<ParcelEntry> cancel(int id) async {
    final data = await ApiClient.post('/customer/parcels/$id/cancel');
    return ParcelEntry.fromJson(data as Map<String, dynamic>);
  }
}

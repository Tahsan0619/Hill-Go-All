import 'dart:async';
import 'dart:math' as math;

import '../../models/catalog_models.dart';
import 'api_client.dart';

/// Customer parcel endpoints.
class ParcelsApi {
  ParcelsApi._();

  static double _clampWeight(double kg) => kg.clamp(0.1, 50.0);
  static double _clampDistance(double km) => km.clamp(0.1, 500.0);

  /// Great-circle distance in km when both endpoints have coordinates.
  static double? haversineKm({
    double? pickupLat,
    double? pickupLng,
    double? dropLat,
    double? dropLng,
  }) {
    if (pickupLat == null ||
        pickupLng == null ||
        dropLat == null ||
        dropLng == null) {
      return null;
    }
    const earthRadiusKm = 6371.0;
    final dLat = _toRad(dropLat - pickupLat);
    final dLng = _toRad(dropLng - pickupLng);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(pickupLat)) *
            math.cos(_toRad(dropLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRad(double deg) => deg * math.pi / 180.0;

  static Future<ParcelQuote> quote({
    required double distanceKm,
    required double weightKg,
    String priority = 'standard',
  }) async {
    final data = await ApiClient.post('/customer/parcels/quote', body: {
      'distance_km': _clampDistance(distanceKm),
      'weight_kg': _clampWeight(weightKg),
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
      'weight_kg': _clampWeight(booking.weightKg),
      'distance_km': _clampDistance(booking.distanceKm),
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

import '../../models/catalog_models.dart';
import 'api_client.dart';

/// Customer SOS contacts and alerts.
class SosApi {
  SosApi._();

  static Future<List<EmergencyContact>> contacts() async {
    final data = await ApiClient.get('/customer/sos/contacts');
    return (data as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(EmergencyContact.fromJson)
        .toList();
  }

  static Future<EmergencyContact> addContact({
    required String name,
    required String phone,
    String relation = 'Contact',
  }) async {
    final data = await ApiClient.post('/customer/sos/contacts', body: {
      'name': name,
      'phone': phone,
      'relation': relation,
    });
    return EmergencyContact.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deleteContact(int id) async {
    await ApiClient.delete('/customer/sos/contacts/$id');
  }

  static Future<List<SosAlertEntry>> alerts() async {
    final data = await ApiClient.get('/customer/sos/alerts');
    final rows = (data as Map<String, dynamic>)['data'] as List? ?? [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(SosAlertEntry.fromJson)
        .toList();
  }

  /// type: sos|ride_sos|police|ambulance|location_share
  static Future<SosAlertEntry> trigger({
    required String type,
    String? locationLabel,
    double? lat,
    double? lng,
  }) async {
    final data = await ApiClient.post('/customer/sos/alerts', body: {
      'type': type,
      if (locationLabel != null && locationLabel.isNotEmpty)
        'location_label': locationLabel,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    });
    return SosAlertEntry.fromJson(data as Map<String, dynamic>);
  }
}

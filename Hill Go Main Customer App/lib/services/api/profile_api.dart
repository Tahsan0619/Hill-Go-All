import '../../models/catalog_models.dart';
import 'api_client.dart';

/// Customer addresses, payment methods and preferences.
class ProfileApi {
  ProfileApi._();

  // ── Addresses ────────────────────────────────────────────────────────────

  static Future<List<SavedAddress>> addresses() async {
    final data = await ApiClient.get('/customer/addresses');
    return (data as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(SavedAddress.fromJson)
        .toList();
  }

  static Future<SavedAddress> createAddress({
    required String label,
    required String address,
    double? lat,
    double? lng,
    bool isDefault = false,
  }) async {
    final data = await ApiClient.post('/customer/addresses', body: {
      'label': label,
      'address': address,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'is_default': isDefault,
    });
    return SavedAddress.fromJson(data as Map<String, dynamic>);
  }

  static Future<SavedAddress> updateAddress(
    int id, {
    String? label,
    String? address,
    bool? isDefault,
  }) async {
    final data = await ApiClient.patch('/customer/addresses/$id', body: {
      if (label != null) 'label': label,
      if (address != null) 'address': address,
      if (isDefault != null) 'is_default': isDefault,
    });
    return SavedAddress.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deleteAddress(int id) async {
    await ApiClient.delete('/customer/addresses/$id');
  }

  // ── Payment methods ──────────────────────────────────────────────────────

  static Future<List<PaymentMethodEntry>> paymentMethods() async {
    final data = await ApiClient.get('/customer/payment-methods');
    return (data as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PaymentMethodEntry.fromJson)
        .toList();
  }

  static Future<PaymentMethodEntry> addPaymentMethod({
    required String type,
    required String label,
    Map<String, dynamic>? details,
    bool isDefault = false,
  }) async {
    final data = await ApiClient.post('/customer/payment-methods', body: {
      'type': type,
      'label': label,
      if (details != null) 'details': details,
      'is_default': isDefault,
    });
    return PaymentMethodEntry.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deletePaymentMethod(int id) async {
    await ApiClient.delete('/customer/payment-methods/$id');
  }

  // ── Preferences ──────────────────────────────────────────────────────────

  static Future<void> setLanguage(String language) async {
    await ApiClient.patch('/customer/preferences', body: {
      'language': language,
    });
  }
}

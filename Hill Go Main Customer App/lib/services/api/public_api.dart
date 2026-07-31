import '../../models/catalog_models.dart';
import 'api_client.dart';

/// Public (unauthenticated) endpoints.
class PublicApi {
  PublicApi._();

  /// Districts open for customer registration.
  static Future<List<DistrictOption>> districts() async {
    final data = await ApiClient.get('/public/districts');
    return (data as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(DistrictOption.fromJson)
        .toList();
  }
}

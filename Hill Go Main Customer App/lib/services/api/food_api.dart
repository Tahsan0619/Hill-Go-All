import '../../models/catalog_models.dart';
import 'api_client.dart';

/// Customer food delivery endpoints.
class FoodApi {
  FoodApi._();

  static Future<List<RestaurantInfo>> restaurants(
      {String? query, String? cuisine}) async {
    final data = await ApiClient.get('/customer/food/restaurants', query: {
      if (query != null && query.isNotEmpty) 'q': query,
      if (cuisine != null && cuisine != 'All') 'cuisine': cuisine,
    });
    final rows = (data as Map<String, dynamic>)['data'] as List? ?? [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(RestaurantInfo.fromJson)
        .toList();
  }

  /// Restaurant with its full menu.
  static Future<RestaurantInfo> restaurant(int id) async {
    final data = await ApiClient.get('/customer/food/restaurants/$id');
    return RestaurantInfo.fromJson(data as Map<String, dynamic>);
  }

  static Future<FoodOrder> checkout({
    required int storeId,
    required List<FoodCartLine> lines,
    required String deliveryAddress,
    required String paymentMethod,
    String? customerNote,
    String? promoCode,
  }) async {
    final data = await ApiClient.post('/customer/food/orders', body: {
      'store_id': storeId,
      'items': [
        for (final line in lines)
          {'product_id': line.item.id, 'qty': line.quantity},
      ],
      'delivery_address': deliveryAddress,
      'payment_method': paymentMethod,
      if (customerNote != null && customerNote.isNotEmpty)
        'customer_note': customerNote,
      if (promoCode != null && promoCode.isNotEmpty) 'promo_code': promoCode,
    });
    return FoodOrder.fromJson(data as Map<String, dynamic>);
  }

  static Future<List<FoodOrder>> orders() async {
    final data = await ApiClient.get('/customer/food/orders');
    final rows = (data as Map<String, dynamic>)['data'] as List? ?? [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(FoodOrder.fromJson)
        .toList();
  }

  static Future<FoodOrder> order(int id) async {
    final data = await ApiClient.get('/customer/food/orders/$id');
    return FoodOrder.fromJson(data as Map<String, dynamic>);
  }
}

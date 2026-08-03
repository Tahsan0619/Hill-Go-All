import '../../models/catalog_models.dart';
import '../../models/paged_result.dart';
import 'api_client.dart';

/// Customer marketplace endpoints.
class MarketplaceApi {
  MarketplaceApi._();

  static Future<List<ProductCategory>> categories() async {
    final data = await ApiClient.get('/customer/marketplace/categories');
    return (data as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ProductCategory.fromJson)
        .toList();
  }

  static Future<List<Product>> products(
      {String? category, String? query}) async {
    final data = await ApiClient.get('/customer/marketplace/products', query: {
      'per_page': '50',
      if (category != null && category != 'All') 'category': category,
      if (query != null && query.isNotEmpty) 'q': query,
    });
    final rows = (data as Map<String, dynamic>)['data'] as List? ?? [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  static Future<Product> product(int id) async {
    final data = await ApiClient.get('/customer/marketplace/products/$id');
    return Product.fromJson(data as Map<String, dynamic>);
  }

  /// Places one merchant order per store; returns the created order stubs.
  static Future<List<Map<String, dynamic>>> checkout({
    required List<CartLine> lines,
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    final data = await ApiClient.post(
      '/customer/marketplace/orders',
      body: {
      'items': [
        for (final line in lines)
          {'product_id': line.product.id, 'qty': line.quantity},
      ],
      'delivery_address': deliveryAddress,
      'payment_method': paymentMethod,
    },
      idempotencyKey: ApiClient.newIdempotencyKey(),
    );
    final orders = (data as Map<String, dynamic>)['orders'] as List? ?? [];
    return orders.whereType<Map<String, dynamic>>().toList();
  }

  static Future<PagedResult<MarketplaceOrderEntry>> orders({int page = 1}) async {
    final data = await ApiClient.get('/customer/marketplace/orders', query: {
      'page': '$page',
      'per_page': '50',
    });
    return PagedResult.parse(
      data as Map<String, dynamic>,
      MarketplaceOrderEntry.fromJson,
    );
  }
}

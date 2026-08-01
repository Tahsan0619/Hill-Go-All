import '../../models/order_model.dart';
import '../repositories.dart';
import 'api_client.dart';

class ApiOrderRepository implements OrderRepository {
  ApiOrderRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await _api.get(
      '/merchant/orders',
      query: {'per_page': '50'},
    ) as Map<String, dynamic>;
    return ((response['data'] as List?) ?? const [])
        .map((o) => OrderModel.fromJson(o as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OrderModel> getOrder(String id) async {
    final response =
        await _api.get('/merchant/orders/${id.replaceAll('#', '')}')
            as Map<String, dynamic>;
    return OrderModel.fromJson(response);
  }

  @override
  Future<OrderModel> updateStatus(String id, OrderStatus status) async {
    final orderId = id.replaceAll('#', '');
    final String action;
    switch (status) {
      case OrderStatus.preparing:
        action = 'accept';
        break;
      case OrderStatus.ready:
        action = 'ready';
        break;
      case OrderStatus.delivered:
        action = 'deliver';
        break;
      case OrderStatus.rejected:
        action = 'reject';
        break;
      case OrderStatus.newOrder:
        throw ApiException(422, 'Orders cannot be moved back to new.');
    }
    final response = await _api.post('/merchant/orders/$orderId/$action')
        as Map<String, dynamic>;
    return OrderModel.fromJson(response);
  }

  @override
  Future<void> rejectOrder(String id, {String? reason}) async {
    await _api.post('/merchant/orders/${id.replaceAll('#', '')}/reject', {
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
  }
}

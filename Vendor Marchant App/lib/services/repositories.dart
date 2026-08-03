import '../models/order_model.dart';
import '../models/paged_result.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';

abstract class OrderRepository {
  /// Server-paginated order list (newest first). Callers accumulate pages
  /// client-side via [PagedResult.hasMore] / [PagedResult.page].
  Future<PagedResult<OrderModel>> getOrders({int page = 1});
  Future<OrderModel> getOrder(String id);
  Future<OrderModel> updateStatus(String id, OrderStatus status);
  Future<void> rejectOrder(String id, {String? reason});
}

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts();
  Future<List<CategoryModel>> getCategories();
  Future<ProductModel> saveProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<CategoryModel> addCategory(String name);
  Future<void> setCategoryVisibility(String id, bool visible);
  Future<void> reorderCategories(List<String> orderedIds);
}

abstract class StoreRepository {
  Future<StoreModel> getStore();
  Future<StoreModel> saveStore(StoreModel store);
  Future<void> setStoreStatus({bool? isOpen, bool? acceptingOrders});
  Future<List<ReviewModel>> getReviews();
  Future<ReviewModel> replyToReview(String id, String reply);
  Future<List<PayoutModel>> getPayouts();
  Future<List<TransactionModel>> getTransactions();
  Future<Map<String, dynamic>> getRevenueSummary();
  Future<List<double>> getRevenueTrend(String period);
  Future<void> requestEarlyPayout({
    required double amount,
    required String method,
  });
  Future<void> updateSettings(Map<String, dynamic> settings);
  /// Notification/language prefs from `/merchant/me` (server source of truth).
  Future<Map<String, dynamic>?> getMePrefs();
}

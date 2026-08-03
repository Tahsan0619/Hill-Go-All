import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../services/api/api_client.dart';
import '../services/repositories.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider(this._repo);

  final OrderRepository _repo;

  List<OrderModel> orders = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isActing = false;
  String? error;
  String searchQuery = '';
  String newFilter = 'All New'; // All New | Priority | Express
  DateTime? historyFrom;
  DateTime? historyTo;

  int _page = 1;
  bool hasMoreHistory = false;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.getOrders(page: 1);
      orders = result.items;
      _page = result.page;
      hasMoreHistory = result.hasMore;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e is ApiException ? e.message : e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  /// Reloads page 1 in the background (e.g. for live-update polling) without
  /// toggling [isLoading], so it doesn't disrupt whatever the user is doing.
  /// Failures are swallowed — pull-to-refresh / manual [load] remain available.
  Future<void> refreshSilently() async {
    try {
      final result = await _repo.getOrders(page: 1);
      orders = result.items;
      _page = result.page;
      hasMoreHistory = result.hasMore;
      error = null;
      notifyListeners();
    } catch (_) {
      // Silent: a background poll failing shouldn't surface an error banner.
    }
  }

  /// Fetches a single order from the server (used when opening an order
  /// that isn't in the currently loaded [orders] page, e.g. a deep link or
  /// cold app start straight into order details).
  Future<OrderModel?> fetchOrder(String id) async {
    try {
      final order = await _repo.getOrder(id);
      final idx = orders.indexWhere((o) => o.id == order.id);
      if (idx >= 0) {
        orders[idx] = order;
      } else {
        orders = [...orders, order];
      }
      notifyListeners();
      return order;
    } catch (e) {
      error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Loads the next server page and appends any not-yet-seen orders.
  /// Replaces the old client-side `historyVisible` slicing.
  Future<void> loadMoreHistory() async {
    if (isLoadingMore || !hasMoreHistory) return;
    isLoadingMore = true;
    notifyListeners();
    try {
      final result = await _repo.getOrders(page: _page + 1);
      final existingIds = orders.map((o) => o.id).toSet();
      final newOnes = result.items.where((o) => !existingIds.contains(o.id));
      orders = [...orders, ...newOnes];
      _page = result.page;
      hasMoreHistory = result.hasMore;
    } catch (e) {
      error = e is ApiException ? e.message : e.toString();
    }
    isLoadingMore = false;
    notifyListeners();
  }

  List<OrderModel> byStatus(OrderStatus status) {
    var list = orders.where((o) => o.status == status).toList();
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where(
            (o) =>
                o.id.toLowerCase().contains(q) ||
                o.code.toLowerCase().contains(q) ||
                o.customerName.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  List<OrderModel> get newOrders {
    var list = byStatus(OrderStatus.newOrder);
    if (newFilter == 'Priority') {
      list = list.where((o) => o.priority == OrderPriority.priority).toList();
    } else if (newFilter == 'Express') {
      list = list.where((o) => o.priority == OrderPriority.express).toList();
    }
    return list;
  }

  List<OrderModel> get preparingOrders => byStatus(OrderStatus.preparing);
  List<OrderModel> get readyOrders => byStatus(OrderStatus.ready);

  List<OrderModel> get deliveredOrders {
    var list = byStatus(OrderStatus.delivered);
    if (historyFrom != null) {
      list = list
          .where(
            (o) =>
                o.deliveredAt != null &&
                !o.deliveredAt!.isBefore(historyFrom!),
          )
          .toList();
    }
    if (historyTo != null) {
      list = list
          .where(
            (o) =>
                o.deliveredAt != null && !o.deliveredAt!.isAfter(historyTo!),
          )
          .toList();
    }
    return list;
  }

  OrderModel? findById(String id) {
    final clean = id.replaceAll('#', '');
    try {
      return orders.firstWhere(
        (o) => o.id == clean || o.id == id || o.code == clean,
      );
    } catch (_) {
      return null;
    }
  }

  void setSearch(String q) {
    searchQuery = q;
    notifyListeners();
  }

  void setNewFilter(String f) {
    newFilter = f;
    notifyListeners();
  }

  void setHistoryDateRange(DateTime? from, DateTime? to) {
    historyFrom = from;
    historyTo = to;
    notifyListeners();
  }

  Future<bool> accept(String id) async {
    isActing = true;
    notifyListeners();
    try {
      await _repo.updateStatus(id, OrderStatus.preparing);
      await load();
      isActing = false;
      notifyListeners();
      return true;
    } catch (_) {
      isActing = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> reject(String id) async {
    isActing = true;
    notifyListeners();
    try {
      await _repo.rejectOrder(id);
      await load();
      isActing = false;
      notifyListeners();
      return true;
    } catch (_) {
      isActing = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markReady(String id) async {
    isActing = true;
    notifyListeners();
    try {
      await _repo.updateStatus(id, OrderStatus.ready);
      await load();
      isActing = false;
      notifyListeners();
      return true;
    } catch (_) {
      isActing = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markDelivered(String id) async {
    isActing = true;
    notifyListeners();
    try {
      await _repo.updateStatus(id, OrderStatus.delivered);
      await load();
      isActing = false;
      notifyListeners();
      return true;
    } catch (_) {
      isActing = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> startPreparing(String id) async {
    return accept(id);
  }
}

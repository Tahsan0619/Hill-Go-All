import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../services/mock/mock_data_repositories.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider(this._repo);

  final OrderRepository _repo;

  List<OrderModel> orders = [];
  bool isLoading = false;
  bool isActing = false;
  String? error;
  String searchQuery = '';
  String newFilter = 'All New'; // All New | Priority | Express
  DateTime? historyFrom;
  DateTime? historyTo;
  int historyVisible = 3;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      orders = await _repo.getOrders();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  List<OrderModel> byStatus(OrderStatus status) {
    var list = orders.where((o) => o.status == status).toList();
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where(
            (o) =>
                o.id.toLowerCase().contains(q) ||
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

  List<OrderModel> get visibleHistory {
    final all = deliveredOrders;
    return all.take(historyVisible).toList();
  }

  OrderModel? findById(String id) {
    final clean = id.replaceAll('#', '');
    try {
      return orders.firstWhere((o) => o.id == clean || o.id == id);
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

  void loadMoreHistory() {
    historyVisible += 5;
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

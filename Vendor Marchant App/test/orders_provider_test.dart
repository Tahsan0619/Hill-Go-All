import 'package:flutter_test/flutter_test.dart';
import 'package:vendor_marchant_app/models/order_model.dart';
import 'package:vendor_marchant_app/models/paged_result.dart';
import 'package:vendor_marchant_app/providers/orders_provider.dart';
import 'package:vendor_marchant_app/services/api/api_client.dart';
import 'package:vendor_marchant_app/services/repositories.dart';

OrderModel _order(String id, OrderStatus status, {String? code}) {
  return OrderModel(
    id: id,
    code: code ?? id,
    customerName: 'Test Customer',
    customerPhone: '01700000000',
    customerRating: 4.5,
    customerOrderCount: 3,
    items: const [],
    status: status,
    createdAt: DateTime(2026, 1, 1),
    priority: OrderPriority.standard,
  );
}

/// In-memory fake standing in for [ApiOrderRepository] so provider logic
/// (accept/reject/pagination/cold-open fetch) can be tested without network.
class FakeOrderRepository implements OrderRepository {
  FakeOrderRepository({
    Map<int, PagedResult<OrderModel>>? pages,
    this.getOrderResult,
    this.throwOnGetOrders = false,
    this.throwOnUpdateStatus = false,
    this.throwOnReject = false,
  }) : pages = pages ??
            {
              1: PagedResult(
                items: [_order('1', OrderStatus.newOrder)],
                page: 1,
                hasMore: false,
              ),
            };

  final Map<int, PagedResult<OrderModel>> pages;
  OrderModel? getOrderResult;
  bool throwOnGetOrders;
  bool throwOnUpdateStatus;
  bool throwOnReject;

  int updateStatusCalls = 0;
  int rejectCalls = 0;
  final List<int> getOrdersPagesRequested = [];

  @override
  Future<PagedResult<OrderModel>> getOrders({int page = 1}) async {
    getOrdersPagesRequested.add(page);
    if (throwOnGetOrders) throw ApiException(500, 'boom');
    return pages[page] ??
        PagedResult(items: const [], page: page, hasMore: false);
  }

  @override
  Future<OrderModel> getOrder(String id) async {
    final result = getOrderResult;
    if (result == null) throw ApiException(404, 'not found');
    return result;
  }

  @override
  Future<OrderModel> updateStatus(String id, OrderStatus status) async {
    updateStatusCalls++;
    if (throwOnUpdateStatus) throw ApiException(500, 'boom');
    return _order(id, status);
  }

  @override
  Future<void> rejectOrder(String id, {String? reason}) async {
    rejectCalls++;
    if (throwOnReject) throw ApiException(500, 'boom');
  }
}

void main() {
  group('OrdersProvider.load', () {
    test('populates orders and pagination flags on success', () async {
      final repo = FakeOrderRepository(pages: {
        1: PagedResult(
          items: [_order('1', OrderStatus.newOrder)],
          page: 1,
          hasMore: true,
        ),
      });
      final provider = OrdersProvider(repo);
      await provider.load();
      expect(provider.orders.length, 1);
      expect(provider.hasMoreHistory, isTrue);
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
    });

    test('sets an error message on failure', () async {
      final repo = FakeOrderRepository(throwOnGetOrders: true);
      final provider = OrdersProvider(repo);
      await provider.load();
      expect(provider.error, isNotNull);
      expect(provider.isLoading, isFalse);
    });
  });

  group('OrdersProvider.accept / reject (provider logic)', () {
    test('accept calls updateStatus then reloads, returns true', () async {
      final repo = FakeOrderRepository();
      final provider = OrdersProvider(repo);
      final ok = await provider.accept('1');
      expect(ok, isTrue);
      expect(repo.updateStatusCalls, 1);
      expect(provider.isActing, isFalse);
    });

    test('accept returns false and resets isActing on failure', () async {
      final repo = FakeOrderRepository(throwOnUpdateStatus: true);
      final provider = OrdersProvider(repo);
      final ok = await provider.accept('1');
      expect(ok, isFalse);
      expect(provider.isActing, isFalse);
    });

    test('startPreparing delegates to accept', () async {
      final repo = FakeOrderRepository();
      final provider = OrdersProvider(repo);
      final ok = await provider.startPreparing('1');
      expect(ok, isTrue);
      expect(repo.updateStatusCalls, 1);
    });

    test('reject calls rejectOrder then reloads, returns true', () async {
      final repo = FakeOrderRepository();
      final provider = OrdersProvider(repo);
      final ok = await provider.reject('1');
      expect(ok, isTrue);
      expect(repo.rejectCalls, 1);
    });

    test('reject returns false and resets isActing on failure', () async {
      final repo = FakeOrderRepository(throwOnReject: true);
      final provider = OrdersProvider(repo);
      final ok = await provider.reject('1');
      expect(ok, isFalse);
      expect(provider.isActing, isFalse);
    });
  });

  group('OrdersProvider.fetchOrder (cold-open fix)', () {
    test('fetches and inserts an order missing from the loaded page', () async {
      final missing = _order('99', OrderStatus.preparing, code: 'HG-99');
      final repo = FakeOrderRepository(getOrderResult: missing);
      final provider = OrdersProvider(repo);
      await provider.load(); // page 1 only contains order '1'
      expect(provider.findById('99'), isNull);

      final fetched = await provider.fetchOrder('99');
      expect(fetched, isNotNull);
      expect(provider.findById('99'), isNotNull);
    });

    test('updates an already-loaded order in place', () async {
      final updated = _order('1', OrderStatus.ready);
      final repo = FakeOrderRepository(getOrderResult: updated);
      final provider = OrdersProvider(repo);
      await provider.load();
      expect(provider.findById('1')!.status, OrderStatus.newOrder);

      await provider.fetchOrder('1');
      expect(provider.orders.length, 1);
      expect(provider.findById('1')!.status, OrderStatus.ready);
    });

    test('returns null and sets an error when the fetch fails', () async {
      final repo = FakeOrderRepository(getOrderResult: null);
      final provider = OrdersProvider(repo);
      final fetched = await provider.fetchOrder('missing');
      expect(fetched, isNull);
      expect(provider.error, isNotNull);
    });
  });

  group('OrdersProvider.loadMoreHistory (server-driven pagination)', () {
    test('appends the next page and clears hasMoreHistory at the last page',
        () async {
      final repo = FakeOrderRepository(pages: {
        1: PagedResult(
          items: [_order('1', OrderStatus.delivered)],
          page: 1,
          hasMore: true,
        ),
        2: PagedResult(
          items: [_order('2', OrderStatus.delivered)],
          page: 2,
          hasMore: false,
        ),
      });
      final provider = OrdersProvider(repo);
      await provider.load();
      expect(provider.orders.length, 1);
      expect(provider.hasMoreHistory, isTrue);

      await provider.loadMoreHistory();
      expect(provider.orders.length, 2);
      expect(provider.hasMoreHistory, isFalse);
      expect(repo.getOrdersPagesRequested, [1, 2]);
    });

    test('is a no-op once hasMoreHistory is false', () async {
      final repo = FakeOrderRepository(pages: {
        1: PagedResult(
          items: [_order('1', OrderStatus.delivered)],
          page: 1,
          hasMore: false,
        ),
      });
      final provider = OrdersProvider(repo);
      await provider.load();
      await provider.loadMoreHistory();
      expect(repo.getOrdersPagesRequested, [1]);
      expect(provider.orders.length, 1);
    });

    test('deduplicates orders already present in the list', () async {
      final repo = FakeOrderRepository(pages: {
        1: PagedResult(
          items: [_order('1', OrderStatus.delivered)],
          page: 1,
          hasMore: true,
        ),
        2: PagedResult(
          items: [
            _order('1', OrderStatus.delivered),
            _order('2', OrderStatus.delivered),
          ],
          page: 2,
          hasMore: false,
        ),
      });
      final provider = OrdersProvider(repo);
      await provider.load();
      await provider.loadMoreHistory();
      expect(provider.orders.map((o) => o.id).toSet(), {'1', '2'});
    });
  });

  group('OrdersProvider.refreshSilently (live updates)', () {
    test('updates orders without ever setting isLoading', () async {
      final repo = FakeOrderRepository();
      final provider = OrdersProvider(repo);
      await provider.load();
      expect(provider.isLoading, isFalse);

      repo.pages[1] = PagedResult(
        items: [
          _order('1', OrderStatus.newOrder),
          _order('2', OrderStatus.newOrder),
        ],
        page: 1,
        hasMore: false,
      );
      await provider.refreshSilently();
      expect(provider.orders.length, 2);
      expect(provider.isLoading, isFalse);
    });

    test('swallows errors instead of surfacing them', () async {
      final repo = FakeOrderRepository();
      final provider = OrdersProvider(repo);
      await provider.load();
      repo.throwOnGetOrders = true;

      await provider.refreshSilently();
      // Orders/error state from the last successful load are preserved.
      expect(provider.orders.length, 1);
    });
  });
}

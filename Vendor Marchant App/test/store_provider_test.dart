import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_marchant_app/models/store_model.dart';
import 'package:vendor_marchant_app/providers/store_provider.dart';
import 'package:vendor_marchant_app/services/api/api_client.dart';
import 'package:vendor_marchant_app/services/repositories.dart';

StoreModel _store() {
  return StoreModel(
    name: 'Test Store',
    description: 'desc',
    address: 'addr',
    specialties: '',
    bio: '',
    latitude: 22.0,
    longitude: 92.0,
    isOpen: true,
    acceptingOrders: true,
    hours: StoreModel.defaultHours(),
    id: '1',
  );
}

/// In-memory fake standing in for [ApiStoreRepository]. Each of the four
/// "independent" calls records a start/end marker (after an artificial
/// [delay]) so tests can assert they overlap instead of running sequentially.
class FakeStoreRepository implements StoreRepository {
  FakeStoreRepository({this.delay = const Duration(milliseconds: 30)});

  final Duration delay;
  final List<String> callLog = [];

  @override
  Future<StoreModel> getStore() async {
    callLog.add('getStore');
    return _store();
  }

  @override
  Future<StoreModel> saveStore(StoreModel store) async => store;

  @override
  Future<void> setStoreStatus({bool? isOpen, bool? acceptingOrders}) async {}

  @override
  Future<List<ReviewModel>> getReviews() async {
    callLog.add('getReviews-start');
    await Future<void>.delayed(delay);
    callLog.add('getReviews-end');
    return [];
  }

  @override
  Future<ReviewModel> replyToReview(String id, String reply) async {
    return ReviewModel(
      id: id,
      customerName: '',
      avatarUrl: '',
      rating: 5,
      comment: reply,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<PayoutModel>> getPayouts() async {
    callLog.add('getPayouts-start');
    await Future<void>.delayed(delay);
    callLog.add('getPayouts-end');
    return [];
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    callLog.add('getTransactions-start');
    await Future<void>.delayed(delay);
    callLog.add('getTransactions-end');
    return [];
  }

  @override
  Future<Map<String, dynamic>> getRevenueSummary() async {
    callLog.add('getRevenueSummary-start');
    await Future<void>.delayed(delay);
    callLog.add('getRevenueSummary-end');
    return {'totalRevenue': 100.0};
  }

  @override
  Future<List<double>> getRevenueTrend(String period) async {
    callLog.add('getRevenueTrend');
    return [1, 2, 3];
  }

  @override
  Future<void> requestEarlyPayout({
    required double amount,
    required String method,
  }) async {}

  @override
  Future<void> updateSettings(Map<String, dynamic> settings) async {}

  @override
  Future<Map<String, dynamic>?> getMePrefs() async => null;
}

class _NotFoundStoreRepository extends FakeStoreRepository {
  @override
  Future<StoreModel> getStore() async {
    throw ApiException(404, 'no store');
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StoreProvider.load', () {
    test('populates store, reviews, payouts, transactions and revenue',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = FakeStoreRepository();
      final provider = StoreProvider(repo, prefs);
      await provider.load();

      expect(provider.store, isNotNull);
      expect(provider.storePending, isFalse);
      expect(provider.revenueSummary['totalRevenue'], 100.0);
      expect(provider.revenueTrend, [1, 2, 3]);
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
    });

    test(
        'runs reviews/payouts/transactions/revenue concurrently via Future.wait',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final repo =
          FakeStoreRepository(delay: const Duration(milliseconds: 60));
      final provider = StoreProvider(repo, prefs);

      final stopwatch = Stopwatch()..start();
      await provider.load();
      stopwatch.stop();

      // Sequential awaits would take >= 4 * 60ms = 240ms; running the four
      // independent calls in parallel should finish close to a single delay.
      expect(stopwatch.elapsedMilliseconds, lessThan(200));

      // Every call should have *started* before any of them finished,
      // proving they overlapped rather than running one after another.
      final starts = [
        'getReviews-start',
        'getPayouts-start',
        'getTransactions-start',
        'getRevenueSummary-start',
      ].map(repo.callLog.indexOf).toList();
      final firstEnd = [
        'getReviews-end',
        'getPayouts-end',
        'getTransactions-end',
        'getRevenueSummary-end',
      ].map(repo.callLog.indexOf).reduce((a, b) => a < b ? a : b);

      expect(starts.every((i) => i < firstEnd), isTrue);
    });

    test('marks the store pending on a 404 instead of surfacing an error',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = _NotFoundStoreRepository();
      final provider = StoreProvider(repo, prefs);
      await provider.load();

      expect(provider.storePending, isTrue);
      expect(provider.store, isNull);
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
    });
  });
}

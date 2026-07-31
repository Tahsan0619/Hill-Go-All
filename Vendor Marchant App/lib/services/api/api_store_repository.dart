import '../../models/store_model.dart';
import '../repositories.dart';
import 'api_client.dart';

class ApiStoreRepository implements StoreRepository {
  ApiStoreRepository(this._api);

  final ApiClient _api;

  /// Trend series cached from the latest `GET /merchant/revenue` call.
  Map<String, dynamic>? _trend;

  @override
  Future<StoreModel> getStore() async {
    final response = await _api.get('/merchant/store') as Map<String, dynamic>;
    return StoreModel.fromJson(response, resolveUrl: ApiClient.absoluteUrl);
  }

  @override
  Future<StoreModel> saveStore(StoreModel store) async {
    if (store.bannerLocalPath != null || store.logoLocalPath != null) {
      await _api.multipart('/merchant/store/branding', files: {
        if (store.bannerLocalPath != null) 'banner': store.bannerLocalPath!,
        if (store.logoLocalPath != null) 'logo': store.logoLocalPath!,
      });
    }
    final response = await _api.put('/merchant/store', {
      'name': store.name,
      'description': store.description,
      'specialties': store.specialties,
      'bio': store.bio,
      'address': store.address,
      'lat': store.latitude,
      'lng': store.longitude,
      'hours': store.hoursToJson(),
    }) as Map<String, dynamic>;
    return StoreModel.fromJson(response, resolveUrl: ApiClient.absoluteUrl);
  }

  @override
  Future<void> setStoreStatus({bool? isOpen, bool? acceptingOrders}) async {
    await _api.patch('/merchant/store/status', {
      if (isOpen != null) 'is_open': isOpen,
      if (acceptingOrders != null) 'accepting_orders': acceptingOrders,
    });
  }

  @override
  Future<List<ReviewModel>> getReviews() async {
    final response =
        await _api.get('/merchant/reviews') as Map<String, dynamic>;
    return ((response['data'] as List?) ?? const [])
        .map((r) => ReviewModel.fromJson(
              r as Map<String, dynamic>,
              resolveUrl: ApiClient.absoluteUrl,
            ))
        .toList();
  }

  @override
  Future<ReviewModel> replyToReview(String id, String reply) async {
    final response = await _api.post('/merchant/reviews/$id/reply', {
      'reply': reply,
    }) as Map<String, dynamic>;
    return ReviewModel.fromJson(response, resolveUrl: ApiClient.absoluteUrl);
  }

  @override
  Future<List<PayoutModel>> getPayouts() async {
    final response =
        await _api.get('/merchant/payouts') as Map<String, dynamic>;
    return ((response['data'] as List?) ?? const [])
        .map((p) => PayoutModel.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final response = await _api.get('/merchant/transactions') as List;
    return [
      for (var i = 0; i < response.length; i++)
        TransactionModel.fromJson(response[i] as Map<String, dynamic>, i),
    ];
  }

  @override
  Future<Map<String, dynamic>> getRevenueSummary() async {
    final r = await _api.get('/merchant/revenue') as Map<String, dynamic>;
    _trend = r['trend'] as Map<String, dynamic>?;
    return {
      'totalRevenue': (r['total_revenue'] as num?)?.toDouble() ?? 0.0,
      'pendingPayout': (r['pending_payout'] as num?)?.toDouble() ?? 0.0,
      'orders': (r['orders_count'] as num?)?.toInt() ?? 0,
      'growthPercent': (r['growth_percent'] as num?)?.toDouble() ?? 0.0,
      'nextPayoutDate': r['next_payout_date'] != null
          ? DateTime.tryParse('${r['next_payout_date']}')
          : null,
      'totalWithdrawn': (r['total_withdrawn'] as num?)?.toDouble() ?? 0.0,
      'lastPayoutDate': r['last_payout_date'] != null
          ? DateTime.tryParse('${r['last_payout_date']}')
          : null,
      'todaySales': (r['today_sales'] as num?)?.toDouble() ?? 0.0,
      'todayOrders': (r['today_orders'] as num?)?.toInt() ?? 0,
      'rating': (r['rating'] as num?)?.toDouble() ?? 0.0,
      'reviewCount': (r['review_count'] as num?)?.toInt() ?? 0,
    };
  }

  @override
  Future<List<double>> getRevenueTrend(String period) async {
    if (_trend == null) {
      await getRevenueSummary();
    }
    final trend = _trend;
    if (trend == null) return const [];
    final List series;
    switch (period) {
      case 'Weekly':
        series = (trend['weekly'] as List?) ?? const [];
        break;
      case 'Monthly':
        series = (trend['monthly'] as List?) ?? const [];
        break;
      default:
        series = (trend['daily'] as List?) ?? const [];
    }
    return series
        .map((e) => ((e as Map)['total'] as num?)?.toDouble() ?? 0.0)
        .toList();
  }

  @override
  Future<void> requestEarlyPayout({
    required double amount,
    required String method,
  }) async {
    await _api.post('/merchant/payouts/early-request', {
      'amount': amount,
      'method': method,
    });
  }

  @override
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    await _api.patch('/merchant/settings', settings);
  }
}

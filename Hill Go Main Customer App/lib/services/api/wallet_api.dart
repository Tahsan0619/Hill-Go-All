import '../../models/catalog_models.dart';
import '../../models/paged_result.dart';
import 'api_client.dart';

/// Customer wallet, loyalty and promo endpoints.
class WalletApi {
  WalletApi._();

  static Future<WalletSummary> summary() async {
    final data = await ApiClient.get('/customer/wallet');
    return WalletSummary.fromJson(data as Map<String, dynamic>);
  }

  static Future<PagedResult<WalletTransaction>> transactions({
    int page = 1,
    int perPage = 50,
  }) async {
    final data = await ApiClient.get('/customer/wallet/transactions', query: {
      'page': '$page',
      'per_page': '$perPage',
    });
    return PagedResult.parse(
      data as Map<String, dynamic>,
      WalletTransaction.fromJson,
    );
  }

  /// Requests a top-up (completes after payment confirmation server-side).
  static Future<String> topUp(
      {required double amount, required String method}) async {
    final data = await ApiClient.post('/customer/wallet/top-up', body: {
      'amount': amount,
      'method': method,
    });
    return ((data as Map<String, dynamic>)['message'] as String?) ??
        'Top-up request submitted.';
  }

  static Future<List<LoyaltyReward>> rewards() async {
    final data = await ApiClient.get('/customer/rewards');
    return (data as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(LoyaltyReward.fromJson)
        .toList();
  }

  static Future<void> redeem(int rewardId) async {
    await ApiClient.post('/customer/rewards/$rewardId/redeem');
  }

  static Future<List<PromoItem>> promos() async {
    final data = await ApiClient.get('/customer/promos');
    return (data as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PromoItem.fromJson)
        .toList();
  }
}

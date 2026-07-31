import '../../models/catalog_models.dart';
import 'api_client.dart';

/// Customer wallet, loyalty and promo endpoints.
class WalletApi {
  WalletApi._();

  static Future<WalletSummary> summary() async {
    final data = await ApiClient.get('/customer/wallet');
    return WalletSummary.fromJson(data as Map<String, dynamic>);
  }

  static Future<List<WalletTransaction>> transactions() async {
    final data = await ApiClient.get('/customer/wallet/transactions');
    final rows = (data as Map<String, dynamic>)['data'] as List? ?? [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(WalletTransaction.fromJson)
        .toList();
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

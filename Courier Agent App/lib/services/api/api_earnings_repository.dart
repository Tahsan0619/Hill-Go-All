import '../../models/earnings_model.dart';
import '../../models/notification_model.dart';
import '../repositories.dart';
import 'api_client.dart';

class ApiEarningsRepository implements EarningsRepository {
  ApiEarningsRepository(this._api);

  final ApiClient _api;

  @override
  Future<DashboardStats> getDashboardStats() async =>
      DashboardStats.fromJson(await _api.get('/courier/earnings/dashboard') as Map<String, dynamic>);

  @override
  Future<WeeklySummary> getWeeklySummary() async =>
      WeeklySummary.fromJson(await _api.get('/courier/earnings/weekly') as Map<String, dynamic>);

  @override
  Future<PayoutSummary> getPayoutSummary() async =>
      PayoutSummary.fromJson(await _api.get('/courier/earnings/payout-summary') as Map<String, dynamic>);

  @override
  Future<void> withdrawFunds({required double amount, required String method}) =>
      _api.post('/courier/withdrawals', body: {'amount': amount, 'method': method});

  @override
  Future<List<IncentiveOffer>> getIncentives() async {
    final data = await _api.get('/courier/incentives') as List<dynamic>;
    return data.map((row) => IncentiveOffer.fromJson(row as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> acceptIncentive(String id) => _api.post('/courier/incentives/$id/accept');
}

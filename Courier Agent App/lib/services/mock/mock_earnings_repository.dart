import 'dart:math';
import '../../models/earnings_model.dart';
import '../repositories.dart';
import 'mock_data.dart';

class MockEarningsRepository implements EarningsRepository {
  final _rand = Random();

  Future<void> _delay([int? ms]) async {
    await Future<void>.delayed(Duration(milliseconds: ms ?? (300 + _rand.nextInt(900))));
  }

  @override
  Future<WeeklySummary> getWeeklySummary() async {
    await _delay();
    return MockData.weeklySummary;
  }

  @override
  Future<List<DailyEarning>> getDailyBreakdown() async {
    await _delay();
    return List.unmodifiable(MockData.dailyBreakdown);
  }

  @override
  Future<PayoutSummary> getPayoutSummary() async {
    await _delay();
    return MockData.payoutSummary;
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
    await _delay();
    return MockData.dashboardStats;
  }

  @override
  Future<void> withdrawFunds(double amount) async {
    await _delay(1000);
    if (amount <= 0) throw Exception('Enter a valid amount');
    if (amount > MockData.weeklySummary.total) {
      throw Exception('Amount exceeds available balance');
    }
  }
}

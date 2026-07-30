import 'package:flutter/foundation.dart';
import '../models/earnings_model.dart';
import '../services/mock/mock_earnings_repository.dart';

enum EarningsLoadState { idle, loading, error, success }

class EarningsProvider extends ChangeNotifier {
  EarningsProvider(this._repo);

  final MockEarningsRepository _repo;

  EarningsLoadState state = EarningsLoadState.idle;
  String? error;
  WeeklySummary? weekly;
  List<DailyEarning> daily = [];
  PayoutSummary? payout;
  final Set<int> expandedDays = {0};
  bool withdrawing = false;

  Future<void> loadEarnings() async {
    state = EarningsLoadState.loading;
    error = null;
    notifyListeners();
    try {
      weekly = await _repo.getWeeklySummary();
      daily = await _repo.getDailyBreakdown();
      state = EarningsLoadState.success;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      state = EarningsLoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadPayout() async {
    state = EarningsLoadState.loading;
    error = null;
    notifyListeners();
    try {
      payout = await _repo.getPayoutSummary();
      state = EarningsLoadState.success;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      state = EarningsLoadState.error;
    }
    notifyListeners();
  }

  void toggleDay(int index) {
    if (expandedDays.contains(index)) {
      expandedDays.remove(index);
    } else {
      expandedDays.add(index);
    }
    notifyListeners();
  }

  Future<bool> withdraw(double amount) async {
    withdrawing = true;
    error = null;
    notifyListeners();
    try {
      await _repo.withdrawFunds(amount);
      withdrawing = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      withdrawing = false;
      notifyListeners();
      return false;
    }
  }
}

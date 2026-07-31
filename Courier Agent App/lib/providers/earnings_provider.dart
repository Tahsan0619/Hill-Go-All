import 'package:flutter/foundation.dart';
import '../models/earnings_model.dart';
import '../models/notification_model.dart';
import '../services/repositories.dart';

enum EarningsLoadState { idle, loading, error, success }

class EarningsProvider extends ChangeNotifier {
  EarningsProvider(this._repo);

  final EarningsRepository _repo;

  EarningsLoadState state = EarningsLoadState.idle;
  String? error;
  WeeklySummary? weekly;
  PayoutSummary? payout;
  List<IncentiveOffer> incentives = [];
  final Set<int> expandedDays = {0};
  bool withdrawing = false;

  List<DailyEarning> get daily => weekly?.daily ?? const [];

  Future<void> loadEarnings() => _load(() async {
    weekly = await _repo.getWeeklySummary();
  });

  Future<void> loadPayout() => _load(() async {
    payout = await _repo.getPayoutSummary();
  });

  Future<void> loadIncentives() => _load(() async {
    incentives = await _repo.getIncentives();
  });

  void toggleDay(int index) {
    if (!expandedDays.remove(index)) expandedDays.add(index);
    notifyListeners();
  }

  Future<bool> withdraw({required double amount, required String method}) async {
    withdrawing = true;
    error = null;
    notifyListeners();
    try {
      await _repo.withdrawFunds(amount: amount, method: method);
      payout = await _repo.getPayoutSummary();
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

  Future<bool> acceptIncentive(IncentiveOffer offer) async {
    try {
      await _repo.acceptIncentive(offer.id);
      incentives = await _repo.getIncentives();
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> _load(Future<void> Function() action) async {
    state = EarningsLoadState.loading;
    error = null;
    notifyListeners();
    try {
      await action();
      state = EarningsLoadState.success;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      state = EarningsLoadState.error;
    }
    notifyListeners();
  }
}

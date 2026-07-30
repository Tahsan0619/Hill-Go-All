import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/mock/mock_trip_repository.dart';
import '../services/trip_repository.dart';

class DriverProvider extends ChangeNotifier {
  DriverProvider(this._repo);

  final TripRepository _repo;

  bool isOnline = false;
  bool isLoading = false;
  String? error;
  EarningsSummary? earnings;
  List<Trip> history = [];
  List<PayoutRecord> payouts = [];
  Trip? activeTrip;
  Trip? incomingOffer;
  String historyQuery = '';
  String historyFilter = 'all'; // all | completed | cancelled | surge
  int selectedWeekDay = DateTime.now().weekday % 7; // 0=Mon style map later
  bool simulateCashOutSuccess = true;
  double surgeMultiplier = 1.8;

  Future<void> loadDashboard() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      earnings = await _repo.getEarnings();
      history = await _repo.getTripHistory(query: historyQuery, filter: historyFilter);
      payouts = await _repo.getPayouts();
      if (isOnline && activeTrip == null) {
        incomingOffer = await _repo.getIncomingOffer();
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshHistory() async {
    isLoading = true;
    notifyListeners();
    try {
      history = await _repo.getTripHistory(query: historyQuery, filter: historyFilter);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setHistoryQuery(String q) {
    historyQuery = q;
    refreshHistory();
  }

  void setHistoryFilter(String filter) {
    historyFilter = filter;
    refreshHistory();
  }

  void setSelectedWeekDay(int dayIndex) {
    selectedWeekDay = dayIndex;
    notifyListeners();
  }

  Future<void> toggleOnline(bool value) async {
    isOnline = value;
    notifyListeners();
    if (value) {
      await Future.delayed(const Duration(milliseconds: 600));
      incomingOffer = await _repo.getIncomingOffer();
      notifyListeners();
    } else {
      incomingOffer = null;
      notifyListeners();
    }
  }

  Future<bool> acceptOffer() async {
    if (incomingOffer == null) return false;
    isLoading = true;
    notifyListeners();
    try {
      activeTrip = await _repo.acceptTrip(incomingOffer!.id);
      incomingOffer = null;
      error = null;
      return true;
    } on TripException catch (e) {
      error = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> declineOffer() async {
    if (incomingOffer == null) return;
    isLoading = true;
    notifyListeners();
    try {
      await _repo.declineTrip(incomingOffer!.id);
      incomingOffer = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markArrived() async {
    if (activeTrip == null) return false;
    return _updateStatus(TripStatus.arrived);
  }

  Future<bool> startTrip() async {
    return _updateStatus(TripStatus.inProgress);
  }

  Future<bool> completeTrip() async {
    final ok = await _updateStatus(TripStatus.completed);
    if (ok) {
      activeTrip = null;
      // Stay online — ready for next offer.
      if (isOnline) {
        await Future.delayed(const Duration(milliseconds: 400));
        incomingOffer = await _repo.getIncomingOffer();
      }
      await loadDashboard();
    }
    return ok;
  }

  /// Advances to the next status for the active job type (Ride / Food / Parcel).
  Future<bool> advanceJob() async {
    final trip = activeTrip;
    if (trip == null) return false;
    final next = trip.nextStatus;
    if (next == null) return false;
    if (next == TripStatus.completed) {
      return completeTrip();
    }
    return _updateStatus(next);
  }

  Future<bool> _updateStatus(TripStatus status) async {
    if (activeTrip == null) return false;
    isLoading = true;
    notifyListeners();
    try {
      activeTrip = await _repo.updateTripStatus(activeTrip!.id, status);
      error = null;
      return true;
    } on TripException catch (e) {
      error = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Trip?> getTrip(String id) => _repo.getTripById(id);

  Future<bool> cashOut(double amount) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _repo.requestCashOut(amount, simulateSuccess: simulateCashOutSuccess);
      if (earnings != null) {
        earnings = EarningsSummary(
          todayTotal: earnings!.todayTotal,
          todayTrips: earnings!.todayTrips,
          onlineDuration: earnings!.onlineDuration,
          todayTrendPercent: earnings!.todayTrendPercent,
          currentBalance: (earnings!.currentBalance - amount).clamp(0, double.infinity),
          weekTrendPercent: earnings!.weekTrendPercent,
          baseFare: earnings!.baseFare,
          tips: earnings!.tips,
          surgeBonuses: earnings!.surgeBonuses,
          dailyTotals: earnings!.dailyTotals,
        );
      }
      return true;
    } on TripException catch (e) {
      error = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSimulateCashOutSuccess(bool value) {
    simulateCashOutSuccess = value;
    notifyListeners();
  }

  String formatOnlineDuration() {
    final d = earnings?.onlineDuration ?? Duration.zero;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }
}

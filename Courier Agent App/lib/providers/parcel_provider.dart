import 'package:flutter/foundation.dart';
import '../models/earnings_model.dart';
import '../models/parcel_model.dart';
import '../services/mock/mock_parcel_repository.dart';
import '../services/mock/mock_earnings_repository.dart';

enum LoadState { idle, loading, error, success }

class ParcelProvider extends ChangeNotifier {
  ParcelProvider(this._parcelRepo, this._earningsRepo);

  final MockParcelRepository _parcelRepo;
  final MockEarningsRepository _earningsRepo;

  LoadState assignedState = LoadState.idle;
  LoadState historyState = LoadState.idle;
  LoadState detailState = LoadState.idle;
  String? error;

  List<ParcelModel> assigned = [];
  List<ParcelModel> history = [];
  ParcelModel? selected;
  DashboardStats? dashboardStats;
  bool isOnline = true;

  String historyQuery = '';
  String historyPeriod = 'daily';
  bool loadingMore = false;

  Future<void> loadDashboard() async {
    assignedState = LoadState.loading;
    error = null;
    notifyListeners();
    try {
      assigned = await _parcelRepo.getAssignedParcels();
      dashboardStats = await _earningsRepo.getDashboardStats();
      assignedState = LoadState.success;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      assignedState = LoadState.error;
    }
    notifyListeners();
  }

  void setOnline(bool value) {
    isOnline = value;
    notifyListeners();
  }

  Future<void> loadHistory({String? query, String? period}) async {
    historyState = LoadState.loading;
    error = null;
    if (query != null) historyQuery = query;
    if (period != null) historyPeriod = period;
    notifyListeners();
    try {
      history = await _parcelRepo.getParcelHistory(
        query: historyQuery,
        period: historyPeriod,
      );
      historyState = LoadState.success;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      historyState = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadMoreHistory() async {
    loadingMore = true;
    notifyListeners();
    try {
      history = await _parcelRepo.loadMoreHistory();
    } finally {
      loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadParcel(String id) async {
    detailState = LoadState.loading;
    error = null;
    notifyListeners();
    try {
      selected = await _parcelRepo.getParcelById(id);
      detailState = LoadState.success;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      detailState = LoadState.error;
    }
    notifyListeners();
  }

  Future<bool> confirmPickup(String otp) async {
    if (selected == null) return false;
    detailState = LoadState.loading;
    notifyListeners();
    try {
      await _parcelRepo.confirmPickupOtp(selected!.id, otp);
      selected = selected!.copyWith(status: ParcelStatus.pickedUp);
      detailState = LoadState.success;
      await loadDashboard();
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      detailState = LoadState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmDelivery(String otp) async {
    if (selected == null) return false;
    detailState = LoadState.loading;
    notifyListeners();
    try {
      await _parcelRepo.confirmDeliveryOtp(selected!.id, otp);
      selected = selected!.copyWith(status: ParcelStatus.delivered);
      detailState = LoadState.success;
      await loadDashboard();
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      detailState = LoadState.error;
      notifyListeners();
      return false;
    }
  }

  double get historyTotal {
    final delivered = history.where((p) => p.status == ParcelStatus.delivered);
    return delivered.fold<double>(0, (sum, p) => sum + (p.payout ?? 0));
  }
}

import 'package:flutter/foundation.dart';
import '../models/earnings_model.dart';
import '../models/parcel_model.dart';
import '../services/repositories.dart';

enum LoadState { idle, loading, error, success }

class ParcelProvider extends ChangeNotifier {
  ParcelProvider(this._parcelRepo, this._earningsRepo, this._profileRepo);

  final ParcelRepository _parcelRepo;
  final EarningsRepository _earningsRepo;
  final ProfileRepository _profileRepo;

  LoadState assignedState = LoadState.idle;
  LoadState historyState = LoadState.idle;
  LoadState detailState = LoadState.idle;
  String? error;

  List<ParcelModel> assigned = [];
  List<ParcelModel> history = [];
  ParcelModel? selected;
  DashboardStats? dashboardStats;
  bool isOnline = false;
  bool presenceUpdating = false;

  String historyQuery = '';
  String historyPeriod = 'daily';
  bool loadingMore = false;
  int _historyPage = 1;
  int historyTotalCount = 0;

  bool get hasMoreHistory => history.length < historyTotalCount;

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

  /// Seeds the presence toggle from the server-side profile state.
  void syncOnline(bool value) {
    if (isOnline == value) return;
    isOnline = value;
    notifyListeners();
  }

  /// Persists presence via `PATCH /courier/presence`. Returns the server
  /// message when the request is rejected (e.g. KYC pending), null on success.
  Future<String?> setOnline(bool value) async {
    presenceUpdating = true;
    notifyListeners();
    try {
      isOnline = await _profileRepo.setPresence(value);
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      presenceUpdating = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory({String? query, String? period}) async {
    historyState = LoadState.loading;
    error = null;
    if (query != null) historyQuery = query;
    if (period != null) historyPeriod = period;
    _historyPage = 1;
    notifyListeners();
    try {
      final page = await _parcelRepo.getParcelHistory(
        query: historyQuery,
        period: historyPeriod,
        page: _historyPage,
      );
      history = page.items;
      historyTotalCount = page.total;
      historyState = LoadState.success;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      historyState = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadMoreHistory() async {
    if (loadingMore || !hasMoreHistory) return;
    loadingMore = true;
    notifyListeners();
    try {
      final page = await _parcelRepo.getParcelHistory(
        query: historyQuery,
        period: historyPeriod,
        page: _historyPage + 1,
      );
      _historyPage += 1;
      history = [...history, ...page.items];
      historyTotalCount = page.total;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
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

  Future<bool> confirmPickup(String otp) => _transition(() async {
    selected = await _parcelRepo.confirmPickupOtp(selected!.id, otp);
  });

  Future<bool> confirmDelivery(String otp) => _transition(() async {
    selected = await _parcelRepo.confirmDeliveryOtp(selected!.id, otp);
  });

  Future<bool> markFailed(String reason) => _transition(() async {
    selected = await _parcelRepo.markFailed(selected!.id, reason);
  });

  /// Moves a picked-up parcel to in-transit; a no-op for other statuses.
  Future<void> startTransitIfNeeded() async {
    final parcel = selected;
    if (parcel == null || parcel.status != ParcelStatus.pickedUp) return;
    try {
      selected = await _parcelRepo.startTransit(parcel.id);
      notifyListeners();
    } catch (_) {
      // Transit state is cosmetic for navigation; delivery OTP still works
      // from picked_up, so a failed transition is not surfaced as an error.
    }
  }

  Future<bool> uploadProof({required String type, required String filePath}) async {
    final parcel = selected;
    if (parcel == null) return false;
    try {
      await _parcelRepo.uploadProof(parcel.id, type: type, filePath: filePath);
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  double get historyTotal {
    final delivered = history.where((p) => p.status == ParcelStatus.delivered);
    return delivered.fold<double>(0, (sum, p) => sum + (p.payout ?? 0));
  }

  Future<bool> _transition(Future<void> Function() action) async {
    if (selected == null) return false;
    detailState = LoadState.loading;
    notifyListeners();
    try {
      await action();
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
}

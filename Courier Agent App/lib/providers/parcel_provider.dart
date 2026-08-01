import 'package:flutter/foundation.dart';
import '../models/earnings_model.dart';
import '../models/parcel_model.dart';
import '../services/api/api_client.dart';
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
  double? _serverHistoryEarnings;

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
      _serverHistoryEarnings = page.totalEarnings;
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
      if (page.totalEarnings != null) {
        _serverHistoryEarnings = page.totalEarnings;
      }
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loadingMore = false;
      notifyListeners();
    }
  }

  /// When the assigned list is loaded, only allow IDs in assigned or history.
  bool canAccessParcel(String id) {
    if (assignedState != LoadState.success) return true;
    if (selected?.id == id) return true;
    if (assigned.any((p) => p.id == id)) return true;
    if (history.any((p) => p.id == id)) return true;
    return false;
  }

  String get _accessDeniedMessage =>
      'This parcel is not available on your account.';

  String _friendlyApiError(Object e) {
    if (e is ApiException && (e.statusCode == 403 || e.statusCode == 404)) {
      return 'This parcel was not found or you do not have access to it.';
    }
    return e.toString().replaceFirst('Exception: ', '');
  }

  Future<void> loadParcel(String id) async {
    detailState = LoadState.loading;
    error = null;
    notifyListeners();
    if (!canAccessParcel(id)) {
      error = _accessDeniedMessage;
      detailState = LoadState.error;
      notifyListeners();
      return;
    }
    try {
      selected = await _parcelRepo.getParcelById(id);
      detailState = LoadState.success;
    } catch (e) {
      error = _friendlyApiError(e);
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
    if (!canAccessParcel(parcel.id)) {
      error = _accessDeniedMessage;
      notifyListeners();
      return;
    }
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
    if (!canAccessParcel(parcel.id)) {
      error = _accessDeniedMessage;
      notifyListeners();
      return false;
    }
    try {
      await _parcelRepo.uploadProof(parcel.id, type: type, filePath: filePath);
      return true;
    } catch (e) {
      error = _friendlyApiError(e);
      notifyListeners();
      return false;
    }
  }

  /// Prefers a server-reported history earnings total when available.
  double get historyTotal {
    if (_serverHistoryEarnings != null) return _serverHistoryEarnings!;
    final delivered = history.where((p) => p.status == ParcelStatus.delivered);
    return delivered.fold<double>(0, (sum, p) => sum + (p.payout ?? 0));
  }

  Future<bool> _transition(Future<void> Function() action) async {
    if (selected == null) return false;
    if (!canAccessParcel(selected!.id)) {
      error = _accessDeniedMessage;
      detailState = LoadState.error;
      notifyListeners();
      return false;
    }
    detailState = LoadState.loading;
    notifyListeners();
    try {
      await action();
      detailState = LoadState.success;
      await loadDashboard();
      notifyListeners();
      return true;
    } catch (e) {
      error = _friendlyApiError(e);
      detailState = LoadState.error;
      notifyListeners();
      return false;
    }
  }
}

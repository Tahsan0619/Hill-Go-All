import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api/api_client.dart';
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
  String historyFilter = 'all'; // all | completed | cancelled | cod
  int selectedWeekDay = DateTime.now().weekday % 7;
  DateTime? _lastLocationSentAt;

  int _historyPage = 1;
  bool historyHasMore = false;
  bool isLoadingMoreHistory = false;

  Future<void> loadDashboard() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      earnings = await _repo.getEarnings();
      final page = await _repo.getTripHistory(query: historyQuery, filter: historyFilter, page: 1);
      history = page.items;
      _historyPage = page.page;
      historyHasMore = page.hasMore;
      payouts = await _repo.getPayouts();
      // Always re-sync from server — a bot/other client may have accepted work
      // while this UI still thought the rider was idle.
      activeTrip = await _repo.getActiveTrip();
      if (activeTrip != null) {
        incomingOffer = null;
      } else if (isOnline) {
        incomingOffer = await _repo.getIncomingOffer();
      }
    } on ApiException catch (e) {
      error = e.message;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Restore presence from GET /rider/me so polling resumes after app restart.
  void restoreOnlineFromProfile(bool online) {
    if (isOnline == online) return;
    isOnline = online;
    if (!isOnline) incomingOffer = null;
    notifyListeners();
  }

  Future<void> refreshHistory() async {
    isLoading = true;
    notifyListeners();
    try {
      final page = await _repo.getTripHistory(query: historyQuery, filter: historyFilter, page: 1);
      history = page.items;
      _historyPage = page.page;
      historyHasMore = page.hasMore;
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Appends the next page to [history]. No-op while already loading or
  /// when the server reports no further pages.
  Future<void> loadMoreHistory() async {
    if (isLoadingMoreHistory || !historyHasMore) return;
    isLoadingMoreHistory = true;
    notifyListeners();
    try {
      final page = await _repo.getTripHistory(
        query: historyQuery,
        filter: historyFilter,
        page: _historyPage + 1,
      );
      history = [...history, ...page.items];
      _historyPage = page.page;
      historyHasMore = page.hasMore;
    } catch (_) {
      // Keep the current list on transient failure; the Load more control
      // simply remains available for the rider to retry.
    } finally {
      isLoadingMoreHistory = false;
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

  /// Calls POST /rider/presence. Returns false (with [error] set) when the
  /// backend refuses — e.g. KYC not verified yet.
  Future<bool> toggleOnline(bool value) async {
    error = null;
    isLoading = true;
    notifyListeners();
    try {
      isOnline = await _repo.setPresence(value);
      if (!isOnline) incomingOffer = null;
      notifyListeners();
      if (isOnline && activeTrip == null) {
        incomingOffer = await _repo.getIncomingOffer();
      }
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Lightweight poll of GET /rider/offers/current while online.
  /// Also re-checks active trip so a stuck accept elsewhere cannot block offers forever.
  Future<void> refreshOffer() async {
    if (!isOnline) return;
    try {
      activeTrip = await _repo.getActiveTrip();
      if (activeTrip != null) {
        incomingOffer = null;
        notifyListeners();
        return;
      }
      incomingOffer = await _repo.getIncomingOffer();
      notifyListeners();
    } catch (_) {
      // Transient polling failure — keep the current state.
    }
  }

  /// Reports the rider's live position to POST /rider/location (throttled).
  Future<void> reportLocation(double lat, double lng) async {
    final now = DateTime.now();
    if (_lastLocationSentAt != null &&
        now.difference(_lastLocationSentAt!) < const Duration(seconds: 10)) {
      return;
    }
    _lastLocationSentAt = now;
    try {
      await _repo.updateLocation(lat, lng);
    } catch (_) {
      // Location reporting is best-effort.
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
    } on ApiException catch (e) {
      error = e.message;
      if (e.statusCode == 422) incomingOffer = null; // offer expired/taken
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
    } on ApiException {
      incomingOffer = null; // already expired server-side
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
        await refreshOffer();
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

  /// Re-checks the server active trip while navigating.
  /// Returns `true` when the local active trip was cancelled remotely
  /// (e.g. customer cancelled after the rider accepted).
  /// Does not clear [activeTrip] — call [clearActiveTrip] after the rider acknowledges.
  Future<bool> syncActiveTripCancel() async {
    final local = activeTrip;
    if (local == null) return false;
    try {
      final remote = await _repo.getActiveTrip();
      if (remote != null) {
        if (remote.id == local.id && remote.status != local.status) {
          activeTrip = remote;
          notifyListeners();
        }
        return false;
      }

      final byId = await _repo.getTripById(local.id);
      return byId == null || byId.status == TripStatus.cancelled;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearActiveTrip() async {
    if (activeTrip == null) return;
    activeTrip = null;
    notifyListeners();
    if (isOnline) {
      await refreshOffer();
    }
  }

  Future<bool> _updateStatus(TripStatus status) async {
    if (activeTrip == null) return false;
    isLoading = true;
    notifyListeners();
    try {
      activeTrip = await _repo.updateTripStatus(activeTrip!.id, status);
      error = null;
      return true;
    } on ApiException catch (e) {
      // Customer may have cancelled while the rider was mid-job.
      final cancelled = await syncActiveTripCancel();
      if (cancelled) {
        error = 'Ride cancelled by the customer.';
      } else {
        error = e.message;
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Trip?> getTrip(String id) => _repo.getTripById(id);

  Future<bool> cashOut(double amount, String method) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _repo.requestCashOut(amount, method: method);
      earnings = await _repo.getEarnings();
      payouts = await _repo.getPayouts();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String formatOnlineDuration() {
    final d = earnings?.onlineDuration ?? Duration.zero;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }
}

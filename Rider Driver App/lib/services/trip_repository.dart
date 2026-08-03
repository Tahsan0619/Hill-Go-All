import '../models/models.dart';
import '../models/paged_result.dart';

abstract class TripRepository {
  Future<EarningsSummary> getEarnings();

  /// [page] is 1-indexed. Callers accumulate [PagedResult.items] across
  /// pages while [PagedResult.hasMore] is true to implement load-more.
  Future<PagedResult<Trip>> getTripHistory({
    String query = '',
    String filter = 'all',
    int page = 1,
  });
  Future<Trip?> getTripById(String id);
  Future<Trip?> getActiveTrip();
  Future<Trip?> getIncomingOffer();
  Future<Trip> acceptTrip(String id);
  Future<void> declineTrip(String id);
  Future<Trip> updateTripStatus(String id, TripStatus status);
  Future<List<PayoutRecord>> getPayouts();
  Future<void> requestCashOut(double amount, {required String method});

  /// Returns the server-confirmed online state.
  Future<bool> setPresence(bool online);
  Future<void> updateLocation(double lat, double lng);
}

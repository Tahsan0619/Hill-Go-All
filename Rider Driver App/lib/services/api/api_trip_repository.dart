import '../../models/models.dart';
import '../../models/paged_result.dart';
import '../trip_repository.dart';
import 'api_client.dart';

/// Rider work + money endpoints against the HillGo Laravel backend.
class ApiTripRepository implements TripRepository {
  ApiTripRepository(this._client);

  final ApiClient _client;

  /// The trip shape returned by accept/advance omits the customer block that
  /// only the offer shape includes, so remember it per trip and re-attach.
  final Map<String, Map<String, dynamic>> _customerByTripId = {};

  Trip _mapTrip(Map<String, dynamic> json) {
    final id = json['id'].toString();
    if (json['customer'] is Map<String, dynamic>) {
      _customerByTripId[id] = json['customer'] as Map<String, dynamic>;
    } else if (_customerByTripId.containsKey(id)) {
      json = {...json, 'customer': _customerByTripId[id]};
    }
    return Trip.fromJson(json);
  }

  @override
  Future<EarningsSummary> getEarnings() async {
    final json = await _client.get('/rider/earnings');
    return EarningsSummary.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<PagedResult<Trip>> getTripHistory({
    String query = '',
    String filter = 'all',
    int page = 1,
  }) async {
    final json = await _client.get('/rider/trips', query: {
      'filter': filter,
      'per_page': '50',
      'page': '$page',
      if (query.trim().isNotEmpty) 'q': query.trim(),
    }) as Map<String, dynamic>;
    return PagedResult.parse(json, (t) => _mapTrip(t));
  }

  @override
  Future<Trip?> getTripById(String id) async {
    try {
      final json = await _client.get('/rider/trips/$id');
      return _mapTrip(json as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 403) return null;
      rethrow;
    }
  }

  @override
  Future<Trip?> getActiveTrip() async {
    final json = await _client.get('/rider/trips/active') as Map<String, dynamic>;
    final trip = json['trip'];
    return trip == null ? null : _mapTrip(trip as Map<String, dynamic>);
  }

  @override
  Future<Trip?> getIncomingOffer() async {
    final json = await _client.get('/rider/offers/current') as Map<String, dynamic>;
    final offer = json['offer'];
    return offer == null ? null : _mapTrip(offer as Map<String, dynamic>);
  }

  @override
  Future<Trip> acceptTrip(String id) async {
    final json = await _client.post('/rider/offers/$id/accept');
    return _mapTrip(json as Map<String, dynamic>);
  }

  @override
  Future<void> declineTrip(String id) async {
    await _client.post('/rider/offers/$id/decline');
  }

  @override
  Future<Trip> updateTripStatus(String id, TripStatus status) async {
    if (status == TripStatus.cancelled) {
      final json = await _client.post('/rider/trips/$id/status', body: {
        'status': 'cancelled',
      });
      return _mapTrip(json as Map<String, dynamic>);
    }

    var json = await _client.post('/rider/trips/$id/advance');
    var trip = _mapTrip(json as Map<String, dynamic>);
    // The app treats "arrived" as one tap after accepting a ride while the
    // backend machine has an intermediate "arriving" step — advance through it.
    if (status == TripStatus.arrived && trip.status == TripStatus.arriving) {
      json = await _client.post('/rider/trips/$id/advance');
      trip = _mapTrip(json as Map<String, dynamic>);
    }
    return trip;
  }

  @override
  Future<List<PayoutRecord>> getPayouts() async {
    final json = await _client.get('/rider/payouts', query: {
      'per_page': '50',
    }) as Map<String, dynamic>;
    return (json['data'] as List<dynamic>)
        .map((p) => PayoutRecord.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> requestCashOut(double amount, {required String method}) async {
    await _client.post('/rider/payouts/cash-out', body: {
      'amount': amount,
      'method': method,
    });
  }

  @override
  Future<bool> setPresence(bool online) async {
    final json = await _client.post('/rider/presence', body: {'online': online});
    return (json as Map<String, dynamic>)['online'] as bool? ?? false;
  }

  @override
  Future<void> updateLocation(double lat, double lng) async {
    await _client.post('/rider/location', body: {'lat': lat, 'lng': lng});
  }
}

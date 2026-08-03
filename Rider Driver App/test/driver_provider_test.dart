import 'package:flutter_test/flutter_test.dart';
import 'package:rider_driver_app/models/models.dart';
import 'package:rider_driver_app/models/paged_result.dart';
import 'package:rider_driver_app/providers/driver_provider.dart';
import 'package:rider_driver_app/services/api/api_client.dart';
import 'package:rider_driver_app/services/trip_repository.dart';

/// In-memory [TripRepository] double so [DriverProvider] logic (accept
/// flow, location throttling) can be unit tested without hitting the
/// network.
class FakeTripRepository implements TripRepository {
  Trip? activeTripToReturn;
  Trip? offerToReturn;

  /// When set, [acceptTrip] throws this instead of returning [acceptResult].
  Object? acceptError;
  Trip? acceptResult;

  int updateLocationCallCount = 0;
  final List<List<double>> updateLocationCalls = [];

  @override
  Future<EarningsSummary> getEarnings() async => EarningsSummary(
        todayTotal: 0,
        todayTrips: 0,
        onlineDuration: Duration.zero,
        todayTrendPercent: 0,
        currentBalance: 0,
        weekTrendPercent: 0,
        baseFare: 0,
        tips: 0,
        surgeBonuses: 0,
        dailyTotals: List<double>.filled(7, 0),
      );

  @override
  Future<PagedResult<Trip>> getTripHistory({
    String query = '',
    String filter = 'all',
    int page = 1,
  }) async =>
      const PagedResult(items: [], page: 1, hasMore: false);

  @override
  Future<Trip?> getTripById(String id) async => null;

  @override
  Future<Trip?> getActiveTrip() async => activeTripToReturn;

  @override
  Future<Trip?> getIncomingOffer() async => offerToReturn;

  @override
  Future<Trip> acceptTrip(String id) async {
    final error = acceptError;
    if (error != null) throw error;
    return acceptResult!;
  }

  @override
  Future<void> declineTrip(String id) async {}

  @override
  Future<Trip> updateTripStatus(String id, TripStatus status) async => acceptResult!;

  @override
  Future<List<PayoutRecord>> getPayouts() async => [];

  @override
  Future<void> requestCashOut(double amount, {required String method}) async {}

  @override
  Future<bool> setPresence(bool online) async => online;

  @override
  Future<void> updateLocation(double lat, double lng) async {
    updateLocationCallCount++;
    updateLocationCalls.add([lat, lng]);
  }
}

Trip _buildTrip({
  String id = 'trip-1',
  TripStatus status = TripStatus.requested,
  JobType jobType = JobType.ride,
}) {
  return Trip(
    id: id,
    jobType: jobType,
    pickupName: 'Gulshan 1',
    pickupAddress: 'Road 11, Gulshan',
    dropoffName: 'Banani',
    dropoffAddress: 'Road 27, Banani',
    distanceKm: 5.2,
    durationMin: 18,
    earning: 150,
    status: status,
    createdAt: DateTime(2026, 1, 1, 10, 30),
    customerName: 'Rahim',
    customerPhone: '01700000000',
    customerRating: 4.7,
  );
}

void main() {
  group('DriverProvider.acceptOffer (trip accept flow)', () {
    test('accepts the incoming offer and moves it to activeTrip on success', () async {
      final repo = FakeTripRepository();
      final provider = DriverProvider(repo);
      final offer = _buildTrip(id: 'offer-1', status: TripStatus.requested);
      final accepted = _buildTrip(id: 'offer-1', status: TripStatus.accepted);
      provider.incomingOffer = offer;
      repo.acceptResult = accepted;

      final ok = await provider.acceptOffer();

      expect(ok, isTrue);
      expect(provider.activeTrip?.id, 'offer-1');
      expect(provider.activeTrip?.status, TripStatus.accepted);
      expect(provider.incomingOffer, isNull);
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
    });

    test('clears the expired offer and surfaces the error on a 422 response', () async {
      final repo = FakeTripRepository();
      final provider = DriverProvider(repo);
      provider.incomingOffer = _buildTrip(id: 'offer-2');
      repo.acceptError = ApiException(422, 'Offer already taken');

      final ok = await provider.acceptOffer();

      expect(ok, isFalse);
      expect(provider.incomingOffer, isNull, reason: '422 means the offer is gone server-side');
      expect(provider.error, 'Offer already taken');
      expect(provider.activeTrip, isNull);
    });

    test('keeps the offer visible so the rider can retry on a non-422 failure', () async {
      final repo = FakeTripRepository();
      final provider = DriverProvider(repo);
      final offer = _buildTrip(id: 'offer-3');
      provider.incomingOffer = offer;
      repo.acceptError = ApiException(500, 'Server error');

      final ok = await provider.acceptOffer();

      expect(ok, isFalse);
      expect(provider.incomingOffer, same(offer));
      expect(provider.error, 'Server error');
    });

    test('returns false with no offer to accept', () async {
      final repo = FakeTripRepository();
      final provider = DriverProvider(repo);

      final ok = await provider.acceptOffer();

      expect(ok, isFalse);
      expect(repo.updateLocationCallCount, 0);
    });
  });

  group('DriverProvider.reportLocation (10s throttle)', () {
    test('the first call always reports to the repository', () async {
      final repo = FakeTripRepository();
      final provider = DriverProvider(repo);

      await provider.reportLocation(23.81, 90.41);

      expect(repo.updateLocationCallCount, 1);
      expect(repo.updateLocationCalls.single, [23.81, 90.41]);
    });

    test('an immediate second call within the 10s window is suppressed', () async {
      final repo = FakeTripRepository();
      final provider = DriverProvider(repo);

      await provider.reportLocation(23.81, 90.41);
      await provider.reportLocation(23.82, 90.42); // fires well under 10s later

      expect(repo.updateLocationCallCount, 1,
          reason: 'second call is inside the 10s throttle window and must be dropped');
    });

    test('repeated rapid calls only ever report once until the throttle window elapses', () async {
      final repo = FakeTripRepository();
      final provider = DriverProvider(repo);

      for (var i = 0; i < 5; i++) {
        await provider.reportLocation(23.8 + i * 0.001, 90.4 + i * 0.001);
      }

      expect(repo.updateLocationCallCount, 1);
    });
  });
}

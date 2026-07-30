import 'dart:async';
import 'dart:math';

import '../../models/models.dart';
import '../fare_config.dart';
import '../trip_repository.dart';

class TripException implements Exception {
  TripException(this.message);
  final String message;
  @override
  String toString() => message;
}

class MockTripRepository implements TripRepository {
  MockTripRepository() {
    _seed();
  }

  final _random = Random();
  late List<Trip> _trips;
  Trip? _incoming;
  late EarningsSummary _earnings;
  late List<PayoutRecord> _payouts;
  bool _cashOutFailOnce = false;
  Timer? _respawnTimer;

  Duration get _latency => Duration(milliseconds: 350 + _random.nextInt(750));

  void _seed() {
    final now = DateTime.now();
    _trips = [
      Trip(
        id: 't1',
        jobType: JobType.ride,
        pickupName: 'Gulshan 1',
        pickupAddress: 'Road 53, Gulshan 1, Dhaka',
        dropoffName: 'Bashundhara City',
        dropoffAddress: 'Panthapath, Dhaka',
        distanceKm: 7.2,
        durationMin: 22,
        earning: calculateRideFare(
          distanceKm: 7.2,
          durationMin: 22,
          vehicle: VehicleCategory.car,
        ),
        tip: 20,
        status: TripStatus.completed,
        createdAt: now.subtract(const Duration(hours: 1)),
        customerName: 'Nusrat Jahan',
        customerPhone: '+8801711001100',
        customerRating: 4.9,
        customerTier: 'Gold',
        vehicleRequired: VehicleCategory.car,
        paymentMethod: PaymentMethod.digital,
        pickupLat: 23.7805,
        pickupLng: 90.4160,
        dropoffLat: 23.7508,
        dropoffLng: 90.3910,
      ),
      Trip(
        id: 't2',
        jobType: JobType.food,
        pickupName: 'KFC Banani',
        pickupAddress: 'Road 11, Banani, Dhaka',
        dropoffName: 'Apartment 4B',
        dropoffAddress: 'House 12, Road 4, Dhanmondi',
        distanceKm: 5.4,
        durationMin: 18,
        earning: calculateFoodFare(),
        status: TripStatus.completed,
        createdAt: now.subtract(const Duration(hours: 2)),
        customerName: 'Rafi Ahmed',
        customerPhone: '+8801811223344',
        customerRating: 4.7,
        paymentMethod: PaymentMethod.cash,
        note: 'Collect ৳430 COD (food + delivery)',
        pickupLat: 23.7937,
        pickupLng: 90.4066,
        dropoffLat: 23.7461,
        dropoffLng: 90.3742,
      ),
      Trip(
        id: 't3',
        jobType: JobType.parcel,
        pickupName: 'Mirpur DOHS',
        pickupAddress: 'Road 9, Mirpur DOHS, Dhaka',
        dropoffName: 'Uttara Sector 7',
        dropoffAddress: 'Road 12, Sector 7, Uttara',
        distanceKm: 9.5,
        durationMin: 28,
        earning: calculateParcelFare(distanceKm: 9.5, weightKg: 2),
        status: TripStatus.completed,
        createdAt: now.subtract(const Duration(hours: 4)),
        customerName: 'Farhana Islam',
        customerPhone: '+8801912345678',
        customerRating: 4.8,
        weightKg: 2,
        packageLabel: '2 kg documents',
        paymentMethod: PaymentMethod.digital,
        pickupLat: 23.8375,
        pickupLng: 90.3675,
        dropoffLat: 23.8740,
        dropoffLng: 90.4000,
      ),
      Trip(
        id: 't4',
        jobType: JobType.ride,
        pickupName: 'Motijheel',
        pickupAddress: 'Dilkhusha, Motijheel, Dhaka',
        dropoffName: 'Farmgate',
        dropoffAddress: 'Kazi Nazrul Islam Ave, Farmgate',
        distanceKm: 4.1,
        durationMin: 16,
        earning: calculateRideFare(
          distanceKm: 4.1,
          durationMin: 16,
          vehicle: VehicleCategory.bike,
        ),
        tip: 10,
        status: TripStatus.completed,
        createdAt: now.subtract(const Duration(hours: 5)),
        customerName: 'Karim Hossain',
        customerPhone: '+8801611112222',
        customerRating: 4.6,
        vehicleRequired: VehicleCategory.bike,
        paymentMethod: PaymentMethod.cash,
        note: 'Collect ৳88 COD',
        pickupLat: 23.7330,
        pickupLng: 90.4172,
        dropoffLat: 23.7563,
        dropoffLng: 90.3900,
      ),
      Trip(
        id: 't5',
        jobType: JobType.ride,
        pickupName: 'Banani',
        pickupAddress: 'Kemal Ataturk Ave, Banani',
        dropoffName: 'Airport',
        dropoffAddress: 'Hazrat Shahjalal International Airport',
        distanceKm: 11.0,
        durationMin: 35,
        earning: calculateRideFare(
          distanceKm: 11,
          durationMin: 35,
          vehicle: VehicleCategory.xl,
        ),
        status: TripStatus.completed,
        createdAt: now.subtract(const Duration(hours: 7)),
        customerName: 'Samira Khan',
        customerPhone: '+8801555667788',
        customerRating: 5.0,
        customerTier: 'Platinum',
        vehicleRequired: VehicleCategory.xl,
        paymentMethod: PaymentMethod.digital,
        pickupLat: 23.7936,
        pickupLng: 90.4043,
        dropoffLat: 23.8433,
        dropoffLng: 90.3978,
      ),
      Trip(
        id: 't6',
        jobType: JobType.food,
        pickupName: 'Pizza Hut Dhanmondi',
        pickupAddress: 'Road 27, Dhanmondi, Dhaka',
        dropoffName: 'Lalmatia',
        dropoffAddress: 'Block D, Lalmatia, Dhaka',
        distanceKm: 2.8,
        durationMin: 12,
        earning: calculateFoodFare(),
        status: TripStatus.cancelled,
        createdAt: now.subtract(const Duration(days: 1)),
        customerName: 'Imran Ali',
        customerPhone: '+8801700001111',
        customerRating: 4.4,
        paymentMethod: PaymentMethod.digital,
        pickupLat: 23.7465,
        pickupLng: 90.3760,
        dropoffLat: 23.7540,
        dropoffLng: 90.3685,
      ),
    ];

    _incoming = _buildRideOffer();

    _earnings = EarningsSummary(
      todayTotal: 2840,
      todayTrips: 14,
      onlineDuration: const Duration(hours: 6, minutes: 12),
      todayTrendPercent: 12,
      currentBalance: 12480,
      weekTrendPercent: 12,
      baseFare: 8420,
      tips: 314,
      surgeBonuses: 0,
      dailyTotals: [960, 1120, 880, 1450, 1300, 1560, 1840],
    );

    _payouts = [
      PayoutRecord(
        id: 'p1',
        amount: 4200,
        date: now.subtract(const Duration(days: 2)),
        method: 'bKash ••4821',
        status: 'Paid',
      ),
      PayoutRecord(
        id: 'p2',
        amount: 3850,
        date: now.subtract(const Duration(days: 9)),
        method: 'Nagad ••1190',
        status: 'Paid',
      ),
      PayoutRecord(
        id: 'p3',
        amount: 5120,
        date: now.subtract(const Duration(days: 16)),
        method: 'bKash ••4821',
        status: 'Paid',
      ),
    ];
  }

  Trip _buildRideOffer() {
    const km = 5.0;
    const mins = 20;
    return Trip(
      id: 'offer-ride-1',
      jobType: JobType.ride,
      pickupName: 'Gulshan 2 Circle',
      pickupAddress: 'Gulshan Avenue, Gulshan 2, Dhaka',
      dropoffName: 'Badda Link Road',
      dropoffAddress: 'Progati Sarani, Badda, Dhaka',
      distanceKm: km,
      durationMin: mins,
      earning: calculateRideFare(
        distanceKm: km,
        durationMin: mins,
        vehicle: VehicleCategory.car,
      ),
      status: TripStatus.requested,
      createdAt: DateTime.now(),
      customerName: 'Marcus Thompson',
      customerPhone: '+8801712345678',
      customerRating: 4.9,
      customerTier: 'Gold',
      vehicleRequired: VehicleCategory.car,
      paymentMethod: PaymentMethod.cash,
      note: 'Collect ৳125 COD at drop-off',
      pickupLat: 23.7925,
      pickupLng: 90.4078,
      dropoffLat: 23.7808,
      dropoffLng: 90.4264,
    );
  }

  Trip _buildFoodOffer() {
    return Trip(
      id: 'offer-food-1',
      jobType: JobType.food,
      pickupName: 'Burger King Banani',
      pickupAddress: 'Road 11, Banani, Dhaka',
      dropoffName: 'Mohakhali DOHS',
      dropoffAddress: 'Road 6, Mohakhali DOHS, Dhaka',
      distanceKm: 3.2,
      durationMin: 14,
      earning: calculateFoodFare(),
      status: TripStatus.requested,
      createdAt: DateTime.now(),
      customerName: 'Sofia Alvarez',
      customerPhone: '+8801899887766',
      customerRating: 4.8,
      customerTier: 'Silver',
      paymentMethod: PaymentMethod.cash,
      note: 'Collect ৳520 COD (order + delivery)',
      pickupLat: 23.7937,
      pickupLng: 90.4066,
      dropoffLat: 23.7800,
      dropoffLng: 90.3950,
    );
  }

  Trip _buildParcelOffer() {
    const km = 6.5;
    const kg = 1.5;
    return Trip(
      id: 'offer-parcel-1',
      jobType: JobType.parcel,
      pickupName: 'Elephant Road',
      pickupAddress: 'New Elephant Road, Dhaka',
      dropoffName: 'Rampura',
      dropoffAddress: 'TV Center Road, Rampura, Dhaka',
      distanceKm: km,
      durationMin: 21,
      earning: calculateParcelFare(distanceKm: km, weightKg: kg),
      status: TripStatus.requested,
      createdAt: DateTime.now(),
      customerName: 'Tanvir Hasan',
      customerPhone: '+8801622334455',
      customerRating: 4.7,
      weightKg: kg,
      packageLabel: '1.5 kg parcel',
      paymentMethod: PaymentMethod.digital,
      pickupLat: 23.7385,
      pickupLng: 90.3860,
      dropoffLat: 23.7600,
      dropoffLng: 90.4205,
    );
  }

  @override
  Future<EarningsSummary> getEarnings() async {
    await Future.delayed(_latency);
    return _earnings;
  }

  @override
  Future<List<Trip>> getTripHistory({String? query, String? filter}) async {
    await Future.delayed(_latency);
    var list = List<Trip>.from(_trips);
    final f = filter ?? 'all';
    if (f == 'completed') {
      list = list.where((t) => t.status == TripStatus.completed).toList();
    } else if (f == 'cancelled') {
      list = list.where((t) => t.status == TripStatus.cancelled).toList();
    } else if (f == 'cod') {
      list = list.where((t) => t.isCod).toList();
    } else if (f == 'ride') {
      list = list.where((t) => t.jobType == JobType.ride).toList();
    } else if (f == 'food') {
      list = list.where((t) => t.jobType == JobType.food).toList();
    } else if (f == 'parcel') {
      list = list.where((t) => t.jobType == JobType.parcel).toList();
    }
    final q = query?.trim().toLowerCase() ?? '';
    if (q.isNotEmpty) {
      list = list
          .where(
            (t) =>
                t.pickupName.toLowerCase().contains(q) ||
                t.dropoffName.toLowerCase().contains(q) ||
                t.customerName.toLowerCase().contains(q) ||
                t.jobType.label.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  @override
  Future<Trip?> getTripById(String id) async {
    await Future.delayed(_latency);
    try {
      return _trips.firstWhere((t) => t.id == id);
    } catch (_) {
      if (_incoming?.id == id) return _incoming;
      return null;
    }
  }

  @override
  Future<Trip?> getIncomingOffer() async {
    await Future.delayed(_latency);
    return _incoming;
  }

  @override
  Future<Trip> acceptTrip(String id) async {
    await Future.delayed(_latency);
    final offer = _incoming;
    if (offer == null || offer.id != id) {
      throw TripException('Offer no longer available');
    }
    offer.status = switch (offer.jobType) {
      JobType.ride => TripStatus.arriving,
      JobType.food || JobType.parcel => TripStatus.accepted,
    };
    return offer;
  }

  @override
  Future<void> declineTrip(String id) async {
    await Future.delayed(_latency);
    if (_incoming?.id == id) {
      _incoming = null;
      _scheduleNextOffer();
    }
  }

  void _scheduleNextOffer() {
    _respawnTimer?.cancel();
    _respawnTimer = Timer(const Duration(seconds: 6), () {
      final roll = _random.nextInt(3);
      _incoming = switch (roll) {
        0 => _buildRideOffer(),
        1 => _buildFoodOffer(),
        _ => _buildParcelOffer(),
      };
    });
  }

  @override
  Future<Trip> updateTripStatus(String id, TripStatus status) async {
    await Future.delayed(_latency);
    final trip = _incoming?.id == id
        ? _incoming!
        : _trips.firstWhere(
            (t) => t.id == id,
            orElse: () => throw TripException('Trip not found'),
          );
    trip.status = status;
    if (status == TripStatus.completed) {
      if (!_trips.any((t) => t.id == trip.id)) {
        _trips.insert(0, trip);
      }
      _earnings = EarningsSummary(
        todayTotal: _earnings.todayTotal + trip.earning + trip.tip,
        todayTrips: _earnings.todayTrips + 1,
        onlineDuration: _earnings.onlineDuration,
        todayTrendPercent: _earnings.todayTrendPercent,
        currentBalance: _earnings.currentBalance + trip.earning + trip.tip,
        weekTrendPercent: _earnings.weekTrendPercent,
        baseFare: _earnings.baseFare + trip.earning,
        tips: _earnings.tips + trip.tip,
        surgeBonuses: _earnings.surgeBonuses,
        dailyTotals: _earnings.dailyTotals,
      );
      _incoming = null;
      _scheduleNextOffer();
    }
    return trip;
  }

  @override
  Future<List<PayoutRecord>> getPayouts() async {
    await Future.delayed(_latency);
    return List.from(_payouts);
  }

  @override
  Future<void> requestCashOut(double amount, {required bool simulateSuccess}) async {
    await Future.delayed(_latency);
    if (!simulateSuccess || _cashOutFailOnce) {
      _cashOutFailOnce = false;
      throw TripException('Cash-out failed. Try again.');
    }
    if (amount > _earnings.currentBalance) {
      throw TripException('Insufficient balance');
    }
    _earnings = EarningsSummary(
      todayTotal: _earnings.todayTotal,
      todayTrips: _earnings.todayTrips,
      onlineDuration: _earnings.onlineDuration,
      todayTrendPercent: _earnings.todayTrendPercent,
      currentBalance: _earnings.currentBalance - amount,
      weekTrendPercent: _earnings.weekTrendPercent,
      baseFare: _earnings.baseFare,
      tips: _earnings.tips,
      surgeBonuses: _earnings.surgeBonuses,
      dailyTotals: _earnings.dailyTotals,
    );
    _payouts.insert(
      0,
      PayoutRecord(
        id: 'p-${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        date: DateTime.now(),
        method: 'bKash ••4821',
        status: 'Processing',
      ),
    );
  }
}

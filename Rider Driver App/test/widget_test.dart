import 'package:flutter_test/flutter_test.dart';
import 'package:rider_driver_app/models/models.dart';
import 'package:rider_driver_app/models/paged_result.dart';
import 'package:rider_driver_app/services/api/api_auth_repository.dart';

void main() {
  group('ApiAuthRepository.normalizeBdPhone', () {
    test('leaves an already-normalized +880 number unchanged', () {
      expect(ApiAuthRepository.normalizeBdPhone('+8801700000000'), '+8801700000000');
    });

    test('converts a leading-zero local number to +880 form', () {
      expect(ApiAuthRepository.normalizeBdPhone('01700000000'), '+8801700000000');
    });

    test('converts a bare 880-prefixed number', () {
      expect(ApiAuthRepository.normalizeBdPhone('8801700000000'), '+8801700000000');
    });

    test('strips non-digit characters before normalizing', () {
      expect(ApiAuthRepository.normalizeBdPhone('+880 170-000-0000'), '+8801700000000');
    });
  });

  group('Trip.fromJson', () {
    test('maps the accepted-trip backend shape, defaulting missing fields', () {
      final trip = Trip.fromJson({
        'id': 42,
        'type': 'ride',
        'pickup_name': 'Gulshan 1',
        'pickup_address': 'Road 11',
        'drop_name': 'Banani',
        'drop_address': 'Road 27',
        'distance_km': '5.2',
        'duration_min': 18,
        'earning': '150.00',
        'status': 'accepted',
        'created_at': '2026-01-01T10:30:00Z',
        'customer': {'name': 'Rahim', 'phone': '01700000000', 'rating': '4.7'},
      });

      expect(trip.id, '42');
      expect(trip.jobType, JobType.ride);
      expect(trip.status, TripStatus.accepted);
      expect(trip.distanceKm, 5.2);
      expect(trip.earning, 150.0);
      expect(trip.customerName, 'Rahim');
      expect(trip.customerRating, 4.7);
      expect(trip.isCod, isFalse);
    });

    test('falls back to safe defaults for an unrecognized status', () {
      final trip = Trip.fromJson({'id': '1', 'status': 'not_a_real_status'});
      expect(trip.status, TripStatus.completed);
      expect(trip.pickupName, 'Pickup');
      expect(trip.customerName, 'Customer');
    });

    test('marks cash-on-delivery jobs and formats the COD note', () {
      final trip = Trip.fromJson({
        'id': '2',
        'status': 'accepted',
        'payment_method': 'cash',
        'cod_amount': '500',
      });
      expect(trip.isCod, isTrue);
      expect(trip.note, contains('500'));
    });
  });

  group('DriverUser.fromJson onboarding step inference', () {
    test('a brand-new account starts at registration', () {
      final user = DriverUser.fromJson({'id': 1, 'name': 'New Rider', 'phone': '01700000000'});
      expect(user.currentOnboardingStep, OnboardingStep.registration);
      expect(user.onboardingComplete, isFalse);
    });

    test('an account with personal info but no vehicle moves to the vehicle step', () {
      final user = DriverUser.fromJson({
        'id': 2,
        'name': 'Rider',
        'phone': '01700000000',
        'profile': {'legal_name': 'Rider Legal Name'},
      });
      expect(user.currentOnboardingStep, OnboardingStep.vehicle);
    });

    test('a verified account is marked onboarding-complete', () {
      final user = DriverUser.fromJson({
        'id': 3,
        'name': 'Rider',
        'phone': '01700000000',
        'status': 'active',
        'profile': {'legal_name': 'Rider Legal Name', 'kyc_status': 'verified', 'vehicle_make': 'Honda'},
      });
      expect(user.onboardingComplete, isTrue);
      expect(user.currentOnboardingStep, OnboardingStep.verification);
    });
  });

  group('PagedResult.parse', () {
    Map<String, dynamic> row(int id) => {'id': id};

    test('reads Laravel meta pagination and reports hasMore correctly', () {
      final result = PagedResult.parse<int>(
        {
          'data': [row(1), row(2)],
          'meta': {'current_page': 1, 'last_page': 3},
        },
        (j) => j['id'] as int,
      );
      expect(result.items, [1, 2]);
      expect(result.page, 1);
      expect(result.hasMore, isTrue);
    });

    test('reports hasMore false on the last page', () {
      final result = PagedResult.parse<int>(
        {
          'data': [row(1)],
          'meta': {'current_page': 3, 'last_page': 3},
        },
        (j) => j['id'] as int,
      );
      expect(result.hasMore, isFalse);
    });

    test('falls back to a single non-paginated page when no page info is present', () {
      final result = PagedResult.parse<int>(
        {
          'data': [row(1), row(2), row(3)],
        },
        (j) => j['id'] as int,
      );
      expect(result.items.length, 3);
      expect(result.hasMore, isFalse);
      expect(result.page, 1);
    });
  });
}

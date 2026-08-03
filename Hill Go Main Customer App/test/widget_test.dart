import 'package:flutter_test/flutter_test.dart';
import 'package:hillgo/config/fare_config.dart';
import 'package:hillgo/services/auth_service.dart';
import 'package:hillgo/services/fare_service.dart';

/// Smoke tests that avoid importing [main.dart] (HillGoApp pulls broken rental screen).
void main() {
  test('FareService enforces minimum fare', () {
    expect(
      FareService.calculate(distanceKm: 0.1, durationMin: 1),
      FareConfig.minimumFare,
    );
  });

  test('AuthUser.fromJson maps profile fields', () {
    final user = AuthUser.fromJson({
      'id': 1,
      'name': 'Test User',
      'phone': '01700000000',
      'profile': {'tier': 'Silver', 'wallet_balance': 100},
    });
    expect(user.name, 'Test User');
    expect(user.tier, 'Silver');
    expect(user.walletBalance, 100.0);
  });
}

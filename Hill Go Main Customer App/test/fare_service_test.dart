import 'package:flutter_test/flutter_test.dart';
import 'package:hillgo/config/fare_config.dart';
import 'package:hillgo/services/fare_service.dart';

void main() {
  group('FareService.calculate', () {
    test('applies base + distance + duration formula', () {
      // 30 + (10 * 15) + (20 * 1) = 200
      expect(
        FareService.calculate(distanceKm: 10, durationMin: 20),
        200.0,
      );
    });

    test('enforces minimum fare', () {
      // 30 + (0.1 * 15) + (1 * 1) = 32.5 → rounds to 33, below min 50
      expect(
        FareService.calculate(distanceKm: 0.1, durationMin: 1),
        FareConfig.minimumFare,
      );
    });

    test('rounds to nearest taka', () {
      // 30 + (1.1 * 15) + (3 * 1) = 49.5 → minimum 50
      expect(
        FareService.calculate(distanceKm: 1.1, durationMin: 3),
        50.0,
      );
    });
  });
}

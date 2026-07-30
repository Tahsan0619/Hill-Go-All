import '../config/fare_config.dart';

/// Pure fare math — no network calls.
///
/// Fare = Base + (km × rate/km) + (min × rate/min), then apply minimum fare.
class FareService {
  FareService._();

  /// Returns fare in taka (rounded up to whole taka for cleaner UI).
  static double calculate({
    required double distanceKm,
    required double durationMin,
  }) {
    final raw = FareConfig.baseFare +
        (distanceKm * FareConfig.ratePerKm) +
        (durationMin * FareConfig.ratePerMin);

    final withMinimum =
        raw < FareConfig.minimumFare ? FareConfig.minimumFare : raw;

    // Round to nearest taka (common for ride apps).
    return withMinimum.roundToDouble();
  }
}

import '../models/models.dart';

/// Fare rules mirrored from the HillGo customer app (৳ / Dhaka).
class RiderFareConfig {
  RiderFareConfig._();

  static const double baseFare = 30;
  static const double ratePerKm = 15;
  static const double ratePerMin = 1;
  static const double minimumFare = 50;

  static const double bikeMultiplier = 0.7;
  static const double carMultiplier = 1.0;
  static const double xlMultiplier = 1.5;

  /// Food delivery fee shown as the rider job amount (v1).
  static const double foodDeliveryFee = 30;

  /// Parcel ৳ pricing mirrored from the customer app formula.
  static const double parcelBase = 40;
  static const double parcelPerKm = 12;
  static const double parcelPerKg = 8;
  static const double parcelMinimum = 50;

  static double multiplierFor(VehicleCategory category) {
    return switch (category) {
      VehicleCategory.bike => bikeMultiplier,
      VehicleCategory.car => carMultiplier,
      VehicleCategory.xl => xlMultiplier,
    };
  }
}

double calculateRideFare({
  required double distanceKm,
  required num durationMin,
  required VehicleCategory vehicle,
}) {
  final raw = RiderFareConfig.baseFare +
      (distanceKm * RiderFareConfig.ratePerKm) +
      (durationMin.toDouble() * RiderFareConfig.ratePerMin);
  final withMin =
      raw < RiderFareConfig.minimumFare ? RiderFareConfig.minimumFare : raw;
  final rounded = withMin.roundToDouble();
  final scaled =
      (rounded * RiderFareConfig.multiplierFor(vehicle)).roundToDouble();
  return scaled < RiderFareConfig.minimumFare
      ? RiderFareConfig.minimumFare
      : scaled;
}

double calculateFoodFare() => RiderFareConfig.foodDeliveryFee;

double calculateParcelFare({
  required double distanceKm,
  required double weightKg,
}) {
  final raw = RiderFareConfig.parcelBase +
      (distanceKm * RiderFareConfig.parcelPerKm) +
      (weightKg * RiderFareConfig.parcelPerKg);
  final rounded = raw.roundToDouble();
  return rounded < RiderFareConfig.parcelMinimum
      ? RiderFareConfig.parcelMinimum
      : rounded;
}

/// Format whole taka amounts for UI.
String formatTaka(num amount) {
  final v = amount.round();
  final s = v.toString();
  final buf = StringBuffer('৳');
  final neg = s.startsWith('-');
  final digits = neg ? s.substring(1) : s;
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    if (i > 0 && fromEnd % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return neg ? '-$buf' : buf.toString();
}

String formatKm(double km) {
  if (km < 10) return '${km.toStringAsFixed(1)} km';
  return '${km.round()} km';
}

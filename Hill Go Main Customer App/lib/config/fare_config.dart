/// Configurable ride fare rates (Bangladesh Taka).
///
/// Change these values anytime — fare math reads from here, nowhere else.
class FareConfig {
  FareConfig._();

  /// Flat amount charged for every ride.
  static double baseFare = 30.0;

  /// Charge per kilometre of road distance (from OSRM).
  static double ratePerKm = 15.0;

  /// Charge per minute of estimated travel time (from OSRM).
  static double ratePerMin = 1.0;

  /// Lowest fare the rider can be charged (after formula).
  static double minimumFare = 50.0;
}

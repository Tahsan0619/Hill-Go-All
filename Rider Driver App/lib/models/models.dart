enum DocStatus { verified, actionRequired, pending, uploaded }

enum JobType { ride, food, parcel }

enum VehicleCategory { bike, car, xl }

enum PaymentMethod { cash, digital }

enum TripStatus {
  /// Offer waiting for accept/decline.
  requested,

  /// Accepted; food/parcel heading to pickup (next: Picked up).
  accepted,

  /// Ride: en route to customer pickup.
  arriving,

  /// Ride: at pickup (next: Start trip).
  arrived,

  /// Ride: trip in progress to drop.
  inProgress,

  /// Food/parcel: goods collected (food → Delivered; parcel → In transit).
  pickedUp,

  /// Parcel: moving to receiver (next: Delivered).
  inTransit,

  completed,
  cancelled,
}

enum OnboardingStep { registration, personalInfo, vehicle, documents, verification }

extension JobTypeX on JobType {
  String get label => switch (this) {
        JobType.ride => 'Ride',
        JobType.food => 'Food',
        JobType.parcel => 'Parcel',
      };

  String get pickupLabel => switch (this) {
        JobType.ride => 'Pickup',
        JobType.food => 'Restaurant',
        JobType.parcel => 'Sender',
      };

  String get dropLabel => switch (this) {
        JobType.ride => 'Drop-off',
        JobType.food => 'Customer',
        JobType.parcel => 'Receiver',
      };
}

extension VehicleCategoryX on VehicleCategory {
  String get label => switch (this) {
        VehicleCategory.bike => 'Bike',
        VehicleCategory.car => 'Car',
        VehicleCategory.xl => 'XL',
      };
}

class DriverUser {
  DriverUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.photoPath,
    this.rating = 4.9,
    this.vehicle,
    this.onboardingComplete = false,
    this.currentOnboardingStep = OnboardingStep.registration,
  });

  final String id;
  String name;
  String email;
  String phone;
  String? avatarUrl;
  String? photoPath;
  double rating;
  VehicleInfo? vehicle;
  bool onboardingComplete;
  OnboardingStep currentOnboardingStep;

  DriverUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? photoPath,
    double? rating,
    VehicleInfo? vehicle,
    bool? onboardingComplete,
    OnboardingStep? currentOnboardingStep,
  }) {
    return DriverUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      photoPath: photoPath ?? this.photoPath,
      rating: rating ?? this.rating,
      vehicle: vehicle ?? this.vehicle,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      currentOnboardingStep: currentOnboardingStep ?? this.currentOnboardingStep,
    );
  }
}

class VehicleInfo {
  VehicleInfo({
    required this.make,
    required this.model,
    required this.year,
    required this.plate,
    this.category = VehicleCategory.car,
    this.photoPath,
  });

  final String make;
  final String model;
  final String year;
  final String plate;
  final VehicleCategory category;
  final String? photoPath;

  String get displayName => '$year $make $model';
}

class DocumentItem {
  DocumentItem({
    required this.id,
    required this.title,
    required this.status,
    this.localPath,
    this.subtitle,
    this.tokenNumber,
    this.allowsTokenAlternative = false,
    this.description,
  });

  final String id;
  final String title;
  DocStatus status;
  String? localPath;
  String? subtitle;
  /// Token / serial number when rider has no license.
  String? tokenNumber;
  final bool allowsTokenAlternative;
  final String? description;
}

class Trip {
  Trip({
    required this.id,
    required this.jobType,
    required this.pickupName,
    required this.pickupAddress,
    required this.dropoffName,
    required this.dropoffAddress,
    required this.distanceKm,
    required this.durationMin,
    required this.earning,
    required this.status,
    required this.createdAt,
    required this.customerName,
    required this.customerPhone,
    required this.customerRating,
    this.tip = 0,
    this.vehicleRequired,
    this.paymentMethod = PaymentMethod.digital,
    this.weightKg,
    this.packageLabel,
    this.pickupLat = 23.8103,
    this.pickupLng = 90.4125,
    this.dropoffLat = 23.7808,
    this.dropoffLng = 90.4070,
    this.note,
    this.customerTier = 'Member',
    // legacy aliases kept for gradual migration
    this.surgeMultiplier = 1.0,
    this.isPremium = false,
    this.isNightRate = false,
  });

  final String id;
  final JobType jobType;
  final String pickupName;
  final String pickupAddress;
  final String dropoffName;
  final String dropoffAddress;
  final double distanceKm;
  final int durationMin;
  final double earning;
  final double tip;
  TripStatus status;
  final DateTime createdAt;
  final String customerName;
  final String customerPhone;
  final double customerRating;
  final String customerTier;
  final VehicleCategory? vehicleRequired;
  final PaymentMethod paymentMethod;
  final double? weightKg;
  final String? packageLabel;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final String? note;
  final double surgeMultiplier;
  final bool isPremium;
  final bool isNightRate;

  bool get isCod => paymentMethod == PaymentMethod.cash;

  double get total => earning + tip;

  String get routeLabel => '$pickupName to $dropoffName';

  /// Compatibility aliases used by older UI.
  String get riderName => customerName;
  double get riderRating => customerRating;
  String get riderTier => customerTier;
  double get distanceMiles => distanceKm * 0.621371;

  /// Next status after the primary action button, or null if complete/cancel.
  TripStatus? get nextStatus {
    return switch (jobType) {
      JobType.ride => switch (status) {
          TripStatus.accepted || TripStatus.arriving => TripStatus.arrived,
          TripStatus.arrived => TripStatus.inProgress,
          TripStatus.inProgress => TripStatus.completed,
          _ => null,
        },
      JobType.food => switch (status) {
          TripStatus.accepted || TripStatus.arriving => TripStatus.pickedUp,
          TripStatus.pickedUp => TripStatus.completed,
          _ => null,
        },
      JobType.parcel => switch (status) {
          TripStatus.accepted || TripStatus.arriving => TripStatus.pickedUp,
          TripStatus.pickedUp => TripStatus.inTransit,
          TripStatus.inTransit => TripStatus.completed,
          _ => null,
        },
    };
  }

  String get nextActionLabel {
    return switch (jobType) {
      JobType.ride => switch (status) {
          TripStatus.accepted || TripStatus.arriving => 'ARRIVED  >',
          TripStatus.arrived => 'START TRIP  >',
          TripStatus.inProgress => 'COMPLETE  >',
          _ => 'CONTINUE  >',
        },
      JobType.food => switch (status) {
          TripStatus.accepted || TripStatus.arriving => 'PICKED UP  >',
          TripStatus.pickedUp => 'DELIVERED  >',
          _ => 'CONTINUE  >',
        },
      JobType.parcel => switch (status) {
          TripStatus.accepted || TripStatus.arriving => 'PICKED UP  >',
          TripStatus.pickedUp => 'IN TRANSIT  >',
          TripStatus.inTransit => 'DELIVERED  >',
          _ => 'CONTINUE  >',
        },
    };
  }

  bool get isGoingToPickup => switch (status) {
        TripStatus.accepted ||
        TripStatus.arriving ||
        TripStatus.arrived =>
          true,
        _ => false,
      };

  bool get isGoingToDrop => !isGoingToPickup && status != TripStatus.completed;
}

class EarningsSummary {
  EarningsSummary({
    required this.todayTotal,
    required this.todayTrips,
    required this.onlineDuration,
    required this.todayTrendPercent,
    required this.currentBalance,
    required this.weekTrendPercent,
    required this.baseFare,
    required this.tips,
    required this.surgeBonuses,
    required this.dailyTotals,
  });

  final double todayTotal;
  final int todayTrips;
  final Duration onlineDuration;
  final double todayTrendPercent;
  final double currentBalance;
  final double weekTrendPercent;
  final double baseFare;
  final double tips;
  final double surgeBonuses;
  final List<double> dailyTotals;
}

class PayoutRecord {
  PayoutRecord({
    required this.id,
    required this.amount,
    required this.date,
    required this.method,
    required this.status,
  });

  final String id;
  final double amount;
  final DateTime date;
  final String method;
  final String status;
}

/// Default Dhaka map center.
class DhakaMap {
  static const lat = 23.8103;
  static const lng = 90.4125;
}

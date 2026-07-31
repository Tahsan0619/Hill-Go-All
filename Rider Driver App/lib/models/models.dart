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

/// Laravel often JSON-encodes DECIMAL columns as strings — accept both.
double? asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

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
    this.rating = 0,
    this.vehicle,
    this.onboardingComplete = false,
    this.currentOnboardingStep = OnboardingStep.registration,
    this.kycStatus = 'pending',
    this.accountStatus = 'onboarding',
    this.balance = 0,
    this.isOnline = false,
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

  /// Backend KYC status: pending | uploaded | verified | action_required | rejected.
  String kycStatus;

  /// Backend account status: onboarding | active | suspended.
  String accountStatus;
  double balance;

  /// Mirrors rider_profiles.online from GET /rider/me.
  bool isOnline;

  /// Maps the backend GET /rider/me payload.
  factory DriverUser.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>?;
    final kyc = (profile?['kyc_status'] as String?) ?? 'pending';
    final status = (json['status'] as String?) ?? 'onboarding';

    VehicleInfo? vehicle;
    if (profile != null && profile['vehicle_make'] != null) {
      vehicle = VehicleInfo(
        make: profile['vehicle_make'] as String? ?? '',
        model: profile['vehicle_model'] as String? ?? '',
        year: profile['vehicle_year']?.toString() ?? '',
        plate: profile['plate'] as String? ?? '',
        category: vehicleCategoryFromApi(profile['vehicle_type'] as String?) ??
            VehicleCategory.car,
      );
    }

    // Onboarding is considered complete once documents are submitted for
    // review (or the account is fully verified/active).
    final complete =
        kyc == 'uploaded' || kyc == 'verified' || status == 'active';

    OnboardingStep step;
    if (profile == null || profile['legal_name'] == null) {
      step = OnboardingStep.registration;
    } else if (vehicle == null) {
      step = OnboardingStep.vehicle;
    } else if (!complete) {
      step = OnboardingStep.documents;
    } else {
      step = OnboardingStep.verification;
    }

    return DriverUser(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatar'] as String?,
      rating: asDouble(profile?['rating']) ?? 0,
      vehicle: vehicle,
      onboardingComplete: complete,
      currentOnboardingStep: step,
      kycStatus: kyc,
      accountStatus: status,
      balance: asDouble(profile?['balance']) ?? 0,
      isOnline: profile?['online'] == true || profile?['online'] == 1,
    );
  }

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
    String? kycStatus,
    String? accountStatus,
    double? balance,
    bool? isOnline,
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
      kycStatus: kycStatus ?? this.kycStatus,
      accountStatus: accountStatus ?? this.accountStatus,
      balance: balance ?? this.balance,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

VehicleCategory? vehicleCategoryFromApi(String? value) {
  return switch (value) {
    'bike' => VehicleCategory.bike,
    'car' => VehicleCategory.car,
    'xl' => VehicleCategory.xl,
    _ => null,
  };
}

String vehicleCategoryToApi(VehicleCategory category) {
  return switch (category) {
    VehicleCategory.bike => 'bike',
    VehicleCategory.car => 'car',
    VehicleCategory.xl => 'xl',
  };
}

/// Bangladesh district available for rider registration (Region Lock aware).
class DistrictOption {
  DistrictOption({
    required this.id,
    required this.name,
    this.division,
    this.open = true,
    this.allowRider = true,
  });

  final String id;
  final String name;
  final String? division;
  final bool open;
  final bool allowRider;

  factory DistrictOption.fromJson(Map<String, dynamic> json) {
    return DistrictOption(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      division: json['division'] as String?,
      open: json['open'] as bool? ?? true,
      allowRider: json['allow_rider'] as bool? ?? true,
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

  /// Maps the backend trip / offer shape (snake_case).
  factory Trip.fromJson(Map<String, dynamic> json) {
    final type = switch (json['type'] as String?) {
      'food' => JobType.food,
      'parcel' => JobType.parcel,
      _ => JobType.ride,
    };
    final customer = json['customer'] as Map<String, dynamic>?;
    final codAmount = asDouble(json['cod_amount']) ?? 0;
    final isCash = json['payment_method'] == 'cash';

    return Trip(
      id: json['id'].toString(),
      jobType: type,
      pickupName: json['pickup_name'] as String? ?? 'Pickup',
      pickupAddress: json['pickup_address'] as String? ?? '',
      dropoffName: json['drop_name'] as String? ?? 'Drop-off',
      dropoffAddress: json['drop_address'] as String? ?? '',
      distanceKm: asDouble(json['distance_km']) ?? 0,
      durationMin: asDouble(json['duration_min'])?.round() ?? 0,
      earning: asDouble(json['earning']) ?? 0,
      tip: asDouble(json['tip']) ?? 0,
      status: tripStatusFromApi(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal() ??
              DateTime.now(),
      customerName: customer?['name'] as String? ?? 'Customer',
      customerPhone: customer?['phone'] as String? ?? '',
      customerRating: asDouble(customer?['rating']) ?? 0,
      customerTier: customer?['tier'] as String? ?? 'Member',
      vehicleRequired: vehicleCategoryFromApi(json['vehicle_required'] as String?),
      paymentMethod: isCash ? PaymentMethod.cash : PaymentMethod.digital,
      weightKg: asDouble(json['weight_kg']),
      packageLabel: json['package_label'] as String?,
      pickupLat: asDouble(json['pickup_lat']) ?? DhakaMap.lat,
      pickupLng: asDouble(json['pickup_lng']) ?? DhakaMap.lng,
      dropoffLat: asDouble(json['drop_lat']) ?? DhakaMap.lat,
      dropoffLng: asDouble(json['drop_lng']) ?? DhakaMap.lng,
      note: isCash && codAmount > 0
          ? 'Collect ৳${codAmount.round()} COD'
          : null,
      surgeMultiplier: asDouble(json['surge']) ?? 1.0,
    );
  }

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

TripStatus tripStatusFromApi(String? value) {
  return switch (value) {
    'requested' => TripStatus.requested,
    'accepted' => TripStatus.accepted,
    'arriving' => TripStatus.arriving,
    'arrived' => TripStatus.arrived,
    'in_progress' => TripStatus.inProgress,
    'picked_up' => TripStatus.pickedUp,
    'in_transit' => TripStatus.inTransit,
    'cancelled' => TripStatus.cancelled,
    _ => TripStatus.completed,
  };
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

  /// Maps the backend GET /rider/earnings payload.
  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    final daily = (json['daily_totals'] as List<dynamic>? ?? [])
        .map((d) => asDouble((d as Map<String, dynamic>)['total']) ?? 0.0)
        .toList();
    return EarningsSummary(
      todayTotal: asDouble(json['today_total']) ?? 0,
      todayTrips: asDouble(json['today_trips'])?.round() ?? 0,
      onlineDuration:
          Duration(seconds: asDouble(json['online_duration_seconds'])?.round() ?? 0),
      todayTrendPercent: asDouble(json['today_trend_percent']) ?? 0,
      currentBalance: asDouble(json['current_balance']) ?? 0,
      weekTrendPercent: asDouble(json['week_trend_percent']) ?? 0,
      baseFare: asDouble(json['base_fare']) ?? 0,
      tips: asDouble(json['tips']) ?? 0,
      surgeBonuses: asDouble(json['surge_bonuses']) ?? 0,
      dailyTotals: daily.length == 7 ? daily : List<double>.filled(7, 0),
    );
  }
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

  /// Maps a row from the backend GET /rider/payouts payload.
  factory PayoutRecord.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String? ?? 'pending';
    return PayoutRecord(
      id: json['id'].toString(),
      amount: asDouble(json['amount']) ?? 0,
      date: DateTime.tryParse(
                  (json['paid_at'] ?? json['created_at']) as String? ?? '')
              ?.toLocal() ??
          DateTime.now(),
      method: json['method'] as String? ?? '',
      status: rawStatus.isEmpty
          ? 'Pending'
          : rawStatus[0].toUpperCase() + rawStatus.substring(1),
    );
  }
}

/// Default Dhaka map center.
class DhakaMap {
  static const lat = 23.8103;
  static const lng = 90.4125;
}

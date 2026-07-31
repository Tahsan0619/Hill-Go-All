class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.vehicleType,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.partnerSince,
    required this.rating,
    required this.totalDeliveries,
    this.avatarUrl,
    this.nid,
    this.isVerified = false,
    this.kycStatus = 'pending',
    this.online = false,
    this.balance = 0,
    this.bankLast4,
    this.bankVerified = false,
    this.accountStatus = '',
    this.language = 'en',
  });

  /// Maps the `GET /courier/me` payload (user + courier profile).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final partnerSince = profile['partner_since'] as String?;
    return UserModel(
      id: '${json['id']}',
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      vehicleType: (profile['vehicle_type'] as String?) ?? '',
      vehicleName: (profile['vehicle_name'] as String?) ?? '',
      vehiclePlate: (profile['plate'] as String?) ?? '',
      partnerSince: partnerSince == null
          ? DateTime.now().year
          : (DateTime.tryParse(partnerSince)?.year ?? DateTime.now().year),
      rating: _toDouble(profile['rating']),
      totalDeliveries: _toDouble(profile['deliveries_count']).toInt(),
      avatarUrl: json['avatar'] as String?,
      nid: profile['nid'] as String?,
      isVerified: _toBool(profile['verified']),
      kycStatus: (profile['kyc_status'] as String?) ?? 'pending',
      online: _toBool(profile['online']),
      balance: _toDouble(profile['balance']),
      bankLast4: profile['bank_last4'] as String?,
      bankVerified: _toBool(profile['bank_verified']),
      accountStatus: (json['status'] as String?) ?? '',
      language: (json['language'] as String?) ?? 'en',
    );
  }

  final String id;
  final String name;
  final String email;
  final String phone;
  final String vehicleType;
  final String vehicleName;
  final String vehiclePlate;
  final int partnerSince;
  final double rating;
  final int totalDeliveries;
  final String? avatarUrl;
  final String? nid;
  final bool isVerified;
  final String kycStatus;
  final bool online;
  final double balance;
  final String? bankLast4;
  final bool bankVerified;
  final String accountStatus;
  final String language;

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  static bool _toBool(dynamic value) => value == true || value == 1 || value == '1';
}

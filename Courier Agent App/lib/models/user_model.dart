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
    this.isVerified = true,
  });

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

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? vehicleType,
    String? vehicleName,
    String? vehiclePlate,
    String? avatarUrl,
    String? nid,
    bool? isVerified,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleName: vehicleName ?? this.vehicleName,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      partnerSince: partnerSince,
      rating: rating,
      totalDeliveries: totalDeliveries,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nid: nid ?? this.nid,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  static const demo = UserModel(
    id: 'agent-001',
    name: 'Alex Thompson',
    email: 'demo@hillgo.com',
    phone: '+1 (555) 234-8901',
    vehicleType: 'Motorbike',
    vehicleName: 'Yamaha R15',
    vehiclePlate: 'K-8291',
    partnerSince: 2022,
    rating: 4.9,
    totalDeliveries: 1248,
    avatarUrl: 'https://i.pravatar.cc/150?u=alexthompson',
    nid: 'NID-4829103',
  );
}

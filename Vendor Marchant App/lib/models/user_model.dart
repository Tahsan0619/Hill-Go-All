class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.phone = '',
    this.status = '',
    this.onboardingComplete = false,
  });

  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String phone;

  /// Backend account status: onboarding | active | suspended.
  final String status;

  /// True once the merchant has submitted their onboarding application.
  final bool onboardingComplete;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? phone,
    String? status,
    bool? onboardingComplete,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  /// Maps the payload returned by `GET /merchant/me` (and the `user` object
  /// embedded in auth responses).
  factory UserModel.fromApi(
    Map<String, dynamic> json, {
    bool onboardingComplete = false,
    String? avatarBase,
  }) {
    var avatar = (json['avatar'] as String?) ?? '';
    if (avatar.isNotEmpty && !avatar.startsWith('http') && avatarBase != null) {
      avatar = '$avatarBase$avatar';
    }
    return UserModel(
      id: '${json['id']}',
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      avatarUrl: avatar,
      phone: (json['phone'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      onboardingComplete: onboardingComplete,
    );
  }
}

class OnboardingData {
  String businessName;
  String description;
  String? logoPath;
  String? storefrontPath;
  String category;
  List<String> subcategories;
  String contactName;
  String phone;
  String email;
  String address;
  String city;
  String zip;

  OnboardingData({
    this.businessName = '',
    this.description = '',
    this.logoPath,
    this.storefrontPath,
    this.category = '',
    List<String>? subcategories,
    this.contactName = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.city = '',
    this.zip = '',
  }) : subcategories = subcategories ?? [];

  bool get step1Valid =>
      businessName.trim().isNotEmpty && description.trim().isNotEmpty;

  bool get step2Valid => category.trim().isNotEmpty;

  bool get step3Valid =>
      contactName.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      address.trim().isNotEmpty &&
      city.trim().isNotEmpty;
}

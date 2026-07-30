class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.phone = '',
    this.onboardingComplete = false,
  });

  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String phone;
  final bool onboardingComplete;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? phone,
    bool? onboardingComplete,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'phone': phone,
        'onboardingComplete': onboardingComplete,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String,
        phone: json['phone'] as String? ?? '',
        onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      );
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
      address.trim().isNotEmpty;
}

import 'dart:math';
import '../../models/user_model.dart';
import '../repositories.dart';
import 'mock_data.dart';

class MockProfileRepository implements ProfileRepository {
  final _rand = Random();
  bool pushEnabled = true;
  bool emailEnabled = true;
  String language = 'English (US)';

  Future<void> _delay() async {
    await Future<void>.delayed(Duration(milliseconds: 300 + _rand.nextInt(700)));
  }

  @override
  Future<UserModel> getProfile() async {
    await _delay();
    return MockData.profile;
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _delay();
    MockData.profile = MockData.profile.copyWith(
      name: data['name'] as String?,
      phone: data['phone'] as String?,
      email: data['email'] as String?,
      vehicleName: data['vehicleName'] as String?,
      vehiclePlate: data['vehiclePlate'] as String?,
      vehicleType: data['vehicleType'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
    );
  }

  @override
  Future<void> updateNotificationPrefs({required bool push, required bool email}) async {
    await _delay();
    pushEnabled = push;
    emailEnabled = email;
  }

  @override
  Future<void> updateLanguage(String lang) async {
    await _delay();
    language = lang;
  }
}

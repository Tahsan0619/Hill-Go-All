import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../repositories.dart';
import 'mock_data.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _sessionKey = 'hillgo_session_email';
  static const _keepKey = 'hillgo_keep_logged_in';

  Future<void> _delay([int? ms]) async {
    final latency = ms ?? (300 + Random().nextInt(900));
    await Future<void>.delayed(Duration(milliseconds: latency));
  }

  @override
  Future<bool> isLoggedIn() async {
    final keep = _prefs.getBool(_keepKey) ?? false;
    final email = _prefs.getString(_sessionKey);
    return keep && email != null && email.isNotEmpty;
  }

  @override
  Future<String?> getSessionEmail() async => _prefs.getString(_sessionKey);

  @override
  Future<void> login({
    required String emailOrPhone,
    required String password,
    bool keepLoggedIn = true,
  }) async {
    await _delay();
    final input = emailOrPhone.trim().toLowerCase();
    final isDemo = (input == 'demo@hillgo.com' || input == 'courier@hillgo.com') &&
        password == 'demo1234';
    final wellFormed = (input.contains('@') || RegExp(r'^\+?[\d\s\-()]{7,}$').hasMatch(input)) &&
        password.length >= 4;

    if (!isDemo && !wellFormed) {
      throw Exception('Invalid credentials. Try demo@hillgo.com / demo1234');
    }

    await _prefs.setString(_sessionKey, input.contains('@') ? input : 'demo@hillgo.com');
    await _prefs.setBool(_keepKey, keepLoggedIn);
  }

  @override
  Future<void> sendOtp(String contact) async {
    await _delay(800);
    if (contact.trim().isEmpty) {
      throw Exception('Enter a valid email or phone number');
    }
  }

  @override
  Future<void> loginWithOtp({required String contact, required String otp}) async {
    await _delay();
    final code = otp.trim();
    final valid = code == '123456' || (code.length == 6 && RegExp(r'^\d{6}$').hasMatch(code));
    if (!valid) throw Exception('Invalid OTP. Use 123456 or any 6-digit code.');
    await _prefs.setString(_sessionKey, contact.contains('@') ? contact : 'demo@hillgo.com');
    await _prefs.setBool(_keepKey, true);
  }

  @override
  Future<void> register({
    required String fullName,
    required String phone,
    required String nid,
    required String vehicleType,
    required String email,
    required String password,
  }) async {
    await _delay(1000);
    MockData.profile = UserModel(
      id: 'agent-new',
      name: fullName,
      email: email,
      phone: phone,
      vehicleType: vehicleType,
      vehicleName: vehicleType == 'Bicycle'
          ? 'City Cruiser'
          : vehicleType == 'Van'
              ? 'Ford Transit'
              : 'Yamaha R15',
      vehiclePlate: 'TMP-${Random().nextInt(9000) + 1000}',
      partnerSince: DateTime.now().year,
      rating: 5.0,
      totalDeliveries: 0,
      nid: nid,
      avatarUrl: 'https://i.pravatar.cc/150?u=$email',
    );
    await _prefs.setString(_sessionKey, email);
    await _prefs.setBool(_keepKey, true);
  }

  @override
  Future<void> resetPassword({
    required String contact,
    required String otp,
    required String newPassword,
  }) async {
    await _delay();
    final code = otp.trim();
    final valid = code == '123456' || (code.length == 6 && RegExp(r'^\d{6}$').hasMatch(code));
    if (!valid) throw Exception('Invalid OTP');
    if (newPassword.length < 6) throw Exception('Password must be at least 6 characters');
  }

  @override
  Future<void> logout() async {
    await _delay(300);
    await _prefs.remove(_sessionKey);
    await _prefs.setBool(_keepKey, false);
  }
}

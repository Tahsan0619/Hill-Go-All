import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';
import '../auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _userKey = 'hillgo_user';
  static const _sessionKey = 'hillgo_session';

  static const demoEmail = 'demo@hillgo.com';
  static const demoPassword = 'demo1234';

  Future<void> _delay() async {
    final ms = 400 + Random().nextInt(700);
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  @override
  Future<bool> isLoggedIn() async {
    return _prefs.getBool(_sessionKey) ?? false;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<UserModel> login(String email, String password) async {
    await _delay();
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email and password are required.');
    }
    if (!email.contains('@') || !email.contains('.')) {
      throw Exception('Enter a valid email address.');
    }
    if (password.length < 4) {
      throw Exception('Password must be at least 4 characters.');
    }

    final existing = await getCurrentUser();
    final isDemo =
        email.trim().toLowerCase() == demoEmail && password == demoPassword;

    final user = existing?.email.toLowerCase() == email.trim().toLowerCase()
        ? existing!
        : UserModel(
            id: 'u_${DateTime.now().millisecondsSinceEpoch}',
            name: isDemo ? 'Alex Hill' : email.split('@').first,
            email: email.trim().toLowerCase(),
            avatarUrl:
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
            onboardingComplete: isDemo || (existing?.onboardingComplete ?? false),
          );

    // Demo account is always fully onboarded
    final finalUser = isDemo
        ? user.copyWith(
            name: 'Alex Hill',
            onboardingComplete: true,
            avatarUrl:
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
          )
        : user;

    await _prefs.setString(_userKey, jsonEncode(finalUser.toJson()));
    await _prefs.setBool(_sessionKey, true);
    return finalUser;
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    await _delay();
    final user = UserModel(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email.trim().toLowerCase(),
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
      onboardingComplete: false,
    );
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
    await _prefs.setBool(_sessionKey, true);
    return user;
  }

  @override
  Future<void> completeOnboarding(OnboardingData data) async {
    await _delay();
    final user = await getCurrentUser();
    if (user == null) throw Exception('Not logged in');
    final updated = user.copyWith(
      name: data.contactName.isNotEmpty ? data.contactName : data.businessName,
      phone: data.phone,
      onboardingComplete: true,
    );
    await _prefs.setString(_userKey, jsonEncode(updated.toJson()));
    await _prefs.setString(
      'hillgo_store_name',
      data.businessName,
    );
  }

  @override
  Future<void> logout() async {
    await _delay();
    await _prefs.setBool(_sessionKey, false);
  }
}

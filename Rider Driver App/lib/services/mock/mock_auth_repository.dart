import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../auth_repository.dart';
import '../../models/models.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _sessionKey = 'hillgo_session_email';
  static const _demoEmail = 'demo@hillgo.com';
  // ignore: unused_field - kept for optional email login path
  static const _demoPassword = 'demo1234';
  static const demoOtp = '123456';
  static const demoPhone = '01712345678';

  DriverUser? _user;
  final _uuid = const Uuid();

  Duration get _latency => Duration(milliseconds: 400 + Random().nextInt(700));

  @override
  Future<DriverUser?> getCurrentSession() async {
    await Future.delayed(_latency);
    final email = _prefs.getString(_sessionKey);
    if (email == null) return null;
    _user ??= _seedUser(email);
    return _user;
  }

  @override
  Future<DriverUser> login({required String email, required String password}) async {
    await Future.delayed(_latency);
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || !normalized.contains('@')) {
      throw AuthException('Enter a valid email address.');
    }
    if (password.length < 4) {
      throw AuthException('Password must be at least 4 characters.');
    }
    _user = _seedUser(normalized, onboardingComplete: true);
    await _prefs.setString(_sessionKey, normalized);
    return _user!;
  }

  @override
  Future<void> requestOtp({required String emailOrPhone}) async {
    await Future.delayed(_latency);
    final raw = emailOrPhone.trim();
    if (raw.isEmpty) {
      throw AuthException('Enter your phone number.');
    }
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (!raw.contains('@') && digits.length < 10) {
      throw AuthException('Enter a valid BD mobile number.');
    }
  }

  @override
  Future<DriverUser> verifyOtp({required String emailOrPhone, required String code}) async {
    await Future.delayed(_latency);
    final trimmed = code.trim();
    if (trimmed.length != 6 || int.tryParse(trimmed) == null) {
      throw AuthException('Enter a valid 6-digit code.');
    }
    final isPhone = !emailOrPhone.contains('@');
    final digits = emailOrPhone.replaceAll(RegExp(r'\D'), '');
    final email = isPhone
        ? 'rider$digits@hillgo.com'
        : emailOrPhone.trim().toLowerCase();
    // Phone OTP login skips KYC for v1 — go straight to Home.
    _user = _seedUser(
      email,
      onboardingComplete: true,
      phone: isPhone ? _formatBdPhone(digits) : null,
      name: isPhone ? 'Karim Rahman' : null,
    );
    await _prefs.setString(_sessionKey, email);
    return _user!;
  }

  @override
  Future<DriverUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(_latency);
    if (name.trim().length < 2) throw AuthException('Enter your full name.');
    if (!email.contains('@')) throw AuthException('Enter a valid email.');
    if (phone.replaceAll(RegExp(r'\D'), '').length < 10) {
      throw AuthException('Enter a valid phone number.');
    }
    if (password.length < 6) throw AuthException('Password must be at least 6 characters.');
    _user = DriverUser(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      onboardingComplete: false,
      currentOnboardingStep: OnboardingStep.personalInfo,
    );
    await _prefs.setString(_sessionKey, _user!.email);
    return _user!;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future.delayed(_latency);
    if (!email.contains('@')) throw AuthException('Enter a valid email.');
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await Future.delayed(_latency);
    if (code.trim().length != 6) throw AuthException('Enter the 6-digit code.');
    if (newPassword.length < 6) throw AuthException('Password must be at least 6 characters.');
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _user = null;
    await _prefs.remove(_sessionKey);
  }

  @override
  Future<void> updateProfile(DriverUser user) async {
    await Future.delayed(_latency);
    _user = user;
  }

  @override
  Future<void> saveVehicle(VehicleInfo vehicle) async {
    await Future.delayed(_latency);
    if (_user == null) throw AuthException('Not signed in.');
    _user = _user!.copyWith(
      vehicle: vehicle,
      currentOnboardingStep: OnboardingStep.documents,
    );
  }

  @override
  Future<void> completeOnboarding() async {
    await Future.delayed(_latency);
    if (_user == null) return;
    _user = _user!.copyWith(
      onboardingComplete: true,
      currentOnboardingStep: OnboardingStep.verification,
    );
  }

  @override
  Future<void> setOnboardingStep(OnboardingStep step) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_user == null) return;
    _user = _user!.copyWith(currentOnboardingStep: step);
  }

  DriverUser _seedUser(
    String email, {
    bool onboardingComplete = true,
    String? phone,
    String? name,
  }) {
    return DriverUser(
      id: 'drv-001',
      name: name ?? (email == _demoEmail ? 'Karim Rahman' : 'New Partner'),
      email: email,
      phone: phone ?? '+8801712345678',
      rating: 4.92,
      avatarUrl: null,
      onboardingComplete: onboardingComplete,
      currentOnboardingStep:
          onboardingComplete ? OnboardingStep.verification : OnboardingStep.registration,
      vehicle: onboardingComplete
          ? VehicleInfo(
              make: 'Honda',
              model: 'Grace',
              year: '2021',
              plate: 'ঢাকা মেট্রো-গ 12-3456',
              category: VehicleCategory.car,
            )
          : null,
    );
  }

  String _formatBdPhone(String digits) {
    if (digits.startsWith('880')) return '+$digits';
    if (digits.startsWith('0')) return '+88$digits';
    return '+880$digits';
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

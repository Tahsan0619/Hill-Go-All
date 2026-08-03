import 'package:flutter_test/flutter_test.dart';
import 'package:courier_agent_app/models/document_model.dart';
import 'package:courier_agent_app/models/user_model.dart';
import 'package:courier_agent_app/providers/auth_provider.dart';
import 'package:courier_agent_app/services/repositories.dart';

const _otpUser = UserModel(
  id: '1',
  name: 'Test Courier',
  email: 'courier@example.com',
  phone: '01700000000',
  vehicleType: 'bike',
  vehicleName: '',
  vehiclePlate: '',
  partnerSince: 2024,
  rating: 0,
  totalDeliveries: 0,
);

/// Minimal fake covering only what `AuthProvider`'s OTP flow calls;
/// everything else throws so an accidental new dependency fails loudly.
class _FakeAuthRepository implements AuthRepository {
  bool otpSendShouldFail = false;
  bool otpVerifyShouldFail = false;
  String? lastOtpPhone;
  String? lastVerifiedPhone;
  String? lastVerifiedOtp;

  @override
  Future<void> sendLoginOtp(String phone) async {
    lastOtpPhone = phone;
    if (otpSendShouldFail) {
      throw Exception('Could not send the code');
    }
  }

  @override
  Future<UserModel> loginWithOtp({required String phone, required String otp}) async {
    lastVerifiedPhone = phone;
    lastVerifiedOtp = otp;
    if (otpVerifyShouldFail) {
      throw Exception('Invalid code');
    }
    return _otpUser;
  }

  @override
  Future<UserModel?> restoreSession() => throw UnimplementedError();
  @override
  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
    bool keepLoggedIn = true,
  }) =>
      throw UnimplementedError();
  @override
  Future<UserModel> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();
  @override
  Future<void> sendPasswordResetOtp(String phone) => throw UnimplementedError();
  @override
  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) =>
      throw UnimplementedError();
  @override
  Future<void> logout() => throw UnimplementedError();
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<UserModel> getProfile() => throw UnimplementedError();
  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<void> updateNotificationPrefs({required bool assignments, required bool payouts}) =>
      throw UnimplementedError();
  @override
  Future<void> updateLanguage(String languageCode) => throw UnimplementedError();
  @override
  Future<UserModel> updateVehicle({String? type, String? name, String? plate}) =>
      throw UnimplementedError();
  @override
  Future<List<CourierDocument>> getDocuments() => throw UnimplementedError();
  @override
  Future<void> uploadDocument(String docKey, String filePath) => throw UnimplementedError();
  @override
  Future<bool> setPresence(bool online) => throw UnimplementedError();
}

void main() {
  group('AuthProvider OTP login flow', () {
    late _FakeAuthRepository authRepo;
    late AuthProvider provider;

    setUp(() {
      authRepo = _FakeAuthRepository();
      provider = AuthProvider(authRepo, _FakeProfileRepository());
    });

    test('sendLoginOtp succeeds and clears any prior error', () async {
      final ok = await provider.sendLoginOtp('01711111111');
      expect(ok, isTrue);
      expect(provider.error, isNull);
      expect(authRepo.lastOtpPhone, '01711111111');
    });

    test('sendLoginOtp surfaces the repository error message on failure', () async {
      authRepo.otpSendShouldFail = true;
      final ok = await provider.sendLoginOtp('01711111111');
      expect(ok, isFalse);
      expect(provider.error, 'Could not send the code');
    });

    test('loginWithOtp authenticates and stores the user on success', () async {
      final ok = await provider.loginWithOtp(phone: '01711111111', otp: '1234');
      expect(ok, isTrue);
      expect(provider.status, AuthStatus.authenticated);
      expect(provider.user, _otpUser);
      expect(authRepo.lastVerifiedPhone, '01711111111');
      expect(authRepo.lastVerifiedOtp, '1234');
    });

    test('loginWithOtp keeps the session unauthenticated on an invalid code', () async {
      authRepo.otpVerifyShouldFail = true;
      final ok = await provider.loginWithOtp(phone: '01711111111', otp: '0000');
      expect(ok, isFalse);
      expect(provider.status, isNot(AuthStatus.authenticated));
      expect(provider.user, isNull);
      expect(provider.error, 'Invalid code');
    });

    test('isLoading toggles back to false after either outcome', () async {
      await provider.sendLoginOtp('01711111111');
      expect(provider.isLoading, isFalse);

      authRepo.otpVerifyShouldFail = true;
      await provider.loginWithOtp(phone: '01711111111', otp: '0000');
      expect(provider.isLoading, isFalse);
    });
  });
}

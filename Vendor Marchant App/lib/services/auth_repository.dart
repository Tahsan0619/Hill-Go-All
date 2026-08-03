import '../models/user_model.dart';

/// Outcome of a registration attempt. When the backend requires phone OTP
/// verification, [otpRequired] is true and the caller must repeat the call
/// with the received code.
class RegisterResult {
  const RegisterResult({required this.otpRequired, this.user});

  final bool otpRequired;
  final UserModel? user;
}

/// Snapshot of the merchant onboarding pipeline from the backend.
class OnboardingStatus {
  const OnboardingStatus({
    required this.submitted,
    this.status,
    this.storeActive = false,
  });

  final bool submitted;

  /// pending | approved | rejected (null when nothing was submitted yet).
  final String? status;
  final bool storeActive;
}

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();

  /// Rotates the Sanctum token. Returns null when the session is invalid (401).
  Future<UserModel?> refreshToken();

  /// [identifier] may be an email address or a phone number.
  Future<UserModel> login(String identifier, String password);

  Future<RegisterResult> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? otp,
  });

  Future<void> logout();
  Future<void> completeOnboarding(OnboardingData data);
  Future<bool> isLoggedIn();
  Future<OnboardingStatus> getOnboardingStatus();
}

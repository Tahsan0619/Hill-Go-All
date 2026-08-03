import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/api/api_client.dart';
import '../services/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

enum RegisterOutcome { success, otpRequired, failed }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo);

  final AuthRepository _repo;

  AuthStatus status = AuthStatus.unknown;
  UserModel? user;
  bool isLoading = false;
  String? error;
  final OnboardingData onboarding = OnboardingData();

  /// Latest onboarding pipeline state (pending / approved / rejected).
  String? onboardingReviewStatus;

  Future<void> bootstrap() async {
    try {
      user = await _repo.getCurrentUser();
      if (user != null) {
        try {
          final refreshed = await _repo.refreshToken();
          if (refreshed != null) {
            user = refreshed;
          } else {
            user = null;
          }
        } on ApiException {
          // Transient failure — keep the session from getCurrentUser.
        }
      }
      status =
          user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } catch (e) {
      // Server unreachable or session invalid: fall back to login.
      user = null;
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await _repo.login(identifier, password);
      status = AuthStatus.authenticated;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = _message(e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<RegisterOutcome> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? otp,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
        otp: otp,
      );
      isLoading = false;
      if (result.otpRequired) {
        notifyListeners();
        return RegisterOutcome.otpRequired;
      }
      user = result.user;
      status = AuthStatus.authenticated;
      notifyListeners();
      return RegisterOutcome.success;
    } catch (e) {
      error = _message(e);
      isLoading = false;
      notifyListeners();
      return RegisterOutcome.failed;
    }
  }

  Future<bool> completeOnboarding() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _repo.completeOnboarding(onboarding);
      final onboardingState = await _repo.getOnboardingStatus();
      onboardingReviewStatus = onboardingState.status;
      user = user?.copyWith(onboardingComplete: onboardingState.submitted);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = _message(e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshOnboardingStatus() async {
    try {
      final onboardingState = await _repo.getOnboardingStatus();
      onboardingReviewStatus = onboardingState.status;
      user = user?.copyWith(onboardingComplete: onboardingState.submitted);
      notifyListeners();
    } catch (_) {
      // Non-fatal: keep the last known state.
    }
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();
    await _repo.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    isLoading = false;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  void notifyOnboardingChanged() => notifyListeners();

  String _message(Object e) {
    if (e is ApiException) return e.message;
    return e.toString().replaceFirst('Exception: ', '');
  }
}

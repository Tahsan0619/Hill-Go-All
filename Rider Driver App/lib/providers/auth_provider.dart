import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/auth_repository.dart';
import '../services/mock/mock_auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo);

  final AuthRepository _repo;

  AuthStatus status = AuthStatus.unknown;
  DriverUser? user;
  bool isLoading = false;
  String? error;
  String? pendingOtpTarget;
  int resendSeconds = 0;

  Future<void> bootstrap() async {
    isLoading = true;
    notifyListeners();
    try {
      user = await _repo.getCurrentSession();
      status = user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    } catch (_) {
      status = AuthStatus.unauthenticated;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    return _run(() async {
      user = await _repo.login(email: email, password: password);
      status = AuthStatus.authenticated;
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _run(() async {
      user = await _repo.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      status = AuthStatus.authenticated;
    });
  }

  Future<bool> sendOtp(String target) async {
    return _run(() async {
      await _repo.requestOtp(emailOrPhone: target);
      pendingOtpTarget = target;
      resendSeconds = 30;
      _tickResend();
    });
  }

  Future<bool> verifyOtp(String code) async {
    final target = pendingOtpTarget;
    if (target == null) {
      error = 'Request a code first.';
      notifyListeners();
      return false;
    }
    return _run(() async {
      user = await _repo.verifyOtp(emailOrPhone: target, code: code);
      status = AuthStatus.authenticated;
    });
  }

  Future<bool> requestPasswordReset(String email) async {
    return _run(() => _repo.requestPasswordReset(email: email));
  }

  Future<bool> resetPassword(String email, String code, String password) async {
    return _run(() => _repo.resetPassword(email: email, code: code, newPassword: password));
  }

  Future<void> logout() async {
    await _repo.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? email,
  }) async {
    if (user == null) return false;
    return _run(() async {
      final updated = user!.copyWith(
        name: name,
        phone: phone,
        email: email ?? user!.email,
      );
      await _repo.updateProfile(updated);
      user = updated;
    });
  }

  Future<bool> saveVehicle(VehicleInfo vehicle) async {
    return _run(() async {
      await _repo.saveVehicle(vehicle);
      user = user?.copyWith(
        vehicle: vehicle,
        currentOnboardingStep: OnboardingStep.documents,
      );
    });
  }

  Future<void> advanceOnboarding(OnboardingStep step) async {
    await _repo.setOnboardingStep(step);
    user = user?.copyWith(currentOnboardingStep: step);
    notifyListeners();
  }

  Future<void> finishOnboarding() async {
    await _repo.completeOnboarding();
    user = user?.copyWith(onboardingComplete: true);
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  void _tickResend() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendSeconds <= 0) return false;
      resendSeconds--;
      notifyListeners();
      return resendSeconds > 0;
    });
  }

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      error = e.message;
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api/api_client.dart';
import '../services/auth_repository.dart';

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
  List<DistrictOption> districts = [];

  Future<void> bootstrap() async {
    isLoading = true;
    notifyListeners();
    try {
      user = await _repo.getCurrentSession();
      if (user != null) {
        try {
          final refreshed = await _repo.refreshToken();
          if (refreshed != null) {
            user = refreshed;
          } else {
            user = null;
          }
        } on ApiException {
          // Transient failure — keep the session from getCurrentSession.
        }
      }
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
      resendSeconds = 45;
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

  Future<bool> requestPasswordReset(String phone) async {
    return _run(() async {
      await _repo.requestPasswordReset(phone: phone);
      resendSeconds = 45;
      _tickResend();
    });
  }

  Future<bool> resetPassword(String phone, String code, String password) async {
    return _run(
      () => _repo.resetPassword(phone: phone, code: code, newPassword: password),
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Re-fetches /rider/me (e.g. after onboarding submissions).
  Future<void> refreshUser() async {
    try {
      final refreshed = await _repo.getCurrentSession();
      if (refreshed != null) {
        user = refreshed;
        notifyListeners();
      }
    } catch (_) {
      // Keep the current in-memory user on transient failures.
    }
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

  Future<bool> submitPersonalInfo({
    required String legalName,
    required String homeAddress,
    required String districtId,
    required String dob,
    required String nid,
  }) async {
    return _run(() async {
      await _repo.submitPersonalInfo(
        legalName: legalName,
        homeAddress: homeAddress,
        districtId: districtId,
        dob: dob,
        nid: nid,
      );
      user = user?.copyWith(currentOnboardingStep: OnboardingStep.vehicle);
    });
  }

  /// Delegates to the repository on every call — [ApiAuthRepository] caches
  /// the result with a TTL internally, so repeated calls within the TTL are
  /// served from memory without a network hit, while calls after the TTL
  /// (or after [refreshDistricts]) pick up backend changes.
  Future<void> loadDistricts() async {
    try {
      districts = await _repo.getDistricts();
      notifyListeners();
    } on ApiException catch (e) {
      if (districts.isEmpty) {
        error = e.message;
        notifyListeners();
      }
    }
  }

  /// Forces a fresh districts fetch — call on pull-to-refresh.
  Future<void> refreshDistricts() async {
    _repo.invalidateDistrictsCache();
    await loadDistricts();
  }

  Future<void> advanceOnboarding(OnboardingStep step) async {
    await _repo.setOnboardingStep(step);
    user = user?.copyWith(currentOnboardingStep: step);
    notifyListeners();
  }

  Future<bool> finishOnboarding() async {
    return _run(() async {
      await _repo.completeOnboarding();
      user = user?.copyWith(
        onboardingComplete: true,
        currentOnboardingStep: OnboardingStep.verification,
        kycStatus: 'uploaded',
      );
    });
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
    } on ApiException catch (e) {
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

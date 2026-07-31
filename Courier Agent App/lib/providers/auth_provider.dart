import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/repositories.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo, this._profileRepo);

  final AuthRepository _repo;
  final ProfileRepository _profileRepo;

  AuthStatus status = AuthStatus.unknown;
  bool isLoading = false;
  String? error;
  UserModel? user;

  /// Non-fatal notice from registration (e.g. a document upload that failed
  /// after the account itself was created).
  String? registrationNotice;

  // Registration draft (survives step navigation)
  String regFullName = '';
  String regPhone = '';
  String regNid = '';
  String regVehicleType = '';
  String regEmail = '';
  String regPassword = '';
  String? licensePath;
  String? nidDocPath;
  String? vehicleDocPath;
  bool termsAccepted = false;

  Future<void> bootstrap() async {
    try {
      user = await _repo.restoreSession();
    } catch (_) {
      user = null;
    }
    status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Called by the API client when the backend rejects the stored token.
  void handleSessionExpired() {
    if (status != AuthStatus.authenticated) return;
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login({
    required String emailOrPhone,
    required String password,
    bool keepLoggedIn = true,
  }) {
    return _guarded(() async {
      user = await _repo.login(
        emailOrPhone: emailOrPhone,
        password: password,
        keepLoggedIn: keepLoggedIn,
      );
      status = AuthStatus.authenticated;
    });
  }

  Future<bool> sendLoginOtp(String phone) => _guarded(() => _repo.sendLoginOtp(phone));

  Future<bool> loginWithOtp({required String phone, required String otp}) {
    return _guarded(() async {
      user = await _repo.loginWithOtp(phone: phone, otp: otp);
      status = AuthStatus.authenticated;
    });
  }

  Future<bool> sendPasswordResetOtp(String phone) =>
      _guarded(() => _repo.sendPasswordResetOtp(phone));

  Future<bool> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) =>
      _guarded(() => _repo.resetPassword(phone: phone, otp: otp, newPassword: newPassword));

  void saveRegistrationStep1({
    required String fullName,
    required String phone,
    required String nid,
    required String vehicleType,
  }) {
    regFullName = fullName;
    regPhone = phone;
    regNid = nid;
    regVehicleType = vehicleType;
    notifyListeners();
  }

  void saveRegistrationDocs({String? license, String? nidDoc, String? vehicleDoc}) {
    licensePath = license ?? licensePath;
    nidDocPath = nidDoc ?? nidDocPath;
    vehicleDocPath = vehicleDoc ?? vehicleDocPath;
    notifyListeners();
  }

  void saveRegistrationCredentials({required String email, required String password}) {
    regEmail = email;
    regPassword = password;
    notifyListeners();
  }

  /// Registers the account, then uploads KYC documents and sets the vehicle
  /// type. Document/vehicle failures do not roll back the registration; they
  /// surface through [registrationNotice] so the user can retry from Profile.
  Future<bool> completeRegistration() async {
    registrationNotice = null;
    final ok = await _guarded(() async {
      user = await _repo.register(
        fullName: regFullName,
        phone: regPhone,
        email: regEmail,
        password: regPassword,
      );
    });
    if (!ok) return false;

    final issues = <String>[];
    final uploads = {
      'license': licensePath,
      'nid': nidDocPath,
      'registration': vehicleDocPath,
    };
    for (final entry in uploads.entries) {
      final path = entry.value;
      if (path == null || path.isEmpty) continue;
      try {
        await _profileRepo.uploadDocument(entry.key, path);
      } catch (e) {
        issues.add('${entry.key} upload failed: $e');
      }
    }
    if (regVehicleType.isNotEmpty) {
      try {
        user = await _profileRepo.updateVehicle(type: regVehicleType);
      } catch (e) {
        issues.add('Vehicle info could not be saved: $e');
      }
    }
    if (issues.isNotEmpty) {
      registrationNotice =
          'Account created, but some details need attention: ${issues.join(' · ')} '
          'You can retry from Profile → Document Status.';
    }

    status = AuthStatus.authenticated;
    isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();
    await _repo.logout();
    status = AuthStatus.unauthenticated;
    user = null;
    isLoading = false;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  Future<bool> _guarded(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await action();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

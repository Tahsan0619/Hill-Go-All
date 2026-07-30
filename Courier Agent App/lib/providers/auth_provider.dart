import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/mock/mock_auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo);

  final MockAuthRepository _repo;

  AuthStatus status = AuthStatus.unknown;
  bool isLoading = false;
  String? error;
  String? sessionEmail;
  UserModel? user;

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
    final loggedIn = await _repo.isLoggedIn();
    sessionEmail = await _repo.getSessionEmail();
    status = loggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    if (loggedIn) user = UserModel.demo;
    notifyListeners();
  }

  Future<bool> login({
    required String emailOrPhone,
    required String password,
    bool keepLoggedIn = true,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _repo.login(
        emailOrPhone: emailOrPhone,
        password: password,
        keepLoggedIn: keepLoggedIn,
      );
      sessionEmail = await _repo.getSessionEmail();
      user = UserModel.demo;
      status = AuthStatus.authenticated;
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

  Future<void> sendOtp(String contact) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _repo.sendOtp(contact);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> loginWithOtp({required String contact, required String otp}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _repo.loginWithOtp(contact: contact, otp: otp);
      sessionEmail = await _repo.getSessionEmail();
      user = UserModel.demo;
      status = AuthStatus.authenticated;
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

  Future<bool> resetPassword({
    required String contact,
    required String otp,
    required String newPassword,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _repo.resetPassword(contact: contact, otp: otp, newPassword: newPassword);
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

  void saveRegistrationDocs({
    String? license,
    String? nidDoc,
    String? vehicleDoc,
  }) {
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

  Future<bool> completeRegistration() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _repo.register(
        fullName: regFullName,
        phone: regPhone,
        nid: regNid,
        vehicleType: regVehicleType,
        email: regEmail.isEmpty ? '${regPhone.replaceAll(RegExp(r'\D'), '')}@hillgo.com' : regEmail,
        password: regPassword.isEmpty ? 'demo1234' : regPassword,
      );
      sessionEmail = await _repo.getSessionEmail();
      status = AuthStatus.authenticated;
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

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();
    await _repo.logout();
    status = AuthStatus.unauthenticated;
    sessionEmail = null;
    user = null;
    isLoading = false;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}

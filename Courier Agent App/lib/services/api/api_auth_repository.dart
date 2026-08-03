import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';
import '../repositories.dart';
import 'api_client.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api, this._prefs);

  static const _keepKey = 'hillgo_keep_logged_in';

  final ApiClient _api;
  final SharedPreferences _prefs;

  @override
  Future<UserModel?> restoreSession() async {
    if (!_api.hasToken) return null;
    if (!(_prefs.getBool(_keepKey) ?? true)) {
      await _api.clearToken();
      return null;
    }
    try {
      final data = await _api.get('/courier/me');
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.isUnauthorized) return null;
      rethrow;
    }
  }

  @override
  Future<UserModel?> refreshToken() async {
    if (!_api.hasToken) return null;
    try {
      final data = await _api.post('/courier/auth/refresh');
      return _storeSession(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.isUnauthorized) return null;
      rethrow;
    }
  }

  @override
  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
    bool keepLoggedIn = true,
  }) async {
    final contact = emailOrPhone.trim();
    final data = await _api.post('/courier/auth/login', body: {
      if (contact.contains('@')) 'email': contact else 'phone': contact,
      'password': password,
    });
    await _prefs.setBool(_keepKey, keepLoggedIn);
    return _storeSession(data as Map<String, dynamic>);
  }

  @override
  Future<void> sendLoginOtp(String phone) =>
      _api.post('/courier/auth/otp/request', body: {'phone': phone.trim()});

  @override
  Future<UserModel> loginWithOtp({required String phone, required String otp}) async {
    final data = await _api.post('/courier/auth/otp/verify', body: {
      'phone': phone.trim(),
      'otp': otp.trim(),
    });
    await _prefs.setBool(_keepKey, true);
    return _storeSession(data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final data = await _api.post('/courier/auth/register', body: {
      'name': fullName.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'password': password,
    });
    await _prefs.setBool(_keepKey, true);
    return _storeSession(data as Map<String, dynamic>);
  }

  @override
  Future<void> sendPasswordResetOtp(String phone) =>
      _api.post('/courier/auth/password/forgot', body: {'phone': phone.trim()});

  @override
  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) =>
      _api.post('/courier/auth/password/reset', body: {
        'phone': phone.trim(),
        'otp': otp.trim(),
        'password': newPassword,
      });

  @override
  Future<void> logout() async {
    try {
      await _api.post('/courier/auth/logout');
    } on ApiException {
      // The local session is cleared regardless of server reachability.
    }
    await _api.clearToken();
  }

  Future<UserModel> _storeSession(Map<String, dynamic> data) async {
    await _api.saveToken(data['token'] as String);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}

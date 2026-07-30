import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo);

  final AuthRepository _repo;

  AuthStatus status = AuthStatus.unknown;
  UserModel? user;
  bool isLoading = false;
  String? error;
  final OnboardingData onboarding = OnboardingData();

  Future<void> bootstrap() async {
    final loggedIn = await _repo.isLoggedIn();
    if (loggedIn) {
      user = await _repo.getCurrentUser();
      status = user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } else {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await _repo.login(email, password);
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

  Future<bool> register(String email, String password, String name) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await _repo.register(email, password, name);
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

  Future<bool> completeOnboarding() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _repo.completeOnboarding(onboarding);
      user = await _repo.getCurrentUser();
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
}

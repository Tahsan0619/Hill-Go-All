abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<void> login({
    required String emailOrPhone,
    required String password,
    bool keepLoggedIn = true,
  });
  Future<void> loginWithOtp({required String contact, required String otp});
  Future<void> sendOtp(String contact);
  Future<void> register({
    required String fullName,
    required String phone,
    required String nid,
    required String vehicleType,
    required String email,
    required String password,
  });
  Future<void> resetPassword({required String contact, required String otp, required String newPassword});
  Future<void> logout();
  Future<String?> getSessionEmail();
}

abstract class ParcelRepository {
  Future<List<dynamic>> getAssignedParcels();
  Future<List<dynamic>> getParcelHistory({String? query, String period = 'daily'});
  Future<dynamic> getParcelById(String id);
  Future<void> confirmPickupOtp(String parcelId, String otp);
  Future<void> confirmDeliveryOtp(String parcelId, String otp);
  Future<void> markFailed(String parcelId, String reason);
}

abstract class EarningsRepository {
  Future<dynamic> getWeeklySummary();
  Future<List<dynamic>> getDailyBreakdown();
  Future<dynamic> getPayoutSummary();
  Future<dynamic> getDashboardStats();
  Future<void> withdrawFunds(double amount);
}

abstract class ProfileRepository {
  Future<dynamic> getProfile();
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<void> updateNotificationPrefs({required bool push, required bool email});
  Future<void> updateLanguage(String language);
}

abstract class NotificationRepository {
  Future<List<dynamic>> getNotifications();
  Future<void> markRead(String id);
  Future<void> markAllRead();
}

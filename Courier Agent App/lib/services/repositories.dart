import '../models/document_model.dart';
import '../models/earnings_model.dart';
import '../models/notification_model.dart';
import '../models/parcel_model.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  /// Returns the current user when a stored token is still valid, else null.
  Future<UserModel?> restoreSession();
  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
    bool keepLoggedIn = true,
  });
  Future<void> sendLoginOtp(String phone);
  Future<UserModel> loginWithOtp({required String phone, required String otp});
  Future<UserModel> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  });
  Future<void> sendPasswordResetOtp(String phone);
  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  });
  Future<void> logout();
}

class ParcelHistoryPage {
  const ParcelHistoryPage({
    required this.items,
    required this.total,
    this.totalEarnings,
  });

  final List<ParcelModel> items;
  final int total;

  /// Server-reported earnings total when present (`total_earnings` / `payout_total`).
  final double? totalEarnings;
}

abstract class ParcelRepository {
  Future<List<ParcelModel>> getAssignedParcels();
  Future<ParcelHistoryPage> getParcelHistory({
    String? query,
    String period = 'daily',
    int page = 1,
  });
  Future<ParcelModel> getParcelById(String id);
  Future<ParcelModel> confirmPickupOtp(String parcelId, String otp);
  Future<ParcelModel> startTransit(String parcelId);
  Future<ParcelModel> confirmDeliveryOtp(String parcelId, String otp);
  Future<ParcelModel> markFailed(String parcelId, String reason);
  Future<void> uploadProof(String parcelId, {required String type, required String filePath});
}

abstract class EarningsRepository {
  Future<DashboardStats> getDashboardStats();
  Future<WeeklySummary> getWeeklySummary();
  Future<PayoutSummary> getPayoutSummary();
  Future<void> withdrawFunds({required double amount, required String method});
  Future<List<IncentiveOffer>> getIncentives();
  Future<void> acceptIncentive(String id);
}

abstract class ProfileRepository {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<void> updateNotificationPrefs({required bool assignments, required bool payouts});
  Future<void> updateLanguage(String languageCode);
  Future<UserModel> updateVehicle({String? type, String? name, String? plate});
  Future<List<CourierDocument>> getDocuments();
  Future<void> uploadDocument(String docKey, String filePath);

  /// Returns the new online state. Throws with the server message when the
  /// backend refuses (e.g. KYC not verified yet).
  Future<bool> setPresence(bool online);
}

/// A page of notification results, mirroring [ParcelHistoryPage] so
/// `GET /courier/notifications` can be paginated the same way as
/// `GET /courier/parcels/history`.
class NotificationPage {
  const NotificationPage({required this.items, required this.total});

  final List<AppNotification> items;
  final int total;
}

abstract class NotificationRepository {
  Future<NotificationPage> getNotifications({int page = 1});
  Future<void> markRead(String id);
  Future<void> markAllRead();
}

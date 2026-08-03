import 'package:flutter/foundation.dart';
import '../models/document_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../services/repositories.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._profileRepo, this._notifRepo, this._earningsRepo);

  final ProfileRepository _profileRepo;
  final NotificationRepository _notifRepo;
  final EarningsRepository _earningsRepo;

  UserModel? profile;
  bool loading = false;
  String? error;

  // The backend does not echo notification prefs back on GET /courier/me,
  // so toggles start from the default (enabled) and persist on change.
  bool assignmentAlerts = true;
  bool payoutAlerts = true;

  String language = 'en';
  List<AppNotification> notifications = [];
  List<CourierDocument> documents = [];
  double todayEarnings = 0;
  double balance = 0;

  int _notificationsPage = 1;
  int notificationsTotal = 0;
  bool loadingMoreNotifications = false;

  bool get hasMoreNotifications => notifications.length < notificationsTotal;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      profile = await _profileRepo.getProfile();
      language = profile!.language;
      balance = profile!.balance;
      final stats = await _earningsRepo.getDashboardStats();
      todayEarnings = stats.todayEarnings;
      balance = stats.balance;
      loading = false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      loading = false;
    }
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    loading = true;
    error = null;
    _notificationsPage = 1;
    notifyListeners();
    try {
      final page = await _notifRepo.getNotifications(page: _notificationsPage);
      notifications = page.items;
      notificationsTotal = page.total;
      loading = false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      loading = false;
    }
    notifyListeners();
  }

  /// Appends the next page of notifications (`GET /courier/notifications`),
  /// matching the load-more pattern used for parcel history.
  Future<void> loadMoreNotifications() async {
    if (loadingMoreNotifications || !hasMoreNotifications) return;
    loadingMoreNotifications = true;
    notifyListeners();
    try {
      final page = await _notifRepo.getNotifications(page: _notificationsPage + 1);
      _notificationsPage += 1;
      notifications = [...notifications, ...page.items];
      notificationsTotal = page.total;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loadingMoreNotifications = false;
      notifyListeners();
    }
  }

  Future<void> loadDocuments() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      documents = await _profileRepo.getDocuments();
      loading = false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      loading = false;
    }
    notifyListeners();
  }

  Future<bool> uploadDocument(String docKey, String filePath) async {
    try {
      await _profileRepo.uploadDocument(docKey, filePath);
      await loadDocuments();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> markRead(String id) async {
    await _notifRepo.markRead(id);
    await loadNotifications();
  }

  Future<void> markAllRead() async {
    await _notifRepo.markAllRead();
    await loadNotifications();
  }

  Future<void> updateNotificationPrefs({required bool assignments, required bool payouts}) async {
    try {
      await _profileRepo.updateNotificationPrefs(assignments: assignments, payouts: payouts);
      assignmentAlerts = assignments;
      payoutAlerts = payouts;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> updateLanguage(String code) async {
    try {
      await _profileRepo.updateLanguage(code);
      language = code;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  Future<bool> updateVehicle({
    required String name,
    required String plate,
    required String type,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      profile = await _profileRepo.updateVehicle(type: type, name: name, plate: plate);
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePersonal({
    required String name,
    required String phone,
    required String email,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      profile = await _profileRepo.updateProfile({'name': name, 'phone': phone, 'email': email});
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      loading = false;
      notifyListeners();
      return false;
    }
  }
}

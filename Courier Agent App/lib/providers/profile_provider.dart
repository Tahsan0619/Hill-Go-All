import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../services/mock/mock_data.dart';
import '../services/mock/mock_notification_repository.dart';
import '../services/mock/mock_profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._profileRepo, this._notifRepo);

  final MockProfileRepository _profileRepo;
  final MockNotificationRepository _notifRepo;

  UserModel? profile;
  bool loading = false;
  String? error;
  bool pushEnabled = true;
  bool emailEnabled = true;
  String language = 'English (US)';
  List<AppNotification> notifications = [];
  double todayEarnings = 142.50;
  String activeTime = '5h 20m';

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      profile = await _profileRepo.getProfile();
      pushEnabled = _profileRepo.pushEnabled;
      emailEnabled = _profileRepo.emailEnabled;
      language = _profileRepo.language;
      loading = false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      loading = false;
    }
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    loading = true;
    notifyListeners();
    try {
      notifications = await _notifRepo.getNotifications();
      loading = false;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      loading = false;
    }
    notifyListeners();
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

  Future<void> updateNotificationPrefs({required bool push, required bool email}) async {
    await _profileRepo.updateNotificationPrefs(push: push, email: email);
    pushEnabled = push;
    emailEnabled = email;
    notifyListeners();
  }

  Future<void> updateLanguage(String lang) async {
    await _profileRepo.updateLanguage(lang);
    language = lang;
    notifyListeners();
  }

  Future<void> updateVehicle({
    required String name,
    required String plate,
    required String type,
  }) async {
    loading = true;
    notifyListeners();
    await _profileRepo.updateProfile({
      'vehicleName': name,
      'vehiclePlate': plate,
      'vehicleType': type,
    });
    profile = MockData.profile;
    loading = false;
    notifyListeners();
  }

  Future<void> updatePersonal({
    required String name,
    required String phone,
    required String email,
  }) async {
    loading = true;
    notifyListeners();
    await _profileRepo.updateProfile({
      'name': name,
      'phone': phone,
      'email': email,
    });
    profile = MockData.profile;
    loading = false;
    notifyListeners();
  }

  List<IncentiveOffer> get incentives => MockData.incentives;
}

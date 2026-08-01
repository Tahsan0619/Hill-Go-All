import '../../models/notification_model.dart';
import '../repositories.dart';
import 'api_client.dart';

class ApiNotificationRepository implements NotificationRepository {
  ApiNotificationRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<AppNotification>> getNotifications() async {
    final data = await _api.get('/courier/notifications', query: {
      'per_page': '50',
    }) as Map<String, dynamic>;
    return (data['data'] as List<dynamic>? ?? const [])
        .map((row) => AppNotification.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markRead(String id) => _api.post('/courier/notifications/$id/read');

  @override
  Future<void> markAllRead() => _api.post('/courier/notifications/read-all');
}

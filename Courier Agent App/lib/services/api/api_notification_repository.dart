import '../../models/notification_model.dart';
import '../repositories.dart';
import 'api_client.dart';

class ApiNotificationRepository implements NotificationRepository {
  ApiNotificationRepository(this._api);

  final ApiClient _api;

  @override
  Future<NotificationPage> getNotifications({int page = 1}) async {
    final data = await _api.get('/courier/notifications', query: {
      'page': '$page',
      'per_page': '30',
    }) as Map<String, dynamic>;
    final items = (data['data'] as List<dynamic>? ?? const [])
        .map((row) => AppNotification.fromJson(row as Map<String, dynamic>))
        .toList();
    return NotificationPage(
      items: items,
      total: (data['total'] as num?)?.toInt() ?? items.length,
    );
  }

  @override
  Future<void> markRead(String id) => _api.post('/courier/notifications/$id/read');

  @override
  Future<void> markAllRead() => _api.post('/courier/notifications/read-all');
}

import '../../models/catalog_models.dart';
import 'api_client.dart';

class NotificationInbox {
  const NotificationInbox({
    required this.items,
    required this.unread,
    required this.total,
  });

  final List<AppNotification> items;
  final int unread;
  final int total;
}

/// Customer notification inbox endpoints.
class NotificationsApi {
  NotificationsApi._();

  static Future<NotificationInbox> inbox() async {
    final data = await ApiClient.get('/customer/notifications')
        as Map<String, dynamic>;
    final rows = data['data'] as List? ?? [];
    return NotificationInbox(
      items: rows
          .whereType<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList(),
      unread: asInt(data['unread']),
      total: asInt(data['total']),
    );
  }

  static Future<void> markRead(int id) async {
    await ApiClient.post('/customer/notifications/$id/read');
  }

  static Future<void> markAllRead() async {
    await ApiClient.post('/customer/notifications/read-all');
  }

  static Future<void> delete(int id) async {
    await ApiClient.delete('/customer/notifications/$id');
  }
}

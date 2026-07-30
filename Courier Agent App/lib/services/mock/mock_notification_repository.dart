import 'dart:math';
import '../../models/notification_model.dart';
import '../repositories.dart';
import 'mock_data.dart';

class MockNotificationRepository implements NotificationRepository {
  final _rand = Random();
  final List<AppNotification> _items = List.of(MockData.notifications);

  Future<void> _delay() async {
    await Future<void>.delayed(Duration(milliseconds: 250 + _rand.nextInt(500)));
  }

  @override
  Future<List<AppNotification>> getNotifications() async {
    await _delay();
    return List.unmodifiable(_items);
  }

  @override
  Future<void> markRead(String id) async {
    await _delay();
    final i = _items.indexWhere((n) => n.id == id);
    if (i >= 0) _items[i] = _items[i].copyWith(isRead: true);
  }

  @override
  Future<void> markAllRead() async {
    await _delay();
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
  }

  int get unreadCount => _items.where((n) => !n.isRead).length;
}

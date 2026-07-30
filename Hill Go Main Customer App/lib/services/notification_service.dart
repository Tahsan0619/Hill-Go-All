import 'package:flutter/material.dart';

/// In-memory notification store for demo / UI testing.
class NotificationService {
  NotificationService._();

  static final List<AppNotification> _items = [
    AppNotification(
      id: '1',
      title: '30% off your next ride',
      body: 'Use code HILLGO30 before midnight. Valid on all car types.',
      timeLabel: '2 min ago',
      icon: Icons.local_taxi,
      iconColor: Color(0xFF004899),
      iconBg: Color(0xFFEAF1FB),
      isRead: false,
    ),
    AppNotification(
      id: '2',
      title: 'Order on the way',
      body: 'Urban Grill House is preparing your order. ETA 22 minutes.',
      timeLabel: '18 min ago',
      icon: Icons.delivery_dining,
      iconColor: Color(0xFFFF6B00),
      iconBg: Color(0xFFFFE4D1),
      isRead: false,
    ),
    AppNotification(
      id: '3',
      title: 'Parcel delivered',
      body: 'Your parcel HG-93821 was delivered to Sam Lee.',
      timeLabel: '1 hr ago',
      icon: Icons.inventory_2_outlined,
      iconColor: Color(0xFF2B7DE9),
      iconBg: Color(0xFFD6E8FF),
      isRead: false,
    ),
    AppNotification(
      id: '4',
      title: 'Wallet top-up successful',
      body: '৳500.00 was added to your HillGo Wallet.',
      timeLabel: 'Yesterday',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: Color(0xFF004899),
      iconBg: Color(0xFFEAF1FB),
      isRead: true,
    ),
    AppNotification(
      id: '5',
      title: 'New offer near you',
      body: 'Zen Sushi House is offering free delivery on orders above ৳300.',
      timeLabel: 'Yesterday',
      icon: Icons.restaurant,
      iconColor: Color(0xFFFF6B00),
      iconBg: Color(0xFFFFE4D1),
      isRead: true,
    ),
    AppNotification(
      id: '6',
      title: 'Ride completed',
      body: 'Your trip to Gulshan 2 was completed. Rate your driver.',
      timeLabel: '2 days ago',
      icon: Icons.two_wheeler,
      iconColor: Color(0xFF6B8E23),
      iconBg: Color(0xFFE9EFD6),
      isRead: true,
    ),
  ];

  static List<AppNotification> get all => List.unmodifiable(_items);

  static int get unreadCount => _items.where((n) => !n.isRead).length;

  static void markAsRead(String id) {
    final index = _items.indexWhere((n) => n.id == id);
    if (index != -1) _items[index] = _items[index].copyWith(isRead: true);
  }

  static void markAllRead() {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
  }

  static void delete(String id) {
    _items.removeWhere((n) => n.id == id);
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      timeLabel: timeLabel,
      icon: icon,
      iconColor: iconColor,
      iconBg: iconBg,
      isRead: isRead ?? this.isRead,
    );
  }
}

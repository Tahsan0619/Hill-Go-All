class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.type = NotificationType.info,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      type: type,
    );
  }
}

enum NotificationType { info, earnings, delivery, alert }

class IncentiveOffer {
  const IncentiveOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.multiplier,
    required this.validUntil,
    required this.isActive,
  });

  final String id;
  final String title;
  final String description;
  final double multiplier;
  final DateTime validUntil;
  final bool isActive;
}

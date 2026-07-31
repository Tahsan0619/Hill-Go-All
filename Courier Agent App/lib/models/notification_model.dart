enum NotificationType { info, earnings, delivery, alert }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.type = NotificationType.info,
  });

  /// One row of `data` from `GET /courier/notifications`.
  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: '${json['id']}',
    title: (json['title'] as String?) ?? '',
    body: (json['body'] as String?) ?? '',
    createdAt: json['created_at'] is String
        ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
        : DateTime.now(),
    isRead: json['read_at'] != null,
    type: _type(json['type'] as String?),
  );

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;

  static NotificationType _type(String? value) {
    switch (value) {
      case 'earning':
      case 'payout':
      case 'incentive':
        return NotificationType.earnings;
      case 'parcel':
        return NotificationType.delivery;
      case 'security':
      case 'sos':
        return NotificationType.alert;
      default:
        return NotificationType.info;
    }
  }
}

class IncentiveOffer {
  const IncentiveOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.multiplier,
    required this.goalDeliveries,
    required this.bonusTk,
    required this.isActive,
    required this.accepted,
    required this.progress,
    this.district,
    this.validUntil,
  });

  /// One row from `GET /courier/incentives`.
  factory IncentiveOffer.fromJson(Map<String, dynamic> json) => IncentiveOffer(
    id: '${json['id']}',
    title: (json['title'] as String?) ?? '',
    description: (json['description'] as String?) ?? '',
    multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1,
    goalDeliveries: (json['goal_deliveries'] as num?)?.toInt() ?? 0,
    bonusTk: (json['bonus_tk'] as num?)?.toDouble() ?? 0,
    isActive: json['is_active'] == true,
    accepted: json['accepted'] == true,
    progress: (json['progress'] as num?)?.toInt() ?? 0,
    district: json['district'] as String?,
    validUntil: json['valid_until'] is String ? DateTime.tryParse(json['valid_until'] as String) : null,
  );

  final String id;
  final String title;
  final String description;
  final double multiplier;
  final int goalDeliveries;
  final double bonusTk;
  final bool isActive;
  final bool accepted;
  final int progress;
  final String? district;
  final DateTime? validUntil;
}

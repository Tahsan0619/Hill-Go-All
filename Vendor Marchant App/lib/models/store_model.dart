import 'package:flutter/material.dart';

class BusinessHours {
  BusinessHours({
    required this.open,
    required this.close,
    this.isClosed = false,
  });

  factory BusinessHours.fromJson(Map<String, dynamic> json) => BusinessHours(
        open: _parseTime(json['open'] as String?) ??
            const TimeOfDay(hour: 8, minute: 0),
        close: _parseTime(json['close'] as String?) ??
            const TimeOfDay(hour: 20, minute: 0),
        isClosed: (json['closed'] as bool?) ?? false,
      );

  static TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'open': _fmt(open),
        'close': _fmt(close),
        'closed': isClosed,
      };

  TimeOfDay open;
  TimeOfDay close;
  bool isClosed;
}

class StoreModel {
  StoreModel({
    required this.name,
    required this.description,
    required this.address,
    required this.specialties,
    required this.bio,
    required this.latitude,
    required this.longitude,
    required this.isOpen,
    required this.acceptingOrders,
    required this.hours,
    this.id = '',
    this.status = '',
    this.rating = 0,
    this.ratingCount = 0,
    this.bannerUrl,
    this.logoUrl,
    this.bannerLocalPath,
    this.logoLocalPath,
    this.profileStrength = 0,
  });

  static const List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static Map<String, BusinessHours> defaultHours() => {
        for (final day in weekDays)
          day: BusinessHours(
            open: const TimeOfDay(hour: 8, minute: 0),
            close: const TimeOfDay(hour: 20, minute: 0),
          ),
      };

  factory StoreModel.fromJson(
    Map<String, dynamic> json, {
    String? Function(String?)? resolveUrl,
  }) {
    final rawHours = json['hours'];
    final hours = defaultHours();
    if (rawHours is Map) {
      rawHours.forEach((day, value) {
        if (value is Map && hours.containsKey(day)) {
          hours['$day'] =
              BusinessHours.fromJson(Map<String, dynamic>.from(value));
        }
      });
    }
    String? url(String? path) => resolveUrl != null ? resolveUrl(path) : path;
    return StoreModel(
      id: '${json['id'] ?? ''}',
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      specialties: (json['specialties'] as String?) ?? '',
      bio: (json['bio'] as String?) ?? '',
      // Default map pin: Bandarban town, HillGo's home region.
      latitude: (json['lat'] as num?)?.toDouble() ?? 22.1953,
      longitude: (json['lng'] as num?)?.toDouble() ?? 92.2184,
      isOpen: (json['is_open'] as bool?) ?? false,
      acceptingOrders: (json['accepting_orders'] as bool?) ?? false,
      status: (json['status'] as String?) ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      hours: hours,
      bannerUrl: url(json['banner'] as String?),
      logoUrl: url(json['logo'] as String?),
      profileStrength: (json['profile_strength'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> hoursToJson() =>
      hours.map((day, h) => MapEntry(day, h.toJson()));

  String id;
  String name;
  String description;
  String address;
  String specialties;
  String bio;
  double latitude;
  double longitude;
  bool isOpen;
  bool acceptingOrders;
  String status;
  double rating;
  int ratingCount;
  Map<String, BusinessHours> hours;
  String? bannerUrl;
  String? logoUrl;
  String? bannerLocalPath;
  String? logoLocalPath;
  int profileStrength;
}

enum PayoutStatus { completed, pending, processing }

class PayoutModel {
  const PayoutModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    this.method = 'Bank Transfer',
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    PayoutStatus status;
    switch (json['status']) {
      case 'completed':
        status = PayoutStatus.completed;
        break;
      case 'processing':
        status = PayoutStatus.processing;
        break;
      default:
        status = PayoutStatus.pending;
    }
    return PayoutModel(
      id: (json['code'] as String?) ?? '${json['id']}',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
      status: status,
      method: (json['method'] as String?) ?? 'Bank Transfer',
    );
  }

  final String id;
  final double amount;
  final DateTime date;
  final PayoutStatus status;
  final String method;
}

enum TransactionType { order, payout }

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
    required this.statusLabel,
  });

  /// Maps a `GET /merchant/transactions` ledger entry
  /// ({type: credit|debit, title, amount, at}).
  factory TransactionModel.fromJson(Map<String, dynamic> json, int index) {
    final isCredit = json['type'] == 'credit';
    final date = DateTime.tryParse('${json['at']}') ?? DateTime.now();
    final amount = (json['amount'] as num?)?.toDouble() ?? 0;
    return TransactionModel(
      id: 'txn_$index',
      title: (json['title'] as String?) ?? '',
      subtitle: isCredit ? 'HillGo Delivery' : 'Payout Transfer',
      amount: isCredit ? amount : -amount,
      date: date,
      type: isCredit ? TransactionType.order : TransactionType.payout,
      statusLabel: isCredit ? 'Completed' : 'Processed',
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String statusLabel;
}

class ReviewModel {
  ReviewModel({
    required this.id,
    required this.customerName,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isVerified = true,
    this.reply,
    this.repliedAt,
    this.imageUrls = const [],
  });

  factory ReviewModel.fromJson(
    Map<String, dynamic> json, {
    String? Function(String?)? resolveUrl,
  }) {
    String? url(String? path) => resolveUrl != null ? resolveUrl(path) : path;
    return ReviewModel(
      id: '${json['id']}',
      customerName: (json['customer_name'] as String?) ?? 'Customer',
      avatarUrl: url(json['avatar'] as String?) ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: (json['comment'] as String?) ?? '',
      createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
      isVerified: (json['verified'] as bool?) ?? false,
      reply: json['reply'] as String?,
      repliedAt: json['replied_at'] != null
          ? DateTime.tryParse('${json['replied_at']}')
          : null,
      imageUrls: ((json['images'] as List?) ?? const [])
          .map((e) => url('$e') ?? '$e')
          .toList(),
    );
  }

  final String id;
  final String customerName;
  final String avatarUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final bool isVerified;
  String? reply;
  DateTime? repliedAt;
  final List<String> imageUrls;

  bool get hasReply => reply != null && reply!.isNotEmpty;
}

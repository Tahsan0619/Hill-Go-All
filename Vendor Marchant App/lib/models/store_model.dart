import 'package:flutter/material.dart';

class BusinessHours {
  BusinessHours({
    required this.open,
    required this.close,
    this.isClosed = false,
  });

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
    this.bannerUrl,
    this.logoUrl,
    this.bannerLocalPath,
    this.logoLocalPath,
    this.profileStrength = 85,
  });

  String name;
  String description;
  String address;
  String specialties;
  String bio;
  double latitude;
  double longitude;
  bool isOpen;
  bool acceptingOrders;
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

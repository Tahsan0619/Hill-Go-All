import 'package:latlong2/latlong.dart';

enum ParcelStatus { assigned, pickedUp, inTransit, delivered, failed }

enum ParcelPriority { standard, express, priority }

class ParcelModel {
  const ParcelModel({
    required this.id,
    required this.orderId,
    required this.type,
    required this.priority,
    required this.status,
    required this.senderName,
    required this.senderAddress,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverAddress,
    required this.receiverPhone,
    required this.pickup,
    required this.dropoff,
    required this.weightKg,
    required this.estimatedEarnings,
    required this.surgeBonus,
    required this.distanceKm,
    required this.etaMinutes,
    required this.notes,
    required this.createdAt,
    this.customerName,
    this.payout,
    this.completedAt,
    this.fragile = false,
  });

  final String id;
  final String orderId;
  final String type;
  final ParcelPriority priority;
  final ParcelStatus status;
  final String senderName;
  final String senderAddress;
  final String senderPhone;
  final String receiverName;
  final String receiverAddress;
  final String receiverPhone;
  final LatLng pickup;
  final LatLng dropoff;
  final double weightKg;
  final double estimatedEarnings;
  final double surgeBonus;
  final double distanceKm;
  final int etaMinutes;
  final String notes;
  final DateTime createdAt;
  final String? customerName;
  final double? payout;
  final DateTime? completedAt;
  final bool fragile;

  String get priorityLabel {
    switch (priority) {
      case ParcelPriority.standard:
        return 'Standard Parcel';
      case ParcelPriority.express:
        return 'Express Delivery';
      case ParcelPriority.priority:
        return 'Priority Express';
    }
  }

  ParcelModel copyWith({ParcelStatus? status, DateTime? completedAt, double? payout}) {
    return ParcelModel(
      id: id,
      orderId: orderId,
      type: type,
      priority: priority,
      status: status ?? this.status,
      senderName: senderName,
      senderAddress: senderAddress,
      senderPhone: senderPhone,
      receiverName: receiverName,
      receiverAddress: receiverAddress,
      receiverPhone: receiverPhone,
      pickup: pickup,
      dropoff: dropoff,
      weightKg: weightKg,
      estimatedEarnings: estimatedEarnings,
      surgeBonus: surgeBonus,
      distanceKm: distanceKm,
      etaMinutes: etaMinutes,
      notes: notes,
      createdAt: createdAt,
      customerName: customerName,
      payout: payout ?? this.payout,
      completedAt: completedAt ?? this.completedAt,
      fragile: fragile,
    );
  }
}

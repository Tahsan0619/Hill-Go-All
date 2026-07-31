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
    this.failReason,
    this.fragile = false,
  });

  /// Maps the courier parcel shape returned by every
  /// `/courier/parcels/*` endpoint.
  factory ParcelModel.fromJson(Map<String, dynamic> json) {
    final status = _status((json['status'] as String?) ?? 'assigned');
    final distanceKm = _toDouble(json['distance_km']);
    final earnings = _toDouble(json['estimated_earnings']);
    final surge = _toDouble(json['surge_bonus']);
    return ParcelModel(
      id: '${json['id']}',
      orderId: (json['order_id'] as String?) ?? (json['code'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'Parcel',
      priority: _priority(json['priority'] as String?),
      status: status,
      senderName: (json['sender_name'] as String?) ?? '',
      senderAddress: (json['pickup_address'] as String?) ?? '',
      senderPhone: (json['sender_phone'] as String?) ?? '',
      receiverName: (json['receiver_name'] as String?) ?? '',
      receiverAddress: (json['drop_address'] as String?) ?? '',
      receiverPhone: (json['receiver_phone'] as String?) ?? '',
      pickup: LatLng(_toDouble(json['pickup_lat']), _toDouble(json['pickup_lng'])),
      dropoff: LatLng(_toDouble(json['drop_lat']), _toDouble(json['drop_lng'])),
      weightKg: _toDouble(json['weight_kg']),
      estimatedEarnings: earnings,
      surgeBonus: surge,
      distanceKm: distanceKm,
      // The backend does not provide an ETA; estimate from distance
      // (~4 min/km urban riding), minimum 5 minutes.
      etaMinutes: distanceKm <= 0 ? 5 : (distanceKm * 4).ceil().clamp(5, 480),
      notes: (json['notes'] as String?) ?? '',
      createdAt: _date(json['created_at']) ?? DateTime.now(),
      customerName: json['customer_name'] as String?,
      payout: status == ParcelStatus.delivered ? earnings + surge : null,
      completedAt: _date(json['delivered_at']),
      failReason: json['fail_reason'] as String?,
      fragile: json['fragile'] == true || json['fragile'] == 1,
    );
  }

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
  final String? failReason;
  final bool fragile;

  /// True when the backend has real coordinates for this parcel.
  bool get hasCoordinates =>
      pickup.latitude != 0 || pickup.longitude != 0 || dropoff.latitude != 0 || dropoff.longitude != 0;

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

  static ParcelStatus _status(String value) {
    switch (value) {
      case 'picked_up':
        return ParcelStatus.pickedUp;
      case 'in_transit':
        return ParcelStatus.inTransit;
      case 'delivered':
        return ParcelStatus.delivered;
      case 'failed':
        return ParcelStatus.failed;
      default:
        return ParcelStatus.assigned;
    }
  }

  static ParcelPriority _priority(String? value) {
    switch (value?.toLowerCase()) {
      case 'express':
        return ParcelPriority.express;
      case 'priority':
        return ParcelPriority.priority;
      default:
        return ParcelPriority.standard;
    }
  }

  static DateTime? _date(dynamic value) => value is String ? DateTime.tryParse(value) : null;

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}

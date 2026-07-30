enum OrderStatus { newOrder, preparing, ready, delivered, rejected }

enum OrderPriority { standard, priority, express, scheduled }

class OrderItem {
  const OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    this.notes = '',
  });

  final String name;
  final int quantity;
  final double price;
  final String imageUrl;
  final String notes;

  double get lineTotal => price * quantity;
}

class OrderModel {
  OrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerRating,
    required this.customerOrderCount,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.priority,
    this.customerNote,
    this.customerAvatar,
    this.scheduledFor,
    this.deliveredAt,
    this.rating,
    this.serviceFee = 2.50,
    this.taxRate = 0.094,
  });

  final String id;
  final String customerName;
  final String customerPhone;
  final double customerRating;
  final int customerOrderCount;
  final List<OrderItem> items;
  OrderStatus status;
  final DateTime createdAt;
  final OrderPriority priority;
  final String? customerNote;
  final String? customerAvatar;
  final DateTime? scheduledFor;
  DateTime? deliveredAt;
  double? rating;
  final double serviceFee;
  final double taxRate;

  double get subtotal => items.fold(0, (s, i) => s + i.lineTotal);
  double get tax => subtotal * taxRate;
  double get total => subtotal + serviceFee + tax;
  int get itemCount => items.fold(0, (s, i) => s + i.quantity);

  String get displayId => id.startsWith('#') ? id : '#$id';

  Duration get age => DateTime.now().difference(createdAt);
}

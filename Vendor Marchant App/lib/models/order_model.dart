enum OrderStatus { newOrder, preparing, ready, delivered, rejected }

enum OrderPriority { standard, priority, express, scheduled }

OrderStatus orderStatusFromApi(String? value) {
  switch (value) {
    case 'new_order':
      return OrderStatus.newOrder;
    case 'preparing':
      return OrderStatus.preparing;
    case 'ready':
    case 'on_the_way':
      return OrderStatus.ready;
    case 'delivered':
      return OrderStatus.delivered;
    case 'rejected':
    case 'cancelled':
      return OrderStatus.rejected;
    default:
      return OrderStatus.newOrder;
  }
}

class OrderItem {
  const OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl = '',
    this.notes = '',
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        name: (json['name'] as String?) ?? '',
        quantity: (json['qty'] as num?)?.toInt() ?? 1,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        notes: (json['notes'] as String?) ?? '',
      );

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
    required this.code,
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
    this.serviceFee = 0,
    this.deliveryFee = 0,
    this.discount = 0,
    double? subtotal,
    double? tax,
    double? total,
    this.paymentMethod = '',
    this.deliveryAddress,
  })  : _subtotal = subtotal,
        _tax = tax,
        _total = total;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: '${json['id']}',
      code: (json['code'] as String?) ?? '${json['id']}',
      customerName: (json['customer_name'] as String?) ?? 'Customer',
      customerPhone: (json['customer_phone'] as String?) ?? '',
      customerRating: (json['customer_rating'] as num?)?.toDouble() ?? 0,
      customerOrderCount: (json['customer_order_count'] as num?)?.toInt() ?? 0,
      priority: OrderPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => OrderPriority.standard,
      ),
      status: orderStatusFromApi(json['status'] as String?),
      createdAt:
          DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
      scheduledFor: json['scheduled_for'] != null
          ? DateTime.tryParse('${json['scheduled_for']}')
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse('${json['delivered_at']}')
          : null,
      customerNote: json['customer_note'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      items: ((json['items'] as List?) ?? const [])
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      serviceFee: (json['service_fee'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble(),
      paymentMethod: (json['payment_method'] as String?) ?? '',
      deliveryAddress: json['delivery_address'] as String?,
    );
  }

  /// Numeric backend id, used for API calls and routing.
  final String id;

  /// Human-readable order code (e.g. HG-1234), used for display.
  final String code;

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
  final double deliveryFee;
  final double discount;
  final String paymentMethod;
  final String? deliveryAddress;

  final double? _subtotal;
  final double? _tax;
  final double? _total;

  double get subtotal =>
      _subtotal ?? items.fold(0, (s, i) => s + i.lineTotal);
  double get tax => _tax ?? 0;
  double get total =>
      _total ?? subtotal + serviceFee + tax + deliveryFee - discount;
  int get itemCount => items.fold(0, (s, i) => s + i.quantity);

  String get displayId => '#$code';

  Duration get age => DateTime.now().difference(createdAt);
}

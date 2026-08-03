import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../utils/app_log.dart';

// ---------------------------------------------------------------------------
// JSON parsing helpers
// ---------------------------------------------------------------------------

double asDouble(dynamic v, [double fallback = 0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? fallback;
}

int asInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

DateTime? asDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString())?.toLocal();
}

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Jul 26, 2026"
String friendlyDate(DateTime? d) {
  if (d == null) return '—';
  return '${_months[d.month - 1]} ${d.day}, ${d.year}';
}

/// "Today, 10:24 AM" / "Yesterday, 6:12 PM" / "Jul 27, 2:45 PM"
String friendlyDateTime(DateTime? d) {
  if (d == null) return '—';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final ampm = d.hour >= 12 ? 'PM' : 'AM';
  final time = '$hour12:${d.minute.toString().padLeft(2, '0')} $ampm';
  if (day == today) return 'Today, $time';
  if (day == today.subtract(const Duration(days: 1))) {
    return 'Yesterday, $time';
  }
  return '${_months[d.month - 1]} ${d.day}, $time';
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// "booked" -> "Booked", "picked_up" -> "Picked up"
String statusLabel(String? raw) {
  if (raw == null || raw.isEmpty) return '—';
  return _capitalize(raw.replaceAll('_', ' '));
}

// ---------------------------------------------------------------------------
// Marketplace
// ---------------------------------------------------------------------------

class _CategoryStyle {
  const _CategoryStyle(this.icon, this.color, this.background);
  final IconData icon;
  final Color color;
  final Color background;
}

const Map<String, _CategoryStyle> _marketplaceStyles = {
  'Electronics': _CategoryStyle(
      Icons.headphones_outlined, AppColors.primaryNavy, Color(0xFFEAF1FB)),
  'Fashion': _CategoryStyle(Icons.checkroom_outlined, AppColors.accentOrange,
      AppColors.accentOrangeSoft),
  'Home': _CategoryStyle(
      Icons.chair_outlined, Color(0xFF5B8A00), Color(0xFFEFFAE6)),
  'Beauty': _CategoryStyle(
      Icons.spa_outlined, Color(0xFFB4218C), Color(0xFFFCE4F3)),
  'Groceries': _CategoryStyle(Icons.local_grocery_store_outlined,
      Color(0xFF2E9E44), Color(0xFFE8F8EB)),
  'Sports': _CategoryStyle(Icons.sports_soccer_outlined, AppColors.accentBlue,
      AppColors.accentBlueSoft),
};

_CategoryStyle _marketplaceStyle(String? category) =>
    _marketplaceStyles[category] ??
    const _CategoryStyle(Icons.shopping_bag_outlined, AppColors.primaryNavy,
        AppColors.accentBlueSoft);

/// Marketplace product from GET /customer/marketplace/products.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.description,
    this.storeName,
    this.inStock = true,
    this.icon = Icons.shopping_bag_outlined,
    this.imageColor = AppColors.accentBlueSoft,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String category;
  final double price;
  final double rating;
  final String description;
  final String? storeName;
  final bool inStock;
  final IconData icon;
  final Color imageColor;
  final String? imageUrl;

  factory Product.fromJson(Map<String, dynamic> json) {
    final category = (json['category'] as String?) ?? 'Other';
    final style = _marketplaceStyle(category);
    return Product(
      id: asInt(json['id']),
      name: (json['name'] as String?) ?? '',
      category: category,
      price: asDouble(json['price']),
      rating: asDouble(json['rating']),
      description: (json['description'] as String?) ?? '',
      storeName: json['store'] as String?,
      inStock: json['in_stock'] as bool? ?? true,
      icon: style.icon,
      imageColor: style.background,
      imageUrl: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'rating': rating,
        'description': description,
        if (storeName != null) 'store': storeName,
        'in_stock': inStock,
        if (imageUrl != null) 'image': imageUrl,
      };
}

/// Marketplace category tile from GET /customer/marketplace/categories.
class ProductCategory {
  const ProductCategory({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    this.count = 0,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final int count;

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as String?) ?? 'Other';
    final style = _marketplaceStyle(name);
    return ProductCategory(
      label: name,
      icon: style.icon,
      color: style.color,
      background: style.background,
      count: asInt(json['count']),
    );
  }
}

/// A single line item inside the marketplace cart.
class CartLine {
  CartLine({required this.product, this.quantity = 1});

  final Product product;
  int quantity;

  double get lineTotal => product.price * quantity;
}

/// In-memory marketplace cart (client state only; orders go to the API).
class MarketplaceCartStore {
  MarketplaceCartStore._();

  static const String _prefsKey = 'hillgo_market_cart';

  static final List<CartLine> _lines = [];

  /// Bumps whenever cart contents change so UI can rebuild.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static List<CartLine> get lines => List.unmodifiable(_lines);

  static bool get isEmpty => _lines.isEmpty;

  static int get itemCount =>
      _lines.fold(0, (sum, line) => sum + line.quantity);

  static void _notify() {
    revision.value++;
    _persist();
  }

  static Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      _lines.clear();
      for (final row in decoded) {
        if (row is! Map<String, dynamic>) continue;
        final productJson = row['product'];
        if (productJson is! Map<String, dynamic>) continue;
        _lines.add(CartLine(
          product: Product.fromJson(productJson),
          quantity: asInt(row['quantity'], 1),
        ));
      }
      if (_lines.isNotEmpty) revision.value++;
      AppLog.d('Restored ${_lines.length} marketplace cart line(s)', tag: 'Cart');
    } catch (e) {
      AppLog.w('Failed to restore marketplace cart', tag: 'Cart', error: e);
    }
  }

  static void _persist() {
    final payload = jsonEncode([
      for (final line in _lines)
        {
          'product': line.product.toJson(),
          'quantity': line.quantity,
        },
    ]);
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(_prefsKey, payload))
        .catchError((Object e) {
      AppLog.w('Failed to persist marketplace cart', tag: 'Cart', error: e);
    });
  }

  static void add(Product product, {int quantity = 1}) {
    final index = _lines.indexWhere((l) => l.product.id == product.id);
    if (index != -1) {
      _lines[index].quantity += quantity;
    } else {
      _lines.add(CartLine(product: product, quantity: quantity));
    }
    _notify();
  }

  static void removeAt(int index) {
    if (index >= 0 && index < _lines.length) {
      _lines.removeAt(index);
      _notify();
    }
  }

  static void setQuantity(int index, int quantity) {
    if (index < 0 || index >= _lines.length) return;
    if (quantity <= 0) {
      removeAt(index);
      return;
    }
    _lines[index].quantity = quantity;
    _notify();
  }

  static void clear() {
    if (_lines.isEmpty) return;
    _lines.clear();
    _notify();
  }

  static double get subtotal =>
      _lines.fold(0, (sum, line) => sum + line.lineTotal);
}

/// Marketplace order from GET /customer/marketplace/orders.
class MarketplaceOrderEntry {
  const MarketplaceOrderEntry({
    required this.id,
    required this.code,
    required this.storeName,
    required this.status,
    required this.total,
    required this.createdAt,
    this.items = const [],
  });

  final int id;
  final String code;
  final String storeName;
  final String status;
  final double total;
  final DateTime? createdAt;
  final List<OrderLineItem> items;

  factory MarketplaceOrderEntry.fromJson(Map<String, dynamic> json) {
    return MarketplaceOrderEntry(
      id: asInt(json['id']),
      code: (json['code'] as String?) ?? '',
      storeName: (json['store'] as String?) ?? 'Store',
      status: (json['status'] as String?) ?? 'placed',
      total: asDouble(json['total']),
      createdAt: asDate(json['created_at']),
      items: (json['items'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(OrderLineItem.fromJson)
          .toList(),
    );
  }
}

class OrderLineItem {
  const OrderLineItem({
    required this.name,
    required this.qty,
    required this.price,
    this.notes,
  });

  final String name;
  final int qty;
  final double price;
  final String? notes;

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      name: (json['name'] as String?) ?? '',
      qty: asInt(json['qty'], 1),
      price: asDouble(json['price']),
      notes: json['notes'] as String?,
    );
  }
}

// ---------------------------------------------------------------------------
// Addresses / wallet / payment methods
// ---------------------------------------------------------------------------

IconData addressIcon(String label) {
  switch (label.toLowerCase()) {
    case 'home':
      return Icons.home_outlined;
    case 'work':
    case 'office':
      return Icons.work_outline;
    default:
      return Icons.place_outlined;
  }
}

/// Saved address from GET /customer/addresses.
class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.address,
    this.lat,
    this.lng,
    this.isDefault = false,
  });

  final int id;
  final String label;
  final String address;
  final double? lat;
  final double? lng;
  final bool isDefault;

  IconData get icon => addressIcon(label);

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: asInt(json['id']),
      label: (json['label'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      lat: json['lat'] == null ? null : asDouble(json['lat']),
      lng: json['lng'] == null ? null : asDouble(json['lng']),
      isDefault: json['is_default'] == true || json['is_default'] == 1,
    );
  }
}

IconData _walletTxIcon(String? refType, bool isCredit) {
  switch (refType) {
    case 'ride':
      return Icons.two_wheeler_outlined;
    case 'food':
      return Icons.restaurant_outlined;
    case 'parcel':
      return Icons.local_shipping_outlined;
    case 'order':
      return Icons.shopping_bag_outlined;
    case 'topup':
      return Icons.add_card_outlined;
    default:
      return isCredit ? Icons.card_giftcard_outlined : Icons.receipt_long_outlined;
  }
}

/// Wallet ledger row from GET /customer/wallet/transactions.
class WalletTransaction {
  const WalletTransaction({
    required this.title,
    required this.dateLabel,
    required this.amount,
    this.isCredit = false,
    this.icon = Icons.receipt_long_outlined,
  });

  final String title;
  final String dateLabel;
  final double amount;
  final bool isCredit;
  final IconData icon;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final isCredit = json['direction'] == 'credit';
    return WalletTransaction(
      title: (json['title'] as String?) ?? 'Transaction',
      dateLabel: friendlyDateTime(asDate(json['created_at'])),
      amount: asDouble(json['amount']).abs(),
      isCredit: isCredit,
      icon: _walletTxIcon(json['ref_type'] as String?, isCredit),
    );
  }
}

/// Wallet summary from GET /customer/wallet.
class WalletSummary {
  const WalletSummary({
    required this.balance,
    required this.loyaltyPoints,
    required this.tier,
    this.nextTierName,
    this.nextTierThreshold,
    this.tiers = const [],
  });

  final double balance;
  final int loyaltyPoints;
  final String tier;
  final String? nextTierName;
  final int? nextTierThreshold;
  final List<LoyaltyTier> tiers;

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    final next = json['next_tier'];
    return WalletSummary(
      balance: asDouble(json['balance']),
      loyaltyPoints: asInt(json['loyalty_points']),
      tier: (json['tier'] as String?) ?? 'Bronze',
      nextTierName: next is Map ? next['name'] as String? : null,
      nextTierThreshold: next is Map ? asInt(next['threshold']) : null,
      tiers: (json['tiers'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(LoyaltyTier.fromJson)
          .toList(),
    );
  }
}

class LoyaltyTier {
  const LoyaltyTier({required this.name, required this.threshold});

  final String name;
  final int threshold;

  factory LoyaltyTier.fromJson(Map<String, dynamic> json) {
    return LoyaltyTier(
      name: (json['name'] as String?) ?? '',
      threshold: asInt(json['threshold']),
    );
  }
}

/// Loyalty reward from GET /customer/rewards.
class LoyaltyReward {
  const LoyaltyReward({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    this.type = 'voucher',
  });

  final int id;
  final String title;
  final String description;
  final int points;
  final String type;

  IconData get icon {
    switch (type) {
      case 'free_delivery':
        return Icons.delivery_dining;
      case 'wallet_cashback':
        return Icons.account_balance_wallet_outlined;
      case 'ride_discount':
        return Icons.local_taxi_outlined;
      default:
        return Icons.card_giftcard_outlined;
    }
  }

  factory LoyaltyReward.fromJson(Map<String, dynamic> json) {
    return LoyaltyReward(
      id: asInt(json['id']),
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      points: asInt(json['points']),
      type: (json['type'] as String?) ?? 'voucher',
    );
  }
}

/// Active promo from GET /customer/promos.
class PromoItem {
  const PromoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    this.type = '',
    this.expiresAt,
  });

  final int id;
  final String title;
  final String description;
  final String code;
  final String type;
  final DateTime? expiresAt;

  String get expiryLabel =>
      expiresAt == null ? 'No expiry' : 'Expires ${friendlyDate(expiresAt)}';

  IconData get icon {
    switch (type) {
      case 'free_delivery':
        return Icons.delivery_dining;
      case 'wallet_cashback':
        return Icons.account_balance_wallet;
      case 'ride_percent':
        return Icons.local_taxi;
      default:
        return Icons.local_offer_outlined;
    }
  }

  factory PromoItem.fromJson(Map<String, dynamic> json) {
    return PromoItem(
      id: asInt(json['id']),
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      expiresAt: asDate(json['expires_at']),
    );
  }
}

/// Saved payment method from GET /customer/payment-methods.
class PaymentMethodEntry {
  const PaymentMethodEntry({
    required this.id,
    required this.type,
    required this.label,
    this.subtitle = '',
    this.isDefault = false,
  });

  final int id;
  final String type; // wallet|card|bkash|nagad
  final String label;
  final String subtitle;
  final bool isDefault;

  IconData get icon {
    switch (type) {
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'card':
        return Icons.credit_card;
      case 'bkash':
      case 'nagad':
        return Icons.phone_iphone;
      default:
        return Icons.payments_outlined;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'wallet':
        return AppColors.primaryNavy;
      case 'card':
        return AppColors.accentBlue;
      case 'bkash':
        return AppColors.accentOrange;
      case 'nagad':
        return const Color(0xFFE53935);
      default:
        return AppColors.brandLime;
    }
  }

  factory PaymentMethodEntry.fromJson(Map<String, dynamic> json) {
    final details = json['details'];
    String subtitle = '';
    if (details is Map) {
      subtitle = details.values.whereType<Object>().map((v) => '$v').join(' · ');
    }
    return PaymentMethodEntry(
      id: asInt(json['id']),
      type: (json['type'] as String?) ?? 'card',
      label: (json['label'] as String?) ?? '',
      subtitle: subtitle,
      isDefault: json['is_default'] == true || json['is_default'] == 1,
    );
  }
}

// ---------------------------------------------------------------------------
// Districts (public endpoint, used by registration)
// ---------------------------------------------------------------------------

class DistrictOption {
  const DistrictOption({
    required this.id,
    required this.name,
    this.division,
    this.open = true,
    this.allowCustomer = true,
  });

  final String id;
  final String name;
  final String? division;
  final bool open;
  final bool allowCustomer;

  factory DistrictOption.fromJson(Map<String, dynamic> json) {
    return DistrictOption(
      id: json['id'].toString(),
      name: (json['name'] as String?) ?? '',
      division: json['division'] as String?,
      open: json['open'] == true,
      allowCustomer: json['allow_customer'] == true,
    );
  }
}

// ---------------------------------------------------------------------------
// Rides
// ---------------------------------------------------------------------------

/// Client-side vehicle presets; fares come from POST /customer/rides/quote.
class VehicleOption {
  const VehicleOption({
    required this.name,
    required this.type,
    required this.icon,
    required this.eta,
    required this.description,
  });

  final String name;
  final String type; // API value: bike|car|xl
  final IconData icon;
  final String eta;
  final String description;
}

const List<VehicleOption> kVehicleOptions = [
  VehicleOption(
    name: 'Bike',
    type: 'bike',
    icon: Icons.two_wheeler,
    eta: '3 min away',
    description: '1 seat • Fastest way around town',
  ),
  VehicleOption(
    name: 'Car',
    type: 'car',
    icon: Icons.directions_car_filled,
    eta: '5 min away',
    description: '4 seats • Comfortable AC ride',
  ),
  VehicleOption(
    name: 'XL',
    type: 'xl',
    icon: Icons.airport_shuttle,
    eta: '8 min away',
    description: '6 seats • Extra space for groups',
  ),
];

/// Fare breakdown from POST /customer/rides/quote.
class RideQuote {
  const RideQuote({
    required this.fare,
    required this.base,
    required this.perKm,
    required this.perMin,
    required this.minimum,
    required this.multiplier,
    required this.distanceKm,
    required this.durationMin,
  });

  final double fare;
  final double base;
  final double perKm;
  final double perMin;
  final double minimum;
  final double multiplier;
  final double distanceKm;
  final double durationMin;

  factory RideQuote.fromJson(Map<String, dynamic> json) {
    return RideQuote(
      fare: asDouble(json['fare']),
      base: asDouble(json['base']),
      perKm: asDouble(json['per_km']),
      perMin: asDouble(json['per_min']),
      minimum: asDouble(json['minimum']),
      multiplier: asDouble(json['multiplier'], 1),
      distanceKm: asDouble(json['distance_km']),
      durationMin: asDouble(json['duration_min']),
    );
  }
}

class RideDriverInfo {
  const RideDriverInfo({
    required this.name,
    required this.rating,
    required this.vehicleModel,
    required this.plateNumber,
    required this.phone,
    this.lat,
    this.lng,
  });

  final String name;
  final double rating;
  final String vehicleModel;
  final String plateNumber;
  final String phone;
  final double? lat;
  final double? lng;

  factory RideDriverInfo.fromJson(Map<String, dynamic> json) {
    return RideDriverInfo(
      name: (json['name'] as String?) ?? 'Driver',
      rating: asDouble(json['rating']),
      vehicleModel: statusLabel(json['vehicle'] as String?),
      plateNumber: (json['plate'] as String?) ?? '—',
      phone: (json['phone'] as String?) ?? '',
      lat: json['lat'] == null ? null : asDouble(json['lat']),
      lng: json['lng'] == null ? null : asDouble(json['lng']),
    );
  }
}

/// Ride from POST/GET /customer/rides.
class RideEntry {
  const RideEntry({
    required this.id,
    required this.code,
    required this.vehicleType,
    required this.pickup,
    required this.drop,
    required this.distanceKm,
    required this.durationMin,
    required this.fare,
    required this.status,
    required this.paymentMethod,
    this.rating,
    this.createdAt,
    this.driver,
    this.pickupLat,
    this.pickupLng,
    this.dropLat,
    this.dropLng,
  });

  final int id;
  final String code;
  final String vehicleType;
  final String pickup;
  final String drop;
  final double distanceKm;
  final double durationMin;
  final double fare;
  final String status;
  final String paymentMethod;
  final int? rating;
  final DateTime? createdAt;
  final RideDriverInfo? driver;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropLat;
  final double? dropLng;

  String get dateLabel => friendlyDateTime(createdAt);

  factory RideEntry.fromJson(Map<String, dynamic> json) {
    return RideEntry(
      id: asInt(json['id']),
      code: (json['code'] as String?) ?? '',
      vehicleType: (json['vehicle_type'] as String?) ?? 'bike',
      pickup: (json['pickup'] as String?) ?? '',
      drop: (json['drop'] as String?) ?? '',
      distanceKm: asDouble(json['distance_km']),
      durationMin: asDouble(json['duration_min']),
      fare: asDouble(json['fare']),
      status: (json['status'] as String?) ?? 'searching',
      paymentMethod: (json['payment_method'] as String?) ?? 'cash',
      rating: json['rating'] == null ? null : asInt(json['rating']),
      createdAt: asDate(json['created_at']),
      driver: json['driver'] is Map<String, dynamic>
          ? RideDriverInfo.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      pickupLat: json['pickup_lat'] == null ? null : asDouble(json['pickup_lat']),
      pickupLng: json['pickup_lng'] == null ? null : asDouble(json['pickup_lng']),
      dropLat: json['drop_lat'] == null ? null : asDouble(json['drop_lat']),
      dropLng: json['drop_lng'] == null ? null : asDouble(json['drop_lng']),
    );
  }
}

// ---------------------------------------------------------------------------
// Food
// ---------------------------------------------------------------------------

class FoodMenuItem {
  const FoodMenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.color = AppColors.accentOrangeSoft,
    this.icon = Icons.restaurant_menu,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final Color color;
  final IconData icon;
  final String? imageUrl;

  factory FoodMenuItem.fromJson(Map<String, dynamic> json) {
    return FoodMenuItem(
      id: asInt(json['id']),
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      price: asDouble(json['price']),
      imageUrl: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        if (imageUrl != null) 'image': imageUrl,
      };
}

class FoodMenuCategory {
  const FoodMenuCategory({required this.name, required this.items});

  final String name;
  final List<FoodMenuItem> items;

  factory FoodMenuCategory.fromJson(Map<String, dynamic> json) {
    return FoodMenuCategory(
      name: (json['name'] as String?) ?? '',
      items: (json['items'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(FoodMenuItem.fromJson)
          .toList(),
    );
  }
}

/// Restaurant from GET /customer/food/restaurants (menu comes with details).
class RestaurantInfo {
  const RestaurantInfo({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.time,
    required this.fee,
    this.color = AppColors.accentOrangeSoft,
    this.menu = const [],
    this.imageUrl,
    this.freeDelivery = false,
    this.isOpen = true,
    this.acceptingOrders = true,
  });

  final int id;
  final String name;
  final String cuisine;
  final double rating;
  final String time;
  final double fee;
  final Color color;
  final List<FoodMenuCategory> menu;
  final String? imageUrl;
  final bool freeDelivery;
  final bool isOpen;
  final bool acceptingOrders;

  factory RestaurantInfo.fromJson(Map<String, dynamic> json) {
    final cuisines = (json['cuisines'] as List? ?? [])
        .whereType<String>()
        .toList();
    return RestaurantInfo(
      id: asInt(json['id']),
      name: (json['name'] as String?) ?? '',
      cuisine: cuisines.isNotEmpty
          ? cuisines.join(' • ')
          : (json['cuisine'] as String?) ?? '',
      rating: asDouble(json['rating']),
      time: (json['eta'] as String?) ?? '30-45 min',
      fee: asDouble(json['fee']),
      menu: (json['menu'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(FoodMenuCategory.fromJson)
          .toList(),
      imageUrl: json['image'] as String?,
      freeDelivery: json['free_delivery'] == true,
      isOpen: json['is_open'] != false,
      acceptingOrders: json['accepting_orders'] != false,
    );
  }
}

class FoodCartLine {
  FoodCartLine({
    required this.item,
    required this.restaurantId,
    required this.restaurantName,
    this.quantity = 1,
  });

  final FoodMenuItem item;
  final int restaurantId;
  final String restaurantName;
  int quantity;

  double get lineTotal => item.price * quantity;
}

/// In-memory food cart (client state only; checkout goes to the API).
class FoodCartStore {
  FoodCartStore._();

  static const String _prefsKey = 'hillgo_food_cart';

  static final List<FoodCartLine> _lines = [];

  /// Bumps whenever cart contents change so UI can rebuild.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static List<FoodCartLine> get lines => List.unmodifiable(_lines);

  static bool get isEmpty => _lines.isEmpty;

  static int get itemCount =>
      _lines.fold(0, (sum, line) => sum + line.quantity);

  static int? get restaurantId => _lines.isEmpty ? null : _lines.first.restaurantId;

  static String? get restaurantName =>
      _lines.isEmpty ? null : _lines.first.restaurantName;

  static void _notify() {
    revision.value++;
    _persist();
  }

  static Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      _lines.clear();
      for (final row in decoded) {
        if (row is! Map<String, dynamic>) continue;
        final itemJson = row['item'];
        if (itemJson is! Map<String, dynamic>) continue;
        _lines.add(FoodCartLine(
          item: FoodMenuItem.fromJson(itemJson),
          restaurantId: asInt(row['restaurant_id']),
          restaurantName: (row['restaurant_name'] as String?) ?? '',
          quantity: asInt(row['quantity'], 1),
        ));
      }
      if (_lines.isNotEmpty) revision.value++;
      AppLog.d('Restored ${_lines.length} food cart line(s)', tag: 'Cart');
    } catch (e) {
      AppLog.w('Failed to restore food cart', tag: 'Cart', error: e);
    }
  }

  static void _persist() {
    final payload = jsonEncode([
      for (final line in _lines)
        {
          'item': line.item.toJson(),
          'restaurant_id': line.restaurantId,
          'restaurant_name': line.restaurantName,
          'quantity': line.quantity,
        },
    ]);
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(_prefsKey, payload))
        .catchError((Object e) {
      AppLog.w('Failed to persist food cart', tag: 'Cart', error: e);
    });
  }

  static void add(
    FoodMenuItem item,
    int restaurantId,
    String restaurantName, {
    int quantity = 1,
  }) {
    // One restaurant per order — starting a new restaurant clears the cart.
    if (_lines.isNotEmpty && _lines.first.restaurantId != restaurantId) {
      _lines.clear();
    }
    final existingIndex = _lines.indexWhere((line) => line.item.id == item.id);
    if (existingIndex != -1) {
      _lines[existingIndex].quantity += quantity;
    } else {
      _lines.add(FoodCartLine(
        item: item,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        quantity: quantity,
      ));
    }
    _notify();
  }

  static void removeAt(int index) {
    if (index >= 0 && index < _lines.length) {
      _lines.removeAt(index);
      _notify();
    }
  }

  static void setQuantity(int index, int quantity) {
    if (index < 0 || index >= _lines.length) return;
    if (quantity <= 0) {
      removeAt(index);
      return;
    }
    _lines[index].quantity = quantity;
    _notify();
  }

  static void clear() {
    if (_lines.isEmpty) return;
    _lines.clear();
    _notify();
  }

  static double get subtotal =>
      _lines.fold(0, (sum, line) => sum + line.lineTotal);
}

/// Food order from POST/GET /customer/food/orders.
class FoodOrder {
  const FoodOrder({
    required this.id,
    required this.code,
    required this.restaurant,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.deliveryAddress,
    this.createdAt,
    this.items = const [],
  });

  final int id;
  final String code;
  final String restaurant;
  final String status;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String paymentMethod;
  final String deliveryAddress;
  final DateTime? createdAt;
  final List<OrderLineItem> items;

  factory FoodOrder.fromJson(Map<String, dynamic> json) {
    return FoodOrder(
      id: asInt(json['id']),
      code: (json['code'] as String?) ?? '',
      restaurant: (json['restaurant'] as String?) ?? 'Restaurant',
      status: (json['status'] as String?) ?? 'placed',
      subtotal: asDouble(json['subtotal']),
      deliveryFee: asDouble(json['delivery_fee']),
      discount: asDouble(json['discount']),
      total: asDouble(json['total']),
      paymentMethod: (json['payment_method'] as String?) ?? 'cash',
      deliveryAddress: (json['delivery_address'] as String?) ?? '',
      createdAt: asDate(json['created_at']),
      items: (json['items'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(OrderLineItem.fromJson)
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Parcels
// ---------------------------------------------------------------------------

/// Mutable booking draft carried across the parcel booking flow screens.
/// Fare comes from POST /customer/parcels/quote (never computed locally).
/// Weight and distance must be set by the user (or computed from lat/lng)
/// before quote/create — no silent 5 km / 2 kg defaults.
class ParcelBooking {
  ParcelBooking({
    this.parcelType,
    this.pickupAddress = '',
    this.pickupContact = '',
    this.pickupPhone = '',
    this.receiverAddress = '',
    this.receiverContact = '',
    this.receiverPhone = '',
    this.pickupLat,
    this.pickupLng,
    this.dropLat,
    this.dropLng,
    this.distanceKm = 0,
    this.weightKg = 0,
    this.priority = 'standard',
    this.paymentMethod = 'cash',
    this.quote,
  });

  String? parcelType;
  String pickupAddress;
  String pickupContact;
  String pickupPhone;
  String receiverAddress;
  String receiverContact;
  String receiverPhone;
  double? pickupLat;
  double? pickupLng;
  double? dropLat;
  double? dropLng;
  double distanceKm;
  double weightKg;
  String priority; // standard|express|priority
  String paymentMethod; // cash|wallet
  ParcelQuote? quote;
}

/// Fare breakdown from POST /customer/parcels/quote.
class ParcelQuote {
  const ParcelQuote({
    required this.fare,
    required this.base,
    required this.perKm,
    required this.perKg,
    required this.minimum,
    required this.multiplier,
    required this.priority,
    required this.distanceKm,
    required this.weightKg,
  });

  final double fare;
  final double base;
  final double perKm;
  final double perKg;
  final double minimum;
  final double multiplier;
  final String priority;
  final double distanceKm;
  final double weightKg;

  factory ParcelQuote.fromJson(Map<String, dynamic> json) {
    return ParcelQuote(
      fare: asDouble(json['fare']),
      base: asDouble(json['base']),
      perKm: asDouble(json['per_km']),
      perKg: asDouble(json['per_kg']),
      minimum: asDouble(json['minimum']),
      multiplier: asDouble(json['multiplier'], 1),
      priority: (json['priority'] as String?) ?? 'standard',
      distanceKm: asDouble(json['distance_km']),
      weightKg: asDouble(json['weight_kg']),
    );
  }
}

/// Parcel from POST/GET /customer/parcels.
class ParcelEntry {
  const ParcelEntry({
    required this.id,
    required this.code,
    required this.type,
    required this.status,
    required this.pickupAddress,
    required this.dropAddress,
    required this.receiverName,
    required this.weightKg,
    required this.distanceKm,
    required this.fare,
    required this.paymentMethod,
    this.priority = 'standard',
    this.createdAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.agentName,
    this.agentPhone,
    this.pickupOtp,
    this.deliveryOtp,
  });

  final int id;
  final String code;
  final String type;
  final String status; // booked|picked_up|in_transit|delivered|cancelled
  final String pickupAddress;
  final String dropAddress;
  final String receiverName;
  final double weightKg;
  final double distanceKm;
  final double fare;
  final String paymentMethod;
  final String priority;
  final DateTime? createdAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? agentName;
  final String? agentPhone;
  final String? pickupOtp;
  final String? deliveryOtp;

  String get dateLabel => friendlyDate(createdAt);

  factory ParcelEntry.fromJson(Map<String, dynamic> json) {
    final agent = json['agent'];
    return ParcelEntry(
      id: asInt(json['id']),
      code: (json['code'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'Box',
      status: (json['status'] as String?) ?? 'booked',
      pickupAddress: (json['pickup_address'] as String?) ?? '',
      dropAddress: (json['drop_address'] as String?) ?? '',
      receiverName: (json['receiver_name'] as String?) ?? '',
      weightKg: asDouble(json['weight_kg']),
      distanceKm: asDouble(json['distance_km']),
      fare: asDouble(json['fare']),
      paymentMethod: (json['payment_method'] as String?) ?? 'cash',
      priority: (json['priority'] as String?) ?? 'standard',
      createdAt: asDate(json['created_at']),
      pickedUpAt: asDate(json['picked_up_at']),
      deliveredAt: asDate(json['delivered_at']),
      agentName: agent is Map ? agent['name'] as String? : null,
      agentPhone: agent is Map ? agent['phone'] as String? : null,
      pickupOtp: json['pickup_otp']?.toString(),
      deliveryOtp: json['delivery_otp']?.toString(),
    );
  }
}

// ---------------------------------------------------------------------------
// Hotels
// ---------------------------------------------------------------------------

const List<Color> _hotelPalette = [
  Color(0xFFE8E0FF),
  Color(0xFFE0F4FF),
  Color(0xFFE8F8EB),
  Color(0xFFFFE8D6),
  Color(0xFFEAF1FB),
];

/// Hotel from GET /customer/hotels.
class HotelInfo {
  const HotelInfo({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.pricePerNight,
    required this.amenities,
    required this.description,
    this.imageUrl,
    this.color = const Color(0xFFEAF1FB),
    this.reviews = 0,
    this.stars = 3,
  });

  final int id;
  final String name;
  final String location;
  final double rating;
  final double pricePerNight;
  final List<String> amenities;
  final String description;
  final String? imageUrl;
  final Color color;
  final int reviews;
  final int stars;

  factory HotelInfo.fromJson(Map<String, dynamic> json) {
    final id = asInt(json['id']);
    return HotelInfo(
      id: id,
      name: (json['name'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
      rating: asDouble(json['rating']),
      pricePerNight: asDouble(json['price_per_night']),
      amenities:
          (json['amenities'] as List? ?? []).whereType<String>().toList(),
      description: (json['description'] as String?) ?? '',
      imageUrl: json['image'] as String?,
      color: _hotelPalette[id % _hotelPalette.length],
      reviews: asInt(json['reviews_count']),
      stars: asInt(json['stars'], 3),
    );
  }
}

/// Mutable draft carried through the hotel booking flow. Totals shown are
/// estimates; the server recomputes them at booking time.
class HotelBooking {
  HotelBooking({
    required this.hotel,
    DateTime? checkIn,
    DateTime? checkOut,
    this.guests = 2,
    this.rooms = 1,
    this.guestName = '',
    this.guestPhone = '',
  })  : checkIn = checkIn ?? DateTime.now().add(const Duration(days: 1)),
        checkOut = checkOut ?? DateTime.now().add(const Duration(days: 3));

  final HotelInfo hotel;
  DateTime checkIn;
  DateTime checkOut;
  int guests;
  int rooms;
  String guestName;
  String guestPhone;

  /// Set from the server response after POST /customer/hotels/bookings.
  String? confirmedCode;
  double? confirmedTotal;

  int get nights {
    final n = DateTime(checkOut.year, checkOut.month, checkOut.day)
        .difference(DateTime(checkIn.year, checkIn.month, checkIn.day))
        .inDays;
    return n < 1 ? 1 : n;
  }

  String get checkInLabel => friendlyDate(checkIn);
  String get checkOutLabel => friendlyDate(checkOut);

  double get roomTotal => hotel.pricePerNight * nights * rooms;
  double get serviceFee => roomTotal * 0.05;
  double get total => confirmedTotal ?? (roomTotal + serviceFee);
}

/// Hotel booking from GET /customer/hotels/bookings/list.
class HotelBookingEntry {
  const HotelBookingEntry({
    required this.id,
    required this.bookingId,
    required this.hotelName,
    required this.location,
    required this.datesLabel,
    required this.status,
    required this.amount,
  });

  final int id;
  final String bookingId;
  final String hotelName;
  final String location;
  final String datesLabel;
  final String status;
  final double amount;

  factory HotelBookingEntry.fromJson(Map<String, dynamic> json) {
    final hotel = json['hotel'];
    final checkIn = asDate(json['check_in']);
    final checkOut = asDate(json['check_out']);
    return HotelBookingEntry(
      id: asInt(json['id']),
      bookingId: (json['code'] as String?) ?? '',
      hotelName: hotel is Map ? (hotel['name'] as String?) ?? 'Hotel' : 'Hotel',
      location: hotel is Map ? (hotel['location'] as String?) ?? '' : '',
      datesLabel: '${friendlyDate(checkIn)} – ${friendlyDate(checkOut)}',
      status: statusLabel(json['status'] as String?),
      amount: asDouble(json['total']),
    );
  }
}

// ---------------------------------------------------------------------------
// Rentals
// ---------------------------------------------------------------------------

IconData rentalCategoryIcon(String category) {
  switch (category) {
    case 'SUV':
      return Icons.airport_shuttle;
    case 'Bike':
      return Icons.two_wheeler;
    case 'Scooter':
      return Icons.electric_scooter;
    case 'Van':
      return Icons.airport_shuttle_outlined;
    default:
      return Icons.directions_car_filled;
  }
}

const List<Color> _rentalPalette = [
  Color(0xFFEAF1FB),
  Color(0xFFE8F8EB),
  Color(0xFFFFE8D6),
  Color(0xFFE0F4FF),
  Color(0xFFE8E0FF),
];

/// Rental vehicle from GET /customer/rentals.
class RentalVehicle {
  const RentalVehicle({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePerDay,
    required this.seats,
    required this.transmission,
    required this.fuel,
    required this.rating,
    required this.description,
    this.imageUrl,
    this.color = const Color(0xFFEAF1FB),
    this.icon = Icons.directions_car_filled,
    this.features = const [],
  });

  final int id;
  final String name;
  final String category;
  final double pricePerDay;
  final int seats;
  final String transmission;
  final String fuel;
  final double rating;
  final String description;
  final String? imageUrl;
  final Color color;
  final IconData icon;
  final List<String> features;

  factory RentalVehicle.fromJson(Map<String, dynamic> json) {
    final id = asInt(json['id']);
    final category = (json['category'] as String?) ?? 'Car';
    return RentalVehicle(
      id: id,
      name: (json['name'] as String?) ?? '',
      category: category,
      pricePerDay: asDouble(json['price_per_day']),
      seats: asInt(json['seats'], 4),
      transmission: (json['transmission'] as String?) ?? 'Manual',
      fuel: (json['fuel'] as String?) ?? 'Petrol',
      rating: asDouble(json['rating']),
      description: (json['description'] as String?) ?? '',
      imageUrl: json['image'] as String?,
      color: _rentalPalette[id % _rentalPalette.length],
      icon: rentalCategoryIcon(category),
      features: (json['features'] as List? ?? []).whereType<String>().toList(),
    );
  }
}

/// Mutable draft carried through the rental booking flow. Totals shown are
/// estimates; the server recomputes them at booking time.
class RentalBooking {
  RentalBooking({
    required this.vehicle,
    this.pickupLocation = '',
    this.dropoffLocation = 'Same as pickup',
    DateTime? startDate,
    DateTime? endDate,
    this.withDriver = false,
    this.renterName = '',
    this.renterPhone = '',
  })  : startDate = startDate ?? DateTime.now().add(const Duration(days: 1)),
        endDate = endDate ?? DateTime.now().add(const Duration(days: 2));

  final RentalVehicle vehicle;
  String pickupLocation;
  String dropoffLocation;
  DateTime startDate;
  DateTime endDate;
  bool withDriver;
  String renterName;
  String renterPhone;

  /// Set from the server response after POST /customer/rentals/bookings.
  String? confirmedCode;
  double? confirmedTotal;

  int get days {
    final d = DateTime(endDate.year, endDate.month, endDate.day)
            .difference(DateTime(startDate.year, startDate.month, startDate.day))
            .inDays +
        1;
    return d < 1 ? 1 : d;
  }

  String get startLabel => friendlyDate(startDate);
  String get endLabel => friendlyDate(endDate);

  double get vehicleTotal => vehicle.pricePerDay * days;
  double get driverFee => withDriver ? 1500.0 * days : 0;
  double get insuranceFee => 300.0 * days;
  double get total => confirmedTotal ?? (vehicleTotal + driverFee + insuranceFee);
}

/// Rental booking from GET /customer/rentals/bookings/list.
class RentalHistoryEntry {
  const RentalHistoryEntry({
    required this.id,
    required this.rentalId,
    required this.vehicleName,
    required this.category,
    required this.datesLabel,
    required this.status,
    required this.amount,
  });

  final int id;
  final String rentalId;
  final String vehicleName;
  final String category;
  final String datesLabel;
  final String status;
  final double amount;

  factory RentalHistoryEntry.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'];
    final start = asDate(json['start_date']);
    final end = asDate(json['end_date']);
    return RentalHistoryEntry(
      id: asInt(json['id']),
      rentalId: (json['code'] as String?) ?? '',
      vehicleName:
          vehicle is Map ? (vehicle['name'] as String?) ?? 'Vehicle' : 'Vehicle',
      category: vehicle is Map ? (vehicle['category'] as String?) ?? '' : '',
      datesLabel: '${friendlyDate(start)} – ${friendlyDate(end)}',
      status: statusLabel(json['status'] as String?),
      amount: asDouble(json['total']),
    );
  }
}

// ---------------------------------------------------------------------------
// SOS
// ---------------------------------------------------------------------------

class EmergencyContact {
  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
  });

  final int id;
  final String name;
  final String phone;
  final String relation;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: asInt(json['id']),
      name: (json['name'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      relation: (json['relation'] as String?) ?? 'Contact',
    );
  }
}

String sosTypeLabel(String type) {
  switch (type) {
    case 'police':
      return 'Police call request';
    case 'ambulance':
      return 'Ambulance request';
    case 'location_share':
      return 'Location shared';
    case 'ride_sos':
      return 'Ride SOS';
    default:
      return 'SOS Alert';
  }
}

class SosAlertEntry {
  const SosAlertEntry({
    required this.id,
    required this.type,
    required this.timeLabel,
    required this.status,
  });

  final int id;
  final String type;
  final String timeLabel;
  final String status; // Active | Resolved

  factory SosAlertEntry.fromJson(Map<String, dynamic> json) {
    return SosAlertEntry(
      id: asInt(json['id']),
      type: sosTypeLabel((json['type'] as String?) ?? 'sos'),
      timeLabel: friendlyDateTime(asDate(json['created_at'])),
      status: json['status'] == 'resolved' ? 'Resolved' : 'Active',
    );
  }
}

// ---------------------------------------------------------------------------
// Notifications
// ---------------------------------------------------------------------------

class _NotificationStyle {
  const _NotificationStyle(this.icon, this.color, this.background);
  final IconData icon;
  final Color color;
  final Color background;
}

_NotificationStyle _notificationStyle(String type) {
  switch (type) {
    case 'ride':
      return const _NotificationStyle(
          Icons.local_taxi, Color(0xFF004899), Color(0xFFEAF1FB));
    case 'food':
    case 'new_order':
      return const _NotificationStyle(
          Icons.delivery_dining, Color(0xFFFF6B00), Color(0xFFFFE4D1));
    case 'parcel':
      return const _NotificationStyle(
          Icons.inventory_2_outlined, Color(0xFF2B7DE9), Color(0xFFD6E8FF));
    case 'wallet':
    case 'wallet_topup':
      return const _NotificationStyle(Icons.account_balance_wallet_outlined,
          Color(0xFF004899), Color(0xFFEAF1FB));
    case 'hotel':
      return const _NotificationStyle(
          Icons.hotel_outlined, Color(0xFF7C4DFF), Color(0xFFE8E0FF));
    case 'rental':
      return const _NotificationStyle(Icons.directions_car_filled_outlined,
          Color(0xFF00897B), Color(0xFFD9F2EF));
    case 'marketplace':
      return const _NotificationStyle(
          Icons.shopping_bag_outlined, Color(0xFF6B8E23), Color(0xFFE9EFD6));
    case 'loyalty':
      return const _NotificationStyle(
          Icons.emoji_events_outlined, Color(0xFFB4218C), Color(0xFFFCE4F3));
    case 'sos':
      return const _NotificationStyle(
          Icons.sos_outlined, Color(0xFFE53935), Color(0xFFFFEBEE));
    default:
      return const _NotificationStyle(
          Icons.notifications_outlined, Color(0xFF004899), Color(0xFFEAF1FB));
  }
}

/// Notification from GET /customer/notifications.
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

  final int id;
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

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final style = _notificationStyle((json['type'] as String?) ?? 'general');
    return AppNotification(
      id: asInt(json['id']),
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      timeLabel: friendlyDateTime(asDate(json['created_at'])),
      icon: style.icon,
      iconColor: style.color,
      iconBg: style.background,
      isRead: json['read_at'] != null,
    );
  }
}

import 'package:flutter/material.dart';

int _asInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

double _asDouble(dynamic value, [double fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

bool _asBool(dynamic value, [bool fallback = false]) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = '$value'.toLowerCase();
  if (text == '1' || text == 'true') return true;
  if (text == '0' || text == 'false') return false;
  return fallback;
}

class CategoryModel {
  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.itemCount,
    required this.isVisible,
    required this.sortOrder,
    this.iconKey = 'category',
  });

  /// Known icon keys the app writes to / reads from the backend `icon` field.
  static const Map<String, IconData> icons = {
    'bakery': Icons.bakery_dining_outlined,
    'cafe': Icons.local_cafe_outlined,
    'egg': Icons.egg_outlined,
    'icecream': Icons.icecream_outlined,
    'inventory': Icons.inventory_2_outlined,
    'headphones': Icons.headphones_outlined,
    'apparel': Icons.checkroom_outlined,
    'home': Icons.chair_outlined,
    'restaurant': Icons.restaurant_outlined,
    'grocery': Icons.local_grocery_store_outlined,
    'beauty': Icons.spa_outlined,
    'category': Icons.category_outlined,
  };

  static const Color _defaultColor = Color(0xFFE3F2FD);

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final iconKey = (json['icon'] as String?) ?? 'category';
    return CategoryModel(
      id: '${json['id']}',
      name: (json['name'] as String?) ?? '',
      iconKey: iconKey,
      icon: icons[iconKey] ?? Icons.category_outlined,
      color: _parseColor(json['color'] as String?),
      itemCount: _asInt(json['item_count']),
      isVisible: _asBool(json['is_visible'], true),
      sortOrder: _asInt(json['sort_order']),
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return _defaultColor;
    var value = hex.replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    final parsed = int.tryParse(value, radix: 16);
    return parsed != null ? Color(parsed) : _defaultColor;
  }

  final String id;
  final String name;
  final IconData icon;
  final String iconKey;
  final Color color;
  int itemCount;
  bool isVisible;
  int sortOrder;

  CategoryModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    String? iconKey,
    Color? color,
    int? itemCount,
    bool? isVisible,
    int? sortOrder,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      iconKey: iconKey ?? this.iconKey,
      color: color ?? this.color,
      itemCount: itemCount ?? this.itemCount,
      isVisible: isVisible ?? this.isVisible,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class ProductModel {
  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.sku,
    required this.stock,
    required this.lowStockAlert,
    required this.imageUrls,
    this.categoryId,
    this.trackStock = true,
    this.status = 'active',
    this.localImagePath,
    this.localImageBytes,
    this.localImageName,
  });

  factory ProductModel.fromJson(
    Map<String, dynamic> json, {
    String? Function(String?)? resolveUrl,
  }) {
    final images = ((json['images'] as List?) ?? const [])
        .map((e) => resolveUrl != null ? (resolveUrl('$e') ?? '$e') : '$e')
        .toList();
    return ProductModel(
      id: '${json['id']}',
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      categoryId:
          json['category_id'] != null ? '${json['category_id']}' : null,
      price: _asDouble(json['price']),
      sku: (json['sku'] as String?) ?? '',
      stock: _asInt(json['stock']),
      lowStockAlert: _asInt(json['low_stock_alert'], 5),
      trackStock: _asBool(json['track_stock'], true),
      status: (json['status'] as String?) ?? 'active',
      imageUrls: images,
    );
  }

  /// Empty string means the product has not been created on the server yet.
  final String id;
  String name;
  String description;
  String category;
  String? categoryId;
  double price;
  String sku;
  int stock;
  int lowStockAlert;
  List<String> imageUrls;
  bool trackStock;
  String status;

  /// Path to a freshly picked local image awaiting multipart upload.
  String? localImagePath;

  /// In-memory bytes for web-safe preview/upload (Image.file is unsupported on web).
  List<int>? localImageBytes;

  /// Original filename for multipart uploads when [localImageBytes] is set.
  String? localImageName;

  bool get isNew => id.isEmpty;
  bool get isLowStock => trackStock && stock <= lowStockAlert;

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? categoryId,
    double? price,
    String? sku,
    int? stock,
    int? lowStockAlert,
    List<String>? imageUrls,
    bool? trackStock,
    String? status,
    String? localImagePath,
    List<int>? localImageBytes,
    String? localImageName,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      sku: sku ?? this.sku,
      stock: stock ?? this.stock,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
      imageUrls: imageUrls ?? this.imageUrls,
      trackStock: trackStock ?? this.trackStock,
      status: status ?? this.status,
      localImagePath: localImagePath ?? this.localImagePath,
      localImageBytes: localImageBytes ?? this.localImageBytes,
      localImageName: localImageName ?? this.localImageName,
    );
  }
}

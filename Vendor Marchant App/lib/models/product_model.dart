import 'package:flutter/material.dart';

class CategoryModel {
  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.itemCount,
    required this.isVisible,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  int itemCount;
  bool isVisible;
  int sortOrder;

  CategoryModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    int? itemCount,
    bool? isVisible,
    int? sortOrder,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
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
    this.trackStock = true,
  });

  final String id;
  String name;
  String description;
  String category;
  double price;
  String sku;
  int stock;
  int lowStockAlert;
  List<String> imageUrls;
  bool trackStock;

  bool get isLowStock => trackStock && stock <= lowStockAlert;

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? sku,
    int? stock,
    int? lowStockAlert,
    List<String>? imageUrls,
    bool? trackStock,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      sku: sku ?? this.sku,
      stock: stock ?? this.stock,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
      imageUrls: imageUrls ?? this.imageUrls,
      trackStock: trackStock ?? this.trackStock,
    );
  }
}

import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/repositories.dart';

class ProductsProvider extends ChangeNotifier {
  ProductsProvider(this._repo);

  final ProductRepository _repo;

  List<ProductModel> products = [];
  List<CategoryModel> categories = [];
  bool isLoading = false;
  bool isSaving = false;
  String? error;
  String searchQuery = '';
  String categoryFilter = 'All Products';
  String categorySearch = '';

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      products = await _repo.getProducts();
      categories = await _repo.getCategories();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  List<ProductModel> get filteredProducts {
    var list = List<ProductModel>.from(products);
    if (categoryFilter != 'All Products') {
      list = list.where((p) => p.category == categoryFilter).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.sku.toLowerCase().contains(q) ||
                p.category.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  List<CategoryModel> get filteredCategories {
    if (categorySearch.trim().isEmpty) return categories;
    final q = categorySearch.toLowerCase();
    return categories.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  int get totalItems => products.length;
  int get lowStockCount => products.where((p) => p.isLowStock).length;

  List<String> get categoryNames =>
      ['All Products', ...categories.map((c) => c.name)];

  void setSearch(String q) {
    searchQuery = q;
    notifyListeners();
  }

  void setCategoryFilter(String c) {
    categoryFilter = c;
    notifyListeners();
  }

  void setCategorySearch(String q) {
    categorySearch = q;
    notifyListeners();
  }

  Future<void> toggleCategoryVisibility(String id, bool visible) async {
    final cat = categories.firstWhere((c) => c.id == id);
    final previous = cat.isVisible;
    cat.isVisible = visible;
    notifyListeners();
    try {
      await _repo.setCategoryVisibility(id, visible);
    } catch (e) {
      cat.isVisible = previous;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = categories.removeAt(oldIndex);
    categories.insert(newIndex, item);
    for (var i = 0; i < categories.length; i++) {
      categories[i].sortOrder = i;
    }
    notifyListeners();
    try {
      await _repo.reorderCategories(categories.map((c) => c.id).toList());
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addCategory(String name) async {
    isSaving = true;
    notifyListeners();
    try {
      final created = await _repo.addCategory(name);
      categories.add(created);
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  ProductModel? findById(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  String? categoryIdForName(String name) {
    for (final c in categories) {
      if (c.name == name) return c.id;
    }
    return null;
  }

  Future<bool> saveProduct(ProductModel product) async {
    isSaving = true;
    notifyListeners();
    try {
      product.categoryId ??= categoryIdForName(product.category);
      await _repo.saveProduct(product);
      await load();
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _repo.deleteProduct(id);
      products = products.where((p) => p.id != id).toList();
      error = null;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  ProductModel newBlankProduct() {
    return ProductModel(
      id: '',
      name: '',
      description: '',
      category: categories.isNotEmpty ? categories.first.name : '',
      categoryId: categories.isNotEmpty ? categories.first.id : null,
      price: 0,
      sku: '',
      stock: 0,
      lowStockAlert: 5,
      imageUrls: [],
    );
  }
}

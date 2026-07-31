import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/marketplace_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/cart_icon_button.dart';
import '../../widgets/view_cart_bar.dart';
import '../../widgets/load_state_views.dart';
import '../../widgets/product_card.dart';
import 'marketplace_cart_screen.dart';
import 'product_details_screen.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key, this.category = 'All'});

  static const String routeName = '/market/products';

  final String category;

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  late String _selectedCategory = widget.category;
  String _sort = 'Popular';
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<Product> _products = [];
  List<ProductCategory> _categories = [];
  bool _loading = true;
  String? _error;

  static const _sortOptions = ['Popular', 'Price: Low', 'Price: High', 'Rating'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        MarketplaceApi.categories(),
        MarketplaceApi.products(
          category: _selectedCategory,
          query: _searchController.text.trim(),
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _categories = results[0] as List<ProductCategory>;
        _products = results[1] as List<Product>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  List<Product> get _sortedProducts {
    final products = List<Product>.from(_products);
    switch (_sort) {
      case 'Price: Low':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Rating':
        products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        break;
    }
    return products;
  }

  void _openDetails(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
    );
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MarketplaceCartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final categories = ['All', ..._categories.map((c) => c.label)];
    final products = _sortedProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AnimatedBuilder(
        animation: MarketplaceCartStore.revision,
        builder: (context, _) {
          return ViewCartBar(
            itemCount: MarketplaceCartStore.itemCount,
            subtotal: MarketplaceCartStore.subtotal,
            onTap: _openCart,
          );
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackBar(
                title: 'Products',
                subtitle: _loading ? 'Loading…' : '${products.length} items found',
                actions: [
                  CartIconButton(
                    size: 40,
                    iconSize: 18,
                    showFood: false,
                    backgroundColor: AppColors.white,
                    borderColor: AppColors.cardBorder,
                    iconColor: AppColors.primaryNavy,
                    onTap: _openCart,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search products',
                          hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final selected = category == _selectedCategory;
                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _selectedCategory = category);
                        _load();
                      },
                      backgroundColor: AppColors.white,
                      selectedColor: AppColors.primaryNavy,
                      side: BorderSide(
                        color: selected ? AppColors.primaryNavy : AppColors.cardBorder,
                      ),
                      labelStyle: textTheme.bodyMedium?.copyWith(
                        color: selected ? AppColors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sort by', style: textTheme.bodyMedium),
                  DropdownButton<String>(
                    value: _sort,
                    underline: const SizedBox.shrink(),
                    icon: const Icon(Icons.expand_more, size: 18, color: AppColors.textSecondary),
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    items: _sortOptions
                        .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _sort = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loading
                    ? const LoadingView()
                    : _error != null
                        ? LoadErrorView(message: _error!, onRetry: _load)
                        : products.isEmpty
                            ? const EmptyView(
                                icon: Icons.shopping_bag_outlined,
                                message: 'No products found',
                              )
                            : RefreshIndicator(
                                onRefresh: _load,
                                child: GridView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  padding: const EdgeInsets.only(bottom: 24),
                                  itemCount: products.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    childAspectRatio: 0.66,
                                  ),
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    return ProductCard(
                                      name: product.name,
                                      price: product.price,
                                      rating: product.rating,
                                      icon: product.icon,
                                      imageColor: product.imageColor,
                                      imageUrl: product.imageUrl,
                                      onTap: () => _openDetails(product),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/marketplace_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/cart_icon_button.dart';
import '../../widgets/category_card.dart';
import '../../widgets/load_state_views.dart';
import 'marketplace_cart_screen.dart';
import 'product_listing_screen.dart';

class ProductCategoriesScreen extends StatefulWidget {
  const ProductCategoriesScreen({super.key});

  static const String routeName = '/market/categories';

  @override
  State<ProductCategoriesScreen> createState() => _ProductCategoriesScreenState();
}

class _ProductCategoriesScreenState extends State<ProductCategoriesScreen> {
  late Future<List<ProductCategory>> _future;

  @override
  void initState() {
    super.initState();
    _future = MarketplaceApi.categories();
  }

  void _reload() {
    setState(() => _future = MarketplaceApi.categories());
  }

  void _openCategory(BuildContext context, String category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListingScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackBar(
                title: 'Marketplace',
                actions: [
                  CartIconButton(
                    size: 40,
                    iconSize: 18,
                    showFood: false,
                    backgroundColor: AppColors.white,
                    borderColor: AppColors.cardBorder,
                    iconColor: AppColors.primaryNavy,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MarketplaceCartScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Shop by category',
                style: textTheme.headlineMedium?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 4),
              Text(
                'Browse products across every category.',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<ProductCategory>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingView();
                    }
                    if (snapshot.hasError) {
                      return LoadErrorView(
                        message: snapshot.error.toString(),
                        onRetry: _reload,
                      );
                    }
                    final categories = snapshot.data ?? const <ProductCategory>[];
                    if (categories.isEmpty) {
                      return const EmptyView(
                        icon: Icons.category_outlined,
                        message: 'No categories available yet.',
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async => _reload(),
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: categories.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.3,
                        ),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return CategoryCard(
                            label: category.label,
                            icon: category.icon,
                            color: category.color,
                            background: category.background,
                            onTap: () => _openCategory(context, category.label),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

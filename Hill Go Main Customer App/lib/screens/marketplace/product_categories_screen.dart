import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/category_card.dart';
import 'product_listing_screen.dart';

class ProductCategoriesScreen extends StatelessWidget {
  const ProductCategoriesScreen({super.key});

  static const String routeName = '/market/categories';

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
              const AppBackBar(title: 'Marketplace'),
              const SizedBox(height: 20),
              Text(
                'Shop by category',
                style: textTheme.headlineMedium?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 4),
              Text(
                'Browse thousands of products across every category.',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: dummyCategories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.3,
                  ),
                  itemBuilder: (context, index) {
                    final category = dummyCategories[index];
                    return CategoryCard(
                      label: category.label,
                      icon: category.icon,
                      color: category.color,
                      background: category.background,
                      onTap: () => _openCategory(context, category.label),
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

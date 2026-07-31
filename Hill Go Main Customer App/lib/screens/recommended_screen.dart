import 'package:flutter/material.dart';

import '../models/catalog_models.dart';
import '../services/api/food_api.dart';
import '../services/api/marketplace_api.dart';
import '../theme/app_theme.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_pull_refresh.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/load_state_views.dart';
import '../widgets/section_header.dart';
import 'cart_hub_screen.dart';
import 'food/restaurant_details_screen.dart';
import 'food/restaurant_list_screen.dart';
import 'marketplace/product_categories_screen.dart';
import 'marketplace/product_details_screen.dart';
import 'marketplace/product_listing_screen.dart';

class RecommendedScreen extends StatefulWidget {
  const RecommendedScreen({super.key});

  static const String routeName = '/recommended';

  @override
  State<RecommendedScreen> createState() => _RecommendedScreenState();
}

class _RecommendedScreenState extends State<RecommendedScreen> {
  bool _loading = true;
  String? _error;
  List<RestaurantInfo> _restaurants = [];
  List<Product> _products = [];
  List<ProductCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        FoodApi.restaurants(),
        MarketplaceApi.products(),
        MarketplaceApi.categories(),
      ]);
      if (!mounted) return;
      setState(() {
        _restaurants = results[0] as List<RestaurantInfo>;
        _products = results[1] as List<Product>;
        _categories = results[2] as List<ProductCategory>;
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_loading) return const LoadingView();
    if (_error != null) {
      return LoadErrorView(message: _error!, onRetry: _load);
    }

    return SafeArea(
      bottom: false,
      child: AppPullRefresh(
        onRefresh: _load,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Marketplace',
                        style: textTheme.headlineMedium?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Discover restaurants and shops nearby',
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Combined cart for food + marketplace products.
                CartIconButton(
                  size: 48,
                  logoSize: 24,
                  emphasized: true,
                  showFood: true,
                  showMarket: true,
                  onTap: () =>
                      Navigator.of(context).pushNamed(CartHubScreen.routeName),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      onTap: () => Navigator.of(context)
                          .pushNamed(ProductListingScreen.routeName),
                      decoration: InputDecoration(
                        hintText: 'Search shops & restaurants',
                        hintStyle: textTheme.bodyMedium,
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            SectionHeader(
              title: 'Top Restaurants',
              trailingLabel: 'See all',
              onTrailingTap: () => Navigator.of(context)
                  .pushNamed(RestaurantListScreen.routeName),
            ),
            const SizedBox(height: 14),
            if (_restaurants.isEmpty)
              const EmptyView(
                icon: Icons.restaurant_outlined,
                message: 'No restaurants yet.',
              )
            else
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _restaurants.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final item = _restaurants[index];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(
                        RestaurantDetailsScreen.routeName,
                        arguments: item,
                      ),
                      child: _ImageOfferCard(
                        title: item.name,
                        subtitle: item.cuisine,
                        rating: item.rating,
                        imageUrl: item.imageUrl,
                        badge: item.isOpen ? 'Open Now' : 'Closed',
                        fallbackColor: AppColors.accentOrangeSoft,
                        fallbackIcon: Icons.restaurant,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 26),
            SectionHeader(
              title: 'Featured Products',
              trailingLabel: 'See all',
              onTrailingTap: () => Navigator.of(context)
                  .pushNamed(ProductListingScreen.routeName),
            ),
            const SizedBox(height: 14),
            if (_products.isEmpty)
              const EmptyView(
                icon: Icons.shopping_bag_outlined,
                message: 'No products yet.',
              )
            else
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _products.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final item = _products[index];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsScreen(product: item),
                        ),
                      ),
                      child: _ImageOfferCard(
                        title: item.name,
                        subtitle: item.category,
                        rating: item.rating,
                        imageUrl: item.imageUrl,
                        badge: item.inStock ? 'In stock' : 'Sold out',
                        fallbackColor: item.imageColor,
                        fallbackIcon: item.icon,
                        width: 180,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 26),
            Text(
              'Quick Categories',
              style: textTheme.titleLarge?.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 14),
            if (_categories.isEmpty)
              Text('No categories yet.', style: textTheme.bodyMedium)
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _categories.map((category) {
                  return GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(
                      ProductCategoriesScreen.routeName,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(category.icon,
                              size: 18, color: category.color),
                          const SizedBox(width: 8),
                          Text(
                            category.label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ImageOfferCard extends StatelessWidget {
  const _ImageOfferCard({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.imageUrl,
    required this.badge,
    required this.fallbackColor,
    required this.fallbackIcon,
    this.width = 200,
  });

  final String title;
  final String subtitle;
  final double rating;
  final String? imageUrl;
  final String badge;
  final Color fallbackColor;
  final IconData fallbackIcon;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AppNetworkImage(
                imageUrl: imageUrl,
                width: width,
                height: 110,
                fallbackColor: fallbackColor,
                fallbackIcon: fallbackIcon,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.white, size: 11),
                      const SizedBox(width: 2),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brandLime,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

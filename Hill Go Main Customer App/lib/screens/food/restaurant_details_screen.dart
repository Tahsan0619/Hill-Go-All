import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/food_item_tile.dart';
import '../../widgets/rating_stars.dart';
import 'food_cart_screen.dart';
import 'food_details_screen.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  const RestaurantDetailsScreen({super.key, this.restaurant});

  static const String routeName = '/food/restaurant';

  final RestaurantInfo? restaurant;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final resolved = restaurant ??
        (args is RestaurantInfo ? args : dummyRestaurants.first);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: resolved.color,
            expandedHeight: 200,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: InkWell(
                  onTap: () => Navigator.of(context).pushNamed(FoodCartScreen.routeName),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: AppNetworkImage(
                imageUrl: resolved.imageUrl,
                fallbackColor: resolved.color,
                fallbackIcon: Icons.storefront,
                fallbackIconSize: 72,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resolved.name,
                    style: textTheme.headlineMedium?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(resolved.cuisine, style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingStars(rating: resolved.rating, size: 16),
                      const SizedBox(width: 6),
                      Text(resolved.rating.toString(), style: textTheme.bodyMedium),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(resolved.time, style: textTheme.bodyMedium),
                      const SizedBox(width: 16),
                      const Icon(Icons.delivery_dining, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text('à§³${resolved.fee.toStringAsFixed(0)} delivery', style: textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
          ),
          for (final category in resolved.menu) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: Text(
                  category.name,
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 17),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: category.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = category.items[index];
                  return FoodItemTile(
                    name: item.name,
                    description: item.description,
                    price: item.price,
                    color: item.color,
                    icon: item.icon,
                    imageUrl: item.imageUrl,
                    onTap: () => Navigator.of(context).pushNamed(
                      FoodDetailsScreen.routeName,
                      arguments: {'item': item, 'restaurantName': resolved.name},
                    ),
                    onAdd: () {
                      FoodCartStore.add(item, resolved.name);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item.name} added to cart'), duration: const Duration(seconds: 1)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

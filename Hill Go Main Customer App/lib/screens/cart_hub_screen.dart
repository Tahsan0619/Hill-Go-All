import 'package:flutter/material.dart';

import '../models/catalog_models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_bar.dart';
import '../widgets/hillgo_cart_logo.dart';
import 'food/food_cart_screen.dart';
import 'marketplace/marketplace_cart_screen.dart';

/// Unified entry point for food and marketplace carts.
class CartHubScreen extends StatelessWidget {
  const CartHubScreen({super.key});

  static const String routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackBar(title: 'My Cart'),
              const SizedBox(height: 20),
              Text(
                'Choose a cart to continue',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    FoodCartStore.revision,
                    MarketplaceCartStore.revision,
                  ]),
                  builder: (context, _) {
                    final foodCount = FoodCartStore.itemCount;
                    final marketCount = MarketplaceCartStore.itemCount;

                    if (foodCount == 0 && marketCount == 0) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: AppColors.accentBlueSoft,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              alignment: Alignment.center,
                              child: const HillGoCartLogo(size: 44),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your carts are empty',
                              style: textTheme.titleLarge?.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Add food or market items to get started.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      children: [
                        _CartSectionCard(
                          title: 'Food cart',
                          subtitle: FoodCartStore.restaurantName ??
                              'Restaurant orders',
                          icon: Icons.restaurant_menu_rounded,
                          itemCount: foodCount,
                          subtotal: FoodCartStore.subtotal,
                          emptyLabel: 'No food items yet',
                          onTap: () => Navigator.of(context)
                              .pushNamed(FoodCartScreen.routeName),
                        ),
                        const SizedBox(height: 12),
                        _CartSectionCard(
                          title: 'Market cart',
                          subtitle: 'Marketplace products',
                          useCartLogo: true,
                          itemCount: marketCount,
                          subtotal: MarketplaceCartStore.subtotal,
                          emptyLabel: 'No market items yet',
                          onTap: () => Navigator.of(context)
                              .pushNamed(MarketplaceCartScreen.routeName),
                        ),
                      ],
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

class _CartSectionCard extends StatelessWidget {
  const _CartSectionCard({
    required this.title,
    required this.subtitle,
    this.icon = Icons.shopping_bag_rounded,
    this.useCartLogo = false,
    required this.itemCount,
    required this.subtotal,
    required this.emptyLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool useCartLogo;
  final int itemCount;
  final double subtotal;
  final String emptyLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasItems = itemCount > 0;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentBlueSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: useCartLogo
                    ? const HillGoCartLogo(size: 24)
                    : Icon(icon, color: AppColors.primaryNavy),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasItems
                          ? '$itemCount item${itemCount == 1 ? '' : 's'} · $subtitle'
                          : emptyLabel,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (hasItems)
                Text(
                  '৳${subtotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryNavy,
                  ),
                )
              else
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

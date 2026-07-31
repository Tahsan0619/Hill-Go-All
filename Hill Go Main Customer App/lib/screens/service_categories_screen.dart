import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cart_icon_button.dart';
import 'cart_hub_screen.dart';

/// App navigation category (not catalog/business data).
class ServiceCategoryItem {
  const ServiceCategoryItem({
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
}

/// "Explore Categories" screen: featured Parcel Delivery banner, a 2x3 grid
/// of service categories, and a loyalty points card with a Redeem action.
class ServiceCategoriesScreen extends StatelessWidget {
  const ServiceCategoriesScreen({
    super.key,
    this.onCategoryTap,
    this.onParcelBannerTap,
    this.onRedeemTap,
  });

  final ValueChanged<ServiceCategoryItem>? onCategoryTap;
  final VoidCallback? onParcelBannerTap;
  final VoidCallback? onRedeemTap;

  static const _categories = [
    ServiceCategoryItem(
      label: 'Food',
      icon: Icons.restaurant,
      iconColor: AppColors.accentOrange,
    ),
    ServiceCategoryItem(
      label: 'Marketplace',
      icon: Icons.storefront,
      iconColor: AppColors.accentBlue,
    ),
    ServiceCategoryItem(
      label: 'Ride',
      icon: Icons.two_wheeler,
      iconColor: AppColors.primaryNavy,
    ),
    ServiceCategoryItem(
      label: 'Hotel',
      icon: Icons.hotel_outlined,
      iconColor: Color(0xFF7C4DFF),
    ),
    ServiceCategoryItem(
      label: 'Rental',
      icon: Icons.directions_car_filled_outlined,
      iconColor: Color(0xFF00897B),
    ),
    ServiceCategoryItem(
      label: 'SOS',
      icon: Icons.sos_outlined,
      iconColor: Color(0xFFE53935),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = AuthService.user;
    final firstName =
        user.name.trim().isEmpty ? 'Your' : user.name.trim().split(' ').first;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore Categories',
                        style:
                            textTheme.headlineMedium?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Everything HillGo offers, in one place',
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                CartIconButton(
                  onTap: () =>
                      Navigator.of(context).pushNamed(CartHubScreen.routeName),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onParcelBannerTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accentOrange, Color(0xFFFF9248)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      bottom: -16,
                      child: Icon(
                        Icons.inventory_2_rounded,
                        size: 110,
                        color: AppColors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FEATURED',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Parcel Delivery',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Send packages across the city in minutes.',
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return GestureDetector(
                  onTap: () => onCategoryTap?.call(category),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: category.iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          category.icon,
                          color: category.iconColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.brandLime,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$firstName's Points",
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${user.loyaltyPoints} points available',
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onRedeemTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandLime,
                      foregroundColor: AppColors.navy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Redeem',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_network_image.dart';

/// A menu item row with photo, name, description, price and add button.
class FoodItemTile extends StatelessWidget {
  const FoodItemTile({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    required this.color,
    this.icon = Icons.restaurant_menu,
    this.imageUrl,
    this.onTap,
    this.onAdd,
  });

  final String name;
  final String description;
  final double price;
  final Color color;
  final IconData icon;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppNetworkImage(
              imageUrl: imageUrl,
              width: 72,
              height: 72,
              borderRadius: BorderRadius.circular(14),
              fallbackColor: color,
              fallbackIcon: icon,
              fallbackIconSize: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '৳${price.toStringAsFixed(0)}',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: AppColors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

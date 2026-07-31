import 'package:flutter/material.dart';

import '../data/app_images.dart';
import '../theme/app_theme.dart';
import '../widgets/app_network_image.dart';

/// Blue promotional card ("30% Off First Ride") with an orange "NEW USER"
/// pill badge. Used on the home dashboard.
class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    this.title = '30% Off First Ride',
    this.subtitle = 'Valid on all car types within the city.',
    this.badgeLabel = 'NEW USER',
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String badgeLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryNavy, AppColors.accentBlue],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeLabel,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AppNetworkImage(
                imageUrl: AppImages.carNight,
                width: 108,
                height: 78,
                borderRadius: BorderRadius.circular(14),
                fallbackIcon: Icons.directions_car_filled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

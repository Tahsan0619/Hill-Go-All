import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_pull_refresh.dart';
import '../widgets/section_header.dart';

/// Marketplace-style landing: a shop search bar, "Top Restaurants" and
/// "Featured Shops" horizontal rails, and a "Quick Categories" grid.
class RecommendedScreen extends StatefulWidget {
  const RecommendedScreen({super.key});

  static const String routeName = '/recommended';

  @override
  State<RecommendedScreen> createState() => _RecommendedScreenState();
}

class _RecommendedScreenState extends State<RecommendedScreen> {
  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: AppPullRefresh(
        onRefresh: _onRefresh,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Marketplace', style: textTheme.headlineMedium?.copyWith(fontSize: 24)),
            const SizedBox(height: 4),
            Text('Discover restaurants and shops nearby', style: textTheme.bodyLarge),
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
            SectionHeader(title: 'Top Restaurants', trailingLabel: 'See all'),
            const SizedBox(height: 14),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: DummyData.restaurants.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final item = DummyData.restaurants[index];
                  return _ImageOfferCard(
                    title: item.name,
                    subtitle: item.cuisine,
                    rating: item.rating,
                    imageUrl: item.imageUrl,
                    badge: 'Open Now',
                    fallbackColor: item.iconColor.withValues(alpha: 0.15),
                    fallbackIcon: item.icon,
                  );
                },
              ),
            ),
            const SizedBox(height: 26),
            SectionHeader(title: 'Featured Shops', trailingLabel: 'See all'),
            const SizedBox(height: 14),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: DummyData.shops.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final item = DummyData.shops[index];
                  return _ImageOfferCard(
                    title: item.name,
                    subtitle: item.category,
                    rating: item.rating,
                    imageUrl: item.imageUrl,
                    badge: 'Open Now',
                    fallbackColor: item.iconColor.withValues(alpha: 0.15),
                    fallbackIcon: item.icon,
                    width: 180,
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
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: DummyData.categories.map((category) {
                return Container(
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
                      Icon(category.icon, size: 18, color: category.iconColor),
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
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.white, size: 11),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

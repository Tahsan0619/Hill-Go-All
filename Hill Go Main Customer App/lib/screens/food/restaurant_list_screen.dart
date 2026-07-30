import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_network_image.dart';
import 'restaurant_details_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  static const String routeName = '/food/restaurants';

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  String _selectedCuisine = 'All';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RestaurantInfo> get _filteredRestaurants {
    final query = _searchController.text.trim().toLowerCase();
    var list = _selectedCuisine == 'All'
        ? dummyRestaurants
        : dummyRestaurants
            .where((r) =>
                r.cuisine.toLowerCase().contains(_selectedCuisine.toLowerCase()))
            .toList();
    if (query.isNotEmpty) {
      list = list
          .where((r) =>
              r.name.toLowerCase().contains(query) ||
              r.cuisine.toLowerCase().contains(query))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Restaurants near you', style: textTheme.titleLarge?.copyWith(fontSize: 18, color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search restaurants or dishes',
                        hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: dummyCuisineChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cuisine = dummyCuisineChips[index];
                final selected = cuisine == _selectedCuisine;
                return ChoiceChip(
                  label: Text(cuisine),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCuisine = cuisine),
                  selectedColor: AppColors.accentOrange,
                  backgroundColor: AppColors.white,
                  side: BorderSide(color: selected ? AppColors.accentOrange : AppColors.cardBorder),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _filteredRestaurants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final restaurant = _filteredRestaurants[index];
                return _RestaurantCard(
                  restaurant: restaurant,
                  onTap: () => Navigator.of(context).pushNamed(
                    RestaurantDetailsScreen.routeName,
                    arguments: restaurant,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant, required this.onTap});

  final RestaurantInfo restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AppNetworkImage(
                  imageUrl: restaurant.imageUrl,
                  width: double.infinity,
                  height: 140,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  fallbackColor: restaurant.color,
                  fallbackIcon: Icons.storefront,
                  fallbackIconSize: 44,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.white, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          restaurant.rating.toString(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, color: AppColors.primaryNavy, size: 18),
                  ),
                ),
                if (restaurant.freeDelivery)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.brandLime,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Free Delivery',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.brandLime.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          restaurant.time,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(restaurant.cuisine, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.delivery_dining, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.freeDelivery ? 'Free Delivery' : '৳${restaurant.fee.toStringAsFixed(0)} Delivery',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text('Min. ৳150', style: textTheme.bodyMedium),
                    ],
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

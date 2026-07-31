import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/food_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/cart_icon_button.dart';
import '../../widgets/load_state_views.dart';
import 'food_cart_screen.dart';
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

  List<RestaurantInfo> _restaurants = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await FoodApi.restaurants();
      if (!mounted) return;
      setState(() {
        _restaurants = rows;
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

  List<String> get _cuisineChips {
    final cuisines = <String>{};
    for (final r in _restaurants) {
      for (final c in r.cuisine.split(' • ')) {
        if (c.trim().isNotEmpty) cuisines.add(c.trim());
      }
    }
    return ['All', ...cuisines.toList()..sort()];
  }

  List<RestaurantInfo> get _filteredRestaurants {
    final query = _searchController.text.trim().toLowerCase();
    var list = _selectedCuisine == 'All'
        ? _restaurants
        : _restaurants
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CartIconButton(
              size: 40,
              iconSize: 18,
              showMarket: false,
              backgroundColor: AppColors.white,
              borderColor: AppColors.cardBorder,
              iconColor: AppColors.primaryNavy,
              onTap: () => Navigator.of(context).pushNamed(FoodCartScreen.routeName),
            ),
          ),
        ],
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? LoadErrorView(message: _error!, onRetry: _load)
              : Column(
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
                        itemCount: _cuisineChips.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cuisine = _cuisineChips[index];
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
                      child: _filteredRestaurants.isEmpty
                          ? const EmptyView(
                              icon: Icons.storefront_outlined,
                              message: 'No restaurants found.',
                            )
                          : RefreshIndicator(
                              onRefresh: _load,
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
                          restaurant.rating.toStringAsFixed(1),
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
                      Icon(
                        restaurant.isOpen ? Icons.check_circle_outline : Icons.do_not_disturb_on_outlined,
                        size: 14,
                        color: restaurant.isOpen ? AppColors.brandLime : Colors.redAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(restaurant.isOpen ? 'Open now' : 'Closed', style: textTheme.bodyMedium),
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

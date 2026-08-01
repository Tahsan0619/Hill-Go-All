import 'package:flutter/material.dart';

import '../models/catalog_models.dart';
import '../services/api/food_api.dart';
import '../services/api/hotels_api.dart';
import '../services/api/rentals_api.dart';
import '../theme/app_theme.dart';
import '../utils/user_facing_error.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_pull_refresh.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/load_state_views.dart';
import 'cart_hub_screen.dart';
import 'food/restaurant_list_screen.dart';
import 'hotel/hotel_list_screen.dart';
import 'rental/rental_list_screen.dart';

/// Unified nearby catalog row composed from live HillGo services.
class _NearbyItem {
  const _NearbyItem({
    required this.name,
    required this.type,
    required this.rating,
    required this.icon,
    required this.filterCategory,
    required this.routeName,
    this.imageUrl,
    this.subtitle = '',
  });

  final String name;
  final String type;
  final double rating;
  final IconData icon;
  final String filterCategory;
  final String routeName;
  final String? imageUrl;
  final String subtitle;
}

class NearbyServicesScreen extends StatefulWidget {
  const NearbyServicesScreen({super.key});

  static const String routeName = '/nearby-services';

  @override
  State<NearbyServicesScreen> createState() => _NearbyServicesScreenState();
}

class _NearbyServicesScreenState extends State<NearbyServicesScreen> {
  static const List<String> _filters = [
    'All',
    'Food',
    'Hotel',
    'Rental',
  ];

  int _selectedFilter = 0;
  bool _loading = true;
  String? _error;
  List<_NearbyItem> _items = [];

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
        HotelsApi.list(),
        RentalsApi.list(),
      ]);
      final restaurants = results[0] as List<RestaurantInfo>;
      final hotels = results[1] as List<HotelInfo>;
      final rentals = results[2] as List<RentalVehicle>;

      final items = <_NearbyItem>[
        for (final r in restaurants)
          _NearbyItem(
            name: r.name,
            type: r.cuisine.isEmpty ? 'Restaurant' : r.cuisine,
            rating: r.rating,
            icon: Icons.restaurant_outlined,
            filterCategory: 'Food',
            routeName: RestaurantListScreen.routeName,
            imageUrl: r.imageUrl,
            subtitle: r.time,
          ),
        for (final h in hotels)
          _NearbyItem(
            name: h.name,
            type: h.location,
            rating: h.rating,
            icon: Icons.hotel_outlined,
            filterCategory: 'Hotel',
            routeName: HotelListScreen.routeName,
            imageUrl: h.imageUrl,
            subtitle: '৳${h.pricePerNight.toStringAsFixed(0)} / night',
          ),
        for (final v in rentals)
          _NearbyItem(
            name: v.name,
            type: '${v.category} · ${v.transmission}',
            rating: v.rating,
            icon: v.icon,
            filterCategory: 'Rental',
            routeName: RentalListScreen.routeName,
            imageUrl: v.imageUrl,
            subtitle: '৳${v.pricePerDay.toStringAsFixed(0)} / day',
          ),
      ];

      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFacingError(e);
        _loading = false;
      });
    }
  }

  List<_NearbyItem> get _filteredServices {
    final selected = _filters[_selectedFilter];
    if (selected == 'All') return _items;
    return _items.where((s) => s.filterCategory == selected).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filtered = _filteredServices;

    return SafeArea(
      bottom: false,
      child: _loading
          ? const LoadingView()
          : _error != null
              ? LoadErrorView(message: _error!, onRetry: _load)
              : AppPullRefresh(
                  onRefresh: _load,
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
                                  'Nearby Services',
                                  style: textTheme.headlineMedium
                                      ?.copyWith(fontSize: 24),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Food, hotels & rentals near you',
                                  style: textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                          CartIconButton(
                            onTap: () => Navigator.of(context)
                                .pushNamed(CartHubScreen.routeName),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Stack(
                        children: [
                          Container(
                            height: 170,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.illustrationSky,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.map_outlined,
                                  size: 72,
                                  color: AppColors.accentBlue
                                      .withValues(alpha: 0.4),
                                ),
                                const Positioned(
                                  left: 32,
                                  top: 40,
                                  child: Icon(
                                    Icons.location_on,
                                    color: AppColors.accentOrange,
                                  ),
                                ),
                                const Positioned(
                                  right: 40,
                                  bottom: 36,
                                  child: Icon(
                                    Icons.location_on,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                                const Positioned(
                                  right: 90,
                                  top: 30,
                                  child: Icon(
                                    Icons.location_on,
                                    color: AppColors.brandLime,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.storefront,
                                    size: 16,
                                    color: AppColors.primaryNavy,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_items.length} Services Nearby',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filters.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final isSelected = index == _selectedFilter;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedFilter = index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryNavy
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryNavy
                                        : AppColors.cardBorder,
                                  ),
                                ),
                                child: Text(
                                  _filters[index],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off_outlined,
                                  size: 48,
                                  color: AppColors.textMuted
                                      .withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No ${_filters[_selectedFilter].toLowerCase()} services nearby',
                                  style: textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...List.generate(filtered.length, (index) {
                          final service = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ServiceCard(
                              service: service,
                              onTap: () => Navigator.of(context)
                                  .pushNamed(service.routeName),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onTap});

  final _NearbyItem service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AppNetworkImage(
                imageUrl: service.imageUrl,
                width: 72,
                height: 72,
                fallbackColor: AppColors.accentOrangeSoft,
                fallbackIcon: service.icon,
                fallbackIconSize: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(service.type,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.brandLime.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          service.filterCategory,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFB800), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${service.rating}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      if (service.subtitle.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(service.subtitle,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.accentOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

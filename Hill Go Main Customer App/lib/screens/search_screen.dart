import 'package:flutter/material.dart';

import '../data/app_images.dart';
import '../theme/app_theme.dart';
import '../widgets/app_network_image.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/search_filter_sheet.dart';
import 'cart_hub_screen.dart';

class _SearchDiscovery {
  const _SearchDiscovery({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.imageUrl,
    required this.labelColor,
    required this.serviceType,
    required this.rating,
    this.openNow = true,
  });

  final String title;
  final String subtitle;
  final String label;
  final String imageUrl;
  final Color labelColor;
  final String serviceType;
  final double rating;
  final bool openNow;
}

/// Search screen with a HillGo header, search + filter row, trending
/// chips, recent searches, and filterable "Explore Discoveries" cards.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static const String routeName = '/search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  SearchFilters _filters = const SearchFilters();

  static const List<String> _trending = [
    'Biriyani',
    'Grocery Deals',
    'Fast Ride',
    'Laundry',
    'Pharmacy',
  ];

  static const List<String> _recentSearches = [
    'Hilltop Grill',
    'Fresh Mart',
    'Airport ride',
    'City Pharmacy',
  ];

  static const List<_SearchDiscovery> _discoveries = [
    _SearchDiscovery(
      title: 'Artisan Finds',
      subtitle: 'Fresh market picks',
      label: 'MARKET',
      imageUrl: AppImages.marketplace,
      labelColor: AppColors.accentOrange,
      serviceType: 'Market',
      rating: 4.8,
    ),
    _SearchDiscovery(
      title: 'Eco-Commute',
      subtitle: 'Ride green across town',
      label: 'RIDE',
      imageUrl: AppImages.scooter,
      labelColor: AppColors.accentBlue,
      serviceType: 'Ride',
      rating: 4.6,
    ),
    _SearchDiscovery(
      title: 'Urban Grill House',
      subtitle: 'Top-rated burgers & grills',
      label: 'FOOD',
      imageUrl: AppImages.burger,
      labelColor: AppColors.accentOrange,
      serviceType: 'Food',
      rating: 4.9,
    ),
    _SearchDiscovery(
      title: 'Express Parcel Hub',
      subtitle: 'Same-day local delivery',
      label: 'PARCEL',
      imageUrl: AppImages.parcelCounter,
      labelColor: AppColors.primaryNavy,
      serviceType: 'Parcel',
      rating: 4.7,
      openNow: false,
    ),
  ];

  static const Color _oliveColor = Color(0xFF6B8E23);
  static const Color _oliveSoft = Color(0xFFE9EFD6);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_SearchDiscovery> get _filteredDiscoveries {
    final query = _searchController.text.trim().toLowerCase();
    var results = _discoveries.where((item) {
      if (_filters.openNowOnly && !item.openNow) return false;
      if (_filters.serviceType != 'All' && item.serviceType != _filters.serviceType) {
        return false;
      }
      if (query.isEmpty) return true;
      return item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query) ||
          item.label.toLowerCase().contains(query);
    }).toList();

    switch (_filters.sortBy) {
      case 'Nearest':
        results = results.reversed.toList();
      case 'Top rated':
        results = [...results]..sort((a, b) => b.rating.compareTo(a.rating));
      case 'Fastest delivery':
        results = [...results]..sort((a, b) => a.title.compareTo(b.title));
      case 'Recommended':
        break;
    }
    return results;
  }

  List<String> get _filteredRecent {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _recentSearches;
    return _recentSearches
        .where((item) => item.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _openFilters() async {
    final result = await showSearchFilterSheet(context, initial: _filters);
    if (result != null) setState(() => _filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final discoveries = _filteredDiscoveries;
    final recent = _filteredRecent;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('HillGo', style: textTheme.titleLarge),
                  ),
                  CartIconButton(
                    size: 40,
                    iconSize: 20,
                    onTap: () =>
                        Navigator.of(context).pushNamed(CartHubScreen.routeName),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Search restaurants, shops, rides...',
                                hintStyle: textTheme.bodyMedium,
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _openFilters,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.tune, color: AppColors.white),
                        ),
                        if (_filters.hasActiveFilters)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.accentOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_filters.hasActiveFilters) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_filters.serviceType != 'All')
                      _ActiveFilterChip(
                        label: _filters.serviceType,
                        onRemove: () => setState(
                          () => _filters = _filters.copyWith(serviceType: 'All'),
                        ),
                      ),
                    if (_filters.sortBy != 'Recommended')
                      _ActiveFilterChip(
                        label: _filters.sortBy,
                        onRemove: () => setState(
                          () => _filters = _filters.copyWith(sortBy: 'Recommended'),
                        ),
                      ),
                    if (_filters.openNowOnly)
                      _ActiveFilterChip(
                        label: 'Open now',
                        onRemove: () => setState(
                          () => _filters = _filters.copyWith(openNowOnly: false),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 26),
              Text(
                'Trending Now',
                style: textTheme.titleLarge?.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _trending.map((label) {
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = label;
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: _oliveSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: _oliveColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (recent.isNotEmpty) ...[
                const SizedBox(height: 26),
                Text(
                  'Recent Searches',
                  style: textTheme.titleLarge?.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 8),
                ...List.generate(recent.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: InkWell(
                      onTap: () {
                        _searchController.text = recent[index];
                        setState(() {});
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.history,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              recent[index],
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.north_west,
                            color: AppColors.textMuted,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 22),
              Text(
                'Explore Discoveries',
                style: textTheme.titleLarge?.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 14),
              if (discoveries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No results match your search or filters',
                      style: textTheme.bodyLarge,
                    ),
                  ),
                )
              else
                ...List.generate((discoveries.length / 2).ceil(), (row) {
                  final left = discoveries[row * 2];
                  final rightIndex = row * 2 + 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: _DiscoveryCard(
                            title: left.title,
                            subtitle: left.subtitle,
                            label: left.label,
                            imageUrl: left.imageUrl,
                            labelColor: left.labelColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: rightIndex < discoveries.length
                              ? _DiscoveryCard(
                                  title: discoveries[rightIndex].title,
                                  subtitle: discoveries[rightIndex].subtitle,
                                  label: discoveries[rightIndex].label,
                                  imageUrl: discoveries[rightIndex].imageUrl,
                                  labelColor: discoveries[rightIndex].labelColor,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentBlueSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppColors.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  const _DiscoveryCard({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.imageUrl,
    required this.labelColor,
  });

  final String title;
  final String subtitle;
  final String label;
  final String imageUrl;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
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
                height: 100,
                width: double.infinity,
                fallbackColor: labelColor.withValues(alpha: 0.12),
                fallbackIcon: Icons.explore_outlined,
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: labelColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

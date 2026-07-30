import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_pull_refresh.dart';

/// Nearby services screen: a rounded map placeholder with a services count
/// badge, filter chips, and a scrollable list of nearby service cards.
class NearbyServicesScreen extends StatefulWidget {
  const NearbyServicesScreen({super.key});

  static const String routeName = '/nearby-services';

  @override
  State<NearbyServicesScreen> createState() => _NearbyServicesScreenState();
}

class _NearbyServicesScreenState extends State<NearbyServicesScreen> {
  static const List<String> _filters = [
    'All',
    'Repair',
    'Laundry',
    'Salon',
    'Pharmacy',
  ];

  int _selectedFilter = 0;

  List<NearbyServiceItem> get _filteredServices {
    final selected = _filters[_selectedFilter];
    if (selected == 'All') return DummyData.nearbyServices;
    return DummyData.nearbyServices
        .where((s) => s.filterCategory == selected)
        .toList();
  }

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
            Text(
              'Nearby Services',
              style: textTheme.headlineMedium?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text('Services around your location', style: textTheme.bodyLarge),
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
                        color: AppColors.accentBlue.withValues(alpha: 0.4),
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
                          '${DummyData.nearbyServices.length} Services Nearby',
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
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            if (_filteredServices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_outlined,
                        size: 48,
                        color: AppColors.textMuted.withValues(alpha: 0.5),
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
              ...List.generate(_filteredServices.length, (index) {
                final service = _filteredServices[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _ServiceCard(service: service),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final NearbyServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(service.type, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.brandLime.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 11, color: AppColors.textPrimary),
                          const SizedBox(width: 2),
                          Text(
                            '${service.distanceKm} km',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${service.rating}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text(service.hours, style: Theme.of(context).textTheme.bodySmall),
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
    );
  }
}

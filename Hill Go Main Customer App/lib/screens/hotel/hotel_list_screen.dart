import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/hotels_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/load_state_views.dart';
import 'hotel_details_screen.dart';

class HotelListScreen extends StatefulWidget {
  const HotelListScreen({super.key});

  static const String routeName = '/hotel/list';

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  String _selectedChip = 'All';
  final _searchController = TextEditingController();
  List<HotelInfo> _hotels = [];
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
      final rows = await HotelsApi.list(
        location: _selectedChip,
        query: _searchController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _hotels = rows;
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

  List<String> get _chips {
    final locations = <String>{};
    for (final h in _hotels) {
      final loc = h.location.trim();
      if (loc.isNotEmpty) locations.add(loc.split(',').first.trim());
    }
    return ['All', ...locations.toList()..sort()];
  }

  List<HotelInfo> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    var list = _selectedChip == 'All'
        ? _hotels
        : _hotels
            .where((h) =>
                h.location.toLowerCase().contains(_selectedChip.toLowerCase()))
            .toList();
    if (query.isNotEmpty) {
      list = list
          .where((h) =>
              h.name.toLowerCase().contains(query) ||
              h.location.toLowerCase().contains(query))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final chips = _chips;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Hotels & Stays',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
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
                            const Icon(Icons.search,
                                color: AppColors.textMuted, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (_) => setState(() {}),
                                onSubmitted: (_) => _load(),
                                style: textTheme.bodyLarge
                                    ?.copyWith(color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Search hotels or cities',
                                  hintStyle: textTheme.bodyLarge
                                      ?.copyWith(color: AppColors.textMuted),
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
                        itemCount: chips.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final chip = chips[index];
                          final selected = chip == _selectedChip;
                          return ChoiceChip(
                            label: Text(chip),
                            selected: selected,
                            onSelected: (_) {
                              setState(() => _selectedChip = chip);
                              _load();
                            },
                            selectedColor: AppColors.primaryNavy,
                            backgroundColor: AppColors.white,
                            side: BorderSide(
                              color: selected
                                  ? AppColors.primaryNavy
                                  : AppColors.cardBorder,
                            ),
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? const EmptyView(
                              icon: Icons.hotel_outlined,
                              message: 'No hotels found.',
                            )
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.separated(
                                padding: const EdgeInsets.all(20),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final hotel = filtered[index];
                                  return _HotelCard(
                                    hotel: hotel,
                                    onTap: () => Navigator.of(context).pushNamed(
                                      HotelDetailsScreen.routeName,
                                      arguments: hotel,
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

class _HotelCard extends StatelessWidget {
  const _HotelCard({required this.hotel, required this.onTap});

  final HotelInfo hotel;
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
                  imageUrl: hotel.imageUrl,
                  width: double.infinity,
                  height: 140,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  fallbackColor: hotel.color,
                  fallbackIcon: Icons.hotel,
                  fallbackIconSize: 44,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.white, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          hotel.rating.toString(),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${hotel.stars}★',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
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
                  Text(
                    hotel.name,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.location,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '৳${hotel.pricePerNight.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      Text(
                        ' / night',
                        style: textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        '${hotel.reviews} reviews',
                        style: textTheme.bodySmall,
                      ),
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

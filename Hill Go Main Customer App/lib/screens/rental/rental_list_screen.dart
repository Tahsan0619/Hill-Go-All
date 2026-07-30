import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_network_image.dart';
import 'rental_details_screen.dart';

class RentalListScreen extends StatefulWidget {
  const RentalListScreen({super.key});

  static const String routeName = '/rental/list';

  @override
  State<RentalListScreen> createState() => _RentalListScreenState();
}

class _RentalListScreenState extends State<RentalListScreen> {
  String _selectedChip = 'All';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RentalVehicle> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    var list = _selectedChip == 'All'
        ? dummyRentals
        : dummyRentals
            .where((v) =>
                v.category.toLowerCase() == _selectedChip.toLowerCase())
            .toList();
    if (query.isNotEmpty) {
      list = list
          .where((v) =>
              v.name.toLowerCase().contains(query) ||
              v.category.toLowerCase().contains(query))
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
        title: Text(
          'Rent a vehicle',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
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
                      style: textTheme.bodyLarge
                          ?.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search cars, bikes, vans…',
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
              itemCount: dummyRentalChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final chip = dummyRentalChips[index];
                final selected = chip == _selectedChip;
                return ChoiceChip(
                  label: Text(chip),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedChip = chip),
                  selectedColor: const Color(0xFF00897B),
                  backgroundColor: AppColors.white,
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFF00897B)
                        : AppColors.cardBorder,
                  ),
                  labelStyle: TextStyle(
                    color:
                        selected ? AppColors.white : AppColors.textPrimary,
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
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final vehicle = _filtered[index];
                return _RentalCard(
                  vehicle: vehicle,
                  onTap: () => Navigator.of(context).pushNamed(
                    RentalDetailsScreen.routeName,
                    arguments: vehicle,
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

class _RentalCard extends StatelessWidget {
  const _RentalCard({required this.vehicle, required this.onTap});

  final RentalVehicle vehicle;
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
                  imageUrl: vehicle.imageUrl,
                  width: double.infinity,
                  height: 140,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  fallbackColor: vehicle.color,
                  fallbackIcon: vehicle.icon,
                  fallbackIconSize: 44,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00897B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vehicle.category,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFB800), size: 12),
                        const SizedBox(width: 3),
                        Text(
                          '${vehicle.rating}',
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
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${vehicle.seats} seats · ${vehicle.transmission} · ${vehicle.fuel}',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '৳${vehicle.pricePerDay.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00897B),
                        ),
                      ),
                      Text(' / day', style: textTheme.bodyMedium),
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

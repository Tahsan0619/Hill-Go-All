import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rating_stars.dart';
import 'rental_booking_screen.dart';

class RentalDetailsScreen extends StatelessWidget {
  const RentalDetailsScreen({super.key, this.vehicle});

  static const String routeName = '/rental/details';

  final RentalVehicle? vehicle;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final resolved =
        vehicle ?? (args is RentalVehicle ? args : dummyRentals.first);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: resolved.color,
            expandedHeight: 220,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: AppColors.textPrimary),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: AppNetworkImage(
                imageUrl: resolved.imageUrl,
                fallbackColor: resolved.color,
                fallbackIcon: resolved.icon,
                fallbackIconSize: 72,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          resolved.name,
                          style:
                              textTheme.headlineMedium?.copyWith(fontSize: 22),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          resolved.category,
                          style: const TextStyle(
                            color: Color(0xFF00897B),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      RatingStars(rating: resolved.rating, size: 16),
                      const SizedBox(width: 6),
                      Text('${resolved.rating}', style: textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _SpecChip(
                          icon: Icons.event_seat_outlined,
                          label: '${resolved.seats} seats'),
                      const SizedBox(width: 8),
                      _SpecChip(
                          icon: Icons.settings,
                          label: resolved.transmission),
                      const SizedBox(width: 8),
                      _SpecChip(
                          icon: Icons.local_gas_station_outlined,
                          label: resolved.fuel),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'About',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(resolved.description, style: textTheme.bodyLarge),
                  const SizedBox(height: 20),
                  Text(
                    'Included',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: resolved.features
                        .map(
                          (f) => Chip(
                            label: Text(f),
                            backgroundColor: AppColors.white,
                            side:
                                const BorderSide(color: AppColors.cardBorder),
                            labelStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('From', style: textTheme.bodyMedium),
                              const SizedBox(height: 2),
                              Text(
                                '৳${resolved.pricePerDay.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF00897B),
                                ),
                              ),
                              Text('/ day', style: textTheme.bodySmall),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          child: PrimaryButton(
                            label: 'Rent now',
                            backgroundColor: const Color(0xFF00897B),
                            borderRadius: 14,
                            height: 48,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RentalBookingScreen(
                                    booking:
                                        RentalBooking(vehicle: resolved),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  const _SpecChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF00897B)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rating_stars.dart';
import 'hotel_booking_screen.dart';

class HotelDetailsScreen extends StatelessWidget {
  const HotelDetailsScreen({super.key, this.hotel});

  static const String routeName = '/hotel/details';

  final HotelInfo? hotel;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final resolved =
        hotel ?? (args is HotelInfo ? args : dummyHotels.first);
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
                fallbackIcon: Icons.hotel,
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
                  Text(
                    resolved.name,
                    style: textTheme.headlineMedium?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(resolved.location, style: textTheme.bodyLarge),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingStars(rating: resolved.rating, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${resolved.rating} · ${resolved.reviews} reviews',
                        style: textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        '${resolved.stars}★ hotel',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                      ),
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
                    'Amenities',
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
                    children: resolved.amenities
                        .map(
                          (a) => Chip(
                            label: Text(a),
                            backgroundColor: AppColors.white,
                            side: const BorderSide(color: AppColors.cardBorder),
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
                                '৳${resolved.pricePerNight.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                              Text('/ night', style: textTheme.bodySmall),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          child: PrimaryButton(
                            label: 'Book stay',
                            borderRadius: 14,
                            height: 48,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => HotelBookingScreen(
                                    booking: HotelBooking(hotel: resolved),
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

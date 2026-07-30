import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';

class ParcelTrackingScreen extends StatelessWidget {
  const ParcelTrackingScreen({super.key, this.trackingId = 'HG-93217'});

  static const String routeName = '/parcel/tracking';

  final String trackingId;

  static const _steps = [
    ('Booked', 'Your parcel booking has been confirmed', Icons.check_circle_outline),
    ('Picked Up', 'Rider collected the parcel from sender', Icons.inventory_2_outlined),
    ('In Transit', 'Parcel is on the way to destination', Icons.local_shipping_outlined),
    ('Delivered', 'Parcel delivered to the receiver', Icons.home_outlined),
  ];

  static const int _currentStep = 1;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackBar(title: 'Track Parcel', subtitle: trackingId),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          color: AppColors.accentBlueSoft,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.map_outlined,
                                size: 56,
                                color: AppColors.primaryNavy,
                              ),
                              Positioned(
                                bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Live map preview',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Delivery status',
                        style: textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: List.generate(_steps.length, (index) {
                          final (title, description, icon) = _steps[index];
                          final isCompleted = index <= _currentStep;
                          final isLast = index == _steps.length - 1;
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? AppColors.primaryNavy
                                            : AppColors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isCompleted
                                              ? AppColors.primaryNavy
                                              : AppColors.cardBorder,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        icon,
                                        size: 18,
                                        color: isCompleted
                                            ? AppColors.white
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: isCompleted
                                              ? AppColors.primaryNavy
                                              : AppColors.cardBorder,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: textTheme.bodyLarge?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(description, style: textTheme.bodyMedium),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

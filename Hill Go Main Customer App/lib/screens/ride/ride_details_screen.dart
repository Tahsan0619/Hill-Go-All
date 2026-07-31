import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fare_row.dart';
import '../../widgets/hillgo_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_badge.dart';
import 'ride_rating_screen.dart';

class RideDetailsScreen extends StatelessWidget {
  const RideDetailsScreen({super.key});

  static const String routeName = '/ride/details';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final args = ModalRoute.of(context)?.settings.arguments;
    final ride = args is RideEntry ? args : null;

    if (ride == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const HillgoAppBar(title: 'Trip summary'),
        body: Center(child: Text('Ride not found.', style: textTheme.bodyLarge)),
      );
    }

    final isCompleted = ride.status == 'completed';
    final canRate = isCompleted && ride.rating == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HillgoAppBar(title: 'Trip summary'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${ride.code} • ${ride.dateLabel}',
                          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      StatusBadge(
                        label: statusLabel(ride.status),
                        color: isCompleted
                            ? AppColors.brandLime
                            : ride.status == 'cancelled'
                                ? Colors.red
                                : AppColors.accentOrange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.radio_button_checked, color: AppColors.primaryNavy, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ride.pickup,
                          style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: SizedBox(height: 24, child: VerticalDivider(color: AppColors.inputBorder, thickness: 1.5)),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.accentOrange, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ride.drop,
                          style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  if (ride.driver != null) ...[
                    const Divider(color: AppColors.inputBorder, height: 28),
                    Row(
                      children: [
                        const Icon(Icons.person, color: AppColors.primaryNavy, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${ride.driver!.name} • ${ride.driver!.vehicleModel} • ${ride.driver!.plateNumber}',
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Payment', style: textTheme.headlineMedium?.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  FareRow(
                    label: 'Distance',
                    value: '${ride.distanceKm.toStringAsFixed(1)} km',
                  ),
                  FareRow(
                    label: 'Duration',
                    value: '${ride.durationMin.round()} min',
                  ),
                  const Divider(color: AppColors.inputBorder, height: 24),
                  FareRow(
                    label: isCompleted ? 'Total paid' : 'Fare',
                    value: '৳${ride.fare.toStringAsFixed(0)}',
                    isTotal: true,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: AppColors.primaryNavy, size: 18),
                      const SizedBox(width: 8),
                      Text('Paid via ${statusLabel(ride.paymentMethod)}', style: textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            if (ride.rating != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.accentOrange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'You rated this trip ${ride.rating}/5',
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: canRate
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -3)),
                ],
              ),
              child: PrimaryButton(
                label: 'Rate your ride',
                backgroundColor: AppColors.accentOrange,
                borderRadius: 14,
                onPressed: () => Navigator.of(context).pushNamed(
                  RideRatingScreen.routeName,
                  arguments: ride,
                ),
              ),
            )
          : null,
    );
  }
}

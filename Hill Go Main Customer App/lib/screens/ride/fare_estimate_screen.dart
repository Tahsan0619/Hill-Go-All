import 'package:flutter/material.dart';

import '../../config/fare_config.dart';
import '../../data/dummy_data.dart';
import '../../models/route_result.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fare_row.dart';
import '../../widgets/hillgo_app_bar.dart';
import '../../widgets/primary_button.dart';
import 'driver_searching_screen.dart';

class FareEstimateScreen extends StatelessWidget {
  const FareEstimateScreen({super.key});

  static const String routeName = '/ride/fare';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    VehicleOption vehicle = dummyVehicleOptions.first;
    RideLocationArgs? ride;

    if (args is Map) {
      if (args['vehicle'] is VehicleOption) {
        vehicle = args['vehicle'] as VehicleOption;
      }
      if (args['ride'] is RideLocationArgs) {
        ride = args['ride'] as RideLocationArgs;
      }
    } else if (args is VehicleOption) {
      vehicle = args;
    }

    final pickupLabel = ride?.pickup.displayName ?? 'Bashundhara R/A, Dhaka';
    final dropLabel = ride?.destination.displayName ?? 'Gulshan 2 Circle, Dhaka';

    final baseFare = FareConfig.baseFare;
    final distanceKm = ride?.distanceKm ?? 0;
    final durationMin = ride?.durationMin ?? 0;
    final distanceCharge = distanceKm * FareConfig.ratePerKm;
    final timeCharge = durationMin * FareConfig.ratePerMin;
    final total = vehicle.price;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HillgoAppBar(title: 'Fare estimate'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _RoutePoint(
                    icon: Icons.radio_button_checked,
                    iconColor: AppColors.primaryNavy,
                    label: pickupLabel,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 9),
                    child: SizedBox(
                      height: 24,
                      child: VerticalDivider(color: AppColors.inputBorder, thickness: 1.5),
                    ),
                  ),
                  _RoutePoint(
                    icon: Icons.location_on,
                    iconColor: AppColors.accentOrange,
                    label: dropLabel,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(vehicle.icon, color: AppColors.primaryNavy),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ride != null
                          ? '${vehicle.name} • ${distanceKm.toStringAsFixed(1)} km • ${durationMin.round()} min'
                          : '${vehicle.name} • ${vehicle.eta}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Fare breakdown', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  FareRow(label: 'Base fare', value: '৳${baseFare.toStringAsFixed(0)}'),
                  if (ride != null) ...[
                    FareRow(
                      label: 'Distance (${distanceKm.toStringAsFixed(1)} km)',
                      value: '৳${distanceCharge.toStringAsFixed(0)}',
                    ),
                    FareRow(
                      label: 'Time (${durationMin.round()} min)',
                      value: '৳${timeCharge.toStringAsFixed(0)}',
                    ),
                  ] else ...[
                    const FareRow(label: 'Distance charge', value: '৳85'),
                  ],
                  const Divider(color: AppColors.inputBorder, height: 24),
                  FareRow(label: 'Total', value: '৳${total.toStringAsFixed(0)}', isTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -3)),
          ],
        ),
        child: PrimaryButton(
          label: 'Book Ride',
          backgroundColor: AppColors.accentOrange,
          borderRadius: 14,
          onPressed: () => Navigator.of(context).pushNamed(DriverSearchingScreen.routeName),
        ),
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

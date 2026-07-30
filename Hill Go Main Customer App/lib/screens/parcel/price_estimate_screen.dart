import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/primary_button.dart';
import 'parcel_summary_screen.dart';

class PriceEstimateScreen extends StatelessWidget {
  const PriceEstimateScreen({super.key, required this.booking});

  static const String routeName = '/parcel/estimate';

  final ParcelBooking booking;

  void _confirm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ParcelSummaryScreen(booking: booking)),
    );
  }

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
              const AppBackBar(
                title: 'Price Estimate',
                subtitle: 'Step 4 of 5',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatBlock(
                                icon: Icons.route_outlined,
                                label: 'Distance',
                                value: '${booking.distanceKm.toStringAsFixed(1)} km',
                              ),
                            ),
                            Container(width: 1, height: 44, color: AppColors.cardBorder),
                            Expanded(
                              child: _StatBlock(
                                icon: Icons.scale_outlined,
                                label: 'Weight',
                                value: '${booking.weightKg.toStringAsFixed(1)} kg',
                              ),
                            ),
                            Container(width: 1, height: 44, color: AppColors.cardBorder),
                            Expanded(
                              child: _StatBlock(
                                icon: Icons.inventory_2_outlined,
                                label: 'Type',
                                value: booking.parcelType ?? 'Box',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Fare breakdown', style: textTheme.titleLarge?.copyWith(fontSize: 18)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          children: [
                            _FareRow(label: 'Base fare', value: ParcelBooking.baseFare),
                            const SizedBox(height: 12),
                            _FareRow(label: 'Distance charge', value: booking.distanceFare),
                            const SizedBox(height: 12),
                            _FareRow(label: 'Weight charge', value: booking.weightFare),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(height: 1, color: AppColors.cardBorder),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Fare',
                                  style: textTheme.titleLarge?.copyWith(fontSize: 18),
                                ),
                                Text(
                                  '\$${booking.total.toStringAsFixed(2)}',
                                  style: textTheme.titleLarge?.copyWith(
                                    fontSize: 18,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Confirm',
                backgroundColor: AppColors.accentOrange,
                borderRadius: 14,
                onPressed: () => _confirm(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryNavy),
        const SizedBox(height: 6),
        Text(
          value,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }
}

class _FareRow extends StatelessWidget {
  const _FareRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyLarge),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

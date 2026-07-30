import 'package:flutter/material.dart';

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
                      Text(
                        'Today, 9:24 AM',
                        style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                      const StatusBadge(label: 'Completed', color: AppColors.brandLime),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.radio_button_checked, color: AppColors.primaryNavy, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bashundhara R/A, Dhaka',
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
                          'Gulshan 2 Circle, Dhaka',
                          style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
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
                  const FareRow(label: 'Base fare', value: '৳40'),
                  const FareRow(label: 'Distance charge', value: '৳85'),
                  const FareRow(label: 'Promo discount', value: '-৳15', valueColor: AppColors.brandLime),
                  const Divider(color: AppColors.inputBorder, height: 24),
                  const FareRow(label: 'Total paid', value: '৳110', isTotal: true),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: AppColors.primaryNavy, size: 18),
                      const SizedBox(width: 8),
                      Text('Paid via HillGo Wallet', style: textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Receipt sent to your email'), duration: Duration(seconds: 1)),
                  );
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('View Receipt'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryNavy,
                  side: const BorderSide(color: AppColors.primaryNavy),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
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
          label: 'Rate your ride',
          backgroundColor: AppColors.accentOrange,
          borderRadius: 14,
          onPressed: () => Navigator.of(context).pushNamed(RideRatingScreen.routeName),
        ),
      ),
    );
  }
}

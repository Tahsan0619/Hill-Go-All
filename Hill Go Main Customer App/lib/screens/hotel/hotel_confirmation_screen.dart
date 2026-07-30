import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/fare_row.dart';
import '../../widgets/primary_button.dart';
import '../main_shell_screen.dart';

class HotelConfirmationScreen extends StatelessWidget {
  const HotelConfirmationScreen({super.key, required this.booking});

  static const String routeName = '/hotel/confirmation';

  final HotelBooking booking;

  void _confirm(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hotel booked successfully'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pushNamedAndRemoveUntil(
      MainShellScreen.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotel = booking.hotel;
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
                title: 'Confirm booking',
                subtitle: 'Review & pay',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
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
                            Text(hotel.location, style: textTheme.bodyMedium),
                            const Divider(height: 24),
                            _Line('Check-in', booking.checkInLabel),
                            _Line('Check-out', booking.checkOutLabel),
                            _Line('Nights', '${booking.nights}'),
                            _Line('Guests', '${booking.guests}'),
                            _Line('Rooms', '${booking.rooms}'),
                            _Line(
                              'Guest',
                              booking.guestName.isEmpty
                                  ? '—'
                                  : booking.guestName,
                            ),
                            _Line(
                              'Phone',
                              booking.guestPhone.isEmpty
                                  ? '—'
                                  : booking.guestPhone,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          children: [
                            FareRow(
                              label: 'Room total',
                              value:
                                  '৳${booking.roomTotal.toStringAsFixed(0)}',
                            ),
                            FareRow(
                              label: 'Service fee',
                              value:
                                  '৳${booking.serviceFee.toStringAsFixed(0)}',
                            ),
                            const Divider(height: 12),
                            FareRow(
                              label: 'Total',
                              value: '৳${booking.total.toStringAsFixed(0)}',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF1FB),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_outlined,
                                color: AppColors.primaryNavy),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Pay with HillGo Wallet',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(Icons.check_circle,
                                color: AppColors.primaryNavy, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Confirm & pay ৳${booking.total.toStringAsFixed(0)}',
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

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/api_client.dart';
import '../../services/api/rentals_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/fare_row.dart';
import '../../widgets/primary_button.dart';
import '../main_shell_screen.dart';

class RentalConfirmationScreen extends StatefulWidget {
  const RentalConfirmationScreen({super.key, required this.booking});

  static const String routeName = '/rental/confirmation';

  final RentalBooking booking;

  @override
  State<RentalConfirmationScreen> createState() =>
      _RentalConfirmationScreenState();
}

class _RentalConfirmationScreenState extends State<RentalConfirmationScreen> {
  bool _submitting = false;

  Future<void> _confirm() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final result = await RentalsApi.book(widget.booking);
      widget.booking.confirmedCode = result['code'] as String?;
      widget.booking.confirmedTotal = asDouble(result['total']);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vehicle rental confirmed${widget.booking.confirmedCode != null ? ' · ${widget.booking.confirmedCode}' : ''}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        MainShellScreen.routeName,
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final vehicle = booking.vehicle;
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
                title: 'Confirm rental',
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
                              vehicle.name,
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(vehicle.category, style: textTheme.bodyMedium),
                            const Divider(height: 24),
                            _Line('Start', booking.startLabel),
                            _Line('End', booking.endLabel),
                            _Line('Days', '${booking.days}'),
                            _Line(
                              'Driver',
                              booking.withDriver ? 'Included' : 'Self-drive',
                            ),
                            _Line('Pickup', booking.pickupLocation),
                            _Line('Drop-off', booking.dropoffLocation),
                            _Line(
                              'Renter',
                              booking.renterName.isEmpty
                                  ? '—'
                                  : booking.renterName,
                            ),
                            _Line(
                              'Phone',
                              booking.renterPhone.isEmpty
                                  ? '—'
                                  : booking.renterPhone,
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
                              label: 'Vehicle',
                              value:
                                  '৳${booking.vehicleTotal.toStringAsFixed(0)}',
                            ),
                            if (booking.withDriver)
                              FareRow(
                                label: 'Driver',
                                value:
                                    '৳${booking.driverFee.toStringAsFixed(0)}',
                              ),
                            FareRow(
                              label: 'Insurance',
                              value:
                                  '৳${booking.insuranceFee.toStringAsFixed(0)}',
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: _submitting
                    ? 'Booking…'
                    : 'Confirm & pay ৳${booking.total.toStringAsFixed(0)}',
                backgroundColor: const Color(0xFF00897B),
                borderRadius: 14,
                onPressed: _submitting ? null : _confirm,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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

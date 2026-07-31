import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/api_client.dart';
import '../../services/api/parcels_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/primary_button.dart';
import 'parcel_tracking_screen.dart';

class ParcelSummaryScreen extends StatefulWidget {
  const ParcelSummaryScreen({super.key, required this.booking});

  static const String routeName = '/parcel/summary';

  final ParcelBooking booking;

  @override
  State<ParcelSummaryScreen> createState() => _ParcelSummaryScreenState();
}

class _ParcelSummaryScreenState extends State<ParcelSummaryScreen> {
  bool _booking = false;
  String _paymentMethod = 'cash';

  Future<void> _bookParcel() async {
    setState(() {
      _booking = true;
      widget.booking.paymentMethod = _paymentMethod;
    });
    try {
      final parcel = await ParcelsApi.create(widget.booking);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ParcelTrackingScreen(parcel: parcel),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _booking = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final fare = booking.quote?.fare ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackBar(
                title: 'Review & Confirm',
                subtitle: 'Step 5 of 5',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummarySection(
                        title: 'Parcel Type',
                        icon: Icons.inventory_2_outlined,
                        children: [
                          _SummaryLine(label: 'Type', value: booking.parcelType ?? 'Box'),
                          _SummaryLine(label: 'Priority', value: statusLabel(booking.priority)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _SummarySection(
                        title: 'Pickup',
                        icon: Icons.trip_origin,
                        children: [
                          _SummaryLine(
                            label: 'Address',
                            value: booking.pickupAddress.isEmpty ? 'Not provided' : booking.pickupAddress,
                          ),
                          _SummaryLine(
                            label: 'Contact',
                            value: booking.pickupContact.isEmpty ? 'Not provided' : booking.pickupContact,
                          ),
                          _SummaryLine(
                            label: 'Phone',
                            value: booking.pickupPhone.isEmpty ? 'Not provided' : booking.pickupPhone,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _SummarySection(
                        title: 'Receiver',
                        icon: Icons.location_on_outlined,
                        children: [
                          _SummaryLine(
                            label: 'Address',
                            value: booking.receiverAddress.isEmpty ? 'Not provided' : booking.receiverAddress,
                          ),
                          _SummaryLine(
                            label: 'Contact',
                            value: booking.receiverContact.isEmpty ? 'Not provided' : booking.receiverContact,
                          ),
                          _SummaryLine(
                            label: 'Phone',
                            value: booking.receiverPhone.isEmpty ? 'Not provided' : booking.receiverPhone,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _SummarySection(
                        title: 'Pay with',
                        icon: Icons.payments_outlined,
                        children: [
                          RadioListTile<String>(
                            value: 'cash',
                            groupValue: _paymentMethod,
                            onChanged: (v) => setState(() => _paymentMethod = v ?? 'cash'),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            activeColor: AppColors.primaryNavy,
                            title: const Text('Cash'),
                          ),
                          RadioListTile<String>(
                            value: 'wallet',
                            groupValue: _paymentMethod,
                            onChanged: (v) => setState(() => _paymentMethod = v ?? 'wallet'),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            activeColor: AppColors.primaryNavy,
                            title: const Text('HillGo Wallet'),
                          ),
                          _SummaryLine(
                            label: 'Total Fare',
                            value: '৳${fare.toStringAsFixed(0)}',
                            emphasize: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: _booking ? 'Booking…' : 'Book Parcel',
                backgroundColor: AppColors.accentOrange,
                borderRadius: 14,
                onPressed: _booking ? null : _bookParcel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
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
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryNavy),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyLarge?.copyWith(
                color: emphasize ? AppColors.primaryNavy : AppColors.textPrimary,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

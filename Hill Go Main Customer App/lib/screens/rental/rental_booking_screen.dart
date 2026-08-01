import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/fare_row.dart';
import '../../widgets/primary_button.dart';
import 'rental_confirmation_screen.dart';

class RentalBookingScreen extends StatefulWidget {
  const RentalBookingScreen({super.key, required this.booking});

  static const String routeName = '/rental/booking';

  final RentalBooking booking;

  @override
  State<RentalBookingScreen> createState() => _RentalBookingScreenState();
}

class _RentalBookingScreenState extends State<RentalBookingScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _pickupController;
  late final TextEditingController _dropoffController;

  @override
  void initState() {
    super.initState();
    final user = AuthService.user;
    final booking = widget.booking;
    _nameController = TextEditingController(
      text: booking.renterName.isEmpty ? user.name : booking.renterName,
    );
    _phoneController = TextEditingController(
      text: booking.renterPhone.isEmpty
          ? user.phoneDisplay
          : booking.renterPhone,
    );
    _pickupController = TextEditingController(text: booking.pickupLocation);
    _dropoffController = TextEditingController(text: booking.dropoffLocation);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  void _continue() {
    final booking = widget.booking;
    booking.renterName = _nameController.text.trim();
    booking.renterPhone = _phoneController.text.trim();
    booking.pickupLocation = _pickupController.text.trim();
    booking.dropoffLocation = _dropoffController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RentalConfirmationScreen(booking: booking),
      ),
    );
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
                title: 'Rent vehicle',
                subtitle: 'Dates & pickup',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${vehicle.category} · ${vehicle.transmission}',
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DaysStepper(
                        days: booking.days,
                        onChanged: (v) => setState(() {
                          booking.endDate = booking.startDate
                              .add(Duration(days: v < 1 ? 0 : v - 1));
                        }),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'With driver',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: const Text('+৳1,500 / day'),
                        value: booking.withDriver),
                        onChanged: (v) =>
                            setState(() => booking.withDriver = v),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Schedule',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _DateChip(
                              label: 'Start',
                              value: booking.startLabel,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DateChip(
                              label: 'End',
                              value: booking.endLabel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pickup & drop-off',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _InputBox(
                        controller: _pickupController,
                        hint: 'Pickup location',
                        icon: Icons.trip_origin,
                      ),
                      const SizedBox(height: 10),
                      _InputBox(
                        controller: _dropoffController,
                        hint: 'Drop-off location',
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Renter details',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _InputBox(
                        controller: _nameController,
                        hint: 'Full name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 10),
                      _InputBox(
                        controller: _phoneController,
                        hint: 'Phone number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
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
                              label: 'Vehicle (${booking.days} days)',
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
                label: 'Review rental',
                backgroundColor: const Color(0xFF00897B),
                borderRadius: 14,
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DaysStepper extends StatelessWidget {
  const _DaysStepper({required this.days, required this.onChanged});

  final int days;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Rental days',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: days > 1 ? () => onChanged(days - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: const Color(0xFF00897B),
          ),
          Text(
            '$days',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: days < 14 ? () => onChanged(days + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
            color: const Color(0xFF00897B),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          icon: Icon(icon, color: AppColors.textMuted, size: 20),
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

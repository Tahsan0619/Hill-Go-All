import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/fare_row.dart';
import '../../widgets/primary_button.dart';
import 'hotel_confirmation_screen.dart';

class HotelBookingScreen extends StatefulWidget {
  const HotelBookingScreen({super.key, required this.booking});

  static const String routeName = '/hotel/booking';

  final HotelBooking booking;

  @override
  State<HotelBookingScreen> createState() => _HotelBookingScreenState();
}

class _HotelBookingScreenState extends State<HotelBookingScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = AuthService.user;
    _nameController = TextEditingController(
      text: widget.booking.guestName.isEmpty ? user.name : widget.booking.guestName,
    );
    _phoneController = TextEditingController(
      text: widget.booking.guestPhone.isEmpty
          ? user.phoneDisplay
          : widget.booking.guestPhone,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    widget.booking.guestName = _nameController.text.trim();
    widget.booking.guestPhone = _phoneController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HotelConfirmationScreen(booking: widget.booking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
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
                title: 'Book stay',
                subtitle: 'Dates & guests',
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
                              hotel.name,
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(hotel.location, style: textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _StepperField(
                        label: 'Nights',
                        value: booking.nights,
                        onChanged: (v) => setState(() {
                          booking.checkOut =
                              booking.checkIn.add(Duration(days: v));
                        }),
                        min: 1,
                        max: 14,
                      ),
                      const SizedBox(height: 12),
                      _StepperField(
                        label: 'Guests',
                        value: booking.guests,
                        onChanged: (v) => setState(() => booking.guests = v),
                        min: 1,
                        max: 8,
                      ),
                      const SizedBox(height: 12),
                      _StepperField(
                        label: 'Rooms',
                        value: booking.rooms,
                        onChanged: (v) => setState(() => booking.rooms = v),
                        min: 1,
                        max: 4,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Check-in / Check-out',
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
                              label: 'Check-in',
                              value: booking.checkInLabel,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DateChip(
                              label: 'Check-out',
                              value: booking.checkOutLabel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Guest details',
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
                              label:
                                  'Room (${booking.nights} nights × ${booking.rooms})',
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Review booking',
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

class _StepperField extends StatelessWidget {
  const _StepperField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

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
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.primaryNavy,
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primaryNavy,
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
              fontSize: 13,
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

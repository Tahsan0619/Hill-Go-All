import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/primary_button.dart';
import 'receiver_details_screen.dart';

class PickupDetailsScreen extends StatefulWidget {
  const PickupDetailsScreen({super.key, required this.booking});

  static const String routeName = '/parcel/pickup';

  final ParcelBooking booking;

  @override
  State<PickupDetailsScreen> createState() => _PickupDetailsScreenState();
}

class _PickupDetailsScreenState extends State<PickupDetailsScreen> {
  late final _addressController =
      TextEditingController(text: widget.booking.pickupAddress);
  late final _nameController =
      TextEditingController(text: widget.booking.pickupContact);
  late final _phoneController =
      TextEditingController(text: widget.booking.pickupPhone);

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    widget.booking
      ..pickupAddress = _addressController.text
      ..pickupContact = _nameController.text
      ..pickupPhone = _phoneController.text;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReceiverDetailsScreen(booking: widget.booking),
      ),
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
                title: 'Pickup Details',
                subtitle: 'Step 2 of 5',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Where should we pick it up?",
                        style: textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      LabeledTextField(
                        label: 'Pickup Address',
                        controller: _addressController,
                        hintText: 'House, road, area, city',
                        icon: Icons.location_on_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      LabeledTextField(
                        label: 'Contact Name',
                        controller: _nameController,
                        hintText: 'Full name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      LabeledTextField(
                        label: 'Contact Phone',
                        controller: _phoneController,
                        hintText: '01XXX-XXXXXX',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Continue',
                backgroundColor: AppColors.primaryNavy,
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

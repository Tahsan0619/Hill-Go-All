import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/primary_button.dart';
import 'price_estimate_screen.dart';

class ReceiverDetailsScreen extends StatefulWidget {
  const ReceiverDetailsScreen({super.key, required this.booking});

  static const String routeName = '/parcel/receiver';

  final ParcelBooking booking;

  @override
  State<ReceiverDetailsScreen> createState() => _ReceiverDetailsScreenState();
}

class _ReceiverDetailsScreenState extends State<ReceiverDetailsScreen> {
  late final _addressController =
      TextEditingController(text: widget.booking.receiverAddress);
  late final _nameController =
      TextEditingController(text: widget.booking.receiverContact);
  late final _phoneController =
      TextEditingController(text: widget.booking.receiverPhone);

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    widget.booking
      ..receiverAddress = _addressController.text
      ..receiverContact = _nameController.text
      ..receiverPhone = _phoneController.text;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PriceEstimateScreen(booking: widget.booking),
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
                title: 'Receiver Details',
                subtitle: 'Step 3 of 5',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Who is receiving this parcel?',
                        style: textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      LabeledTextField(
                        label: 'Receiver Address',
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

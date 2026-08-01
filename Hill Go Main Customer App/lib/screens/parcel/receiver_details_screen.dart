import 'package:flutter/material.dart';

import '../../models/catalog_models.dart';
import '../../services/api/parcels_api.dart';
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
  late final _weightController = TextEditingController(
    text: widget.booking.weightKg > 0
        ? widget.booking.weightKg.toStringAsFixed(
            widget.booking.weightKg.truncateToDouble() == widget.booking.weightKg
                ? 0
                : 1)
        : '',
  );
  late final _distanceController = TextEditingController(
    text: widget.booking.distanceKm > 0
        ? widget.booking.distanceKm.toStringAsFixed(1)
        : '',
  );
  String? _fieldError;

  bool get _hasCoords =>
      widget.booking.pickupLat != null &&
      widget.booking.pickupLng != null &&
      widget.booking.dropLat != null &&
      widget.booking.dropLng != null;

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  void _continue() {
    final weight = double.tryParse(_weightController.text.trim());
    if (weight == null || weight <= 0) {
      setState(() => _fieldError = 'Enter parcel weight in kg (0.1–50).');
      return;
    }
    if (weight < 0.1 || weight > 50) {
      setState(() => _fieldError = 'Weight must be between 0.1 and 50 kg.');
      return;
    }

    double distance;
    final computed = ParcelsApi.haversineKm(
      pickupLat: widget.booking.pickupLat,
      pickupLng: widget.booking.pickupLng,
      dropLat: widget.booking.dropLat,
      dropLng: widget.booking.dropLng,
    );
    if (computed != null) {
      distance = computed;
    } else {
      final parsed = double.tryParse(_distanceController.text.trim());
      if (parsed == null || parsed <= 0) {
        setState(() => _fieldError = 'Enter delivery distance in km (0.1–500).');
        return;
      }
      if (parsed < 0.1 || parsed > 500) {
        setState(() => _fieldError = 'Distance must be between 0.1 and 500 km.');
        return;
      }
      distance = parsed;
    }

    widget.booking
      ..receiverAddress = _addressController.text
      ..receiverContact = _nameController.text
      ..receiverPhone = _phoneController.text
      ..weightKg = weight
      ..distanceKm = distance;

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
                      const SizedBox(height: 16),
                      LabeledTextField(
                        label: 'Parcel Weight (kg)',
                        controller: _weightController,
                        hintText: 'e.g. 2.5',
                        icon: Icons.scale_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      if (!_hasCoords) ...[
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: 'Distance (km)',
                          controller: _distanceController,
                          hintText: 'e.g. 8.0',
                          icon: Icons.route_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        Text(
                          'Distance will be calculated from pickup and drop coordinates.',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                      if (_fieldError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _fieldError!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ],
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

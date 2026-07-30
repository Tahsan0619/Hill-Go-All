import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_bar.dart';
import '../../widgets/primary_button.dart';
import 'pickup_details_screen.dart';

class ParcelTypeScreen extends StatefulWidget {
  const ParcelTypeScreen({super.key});

  static const String routeName = '/parcel/type';

  @override
  State<ParcelTypeScreen> createState() => _ParcelTypeScreenState();
}

class _ParcelTypeOption {
  const _ParcelTypeOption(this.label, this.description, this.icon);

  final String label;
  final String description;
  final IconData icon;
}

class _ParcelTypeScreenState extends State<ParcelTypeScreen> {
  String? _selected;

  static const _options = [
    _ParcelTypeOption(
      'Document',
      'Papers, letters and small files',
      Icons.description_outlined,
    ),
    _ParcelTypeOption(
      'Box',
      'Packages, parcels and boxed items',
      Icons.inventory_2_outlined,
    ),
    _ParcelTypeOption(
      'Fragile',
      'Items that need extra careful handling',
      Icons.warning_amber_outlined,
    ),
  ];

  void _continue() {
    if (_selected == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PickupDetailsScreen(
          booking: ParcelBooking(parcelType: _selected),
        ),
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
              const AppBackBar(title: 'Send a Parcel'),
              const SizedBox(height: 20),
              Text(
                'What are you sending?',
                style: textTheme.headlineMedium?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 4),
              Text(
                'Select the parcel type so we can prepare the right handling.',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    final selected = option.label == _selected;
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _selected = option.label),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? AppColors.primaryNavy : AppColors.cardBorder,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primaryNavy
                                    : const Color(0xFFEAF1FB),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                option.icon,
                                size: 24,
                                color: selected ? AppColors.white : AppColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.label,
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(option.description, style: textTheme.bodyMedium),
                                ],
                              ),
                            ),
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: selected ? AppColors.primaryNavy : AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Continue',
                backgroundColor: AppColors.primaryNavy,
                borderRadius: 14,
                onPressed: _selected == null ? null : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

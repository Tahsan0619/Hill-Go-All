import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';
import 'onboarding_shell.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _plate = TextEditingController();
  String? _photoPath;

  @override
  void dispose() {
    _make.dispose();
    _model.dispose();
    _year.dispose();
    _plate.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) setState(() => _photoPath = file.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.saveVehicle(
      VehicleInfo(
        make: _make.text.trim(),
        model: _model.text.trim(),
        year: _year.text.trim(),
        plate: _plate.text.trim().toUpperCase(),
        photoPath: _photoPath,
      ),
    );
    if (!mounted) return;
    if (ok) {
      context.go('/onboarding/documents');
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return OnboardingShell(
      title: 'Partner Portal',
      stepLabel: 'Step 3 of 5',
      currentTab: 0,
      child: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  Text('Vehicle Information', style: AppTextStyles.headline),
                  const SizedBox(height: 8),
                  Text(
                    'Provide details about the vehicle you will be using for deliveries to ensure compliance and safety.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Vehicle Make',
                    controller: _make,
                    hint: 'e.g., Toyota',
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Model',
                    controller: _model,
                    hint: 'e.g., Camry',
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Year',
                    controller: _year,
                    hint: 'e.g., 2022',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final y = int.tryParse(v ?? '');
                      if (y == null || y < 1995 || y > DateTime.now().year + 1) {
                        return 'Enter a valid year';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'License Plate Number',
                    controller: _plate,
                    hint: 'ABC-1234',
                    validator: (v) => (v == null || v.trim().length < 3) ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  Text('Vehicle Photo', style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(
                          color: AppColors.border,
                          style: BorderStyle.solid,
                          width: 1.5,
                        ),
                      ),
                      child: _photoPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                              child: Image.file(File(_photoPath!), fit: BoxFit.cover, width: double.infinity),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.photo_camera, color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                Text('Tap to take or upload a photo', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text('Front view with plate visible preferred', style: AppTextStyles.caption),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardBlueTint,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ensure all information matches your vehicle registration documents. Our team will verify these details within 24 hours.',
                            style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/onboarding/personal'),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: 'Save Vehicle  >',
                    loading: auth.isLoading,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

class AccountVehicleScreen extends StatefulWidget {
  const AccountVehicleScreen({super.key});

  @override
  State<AccountVehicleScreen> createState() => _AccountVehicleScreenState();
}

class _AccountVehicleScreenState extends State<AccountVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _make;
  late final TextEditingController _model;
  late final TextEditingController _year;
  late final TextEditingController _plate;
  VehicleCategory _category = VehicleCategory.car;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    final v = context.read<AuthProvider>().user?.vehicle;
    _make = TextEditingController(text: v?.make ?? '');
    _model = TextEditingController(text: v?.model ?? '');
    _year = TextEditingController(text: v?.year ?? '');
    _plate = TextEditingController(text: v?.plate ?? '');
    _category = v?.category ?? VehicleCategory.car;
    _photoPath = v?.photoPath;
  }

  @override
  void dispose() {
    _make.dispose();
    _model.dispose();
    _year.dispose();
    _plate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Information'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            SegmentedButton<VehicleCategory>(
              segments: VehicleCategory.values
                  .map((c) => ButtonSegment(value: c, label: Text(c.label)))
                  .toList(),
              selected: {_category},
              onSelectionChanged: (s) => setState(() => _category = s.first),
            ),
            const SizedBox(height: 12),
            AppTextField(label: 'Make', controller: _make, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
            const SizedBox(height: 12),
            AppTextField(label: 'Model', controller: _model, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
            const SizedBox(height: 12),
            AppTextField(label: 'Year', controller: _year, keyboardType: TextInputType.number, validator: (v) => (v == null || v.length != 4) ? 'Required' : null),
            const SizedBox(height: 12),
            AppTextField(label: 'Plate', controller: _plate, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (file != null) setState(() => _photoPath = file.path);
              },
              child: Container(
                height: 140,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  color: AppColors.surface,
                ),
                child: _photoPath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.photo_camera, color: AppColors.primary),
                          Text('Update vehicle photo', style: AppTextStyles.body),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(_photoPath!), fit: BoxFit.cover, width: double.infinity, height: 140),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Save Vehicle',
              loading: auth.isLoading,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final ok = await auth.saveVehicle(
                  VehicleInfo(
                    make: _make.text.trim(),
                    model: _model.text.trim(),
                    year: _year.text.trim(),
                    plate: _plate.text.trim().toUpperCase(),
                    category: _category,
                    photoPath: _photoPath,
                  ),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Vehicle saved' : (auth.error ?? 'Failed'))),
                );
                if (ok) context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

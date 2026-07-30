import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';
import 'onboarding_shell.dart';

class RegistrationStepScreen extends StatefulWidget {
  const RegistrationStepScreen({super.key});

  @override
  State<RegistrationStepScreen> createState() => _RegistrationStepScreenState();
}

class _RegistrationStepScreenState extends State<RegistrationStepScreen> {
  final _formKey = GlobalKey<FormState>();
  String _city = 'Chicago';
  String _vehicleType = 'Sedan';
  bool _agree = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return OnboardingShell(
      title: 'Partner Portal',
      stepLabel: 'Step 1 of 5',
      currentTab: 0,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text('Partner Registration', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            Text(
              'Confirm your basics so we can set up your HillGo Rider account.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 24),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.name ?? 'Partner', style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '', style: AppTextStyles.bodySecondary),
                  Text(user?.phone ?? '', style: AppTextStyles.bodySecondary),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Operating city', style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _city,
              items: const [
                DropdownMenuItem(value: 'Chicago', child: Text('Chicago')),
                DropdownMenuItem(value: 'New York', child: Text('New York')),
                DropdownMenuItem(value: 'Austin', child: Text('Austin')),
              ],
              onChanged: (v) => setState(() => _city = v ?? _city),
            ),
            const SizedBox(height: 16),
            Text('Vehicle type', style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _vehicleType,
              items: const [
                DropdownMenuItem(value: 'Sedan', child: Text('Sedan')),
                DropdownMenuItem(value: 'SUV', child: Text('SUV')),
                DropdownMenuItem(value: 'Van', child: Text('Cargo Van')),
                DropdownMenuItem(value: 'Bike', child: Text('E-Bike')),
              ],
              onChanged: (v) => setState(() => _vehicleType = v ?? _vehicleType),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _agree,
              activeColor: AppColors.primary,
              title: Text(
                'I agree to HillGo partner terms and background check policy.',
                style: AppTextStyles.bodySecondary,
              ),
              onChanged: (v) => setState(() => _agree = v ?? false),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Continue',
              onPressed: !_agree
                  ? null
                  : () async {
                      await context.read<AuthProvider>().advanceOnboarding(OnboardingStep.personalInfo);
                      if (context.mounted) context.go('/onboarding/personal');
                    },
            ),
          ],
        ),
      ),
    );
  }
}

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
                      'Next you will add your personal details, vehicle and KYC '
                      'documents. Our team verifies everything before you can go online.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
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

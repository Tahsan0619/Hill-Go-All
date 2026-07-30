import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/document_provider.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';
import 'onboarding_shell.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  final _address = TextEditingController();
  final _city = TextEditingController(text: 'Chicago, IL');
  final _dob = TextEditingController();
  final _ssn = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: context.read<AuthProvider>().user?.name ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _city.dispose();
    _dob.dispose();
    _ssn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      title: 'Partner Portal',
      stepLabel: 'Step 2 of 5',
      currentTab: 0,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text('Personal Information', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            Text(
              'This information is used for identity verification and payouts.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Legal full name',
              controller: _name,
              validator: (v) => (v == null || v.trim().length < 2) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Home address',
              controller: _address,
              hint: '123 Main St, Apt 4',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'City / State',
              controller: _city,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Date of birth',
              controller: _dob,
              hint: 'MM/DD/YYYY',
              validator: (v) => (v == null || v.trim().length < 8) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'SSN last 4',
              controller: _ssn,
              hint: '1234',
              keyboardType: TextInputType.number,
              maxLength: 4,
              validator: (v) => (v == null || v.length != 4) ? 'Enter 4 digits' : null,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/onboarding/registration'),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: 'Continue',
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      context.read<DocumentProvider>().savePersonalInfo(
                            fullName: _name.text.trim(),
                            address: _address.text.trim(),
                            city: _city.text.trim(),
                            dob: _dob.text.trim(),
                            ssnLast4: _ssn.text.trim(),
                          );
                      await context.read<AuthProvider>().advanceOnboarding(OnboardingStep.vehicle);
                      if (context.mounted) context.go('/onboarding/vehicle');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

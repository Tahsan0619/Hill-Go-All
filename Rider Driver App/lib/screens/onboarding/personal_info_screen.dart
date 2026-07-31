import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
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
  final _nid = TextEditingController();
  String? _districtId;
  DateTime? _dob;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: context.read<AuthProvider>().user?.name ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadDistricts();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _nid.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 80),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: 'Date of birth (18+ required)',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select your date of birth')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.submitPersonalInfo(
      legalName: _name.text.trim(),
      homeAddress: _address.text.trim(),
      districtId: _districtId!,
      dob: DateFormat('yyyy-MM-dd').format(_dob!),
      nid: _nid.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      context.go('/onboarding/vehicle');
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final districts = auth.districts
        .where((d) => d.open && d.allowRider)
        .toList();

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
              hint: 'House, road, area',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            Text('District', style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _districtId,
              hint: Text(
                districts.isEmpty ? 'Loading districts…' : 'Select your district',
                style: AppTextStyles.bodySecondary,
              ),
              items: districts
                  .map((d) => DropdownMenuItem(
                        value: d.id,
                        child: Text(
                          d.division == null ? d.name : '${d.name} (${d.division})',
                        ),
                      ))
                  .toList(),
              validator: (v) => v == null ? 'Select your district' : null,
              onChanged: (v) => setState(() => _districtId = v),
            ),
            const SizedBox(height: 14),
            Text('Date of birth', style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDob,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cake_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      _dob == null
                          ? 'Select date of birth'
                          : DateFormat('d MMM yyyy').format(_dob!),
                      style: _dob == null
                          ? AppTextStyles.bodySecondary
                          : AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'NID number',
              controller: _nid,
              hint: 'National ID number',
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.trim().length < 8) ? 'Enter your NID number' : null,
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
                    loading: auth.isLoading,
                    onPressed: _submit,
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

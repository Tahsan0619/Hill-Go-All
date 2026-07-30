import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class RegisterStep1Screen extends StatefulWidget {
  const RegisterStep1Screen({super.key});

  @override
  State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _nid;
  String _vehicle = '';
  bool _terms = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _name = TextEditingController(text: auth.regFullName);
    _phone = TextEditingController(text: auth.regPhone);
    _nid = TextEditingController(text: auth.regNid);
    _vehicle = auth.regVehicleType;
    _terms = auth.termsAccepted;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _nid.dispose();
    super.dispose();
  }

  void _termsDialog(String title) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: const Text(
          'This is a placeholder for HillGo Courier policies. By continuing, you agree to provide accurate information and follow our courier safety standards.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    if (_vehicle.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select your vehicle type')));
      return;
    }
    if (!_terms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accept the Terms of Service to continue'),
        ),
      );
      return;
    }
    context.read<AuthProvider>()
      ..termsAccepted = _terms
      ..saveRegistrationStep1(
        fullName: _name.text.trim(),
        phone: _phone.text.trim(),
        nid: _nid.text.trim(),
        vehicleType: _vehicle,
      );
    context.push('/register/documents');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('HillGo Courier', style: AppTextStyles.brand),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step 1 of 4',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _Steps(active: 1),
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXl,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.delivery_dining_rounded,
                          color: Colors.white,
                          size: 82,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Courier Registration', style: AppTextStyles.h1),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tell us a little about yourself and how you will deliver.',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _field('Full name', _name, Icons.badge_outlined),
                    _field(
                      'Contact number',
                      _phone,
                      Icons.phone_outlined,
                      type: TextInputType.phone,
                    ),
                    _field(
                      'NID / Identity number',
                      _nid,
                      Icons.credit_card_outlined,
                    ),
                    const SectionLabel('Select your vehicle'),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        _VehicleCard(
                          label: 'Motorbike',
                          icon: Icons.two_wheeler_rounded,
                          selected: _vehicle == 'Motorbike',
                          onTap: () => setState(() => _vehicle = 'Motorbike'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _VehicleCard(
                          label: 'Bicycle',
                          icon: Icons.pedal_bike_rounded,
                          selected: _vehicle == 'Bicycle',
                          onTap: () => setState(() => _vehicle = 'Bicycle'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _VehicleCard(
                          label: 'Van',
                          icon: Icons.airport_shuttle_rounded,
                          selected: _vehicle == 'Van',
                          onTap: () => setState(() => _vehicle = 'Van'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CheckboxListTile(
                      value: _terms,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.primary,
                      title: Wrap(
                        children: [
                          Text(
                            'I agree to the ',
                            style: AppTextStyles.bodySecondary,
                          ),
                          InkWell(
                            onTap: () => _termsDialog('Terms of Service'),
                            child: Text(
                              'Terms of Service',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(' and ', style: AppTextStyles.bodySecondary),
                          InkWell(
                            onTap: () => _termsDialog('Privacy Policy'),
                            child: Text(
                              'Privacy Policy',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onChanged: (value) =>
                          setState(() => _terms = value ?? false),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(label: 'Continue', onPressed: _continue),
                    const SizedBox(height: AppSpacing.xl),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            '© 2026 HillGo  ·  ',
                            style: AppTextStyles.caption,
                          ),
                          InkWell(
                            onTap: () => context.push('/help'),
                            child: Text(
                              'Help',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Text('  ·  ', style: AppTextStyles.caption),
                          InkWell(
                            onTap: () => context.push('/help'),
                            child: Text(
                              'Safety',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? type,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            suffixIcon: Icon(icon, color: AppColors.primary),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? '$label is required' : null,
        ),
      ],
    ),
  );
}

class _Steps extends StatelessWidget {
  const _Steps({required this.active});
  final int active;
  @override
  Widget build(BuildContext context) {
    const labels = ['Basic Info', 'Documents', 'Verification', 'Review'];
    return Row(
      children: List.generate(labels.length, (i) {
        final current = i + 1;
        final on = current <= active;
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: on ? AppColors.primary : AppColors.divider,
                ),
                child: Text(
                  '$current',
                  style: AppTextStyles.caption.copyWith(
                    color: on ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[i],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: current == active
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: .08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.cardBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class RegisterStep3Screen extends StatefulWidget {
  const RegisterStep3Screen({super.key});
  @override
  State<RegisterStep3Screen> createState() => _RegisterStep3ScreenState();
}

class _RegisterStep3ScreenState extends State<RegisterStep3Screen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _email = TextEditingController(text: auth.regEmail);
    _password = TextEditingController(text: auth.regPassword);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String get _maskedPhone {
    final phone = context.read<AuthProvider>().regPhone;
    if (phone.length < 5) return phone;
    return '${phone.substring(0, 3)}•••${phone.substring(phone.length - 2)}';
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthProvider>().saveRegistrationCredentials(
      email: _email.text.trim(),
      password: _password.text,
    );
    context.push('/register/review');
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
      body: SingleChildScrollView(
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
                    'Step 3 of 4',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _VerificationSteps(active: 3),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Create your credentials', style: AppTextStyles.h1),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Set the email and password you will use to log in.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    color: AppColors.primary.withValues(alpha: .035),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone_iphone_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Your phone $_maskedPhone will be linked to this '
                            'account for OTP login and delivery updates.',
                            style: AppTextStyles.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionLabel('Email address'),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'you@example.com',
                    ),
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Enter a valid email address'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionLabel('Create password'),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _password,
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      hintText: 'At least 8 characters',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                      ),
                    ),
                    validator: (v) => v == null || v.length < 8
                        ? 'Use at least 8 characters'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: 'Continue to review',
                    onPressed: _continue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VerificationSteps extends StatelessWidget {
  const _VerificationSteps({required this.active});
  final int active;
  @override
  Widget build(BuildContext context) {
    const labels = ['Basic Info', 'Documents', 'Credentials', 'Review'];
    return Row(
      children: List.generate(4, (i) {
        final step = i + 1;
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step <= active ? AppColors.primary : AppColors.divider,
                ),
                child: Text(
                  '$step',
                  style: AppTextStyles.caption.copyWith(
                    color: step <= active
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[i],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: step == active
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

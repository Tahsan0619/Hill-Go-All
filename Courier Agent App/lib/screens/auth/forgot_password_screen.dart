import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/otp_input.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contact = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  int _step = 1;
  String _otp = '';
  bool _hidePassword = true;

  @override
  void dispose() {
    _contact.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final auth = context.read<AuthProvider>();
    if (_step == 1) {
      if (!_formKey.currentState!.validate()) return;
      await auth.sendOtp(_contact.text.trim());
      if (mounted && auth.error == null) setState(() => _step = 2);
      return;
    }
    if (_step == 2) {
      if (_otp.length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter the 6-digit verification code')),
        );
        return;
      }
      setState(() => _step = 3);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final success = await auth.resetPassword(
      contact: _contact.text.trim(),
      otp: _otp,
      newPassword: _password.text,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully. Please log in.'),
        ),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Unable to reset password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    final title = switch (_step) {
      1 => 'Forgot password?',
      2 => 'Verify your code',
      _ => 'Create a new password',
    };
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => _step == 1 ? context.pop() : setState(() => _step--),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.loginBg),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: AppCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STEP $_step OF 3',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(title, style: AppTextStyles.h1),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _step == 1
                            ? 'Enter the email address or phone number linked to your account.'
                            : _step == 2
                            ? 'Enter the code sent to ${_contact.text.trim()}.'
                            : 'Choose a strong password you have not used before.',
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      if (_step == 1) ...[
                        const SectionLabel('Email or phone'),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _contact,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline_rounded),
                            hintText: 'you@example.com',
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Enter your email or phone number'
                              : null,
                        ),
                      ] else if (_step == 2) ...[
                        OtpInputRow(
                          length: 6,
                          onChanged: (value) => _otp = value,
                          onCompleted: (value) => _otp = value,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: ResendTimer(
                            onResend: () => context
                                .read<AuthProvider>()
                                .sendOtp(_contact.text.trim()),
                          ),
                        ),
                      ] else ...[
                        const SectionLabel('New password'),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _password,
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            hintText: 'At least 6 characters',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () => setState(
                                () => _hidePassword = !_hidePassword,
                              ),
                            ),
                          ),
                          validator: (v) => v == null || v.length < 6
                              ? 'Use at least 6 characters'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const SectionLabel('Confirm password'),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _confirm,
                          obscureText: _hidePassword,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                            hintText: 'Repeat your password',
                          ),
                          validator: (v) => v != _password.text
                              ? 'Passwords do not match'
                              : null,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: _step == 1
                            ? 'Send verification code'
                            : _step == 2
                            ? 'Continue'
                            : 'Reset password',
                        loading: loading,
                        onPressed: _next,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

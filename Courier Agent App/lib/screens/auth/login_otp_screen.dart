import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/otp_input.dart';

class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({super.key});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  final _contact = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;
  String _otp = '';

  @override
  void dispose() {
    _contact.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.sendLoginOtp(_contact.text.trim());
    if (!mounted) return;
    if (ok) {
      setState(() => _sent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Could not send the code')),
      );
    }
  }

  Future<void> _verify() async {
    if (_otp.length != 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter the 4-digit code')));
      return;
    }
    final success = await context.read<AuthProvider>().loginWithOtp(
      phone: _contact.text.trim(),
      otp: _otp,
    );
    if (!mounted) return;
    if (success) {
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AuthProvider>().error ?? 'Invalid code'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
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
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: const BoxDecoration(
                          color: AppColors.accentSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sms_outlined,
                          color: AppColors.accent,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        _sent ? 'Check your messages' : 'Log in with OTP',
                        style: AppTextStyles.h1,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _sent
                            ? 'We sent a 4-digit code to ${_contact.text.trim()}.'
                            : 'Enter your registered phone number to receive a login code.',
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      if (!_sent) ...[
                        const SectionLabel('Phone number'),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _contact,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintText: '01XXXXXXXXX',
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Enter your phone number'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: 'Send code',
                          loading: auth.isLoading,
                          onPressed: _sendCode,
                        ),
                      ] else ...[
                        Center(
                          child: OtpInputRow(
                            length: 4,
                            onChanged: (value) => _otp = value,
                            onCompleted: (value) => _otp = value,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: ResendTimer(
                            onResend: () async {
                              final auth = context.read<AuthProvider>();
                              final messenger = ScaffoldMessenger.of(context);
                              final ok = await auth.sendLoginOtp(
                                _contact.text.trim(),
                              );
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? 'A new code has been sent'
                                        : (auth.error ?? 'Could not resend the code'),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: 'Verify & log in',
                          loading: auth.isLoading,
                          onPressed: _verify,
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () => setState(() => _sent = false),
                            child: const Text('Use a different number'),
                          ),
                        ),
                      ],
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

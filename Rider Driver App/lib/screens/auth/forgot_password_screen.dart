import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _codeSent = false;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _send({bool isResend = false}) async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    if (isResend && auth.resendSeconds > 0) return;
    final ok = await auth.requestPasswordReset(_phone.text.trim());
    if (!mounted) return;
    if (ok) {
      setState(() => _codeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isResend
                ? 'Code resent'
                : 'If the account exists, a reset code was sent by SMS.',
          ),
        ),
      );
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.resetPassword(_phone.text.trim(), _code.text.trim(), _password.text);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated. Please sign in.')),
      );
      context.go('/login');
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reset your password', style: AppTextStyles.headline),
                const SizedBox(height: 8),
                Text(
                  'Enter your account phone number. We’ll send a verification code by SMS to continue.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Phone number',
                  controller: _phone,
                  hint: '01712345678',
                  keyboardType: TextInputType.phone,
                  enabled: !_codeSent,
                  validator: (v) {
                    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                    return digits.length < 10 ? 'Enter a valid BD mobile number' : null;
                  },
                ),
                if (_codeSent) ...[
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Code',
                    controller: _code,
                    hint: 'Enter the code',
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (v) => (v == null || v.length < 4) ? 'Enter the code we sent' : null,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'New password',
                    controller: _password,
                    obscure: true,
                    validator: (v) => (v == null || v.length < 8) ? 'Min 8 characters' : null,
                  ),
                ],
                const SizedBox(height: 28),
                PrimaryButton(
                  label: _codeSent ? 'Update Password' : 'Send Code',
                  loading: auth.isLoading,
                  onPressed: _codeSent ? _reset : () => _send(),
                ),
                if (_codeSent) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: auth.resendSeconds > 0 || auth.isLoading
                          ? null
                          : () => _send(isResend: true),
                      child: Text(
                        auth.resendSeconds > 0
                            ? 'Resend in ${auth.resendSeconds}s'
                            : 'Resend code',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

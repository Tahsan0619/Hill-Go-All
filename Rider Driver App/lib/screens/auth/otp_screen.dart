import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, this.target});

  final String? target;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _code = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureSent());
  }

  Future<void> _ensureSent() async {
    final auth = context.read<AuthProvider>();
    final target = widget.target ?? auth.pendingOtpTarget ?? 'demo@hillgo.com';
    if (auth.pendingOtpTarget == null) {
      await auth.sendOtp(target);
    }
    if (mounted) {
      setState(() => _sent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code sent. Use 123456 or any 6-digit code.')),
      );
    }
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(_code.text);
    if (!mounted) return;
    if (ok) {
      final user = auth.user;
      if (user != null && !user.onboardingComplete) {
        context.go('/onboarding/registration');
      } else {
        context.go('/home');
      }
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final target = widget.target ?? auth.pendingOtpTarget ?? 'your device';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Code'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Check your messages', style: AppTextStyles.headline),
                const SizedBox(height: 8),
                Text(
                  _sent
                      ? 'We sent a 6-digit code to $target.'
                      : 'Sending verification code…',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 28),
                AppTextField(
                  label: 'Verification code',
                  controller: _code,
                  hint: '123456',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (v) {
                    if (v == null || v.length != 6 || int.tryParse(v) == null) {
                      return 'Enter a 6-digit code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text('Demo OTP: 123456', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Verify & Continue',
                  loading: auth.isLoading,
                  onPressed: _verify,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: auth.resendSeconds > 0
                        ? null
                        : () async {
                            await auth.sendOtp(target);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Code resent')),
                              );
                            }
                          },
                    child: Text(
                      auth.resendSeconds > 0
                          ? 'Resend in ${auth.resendSeconds}s'
                          : 'Resend code',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

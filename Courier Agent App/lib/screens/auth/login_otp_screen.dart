import 'dart:async';

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
  static const _maxAttempts = 5;
  static const _lockDuration = Duration(seconds: 30);

  final _contact = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;
  String _otp = '';
  int _failedAttempts = 0;
  DateTime? _lockedUntil;
  Timer? _lockTimer;
  int _lockSecondsLeft = 0;

  bool get _isLocked =>
      _lockedUntil != null && DateTime.now().isBefore(_lockedUntil!);

  @override
  void dispose() {
    _lockTimer?.cancel();
    _contact.dispose();
    super.dispose();
  }

  void _startLockout() {
    _lockTimer?.cancel();
    _lockedUntil = DateTime.now().add(_lockDuration);
    _failedAttempts = 0;
    _lockSecondsLeft = _lockDuration.inSeconds;
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = _lockedUntil?.difference(DateTime.now()).inSeconds ?? 0;
      if (remaining <= 0) {
        timer.cancel();
        setState(() {
          _lockedUntil = null;
          _lockSecondsLeft = 0;
        });
      } else {
        setState(() => _lockSecondsLeft = remaining);
      }
    });
    setState(() {});
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.sendLoginOtp(_contact.text.trim());
    if (!mounted) return;
    if (ok) {
      setState(() {
        _sent = true;
        _failedAttempts = 0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Could not send the code')),
      );
    }
  }

  Future<void> _verify() async {
    if (_isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Too many attempts. Try again in $_lockSecondsLeft seconds.',
          ),
        ),
      );
      return;
    }
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
      _failedAttempts += 1;
      if (_failedAttempts >= _maxAttempts) {
        _startLockout();
      } else {
        setState(() {});
      }
      final messenger = ScaffoldMessenger.of(context);
      if (_isLocked) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Too many failed attempts. Please wait 30 seconds before trying again.',
            ),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(context.read<AuthProvider>().error ?? 'Invalid code'),
          ),
        );
      }
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
                        if (_isLocked)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Text(
                              'Submit disabled for $_lockSecondsLeft seconds after too many failed attempts.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
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
                          label: _isLocked
                              ? 'Try again in $_lockSecondsLeft s'
                              : 'Verify & log in',
                          loading: auth.isLoading,
                          enabled: !_isLocked,
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

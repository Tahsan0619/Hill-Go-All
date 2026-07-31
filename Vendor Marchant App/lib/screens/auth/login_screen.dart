import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _obscure = true;
  bool _isRegister = false;
  bool _awaitingOtp = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _afterAuth(AuthProvider auth) {
    final user = auth.user!;
    if (!user.onboardingComplete) {
      context.go('/onboarding');
    } else {
      context.go('/home');
    }
  }

  void _showError(AuthProvider auth) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(auth.error ?? 'Authentication failed')),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();

    if (!_isRegister) {
      final ok = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;
      ok ? _afterAuth(auth) : _showError(auth);
      return;
    }

    final outcome = await auth.register(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      otp: _awaitingOtp ? _otpCtrl.text.trim() : null,
    );
    if (!mounted) return;
    switch (outcome) {
      case RegisterOutcome.success:
        _afterAuth(auth);
        break;
      case RegisterOutcome.otpRequired:
        setState(() => _awaitingOtp = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('We sent a verification code to your phone.'),
          ),
        );
        break;
      case RegisterOutcome.failed:
        _showError(auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text('HillGo', style: AppTextStyles.brand.copyWith(fontSize: 32)),
                const SizedBox(height: 4),
                Text(
                  'Vendor',
                  style: AppTextStyles.h1.copyWith(color: AppColors.accent),
                ),
                const SizedBox(height: 12),
                Text(
                  _isRegister
                      ? 'Create your merchant account to start selling.'
                      : 'Sign in to manage your store, orders, and revenue.',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 32),
                AppCard(
                  child: _awaitingOtp ? _buildOtpStep(auth) : _buildForm(auth),
                ),
                const SizedBox(height: 16),
                if (!_awaitingOtp)
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _isRegister = !_isRegister),
                      child: Text(
                        _isRegister
                            ? 'Already have an account? Sign in'
                            : 'New merchant? Create an account',
                        style: AppTextStyles.bodyBold
                            .copyWith(color: AppColors.primary),
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

  Widget _buildForm(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isRegister) ...[
          Text('Full Name', style: AppTextStyles.label),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Owner or manager name',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          Text('Phone', style: AppTextStyles.label),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: '+8801XXXXXXXXX',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 16),
        ],
        Text(_isRegister ? 'Email' : 'Email or Phone',
            style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: _isRegister
              ? TextInputType.emailAddress
              : TextInputType.text,
          decoration: InputDecoration(
            hintText: _isRegister ? 'you@business.com' : 'Email or phone number',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (_isRegister && (!v.contains('@') || !v.contains('.'))) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Text('Password', style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passwordCtrl,
          obscureText: _obscure,
          decoration: InputDecoration(
            hintText: '••••••••',
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (_isRegister && v.length < 8) return 'At least 8 characters';
            return null;
          },
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: _isRegister ? 'Create Account' : 'Sign In',
          loading: auth.isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }

  Widget _buildOtpStep(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verify your phone', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(
          'Enter the code we sent to ${_phoneCtrl.text.trim()}.',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: 16),
        Text('Verification Code', style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextFormField(
          controller: _otpCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: '6-digit code',
            counterText: '',
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Enter the code' : null,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Verify & Create Account',
          loading: auth.isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _awaitingOtp = false;
              _otpCtrl.clear();
            }),
            child: Text(
              'Back',
              style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

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
  final _contact = TextEditingController(text: 'demo@hillgo.com');
  final _password = TextEditingController(text: 'demo1234');
  bool _obscure = true;
  bool _keepLoggedIn = true;

  @override
  void dispose() {
    _contact.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthProvider>().login(
      emailOrPhone: _contact.text.trim(),
      password: _password.text,
      keepLoggedIn: _keepLoggedIn,
    );
    if (!mounted) return;
    if (success) {
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AuthProvider>().error ?? 'Unable to log in',
          ),
        ),
      );
    }
  }

  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.loginBg),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .25),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('HillGo Courier', style: AppTextStyles.brandLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Urban Logistics, Accelerated.',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back', style: AppTextStyles.h1),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Log in to manage your deliveries.',
                              style: AppTextStyles.bodySecondary,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            const SectionLabel('Email or phone'),
                            const SizedBox(height: AppSpacing.sm),
                            TextFormField(
                              controller: _contact,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _decoration(
                                'you@example.com',
                                Icons.person_outline_rounded,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Enter your email or phone number'
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SectionLabel('Password'),
                                TextButton(
                                  onPressed: () =>
                                      context.push('/forgot-password'),
                                  child: const Text('Forgot Password?'),
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              decoration: _decoration(
                                'Enter your password',
                                Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => v == null || v.length < 6
                                  ? 'Password must be at least 6 characters'
                                  : null,
                            ),
                            CheckboxListTile(
                              value: _keepLoggedIn,
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppColors.primary,
                              title: Text(
                                'Keep me logged in',
                                style: AppTextStyles.body,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (value) =>
                                  setState(() => _keepLoggedIn = value ?? true),
                            ),
                            PrimaryButton(
                              label: 'Log In',
                              loading: loading,
                              onPressed: _login,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                  ),
                                  child: Text(
                                    'OR CONTINUE WITH',
                                    style: AppTextStyles.label,
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        context.push('/biometrics'),
                                    icon: const Icon(Icons.fingerprint_rounded),
                                    label: const Text('Biometrics'),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => context.push('/login-otp'),
                                    icon: const Icon(Icons.sms_outlined),
                                    label: const Text('OTP'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New to HillGo? ',
                          style: AppTextStyles.bodySecondary,
                        ),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: const Text('Register as a Courier →'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Your data is protected with secure encryption',
                          style: AppTextStyles.caption,
                        ),
                      ],
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
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/demo_auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/demo_login_banner.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_auth_button.dart';
import 'login_screen.dart';
import 'main_shell_screen.dart';
import 'registration_screen.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  static const String routeName = '/email-login';

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemo() {
    setState(() {
      _emailController.text = DemoAuthService.demoEmail;
      _passwordController.text = DemoAuthService.demoPassword;
      _error = null;
    });
  }

  void _login() {
    final ok = DemoAuthService.loginWithEmail(
      _emailController.text,
      _passwordController.text,
    );
    if (!ok) {
      setState(() => _error = 'Invalid email or password. Use the demo account.');
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      MainShellScreen.routeName,
      (route) => false,
    );
  }

  void _googleLogin() {
    DemoAuthService.login();
    Navigator.of(context).pushNamedAndRemoveUntil(
      MainShellScreen.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'HillGo',
                      style: textTheme.titleLarge?.copyWith(fontSize: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DemoLoginBanner(onUseDemo: _fillDemo, compact: true),
                const SizedBox(height: 24),
                Text(
                  'Welcome back',
                  style: textTheme.headlineMedium?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to continue your journey',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                AppTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  hintText: DemoAuthService.demoEmail,
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Demo password: ${DemoAuthService.demoPassword}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.signUpAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Login',
                  icon: Icons.arrow_forward,
                  backgroundColor: AppColors.primaryNavy,
                  borderRadius: 12,
                  onPressed: _login,
                ),
                const SizedBox(height: 28),
                const _LimePillDivider(label: 'or continue with phone'),
                const SizedBox(height: 20),
                SocialAuthButton(
                  label: 'Login with Phone Number',
                  leading: const Icon(
                    Icons.phone_iphone,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(LoginScreen.routeName),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SocialAuthButton(
                        label: 'Google',
                        leading: const GoogleMark(),
                        onPressed: _googleLogin,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SocialAuthButton(
                        label: 'Assistant',
                        leading: const Icon(
                          Icons.record_voice_over_outlined,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: _googleLogin,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign up now',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.signUpAccent,
                            fontWeight: FontWeight.w700,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.of(
                              context,
                            ).pushNamed(RegistrationScreen.routeName),
                        ),
                      ],
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

class _LimePillDivider extends StatelessWidget {
  const _LimePillDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.inputBorder, thickness: 1),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.brandLime,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.inputBorder, thickness: 1),
        ),
      ],
    );
  }
}

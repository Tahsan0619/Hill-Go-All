import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/demo_auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/demo_login_banner.dart';
import '../widgets/hillgo_wordmark.dart';
import '../widgets/or_divider.dart';
import '../widgets/phone_number_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_auth_button.dart';
import 'email_login_screen.dart';
import 'otp_verification_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    if (DemoAuthService.isLoggedIn) {
      _phoneController.text = DemoAuthService.user.phone;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _fillDemo() {
    setState(() {
      _phoneController.text = DemoAuthService.demoPhone;
      _error = null;
    });
  }

  void _continue() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'Please enter your phone number');
      return;
    }
    DemoAuthService.startPhoneLogin(phone);
    Navigator.of(context).pushNamed(
      OtpVerificationScreen.routeName,
      arguments: DemoAuthService.pendingPhone,
    );
  }

  void _googleLogin() {
    DemoAuthService.login();
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
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
                const HillGoWordmark(),
                const SizedBox(height: 20),
                DemoLoginBanner(onUseDemo: _fillDemo),
                const SizedBox(height: 28),
                Text(
                  'Welcome back',
                  style: textTheme.headlineMedium?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone number to continue with HillGo.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                PhoneNumberField(controller: _phoneController),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Continue',
                  backgroundColor: AppColors.primaryNavy,
                  borderRadius: 12,
                  onPressed: _continue,
                ),
                const SizedBox(height: 32),
                const OrDivider(),
                const SizedBox(height: 20),
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
                        label: 'Email',
                        leading: const Icon(
                          Icons.mail_outline,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () => Navigator.of(context).pushNamed(
                          EmailLoginScreen.routeName,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.signUpAccent,
                            fontWeight: FontWeight.w700,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.of(context).pushNamed(
                                  RegistrationScreen.routeName,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Center(
                  child: Text(
                    'By continuing, you agree to HillGo\'s Terms of Service and Privacy Policy.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
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

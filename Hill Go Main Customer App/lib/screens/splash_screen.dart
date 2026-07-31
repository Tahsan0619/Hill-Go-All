import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/dot_grid_background.dart';
import '../widgets/hillgo_logo.dart';
import '../widgets/secure_platform_badge.dart';
import 'main_shell_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Restore the session while the splash branding is shown.
    final results = await Future.wait<dynamic>([
      AuthService.restoreSession(),
      Future<void>.delayed(const Duration(milliseconds: 2200)),
    ]);
    if (!mounted) return;
    final loggedIn = results.first == true;
    Navigator.of(context).pushReplacementNamed(
      loggedIn ? MainShellScreen.routeName : OnboardingScreen.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.splashGradientStart,
        body: DotGridBackground(
          child: SafeArea(
            child: SizedBox.expand(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  const HillGoLogo(size: 96),
                  const SizedBox(height: 28),
                  Text(
                    'HillGo',
                    style: textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accentOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Spacer(flex: 2),
                  Text(
                    'Your Journey, Our Priority',
                    style: textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  const SecurePlatformBadge(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

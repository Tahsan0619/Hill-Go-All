import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class BiometricsScreen extends StatefulWidget {
  const BiometricsScreen({super.key});

  @override
  State<BiometricsScreen> createState() => _BiometricsScreenState();
}

class _BiometricsScreenState extends State<BiometricsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    if (_scanning) return;
    setState(() => _scanning = true);
    await _controller.forward(from: 0);
    if (!mounted) return;
    final success = await context.read<AuthProvider>().login(
      emailOrPhone: 'demo@hillgo.com',
      password: 'demo1234',
    );
    if (!mounted) return;
    if (success) {
      context.go('/dashboard');
    } else {
      setState(() => _scanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric sign-in could not be completed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.loginBg),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AppCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) => Container(
                        width: 144 + (_controller.value * 16),
                        height: 144 + (_controller.value * 16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: .08),
                          border: Border.all(
                            color: AppColors.primary.withValues(
                              alpha: .25 + _controller.value * .5,
                            ),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.fingerprint_rounded,
                          size: 88,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      _scanning ? 'Scanning fingerprint…' : 'Use biometrics',
                      style: AppTextStyles.h1,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _scanning
                          ? 'Keep your finger on the sensor.'
                          : 'Confirm your identity to securely access your courier account.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      label: _scanning ? 'Scanning…' : 'Scan fingerprint',
                      loading: _scanning,
                      onPressed: _scan,
                    ),
                    TextButton(
                      onPressed: _scanning ? null : () => context.go('/login'),
                      child: const Text('Use password instead'),
                    ),
                    TextButton(
                      onPressed: _scanning ? null : () => context.go('/login'),
                      child: const Text('Cancel'),
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

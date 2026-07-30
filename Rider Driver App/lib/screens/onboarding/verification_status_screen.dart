import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/document_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common.dart';
import 'onboarding_shell.dart';

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  State<VerificationStatusScreen> createState() => _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final steps = context.watch<DocumentProvider>().steps;

    return OnboardingShell(
      title: 'Verification in Progress',
      currentTab: 2,
      stepLabel: 'Step 5 of 5',
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: const Icon(Icons.hourglass_top_rounded, size: 48, color: AppColors.primary),
                ),
                Positioned(
                  right: -8,
                  top: -8,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.orangeDark,
                    child: const Icon(Icons.search, size: 16, color: Colors.white),
                  ),
                ),
                Positioned(
                  left: -8,
                  bottom: -4,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.surgeGreen,
                    child: const Icon(Icons.verified, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('Almost there, Partner!', textAlign: TextAlign.center, style: AppTextStyles.headline),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: AppTextStyles.bodySecondary,
              children: [
                const TextSpan(text: 'Our team is reviewing your documents. This usually takes '),
                TextSpan(text: '24-48 hours', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const TextSpan(text: '. We’ll notify you as soon as your account is active.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...List.generate(4, (i) {
            final labels = ['Registration', 'Documents', 'Vehicle', 'Verification'];
            final completed = i < 3;
            final inProgress = i == 3;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: inProgress ? AppColors.orangeAction : const Color(0xFFF0F1F3),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: inProgress ? Border.all(color: AppColors.orangeDark) : null,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: inProgress ? AppColors.orangeDark : AppColors.primary,
                      child: Icon(
                        inProgress ? Icons.more_horiz : Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STEP ${i + 1}',
                          style: AppTextStyles.labelCaps.copyWith(
                            color: inProgress ? AppColors.orangeDark : AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          labels[i],
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: inProgress ? AppColors.orangeDark : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (completed) ...[
                      const Spacer(),
                      // use steps data subtly
                      if (steps.isNotEmpty)
                        const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Explore Help Center',
            icon: Icons.help_outline,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Help Center', style: AppTextStyles.title),
                      const SizedBox(height: 12),
                      Text(
                        'While verification is running you can review photo tips, payout setup, and delivery safety guidelines.',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support ticket opened (mock)')),
                );
              },
              child: Text.rich(
                TextSpan(
                  style: AppTextStyles.bodySecondary,
                  children: [
                    const TextSpan(text: 'Have questions? '),
                    TextSpan(
                      text: 'Contact Support',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            color: const Color(0xFFF3F4F6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: AppColors.orangeAction),
                    const SizedBox(width: 8),
                    Text('Pro Tip', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'While we review your profile, you can watch our training videos to get ready for your first HillGo delivery.',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AccentButton(
            label: 'Enter Driver Dashboard (Demo)',
            onPressed: () async {
              await context.read<AuthProvider>().finishOnboarding();
              if (context.mounted) context.go('/home');
            },
          ),
        ],
      ),
    );
  }
}

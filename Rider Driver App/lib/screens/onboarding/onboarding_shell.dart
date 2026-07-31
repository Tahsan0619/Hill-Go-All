import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class OnboardingShell extends StatelessWidget {
  const OnboardingShell({
    super.key,
    required this.title,
    required this.child,
    required this.currentTab,
    this.stepLabel,
    this.showBack = true,
  });

  final String title;
  final Widget child;
  final int currentTab; // 0 registration, 1 documents, 2 status
  final String? stepLabel;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              )
            : null,
        actions: [
          if (stepLabel != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF0F3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(stepLabel!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ),
              ),
            )
          else
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile preview coming after verification')),
                );
              },
              icon: const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/onboarding/registration');
            case 1:
              context.go('/onboarding/documents');
            case 2:
              context.go('/onboarding/status');
          }
        },
        indicatorColor: AppColors.orangeAction.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: AppColors.orangeAction),
            label: 'Registration',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description, color: AppColors.orangeAction),
            label: 'Documents',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            selectedIcon: Icon(Icons.verified_user, color: AppColors.orangeAction),
            label: 'Status',
          ),
        ],
      ),
    );
  }
}

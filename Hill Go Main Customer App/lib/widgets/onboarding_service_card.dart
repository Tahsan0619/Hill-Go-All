import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OnboardingServiceCard extends StatelessWidget {
  const OnboardingServiceCard({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.circleColor,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color circleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 0,
                  fontSize: 15,
                ),
          ),
        ],
      ),
    );
  }
}

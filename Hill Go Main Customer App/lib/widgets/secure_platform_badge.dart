import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SecurePlatformBadge extends StatelessWidget {
  const SecurePlatformBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.verified_user_outlined,
          color: AppColors.white.withValues(alpha: 0.9),
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          'SECURE PLATFORM',
          style: labelStyle?.copyWith(
            color: AppColors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

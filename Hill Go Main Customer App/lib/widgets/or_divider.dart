import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({
    super.key,
    this.label = 'OR CONNECT WITH',
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.inputBorder, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.inputBorder, thickness: 1)),
      ],
    );
  }
}

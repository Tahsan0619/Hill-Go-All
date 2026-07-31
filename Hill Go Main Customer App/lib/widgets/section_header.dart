import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Title (+ optional subtitle) row with a trailing "See all" / "View All"
/// link. Used above horizontal lists and grids throughout the app.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingLabel,
    this.onTrailingTap,
  });

  final String title;
  final String? subtitle;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        if (trailingLabel != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailingLabel!,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.accentOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Consistent back-button + title header used across secondary screens.
class AppBackBar extends StatelessWidget {
  const AppBackBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = HillGoColors.of(context);

    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onBack ?? () => Navigator.of(context).maybePop(),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.cardBorder),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }
}

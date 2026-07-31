import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A single tappable row used in profile / settings style menus.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor = AppColors.primaryNavy,
    this.iconBackground = const Color(0xFFEAF1FB),
    this.trailingText,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBackground;
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = HillGoColors.of(context);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (trailing != null)
                  trailing!
                else ...[
                  if (trailingText != null) ...[
                    Text(
                      trailingText!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: colors.textMuted,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, color: colors.cardBorder),
      ],
    );
  }
}

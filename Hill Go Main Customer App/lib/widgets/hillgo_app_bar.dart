import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Consistent AppBar used across the ride and food delivery screens.
class HillgoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HillgoAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor = AppColors.white,
  });

  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

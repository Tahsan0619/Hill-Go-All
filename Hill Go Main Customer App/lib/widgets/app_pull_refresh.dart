import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shared pull-to-refresh wrapper used across main HillGo scroll screens.
class AppPullRefresh extends StatelessWidget {
  const AppPullRefresh({
    super.key,
    required this.child,
    this.onRefresh,
    this.padding,
  });

  final Widget child;
  final Future<void> Function()? onRefresh;
  final EdgeInsetsGeometry? padding;

  Future<void> _defaultRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 850));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.accentOrange,
      backgroundColor: AppColors.white,
      displacement: 40,
      strokeWidth: 2.6,
      onRefresh: onRefresh ?? _defaultRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

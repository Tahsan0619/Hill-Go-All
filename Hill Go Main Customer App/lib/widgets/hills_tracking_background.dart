import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Hills illustration backdrop for the home top bar.
class HillsTrackingBackground extends StatelessWidget {
  const HillsTrackingBackground({super.key, this.borderRadius = 18});

  static const String assetPath = 'assets/images/header_hills.png';

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final surface = HillGoColors.of(context).surface;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            assetPath,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: Color(0xFFE8F4FC)),
          ),
          // Strong left wash so avatar + title stay readable over the art.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  surface.withValues(alpha: 0.92),
                  surface.withValues(alpha: 0.72),
                  surface.withValues(alpha: 0.28),
                  surface.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.38, 0.7, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

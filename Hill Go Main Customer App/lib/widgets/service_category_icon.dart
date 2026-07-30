import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Circular orange (or custom-colored) icon with a label underneath.
/// Used for quick service shortcuts (Ride/Food/Parcel/Market, etc).
class ServiceCategoryIcon extends StatelessWidget {
  const ServiceCategoryIcon({
    super.key,
    required this.label,
    required this.icon,
    this.color = AppColors.accentOrange,
    this.size = 56,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSide =
            constraints.maxWidth.isFinite ? constraints.maxWidth : size;
        final resolved = math.min(size, maxSide);

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: resolved,
                height: resolved,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColors.white, size: resolved * 0.42),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

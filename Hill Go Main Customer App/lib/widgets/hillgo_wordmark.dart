import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HillGoWordmark extends StatelessWidget {
  const HillGoWordmark({
    super.key,
    this.fontSize = 28,
    this.showUnderline = true,
  });

  final double fontSize;
  final bool showUnderline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'HillGo',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
            height: 1.1,
            letterSpacing: -0.3,
          ),
        ),
        if (showUnderline) ...[
          const SizedBox(height: 4),
          Container(
            width: fontSize * 1.55,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.brandLime,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ],
    );
  }
}

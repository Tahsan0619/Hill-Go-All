import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DotGridBackground extends StatelessWidget {
  const DotGridBackground({
    super.key,
    required this.child,
    this.gradientStart = AppColors.splashGradientStart,
    this.gradientEnd = AppColors.splashGradientEnd,
  });

  final Widget child;
  final Color gradientStart;
  final Color gradientEnd;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientStart, gradientEnd],
          ),
        ),
        child: CustomPaint(
          painter: _DotGridPainter(),
          child: child,
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    const dotRadius = 1.5;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

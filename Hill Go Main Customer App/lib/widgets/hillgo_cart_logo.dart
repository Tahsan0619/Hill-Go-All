import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// HillGo branded shopping-bag mark used as the cart logo across the app.
class HillGoCartLogo extends StatelessWidget {
  const HillGoCartLogo({
    super.key,
    this.size = 24,
    this.color = AppColors.primaryNavy,
    this.accentColor = AppColors.accentOrange,
    this.filled = true,
  });

  final double size;
  final Color color;
  final Color accentColor;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HillGoCartLogoPainter(
          color: color,
          accentColor: accentColor,
          filled: filled,
        ),
      ),
    );
  }
}

class _HillGoCartLogoPainter extends CustomPainter {
  const _HillGoCartLogoPainter({
    required this.color,
    required this.accentColor,
    required this.filled,
  });

  final Color color;
  final Color accentColor;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft bag body — slightly tapered shopping tote.
    final bag = Path()
      ..moveTo(w * 0.22, h * 0.34)
      ..lineTo(w * 0.30, h * 0.90)
      ..quadraticBezierTo(w * 0.50, h * 0.98, w * 0.70, h * 0.90)
      ..lineTo(w * 0.78, h * 0.34)
      ..close();

    final bagPaint = Paint()
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    canvas.drawPath(bag, bagPaint);

    // Handles.
    final handlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.085
      ..strokeCap = StrokeCap.round
      ..color = accentColor;

    final leftHandle = Path()
      ..moveTo(w * 0.34, h * 0.36)
      ..quadraticBezierTo(w * 0.34, h * 0.12, w * 0.50, h * 0.12);
    final rightHandle = Path()
      ..moveTo(w * 0.66, h * 0.36)
      ..quadraticBezierTo(w * 0.66, h * 0.12, w * 0.50, h * 0.12);
    canvas.drawPath(leftHandle, handlePaint);
    canvas.drawPath(rightHandle, handlePaint);

    // HillGo mountain accent inside the bag.
    final peakPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = filled ? AppColors.white.withValues(alpha: 0.92) : accentColor;
    final peak = Path()
      ..moveTo(w * 0.34, h * 0.72)
      ..lineTo(w * 0.46, h * 0.52)
      ..lineTo(w * 0.54, h * 0.62)
      ..lineTo(w * 0.66, h * 0.48)
      ..lineTo(w * 0.70, h * 0.72)
      ..close();
    canvas.drawPath(peak, peakPaint);

    // Accent stripe under the rim.
    final stripePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..color = accentColor;
    canvas.drawLine(
      Offset(w * 0.30, h * 0.42),
      Offset(w * 0.70, h * 0.42),
      stripePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HillGoCartLogoPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.filled != filled;
  }
}

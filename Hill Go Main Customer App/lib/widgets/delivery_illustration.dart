import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Decorative scooter delivery scene used on the onboarding hero card.
class DeliveryIllustration extends StatelessWidget {
  const DeliveryIllustration({super.key, this.height = 150});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DeliveryIllustrationPainter(),
      ),
    );
  }
}

class _DeliveryIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFD6EEF8), Color(0xFFF0F7FB)],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(16),
      ),
      skyPaint,
    );

    // Soft ground
    final ground = Paint()..color = const Color(0xFFE8F5E9);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.55, size.height * 0.88),
        width: size.width * 0.7,
        height: size.height * 0.18,
      ),
      ground,
    );

    // Distant buildings
    final buildingPaint = Paint()..color = const Color(0xFFB0C4D8).withValues(alpha: 0.55);
    final buildings = [
      Rect.fromLTWH(size.width * 0.08, size.height * 0.35, 22, size.height * 0.4),
      Rect.fromLTWH(size.width * 0.16, size.height * 0.28, 18, size.height * 0.47),
      Rect.fromLTWH(size.width * 0.72, size.height * 0.32, 20, size.height * 0.43),
      Rect.fromLTWH(size.width * 0.82, size.height * 0.40, 16, size.height * 0.35),
    ];
    for (final rect in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        buildingPaint,
      );
    }

    // Scooter body
    final scooterX = size.width * 0.42;
    final scooterY = size.height * 0.62;
    final blue = Paint()..color = AppColors.accentBlue;
    final dark = Paint()..color = AppColors.navy;
    final orange = Paint()..color = AppColors.accentOrange;
    final white = Paint()..color = AppColors.white;

    // Wheels
    canvas.drawCircle(Offset(scooterX - 28, scooterY + 18), 12, dark);
    canvas.drawCircle(Offset(scooterX - 28, scooterY + 18), 6, white);
    canvas.drawCircle(Offset(scooterX + 38, scooterY + 18), 12, dark);
    canvas.drawCircle(Offset(scooterX + 38, scooterY + 18), 6, white);

    // Deck
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(scooterX + 6, scooterY + 10),
          width: 70,
          height: 10,
        ),
        const Radius.circular(4),
      ),
      blue,
    );

    // Stem / handle
    final stem = Path()
      ..moveTo(scooterX + 30, scooterY + 8)
      ..lineTo(scooterX + 38, scooterY - 28)
      ..lineTo(scooterX + 52, scooterY - 32);
    canvas.drawPath(
      stem,
      Paint()
        ..color = AppColors.navy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Delivery box
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(scooterX - 8, scooterY - 36, 36, 28),
        const Radius.circular(4),
      ),
      orange,
    );
    canvas.drawLine(
      Offset(scooterX - 8, scooterY - 22),
      Offset(scooterX + 28, scooterY - 22),
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.5)
        ..strokeWidth = 2,
    );

    // Rider body
    canvas.drawCircle(Offset(scooterX + 10, scooterY - 48), 10, dark);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(scooterX + 10, scooterY - 22),
          width: 22,
          height: 28,
        ),
        const Radius.circular(8),
      ),
      blue,
    );

    // Motion lines
    final linePaint = Paint()
      ..color = AppColors.accentBlue.withValues(alpha: 0.35)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = scooterY - 10 + i * 10.0;
      canvas.drawLine(
        Offset(scooterX - 70, y),
        Offset(scooterX - 48, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A lightweight stand-in for an interactive map (e.g. Google Maps) so ride
/// screens can be designed without pulling in a maps SDK/API key.
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({
    super.key,
    this.height,
    this.borderRadius = 0,
    this.showPin = true,
    this.showRoute = false,
    this.child,
  });

  final double? height;
  final double borderRadius;
  final bool showPin;
  final bool showRoute;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFFE3E8ED)),
            CustomPaint(
              painter: _MapGridPainter(showRoute: showRoute),
              size: Size.infinite,
            ),
            if (showPin)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 28),
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.accentOrange,
                    size: 44,
                  ),
                ),
              ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  _MapGridPainter({required this.showRoute});

  final bool showRoute;

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.9)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final minorRoadPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.6)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.34),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.66),
      minorRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.3, size.height),
      minorRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, 0),
      Offset(size.width * 0.68, size.height),
      roadPaint,
    );

    final blockPaint = Paint()..color = AppColors.white.withValues(alpha: 0.35);
    final blocks = [
      Rect.fromLTWH(size.width * 0.08, size.height * 0.08, size.width * 0.15, size.height * 0.15),
      Rect.fromLTWH(size.width * 0.35, size.height * 0.42, size.width * 0.18, size.height * 0.14),
      Rect.fromLTWH(size.width * 0.55, size.height * 0.75, size.width * 0.2, size.height * 0.16),
      Rect.fromLTWH(size.width * 0.8, size.height * 0.15, size.width * 0.14, size.height * 0.12),
    ];
    for (final block in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, const Radius.circular(4)),
        blockPaint,
      );
    }

    if (showRoute) {
      final routePaint = Paint()
        ..color = AppColors.primaryNavy
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path()
        ..moveTo(size.width * 0.2, size.height * 0.85)
        ..quadraticBezierTo(
          size.width * 0.3,
          size.height * 0.4,
          size.width * 0.55,
          size.height * 0.45,
        )
        ..quadraticBezierTo(
          size.width * 0.8,
          size.height * 0.5,
          size.width * 0.78,
          size.height * 0.18,
        );
      canvas.drawPath(path, routePaint);

      canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.85), 7, Paint()..color = AppColors.primaryNavy);
      canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.18), 7, Paint()..color = AppColors.accentOrange);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) =>
      oldDelegate.showRoute != showRoute;
}

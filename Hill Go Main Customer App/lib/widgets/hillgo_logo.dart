import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HillGoLogo extends StatelessWidget {
  const HillGoLogo({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: CustomPaint(
          painter: _HillGoLogoPainter(),
          size: Size(size, size),
        ),
      ),
    );
  }
}

class _HillGoLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final shieldTop = size.height * 0.18;
    final shieldWidth = size.width * 0.42;
    final shieldHeight = size.height * 0.38;

    final shieldPath = Path()
      ..moveTo(centerX, shieldTop)
      ..lineTo(centerX + shieldWidth / 2, shieldTop + shieldHeight * 0.25)
      ..lineTo(centerX + shieldWidth / 2, shieldTop + shieldHeight * 0.65)
      ..quadraticBezierTo(
        centerX + shieldWidth / 2,
        shieldTop + shieldHeight,
        centerX,
        shieldTop + shieldHeight,
      )
      ..quadraticBezierTo(
        centerX - shieldWidth / 2,
        shieldTop + shieldHeight,
        centerX - shieldWidth / 2,
        shieldTop + shieldHeight * 0.65,
      )
      ..lineTo(centerX - shieldWidth / 2, shieldTop + shieldHeight * 0.25)
      ..close();

    final shieldPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.logoBlue, AppColors.logoGreen],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(shieldPath, shieldPaint);

    final mountainPaint = Paint()..color = AppColors.white;
    final mountainPath = Path()
      ..moveTo(centerX - shieldWidth * 0.22, shieldTop + shieldHeight * 0.62)
      ..lineTo(centerX - shieldWidth * 0.05, shieldTop + shieldHeight * 0.38)
      ..lineTo(centerX + shieldWidth * 0.08, shieldTop + shieldHeight * 0.52)
      ..lineTo(centerX + shieldWidth * 0.22, shieldTop + shieldHeight * 0.35)
      ..lineTo(centerX + shieldWidth * 0.28, shieldTop + shieldHeight * 0.62)
      ..close();
    canvas.drawPath(mountainPath, mountainPaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'HillGo',
        style: TextStyle(
          color: AppColors.logoBlue,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2, shieldTop + shieldHeight + 6),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

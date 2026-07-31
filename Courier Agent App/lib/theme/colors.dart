import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0A4B8C);
  static const Color primaryDark = Color(0xFF083A6E);
  static const Color primaryLight = Color(0xFF1565C0);
  static const Color accent = Color(0xFFFF6D00);
  static const Color accentSoft = Color(0xFFFFE8D6);

  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E9F0);

  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF2D6A4F);
  static const Color successBg = Color(0xFFCCF0D1);
  static const Color error = Color(0xFFC53030);
  static const Color errorBg = Color(0xFFFCE4E4);
  static const Color warning = Color(0xFFE67E22);
  static const Color verified = Color(0xFF7CB342);

  static const Color inputBorder = Color(0xFFD1D5DB);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color navInactive = Color(0xFF9CA3AF);
  static const Color mapOverlay = Color(0xFF0A4B8C);

  static const LinearGradient loginBg = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8F1FB), Color(0xFFF8FAFC)],
  );
}

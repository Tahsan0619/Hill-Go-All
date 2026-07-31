import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Splash
  static const Color splashGradientStart = Color(0xFF1A6B8A);
  static const Color splashGradientEnd = Color(0xFFA8E635);
  static const Color logoBlue = Color(0xFF1E88C7);
  static const Color logoGreen = Color(0xFF7CB342);

  // Brand / common
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F6F8);
  static const Color navy = Color(0xFF0D2C4A);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Accents
  static const Color accentOrange = Color(0xFFFF6B00);
  static const Color accentOrangeSoft = Color(0xFFFFE4D1);
  static const Color accentBlue = Color(0xFF2B7DE9);
  static const Color accentBlueSoft = Color(0xFFD6E8FF);
  static const Color indicatorGreen = Color(0xFF8BC34A);
  static const Color brandLime = Color(0xFFA2E000);
  static const Color primaryNavy = Color(0xFF004899);
  static const Color signUpAccent = Color(0xFFB45309);
  static const Color cardBorder = Color(0xFFE8EAED);
  static const Color illustrationSky = Color(0xFFE8F4FC);
  static const Color inputBorder = Color(0xFFD1D5DB);

  // Dark surfaces (used when ThemeService.isDark / ThemeExtension)
  static const Color backgroundDark = Color(0xFF0B1220);
  static const Color surfaceDark = Color(0xFF152033);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textMutedDark = Color(0xFF6B7280);
  static const Color cardBorderDark = Color(0xFF243044);
  static const Color inputBorderDark = Color(0xFF334155);
}

/// Adaptive palette resolved from the current theme brightness.
class HillGoColors extends ThemeExtension<HillGoColors> {
  const HillGoColors({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.cardBorder,
    required this.inputBorder,
  });

  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color cardBorder;
  final Color inputBorder;

  static const HillGoColors light = HillGoColors(
    background: AppColors.background,
    surface: AppColors.white,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    cardBorder: AppColors.cardBorder,
    inputBorder: AppColors.inputBorder,
  );

  static const HillGoColors dark = HillGoColors(
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    textMuted: AppColors.textMutedDark,
    cardBorder: AppColors.cardBorderDark,
    inputBorder: AppColors.inputBorderDark,
  );

  static HillGoColors of(BuildContext context) {
    return Theme.of(context).extension<HillGoColors>() ?? light;
  }

  @override
  HillGoColors copyWith({
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? cardBorder,
    Color? inputBorder,
  }) {
    return HillGoColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      cardBorder: cardBorder ?? this.cardBorder,
      inputBorder: inputBorder ?? this.inputBorder,
    );
  }

  @override
  HillGoColors lerp(ThemeExtension<HillGoColors>? other, double t) {
    if (other is! HillGoColors) return this;
    return HillGoColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(HillGoColors colors) {
    return TextTheme(
      headlineLarge: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: 0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        height: 1.25,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: colors == HillGoColors.dark
            ? const Color(0xFFE8EEF7)
            : AppColors.navy,
      ),
      titleMedium: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
        letterSpacing: 0.3,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: colors == HillGoColors.dark
            ? const Color(0xFFE8EEF7)
            : AppColors.navy,
        letterSpacing: 0.8,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.textMuted,
      ),
      labelLarge: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
        letterSpacing: 1.5,
      ),
    );
  }

  static ThemeData get lightTheme {
    const colors = HillGoColors.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: const [colors],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navy,
        brightness: Brightness.light,
        primary: AppColors.accentOrange,
        secondary: AppColors.accentBlue,
        surface: AppColors.white,
      ),
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.surface,
      dividerColor: colors.cardBorder,
      textTheme: _textTheme(colors),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryNavy;
          }
          return const Color(0xFFD1D5DB);
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    const colors = HillGoColors.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: const [colors],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navy,
        brightness: Brightness.dark,
        primary: AppColors.accentOrange,
        secondary: AppColors.accentBlue,
        surface: AppColors.surfaceDark,
      ),
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.surface,
      dividerColor: colors.cardBorder,
      textTheme: _textTheme(colors),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryNavy;
          }
          return AppColors.inputBorderDark;
        }),
      ),
    );
  }
}

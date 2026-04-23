import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF2F855A);
  static const accent = Color(0xFF276749);
  static const surface = Color(0xFFF7FAFC);
  /// Pushed routes (e.g. species detail) use a solid tint so transparent shell does not read as black.
  static const detailBackdrop = Color(0xFFEDF3EF);
  /// Solid pale white–green behind the whole app (no gradient); glass cards read as frosted on top.
  static const pageMist = Color(0xFFE9F1EC);
  /// Warm stone ink on mint glass — reads clearer than pure black or green-black on green tint.
  static const textOnGlass = Color(0xFF141110);
  static const textOnGlassSecondary = Color(0xFF2D2926);
  static const textOnGlassMuted = Color(0xFF524E4A);
  /// Cool neutral body copy on frosted panels over forest imagery (avoids blending with green).
  static const textBodyOnFrost = Color(0xFF071210);
  static const textSubtitleOnFrost = Color(0xFF1C2623);
  /// Section icons: deep green, distinct from body ink.
  static const iconSectionOnFrost = Color(0xFF0E4A36);
}

ThemeData buildKachakTheme() {
  const seed = AppColors.primary;
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: const Color(0xE6FFFFFF),
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme),
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white.withValues(alpha: 0.45),
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.72),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: AppColors.primary.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.65), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.55),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.65)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: AppColors.primary.withValues(alpha: 0.22),
      labelTextStyle: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected)) {
          return GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent);
        }
        return GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF5C6B63),
        );
      }),
    ),
  );
}

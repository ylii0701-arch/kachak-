import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized color tokens used across the app theme.
class AppColors {
  static const primary = Color(0xFF5C8A57);
  static const accent = Color(0xFF1F4B36);
  static const iconSectionOnFrost = Color(0xFF2F5A3C);
  static const surface = Color(0xFFFFFDF8);
  static const detailBackdrop = Color(0xFFF8F5EE);
  static const pageMist = Color(0xFFF8F5EE);
  static const textOnGlass = Color(0xFF5E5A50);
  static const textOnGlassSecondary = Color(0xFF5E5A50);
  static const textOnGlassMuted = Color(0xFF8A7A5A);
  static const textBodyOnFrost = Color(0xFF5E5A50);
  static const textSubtitleOnFrost = Color(0xFF8A7A5A);
  static const lightSage = Color(0xFFEAF3E7);
  static const statusYellow = Color(0xFFE7C85E);
  static const badgeText = Color(0xFF4F4330);
  static const border = Color(0xFFE7E0D4);
  static const divider = Color(0xFFEEE8DD);
  static const calmShadow = Color(0x14604628);
}

/// Builds the global Material 3 theme for the Kachak app.
ThemeData buildKachakTheme() {
  const seed = AppColors.primary;
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.surface,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  final inter = GoogleFonts.interTextTheme(base.textTheme);
  final editorialTextTheme = inter.copyWith(
    displayLarge: GoogleFonts.libreBaskerville(
      textStyle: inter.displayLarge,
      color: AppColors.accent,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: GoogleFonts.libreBaskerville(
      textStyle: inter.displayMedium,
      color: AppColors.accent,
      fontWeight: FontWeight.w700,
    ),
    headlineLarge: GoogleFonts.libreBaskerville(
      textStyle: inter.headlineLarge,
      color: AppColors.accent,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: GoogleFonts.libreBaskerville(
      textStyle: inter.headlineMedium,
      color: AppColors.accent,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: GoogleFonts.libreBaskerville(
      textStyle: inter.headlineSmall,
      color: AppColors.accent,
      fontWeight: FontWeight.w700,
    ),
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    textTheme: editorialTextTheme,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: AppColors.calmShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
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
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          );
        }
        return GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF6B6048),
        );
      }),
    ),
  );
}

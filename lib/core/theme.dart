import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Color Palette from DESIGN.md
  static const Color primary = Color(0xFF1A237E); // Navy anchor
  static const Color darkPrimary = Color(0xFF000666);
  static const Color secondary = Color(0xFF4C616C); // Slate
  static const Color background = Color(0xFFFBF8FF); // Soft Gray canvas
  static const Color surface = Color(0xFFFFFFFF); // Pure white active surfaces
  
  static const Color surfaceDim = Color(0xFFDBD9E1);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F2FB);
  static const Color surfaceContainer = Color(0xFFEFECF5);
  static const Color surfaceContainerHigh = Color(0xFFEAE7EF);
  static const Color surfaceContainerHighest = Color(0xFFE4E1EA);

  static const Color onSurface = Color(0xFF1B1B21);
  static const Color onSurfaceVariant = Color(0xFF454652);
  static const Color outline = Color(0xFF767683);
  static const Color outlineVariant = Color(0xFFC6C5D4);
  static const Color dividerColor = Color(0xFFE0E4E8); // 1px borders

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);

  // Border Radii
  static const double radiusSm = 4.0;   // Base buttons, inputs
  static const double radiusLg = 8.0;   // Cards, preview cards, modals
  static const double radiusFull = 9999.0; // Floating, avatars

  // Spacings
  static const double spacingBase = 4.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 40.0;

  static ThemeData get lightTheme {
    // Core color scheme configuration matching Design Tokens
    final colorScheme = const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: error,
      onError: onError,
      surface: surface,
      onSurface: onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      dividerColor: dividerColor,
      cardColor: surface,

      // Custom Typography mapping from DESIGN.md
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32.0,
          fontWeight: FontWeight.w700,
          height: 40.0 / 32.0,
          letterSpacing: -0.02 * 32.0,
          color: onSurface,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 24.0,
          fontWeight: FontWeight.w600,
          height: 32.0 / 24.0,
          letterSpacing: -0.01 * 24.0,
          color: onSurface,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          height: 28.0 / 20.0,
          color: onSurface,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          height: 24.0 / 18.0,
          color: onSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          height: 24.0 / 16.0,
          color: onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          height: 20.0 / 14.0,
          color: onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          height: 16.0 / 12.0,
          letterSpacing: 0.01 * 12.0,
          color: onSurfaceVariant,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11.0,
          fontWeight: FontWeight.w600,
          height: 16.0 / 11.0,
          letterSpacing: 0.03 * 11.0,
          color: onSurfaceVariant,
        ),
      ),

      // Premium Button Theme Definitions
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.02 * 14.0,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondary,
          side: const BorderSide(color: outlineVariant, width: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Minimalist Corporate Input Field Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd),
        labelStyle: GoogleFonts.inter(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: onSurfaceVariant,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 11.0,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: outlineVariant, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: outlineVariant, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: error, width: 2.0),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppConstants {
  // Spacings
  static const double base = 4.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 40.0;

  // Screen Margin Standard from DESIGN.md
  static const double marginMobile = 16.0;
  static const double marginDesktop = 32.0;

  // Maximum standard container width
  static const double maxWidth = 1440.0;

  // Animation Durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  // Animations Curves
  static const Curve curveDefault = Curves.easeInOut;

  // Layout limits
  static const double mobileBreakpoint = 600.0;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sistema tipográfico portado do web.
///
/// - Corpo/UI: **Inter** (substituto fiel de "Geist", que não está no Google Fonts).
/// - Títulos/marca: **Outfit** (equivalente da classe `font-outfit`, pesos pesados).
class AppTypography {
  AppTypography._();

  /// Fonte para títulos e elementos de marca.
  static TextStyle display(
    Color color, {
    double size = 32,
    FontWeight weight = FontWeight.w800,
    double? height,
    double letterSpacing = -0.5,
  }) {
    return GoogleFonts.outfit(
      color: color,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Constrói o TextTheme base a partir do Inter, aplicando Outfit aos títulos.
  static TextTheme textTheme(Color foreground, Color muted) {
    final base = GoogleFonts.interTextTheme();

    TextStyle outfit(double size, FontWeight weight, {double spacing = -0.5}) =>
        GoogleFonts.outfit(
          fontSize: size,
          fontWeight: weight,
          color: foreground,
          letterSpacing: spacing,
        );

    TextStyle inter(double size, FontWeight weight, {Color? c}) =>
        GoogleFonts.inter(
          fontSize: size,
          fontWeight: weight,
          color: c ?? foreground,
        );

    return base.copyWith(
      displayLarge: outfit(40, FontWeight.w800),
      displayMedium: outfit(34, FontWeight.w800),
      displaySmall: outfit(28, FontWeight.w700),
      headlineMedium: outfit(24, FontWeight.w700),
      headlineSmall: outfit(20, FontWeight.w700),
      titleLarge: outfit(18, FontWeight.w700, spacing: 0),
      titleMedium: inter(16, FontWeight.w600),
      titleSmall: inter(14, FontWeight.w600),
      bodyLarge: inter(16, FontWeight.w400),
      bodyMedium: inter(14, FontWeight.w400),
      bodySmall: inter(13, FontWeight.w400, c: muted),
      labelLarge: inter(14, FontWeight.w600),
      labelMedium: inter(12, FontWeight.w600),
      labelSmall: inter(11, FontWeight.w700, c: muted),
    );
  }
}

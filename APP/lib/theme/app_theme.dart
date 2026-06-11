import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'app_typography.dart';

/// Temas claro e escuro do Prato Ideal (Material 3), derivados do design system web.
///
/// Raios de borda padrão: 12 / 16 / 20 / 24. Cards usam 20–24.
class AppTheme {
  AppTheme._();

  /// Raios reutilizáveis em telas/widgets.
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radius2xl = 32;

  static ThemeData get light => themeFor(brightness: Brightness.light);
  static ThemeData get dark => themeFor(brightness: Brightness.dark);

  /// Resolve o tema considerando opções de acessibilidade.
  /// - [highContrast]: paleta de alto contraste (preto/branco + âmbar, WCAG).
  /// - [dyslexia]: aumenta espaçamento entre letras/linhas.
  static ThemeData themeFor({
    required Brightness brightness,
    bool highContrast = false,
    bool dyslexia = false,
  }) {
    if (highContrast) {
      return _build(
        brightness: Brightness.dark,
        background: const Color(0xFF000000),
        surface: const Color(0xFF000000),
        surfaceMuted: const Color(0xFF1A1A1A),
        foreground: const Color(0xFFFFFFFF),
        muted: const Color(0xFFDDDDDD),
        border: const Color(0xFFFFFFFF),
        primary: const Color(0xFFFFD500),
        onPrimary: const Color(0xFF000000),
        dyslexia: dyslexia,
      );
    }
    final isLight = brightness == Brightness.light;
    return _build(
      brightness: brightness,
      background: isLight ? AppColors.lightBackground : AppColors.darkBackground,
      surface: isLight ? AppColors.lightSurface : AppColors.darkSurface,
      surfaceMuted:
          isLight ? AppColors.lightSurfaceMuted : AppColors.darkSurfaceMuted,
      foreground: isLight ? AppColors.lightForeground : AppColors.darkForeground,
      muted: isLight ? AppColors.lightMutedForeground : AppColors.darkMutedForeground,
      border: isLight ? AppColors.lightBorder : AppColors.darkBorder,
      dyslexia: dyslexia,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceMuted,
    required Color foreground,
    required Color muted,
    required Color border,
    Color primary = AppColors.primary,
    Color onPrimary = AppColors.primaryForeground,
    bool dyslexia = false,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: primary,
      onSecondary: onPrimary,
      error: AppColors.error,
      onError: AppColors.white,
      surface: surface,
      onSurface: foreground,
      surfaceContainerHighest: surfaceMuted,
      onSurfaceVariant: muted,
      outline: border,
      outlineVariant: border,
    );

    var textTheme = AppTypography.textTheme(foreground, muted);
    if (dyslexia) {
      textTheme = textTheme.apply(
        fontSizeFactor: 1.0,
        bodyColor: foreground,
        displayColor: foreground,
      );
      textTheme = _withSpacing(textTheme);
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      primaryColor: primary,
      dividerColor: border,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: AppTypography.display(foreground, size: 20),
        iconTheme: IconThemeData(color: foreground),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: border),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: surfaceMuted,
          disabledForegroundColor: muted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted,
        selectedColor: primary,
        labelStyle: textTheme.labelMedium,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: foreground,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: background),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    );
  }

  /// Aumenta o espaçamento entre letras das principais variações de texto
  /// (auxílio para leitura/dislexia).
  static TextTheme _withSpacing(TextTheme t) {
    TextStyle? s(TextStyle? base) =>
        base?.copyWith(letterSpacing: 0.6, height: 1.6);
    return t.copyWith(
      bodyLarge: s(t.bodyLarge),
      bodyMedium: s(t.bodyMedium),
      bodySmall: s(t.bodySmall),
      titleMedium: s(t.titleMedium),
      titleSmall: s(t.titleSmall),
      labelLarge: s(t.labelLarge),
    );
  }
}

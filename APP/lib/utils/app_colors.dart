import 'package:flutter/material.dart';

/// Design tokens do Prato Ideal, portados do design system web (Tailwind/globals.css).
///
/// Cor primária = vermelho (red-500 `#EF4444`), substituindo o antigo azul-escuro.
/// Tokens separados para tema claro e escuro. Os nomes legados (`primary`,
/// `secondary`, `background`, etc.) foram mantidos para não quebrar telas
/// existentes, mas agora apontam para a nova paleta.
class AppColors {
  AppColors._();

  // ----- Marca -----
  /// red-500 — cor primária da marca.
  static const Color primary = Color(0xFFEF4444);
  static const Color primaryDark = Color(0xFFDC2626); // red-600 (hover/pressed)
  static const Color primaryForeground = Color(0xFFFFFFFF);

  /// Gradiente do logotipo (laranja queimado → âmbar).
  static const Color logoGradientStart = Color(0xFFB33817);
  static const Color logoGradientEnd = Color(0xFFDD9318);

  /// Gradiente usado em botões de autenticação (orange-500 → rose-500).
  static const Color authGradientStart = Color(0xFFF97316);
  static const Color authGradientEnd = Color(0xFFF43F5E);

  // ----- Acentos semânticos -----
  static const Color rating = Color(0xFFF59E0B); // amber-500 (estrelas)
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color info = Color(0xFF3B82F6); // blue-500
  static const Color favorite = primary; // coração
  static const Color error = Color(0xFFEF4444);
  static const Color white = Color(0xFFFFFFFF);

  // ----- Tema claro -----
  static const Color lightBackground = Color(0xFFF9FAFB); // gray-50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF3F4F6); // gray-100
  static const Color lightForeground = Color(0xFF171717);
  static const Color lightMutedForeground = Color(0xFF6B7280); // gray-500
  static const Color lightBorder = Color(0xFFE5E7EB); // gray-200

  // ----- Tema escuro -----
  static const Color darkBackground = Color(0xFF0A0A0A); // zinc-950
  static const Color darkSurface = Color(0xFF18181B); // zinc-900
  static const Color darkSurfaceMuted = Color(0xFF27272A); // zinc-800
  static const Color darkForeground = Color(0xFFEDEDED);
  static const Color darkMutedForeground = Color(0xFF9CA3AF); // gray-400
  static const Color darkBorder = Color(0xFF27272A); // zinc-800

  // ----- Aliases legados (mantidos para compatibilidade) -----
  /// Antes era o azul-escuro do header; agora a cor primária da marca.
  static const Color secondary = primary;
  static const Color background = lightBackground;
  static const Color textPrimary = lightForeground;
  static const Color textSecondary = lightMutedForeground;
  static const Color accent = success;
}

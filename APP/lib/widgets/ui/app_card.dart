import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Card padrão do design system: superfície + borda 1px + cantos arredondados,
/// com sombra suave opcional. Toca em [onTap] quando fornecido.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = AppTheme.radiusLg,
    this.onTap,
    this.elevated = false,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final bool elevated;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(radius);

    final decoration = BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: borderRadius,
      border: Border.all(color: theme.colorScheme.outline),
      boxShadow: elevated
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ]
          : null,
    );

    Widget content = Padding(padding: padding, child: child);
    if (clip) {
      content = ClipRRect(borderRadius: borderRadius, child: content);
    }

    if (onTap == null) {
      return DecoratedBox(decoration: decoration, child: content);
    }

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: content,
        ),
      ),
    );
  }
}

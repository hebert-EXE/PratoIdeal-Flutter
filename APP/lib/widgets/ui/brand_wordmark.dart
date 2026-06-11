import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';
import '../../utils/app_colors.dart';

/// Wordmark "Prato Ideal" com texto em gradiente laranja→âmbar, como no Navbar do web.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.fontSize = 20, this.showIcon = true});

  final double fontSize;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final text = ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColors.logoGradientStart, AppColors.logoGradientEnd],
      ).createShader(bounds),
      child: Text(
        'Prato Ideal',
        style: AppTypography.display(
          Colors.white,
          size: fontSize,
          weight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
    );

    if (!showIcon) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.restaurant_menu_rounded,
            size: fontSize + 4, color: AppColors.logoGradientEnd),
        const SizedBox(width: 8),
        text,
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_colors.dart';
import 'ui/ui.dart';

/// Botão de favoritar reutilizável, ligado ao [FavoritesProvider].
/// Trata autenticação e erros (ex.: restaurante não registrado no backend).
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.placeId,
    required this.name,
    this.size = 20,
    this.light = false,
  });

  final String placeId;
  final String name;
  final double size;

  /// `true` para usar sobre fundos escuros (ícone branco, sem fundo).
  final bool light;

  Future<void> _toggle(BuildContext context) async {
    final user = context.read<UserProvider>();
    if (!user.isAuthenticated || user.token == null) {
      AppToast.show(context, 'Faça login para favoritar restaurantes.',
          type: ToastType.info);
      return;
    }
    try {
      await context.read<FavoritesProvider>().toggle(placeId, user.token!);
    } catch (_) {
      if (context.mounted) {
        AppToast.show(
          context,
          '$name ainda não pode ser favoritado (não registrado no sistema).',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFav = context.watch<FavoritesProvider>().isFavorite(placeId);
    final icon = Icon(
      isFav ? Icons.favorite : Icons.favorite_border,
      size: size,
      color: isFav
          ? AppColors.favorite
          : (light ? Colors.white : theme.colorScheme.onSurfaceVariant),
    );

    if (light) {
      return IconButton(icon: icon, onPressed: () => _toggle(context));
    }

    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _toggle(context),
        child: Padding(padding: const EdgeInsets.all(8), child: icon),
      ),
    );
  }
}

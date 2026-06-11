import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'ui/ui.dart';

/// Banner promocional em gradiente com modal de cupom, portado de `PromoBanner.tsx`.
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  static const _coupon = 'PRATOIDEAL';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFDC2626), Color(0xFFF97316)],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Cupom Exclusivo '),
                  TextSpan(
                    text: 'PratoIdeal: ',
                    style: TextStyle(color: Color(0xFFFDE047)),
                  ),
                  TextSpan(text: 'Ganhe até 50% OFF'),
                ],
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Faça sua primeira reserva com nosso código especial e pague menos!',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () => _showCouponModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFDC2626),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.confirmation_num_outlined),
                label: const Text('Pegar Meu Cupom'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCouponModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.confirmation_num,
                      size: 36, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 16),
                Text('Parabéns! 🎉', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Aqui está o seu cupom exclusivo. Use na próxima reserva!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _coupon,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(letterSpacing: 2),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(
                              const ClipboardData(text: _coupon));
                          AppToast.show(ctx, 'Cupom copiado!',
                              type: ToastType.success);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Entendi, obrigado!',
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

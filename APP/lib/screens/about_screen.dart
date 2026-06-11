import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import '../widgets/ui/ui.dart';

class _Value {
  final IconData icon;
  final String title;
  final String desc;
  const _Value(this.icon, this.title, this.desc);
}

const _values = <_Value>[
  _Value(Icons.favorite, 'Paixão',
      'Amamos o que fazemos e a comida que compartilhamos.'),
  _Value(Icons.verified, 'Confiança',
      'Transparência total em todas as avaliações.'),
  _Value(Icons.groups, 'Comunidade',
      'Nossa força vem da colaboração de nossos usuários.'),
  _Value(Icons.storefront, 'Impacto',
      'Apoiamos o comércio local e pequenos restaurantes.'),
];

/// Página "Sobre Nós", portada de `/sobre`.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre Nós')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: BrandWordmark(fontSize: 28)),
          const SizedBox(height: 24),
          Text('Nossa Missão', style: theme.textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Acreditamos que cada refeição é uma oportunidade de criar memórias. '
            'Por isso, trabalhamos para que nossas avaliações sejam transparentes '
            'e que os dados estejam sempre atualizados, ajudando você a descobrir '
            'os melhores sabores perto de você.',
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 24),
          Text('O que nos guia', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.78,
            children: _values.map((v) {
              return AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Icon(v.icon, color: AppColors.primary),
                    ),
                    const SizedBox(height: 10),
                    Text(v.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        v.desc,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Projeto acadêmico desenvolvido pelo curso de Desenvolvimento de '
            'Software Multiplataforma — Fatec Mauá.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

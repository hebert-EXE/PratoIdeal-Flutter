import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/accessibility_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/ui/ui.dart';

/// Configurações: tema (claro/escuro/sistema) e acessibilidade
/// (alto contraste, tamanho de fonte, negrito, espaçamento, reduzir animações).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final a11y = context.watch<AccessibilityProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(theme, 'Aparência'),
          AppCard(
            child: Column(
              children: [
                _themeOption(context, themeProvider, ThemeMode.system,
                    'Sistema', Icons.brightness_auto),
                const Divider(height: 1),
                _themeOption(context, themeProvider, ThemeMode.light, 'Claro',
                    Icons.light_mode),
                const Divider(height: 1),
                _themeOption(context, themeProvider, ThemeMode.dark, 'Escuro',
                    Icons.dark_mode),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(theme, 'Acessibilidade'),
          AppCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Alto contraste'),
                  subtitle: const Text('Paleta preto/branco com destaque âmbar'),
                  value: a11y.highContrast,
                  onChanged: a11y.setHighContrast,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Texto em negrito'),
                  value: a11y.boldText,
                  onChanged: a11y.setBoldText,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Espaçamento de leitura'),
                  subtitle: const Text('Mais espaço entre letras e linhas'),
                  value: a11y.dyslexiaFriendly,
                  onChanged: a11y.setDyslexiaFriendly,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reduzir animações'),
                  value: a11y.reduceMotion,
                  onChanged: a11y.setReduceMotion,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tamanho da fonte', style: theme.textTheme.titleSmall),
                    Text('${(a11y.fontScale * 100).round()}%',
                        style: theme.textTheme.labelLarge),
                  ],
                ),
                Slider(
                  value: a11y.fontScale,
                  min: 0.8,
                  max: 1.6,
                  divisions: 8,
                  label: '${(a11y.fontScale * 100).round()}%',
                  onChanged: a11y.setFontScale,
                ),
                Text(
                  'Exemplo: como o texto aparece no app.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: theme.textTheme.labelSmall),
    );
  }

  Widget _themeOption(BuildContext context, ThemeProvider provider,
      ThemeMode mode, String label, IconData icon) {
    final selected = provider.themeMode == mode;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
          : const Icon(Icons.circle_outlined),
      onTap: () => provider.setThemeMode(mode),
    );
  }
}

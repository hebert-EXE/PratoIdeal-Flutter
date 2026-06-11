import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import '../widgets/ui/ui.dart';

/// Página de Contato, portada de `/contato`. O envio é simulado (sem backend),
/// como no protótipo do web.
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;

  static const _supportEmail = 'contato.pratoideal@fatec.sp.gov.br';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _message.text.trim().isEmpty) {
      AppToast.show(context, 'Preencha todos os campos.', type: ToastType.error);
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _sending = false);
    _name.clear();
    _email.clear();
    _message.clear();
    AppToast.show(context, 'Mensagem enviada! Em breve responderemos.',
        type: ToastType.success);
  }

  Future<void> _openEmail() async {
    final uri = Uri(scheme: 'mailto', path: _supportEmail);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Contato')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Fale com a gente', style: theme.textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Dúvidas, sugestões ou parcerias? Envie sua mensagem.',
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          AppCard(
            onTap: _openEmail,
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Icon(Icons.mail_outline, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('E-mail', style: theme.textTheme.labelSmall),
                      Text(_supportEmail, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppTextField(controller: _name, label: 'Nome completo'),
          const SizedBox(height: 16),
          AppTextField(
            controller: _email,
            label: 'E-mail',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mensagem',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _message,
                maxLines: 4,
                decoration:
                    const InputDecoration(hintText: 'Escreva sua mensagem...'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Enviar mensagem',
            icon: Icons.send,
            isLoading: _sending,
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}

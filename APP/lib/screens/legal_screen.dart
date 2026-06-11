import 'package:flutter/material.dart';

/// Páginas legais (Termos, Privacidade, Cookies), portadas de `/(legal)`.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Termos e Privacidade'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Termos'),
              Tab(text: 'Privacidade'),
              Tab(text: 'Cookies'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LegalText(title: 'Termos de Uso', body: _terms),
            _LegalText(title: 'Política de Privacidade', body: _privacy),
            _LegalText(title: 'Política de Cookies', body: _cookies),
          ],
        ),
      ),
    );
  }
}

class _LegalText extends StatelessWidget {
  const _LegalText({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
      ],
    );
  }
}

const _terms = '''
Ao utilizar o aplicativo Prato Ideal, você concorda com estes Termos de Uso.

1. Uso do serviço
O Prato Ideal é um hub para descoberta e avaliação de restaurantes. Você se compromete a usá-lo de forma lícita e a não publicar conteúdo ofensivo, falso ou que viole direitos de terceiros.

2. Conta
Você é responsável por manter a confidencialidade das suas credenciais e por todas as atividades realizadas na sua conta.

3. Conteúdo do usuário
As avaliações e fotos enviadas são de sua responsabilidade. Ao publicá-las, você concede ao Prato Ideal o direito de exibi-las no aplicativo.

4. Limitação de responsabilidade
As informações de restaurantes podem vir de serviços de terceiros (ex.: Google Places) e estão sujeitas a alterações. Não garantimos exatidão de horários, preços ou disponibilidade.

5. Alterações
Estes termos podem ser atualizados periodicamente. O uso contínuo do app após mudanças implica concordância.
''';

const _privacy = '''
Última atualização: novembro de 2025.

1. Dados coletados
- Cadastro/Perfil: nome, e-mail e senha (autenticação).
- Interação: avaliações (notas e comentários), favoritos e histórico.
- Técnicos: token de autenticação (armazenado com segurança no dispositivo).
- Opcionais: localização (GPS) e fotos para avaliações.

2. Finalidade
Autenticar seu acesso, prestar os serviços do app (avaliações, favoritos, descoberta de restaurantes) e personalizar sua experiência.

3. Compartilhamento
Não compartilhamos seus dados pessoais com terceiros, exceto por obrigação legal. Dados de restaurantes podem ser obtidos via Google Places.

4. Armazenamento e segurança
O token de autenticação é guardado localmente de forma segura. A comunicação com o backend é feita por API RESTful.

5. Seus direitos
Você pode acessar, corrigir ou solicitar a exclusão dos seus dados pelo seu Perfil ou pelo canal de contato.

Contato: contato.pratoideal@fatec.sp.gov.br
''';

const _cookies = '''
O aplicativo Prato Ideal utiliza armazenamento local no dispositivo (equivalente a "cookies") para:

- Manter sua sessão ativa (token de autenticação).
- Lembrar preferências (tema, acessibilidade, buscas recentes, fundo de perfil).

Esses dados ficam apenas no seu dispositivo e podem ser limpos ao sair da conta ou desinstalar o app. Não utilizamos cookies de rastreamento de terceiros para publicidade.
''';

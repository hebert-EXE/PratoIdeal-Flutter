import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../screens/profile_screen.dart';
import '../providers/user_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Drawer(
      backgroundColor: AppColors.primary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  backgroundImage:
                      user?.profileImageUrl != null &&
                          user!.profileImageUrl.isNotEmpty
                      ? NetworkImage(user.profileImageUrl)
                      : null,
                  child:
                      user?.profileImageUrl == null ||
                          user!.profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  user?.name ?? 'Usuário',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person_outline, 'Minha Conta', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }),
          _buildDrawerItem(Icons.favorite_border, 'Meus Favoritos', () {}),
          _buildDrawerItem(Icons.star_border, 'Avaliações recentes', () {}),
          _buildDrawerItem(Icons.info_outline, 'Sobre', () {}),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.instagram,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.facebook,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Termos de uso'),
                        content: const Text(
                          'Termos de uso ainda não disponíveis.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Fechar'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Termos de uso',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Política de Privacidade – Prato Ideal',
                        ),
                        content: const SingleChildScrollView(
                          child: Text(
                            'POLÍTICA DE PRIVACIDADE – PRATO IDEAL\n'
                            'Última atualização: 16 de novembro de 2025\n'
                            '\n'
                            '1. Introdução\n'
                            'Esta Política de Privacidade descreve como a equipe de desenvolvimento do "Prato Ideal", '
                            'vinculada à Faculdade de Tecnologia de Mauá, coleta, usa, armazena e protege suas informações '
                            'pessoais ao utilizar o aplicativo "Prato Ideal", um hub centralizado para descoberta e avaliação de restaurantes.\n'
                            'Ao utilizar nossos serviços, você declara estar ciente e concordar com os termos descritos nesta política.\n'
                            '\n'
                            '2. Quais Dados São Coletados\n'
                            'Para o funcionamento do aplicativo, coletamos os seguintes tipos de dados:\n'
                            'a) Dados Pessoais (Cadastro e Perfil): nome, endereço de e-mail e senha (para fins de autenticação).\n'
                            'b) Dados Gerados pelo Usuário (Interação): avaliações, incluindo notas (1-5) e comentários escritos, '
                            'lista de restaurantes salvos como "Favoritos" e histórico de avaliações.\n'
                            'c) Dados Técnicos e de Navegação: endereço IP, logs de acesso, informações do dispositivo e token de autenticação (armazenado localmente).\n'
                            'd) Dados para Funcionalidades Futuras (Opcional): localização (GPS) e acesso à câmera/galeria para upload de fotos.\n'
                            '\n'
                            '3. Como os Dados São Coletados\n'
                            'A coleta de dados ocorre de forma direta (cadastro, login, avaliações) e automática '
                            '(dados técnicos e de navegação). Utilizamos shared_preferences para armazenar localmente o token de autenticação.\n'
                            '\n'
                            '4. Finalidade do Uso dos Dados\n'
                            'Utilizamos seus dados para identificar e autenticar seu acesso, prestar os serviços principais do aplicativo '
                            '(criação/visualização de avaliações, exibição de informações de restaurantes), personalizar sua experiência '
                            '(perfil, favoritos, "Minhas Avaliações", listas como "Melhores Avaliados" e "Ótimos Preços") e melhorar o aplicativo por meio de métricas de uso.\n'
                            '\n'
                            '5. Compartilhamento de Dados com Terceiros\n'
                            'O "Prato Ideal" não compartilha seus dados pessoais com empresas terceiras ou parceiros, '
                            'exceto em caso de obrigação legal ou solicitação judicial.\n'
                            '\n'
                            '6. Armazenamento e Tempo de Retenção dos Dados\n'
                            'Os dados são armazenados com segurança em banco de dados MongoDB acessado pela nossa API RESTful. '
                            'Os dados são retidos enquanto sua conta estiver ativa ou pelo período necessário para cumprir obrigações legais.\n'
                            '\n'
                            '7. Segurança da Informação\n'
                            'Adotamos medidas técnicas para proteger seus dados. A comunicação entre aplicativo e back-end é feita por API RESTful '
                            'e o token de autenticação é armazenado localmente em seu dispositivo.\n'
                            '\n'
                            '8. Direitos do Titular de Dados\n'
                            'Você pode acessar, corrigir ou solicitar a eliminação de seus dados, bem como revogar o consentimento, '
                            'por meio da "Tela de Perfil" e do canal de comunicação informado.\n'
                            '\n'
                            '9. Como Exercer Seus Direitos\n'
                            'Canal de Comunicação: contato.pratoideal@fatec.sp.gov.br (e-mail fictício para fins deste projeto).\n'
                            '\n'
                            '10. Alterações na Política\n'
                            'Esta Política pode ser atualizada periodicamente. Notificaremos alterações significativas pelo aplicativo ou e-mail.\n'
                            '\n'
                            '11. Contato\n'
                            'Controlador: Equipe de Desenvolvimento Prato Ideal – Curso de Desenvolvimento de Software Multiplataforma.\n'
                            'Instituição: Faculdade de Tecnologia de Mauá (Fatec Mauá).\n'
                            'E-mail: contato.pratoideal@fatec.sp.gov.br\n'
                            '\n'
                            '12. Consentimento\n'
                            'Ao clicar em "Cadastre-se" ou efetuar o "Login" no aplicativo "Prato Ideal", você declara estar ciente e de acordo com '
                            'todos os termos desta Política de Privacidade.\n',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Fechar'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Política de privacidade',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}

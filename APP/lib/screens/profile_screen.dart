import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/place_models.dart';
import '../providers/favorites_provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../services/profile_prefs.dart';
import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import '../utils/gamification.dart';
import '../widgets/ui/ui.dart';

class _Background {
  final String name;
  final String url;
  final int requiredReviews;
  const _Background(this.name, this.url, this.requiredReviews);
}

const _backgrounds = <_Background>[
  _Background('Ingredientes Frescos',
      'https://images.unsplash.com/photo-1466637574441-749b8f19452f?auto=format&fit=crop&q=80&w=1200', 0),
  _Background('Café Aconchegante',
      'https://images.unsplash.com/photo-1513364776144-60967b0f800f?auto=format&fit=crop&q=80&w=1200', 0),
  _Background('Arte Gourmet',
      'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&q=80&w=1200', 11),
  _Background('Adega Exclusiva',
      'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?auto=format&fit=crop&q=80&w=1200', 21),
  _Background('Cozinha Estrelada',
      'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?auto=format&fit=crop&q=80&w=1200', 101),
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();
  final _prefs = ProfilePrefs();
  final _picker = ImagePicker();

  List<ReviewItem> _reviews = [];
  bool _loading = true;
  bool _uploadingPhoto = false;
  int _tab = 0;

  String _bio = 'Explorador da gastronomia digital. 🚀';
  String _dob = '';
  String _bg = _backgrounds.first.url;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<UserProvider>();
    // Preferências locais
    final bio = await _prefs.getBio();
    final dob = await _prefs.getDob();
    final bg = await _prefs.getBackground();
    // Avaliações da API
    List<ReviewItem> reviews = const [];
    if (user.token != null) {
      try {
        reviews = await _api.getUserReviews(user.token!);
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      if (bio != null) _bio = bio;
      if (dob != null) _dob = dob;
      if (bg != null) _bg = bg;
      _reviews = reviews;
      _loading = false;
    });
  }

  Future<void> _uploadPhoto() async {
    final user = context.read<UserProvider>();
    if (user.token == null) return;
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      await _api.updateUserPhoto(picked.path, user.token!);
      await user.refreshUser();
      if (mounted) {
        AppToast.show(context, 'Foto atualizada!', type: ToastType.success);
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(context, 'Erro ao atualizar a foto.',
            type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final favCount = context.watch<FavoritesProvider>().ids.length;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meu Perfil')),
        body: const EmptyState(
          icon: Icons.person_off,
          title: 'Nenhum usuário logado',
        ),
      );
    }

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meu Perfil')),
        body: const AppLoading(),
      );
    }

    final level = getUserLevelData(_reviews.length);

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: ListView(
        children: [
          _header(theme, user.name, user.email, user.profileImageUrl, level),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statsAndProgress(theme, favCount, level),
                const SizedBox(height: 20),
                _achievements(theme),
                const SizedBox(height: 20),
                _tabBar(theme),
                const SizedBox(height: 16),
                _tabContent(theme, user.name, user.email, favCount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----- Header -----
  Widget _header(ThemeData theme, String name, String email, String image,
      UserLevelData level) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(imageUrl: _bg, fit: BoxFit.cover),
              Container(color: Colors.black.withValues(alpha: 0.35)),
              Positioned(
                top: 12,
                right: 12,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                    onPressed: _openBackgroundModal,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 110),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: theme.colorScheme.surface,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      backgroundImage:
                          image.isNotEmpty ? NetworkImage(image) : null,
                      child: image.isEmpty
                          ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: theme.textTheme.displaySmall
                                  ?.copyWith(color: AppColors.primary))
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _uploadingPhoto ? null : _uploadPhoto,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _uploadingPhoto
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.camera_alt,
                                  size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(name, style: theme.textTheme.headlineMedium),
                  AppBadge(label: level.currentTitle, tone: BadgeTone.primary),
                ],
              ),
              const SizedBox(height: 6),
              Text(email,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }

  // ----- Stats + progresso -----
  Widget _statsAndProgress(ThemeData theme, int favCount, UserLevelData level) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              _stat(theme, Icons.star, AppColors.rating,
                  _reviews.length.toString(), 'Avaliações'),
              _stat(theme, Icons.favorite, AppColors.favorite,
                  favCount.toString(), 'Favoritos'),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Progresso de nível',
                style: theme.textTheme.labelSmall),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: level.progress / 100,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(level.currentColor),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              level.nextAt != null
                  ? 'Faltam ${level.remaining} avaliações para o próximo título!'
                  : 'Nível máximo atingido! 👑',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(ThemeData theme, IconData icon, Color color, String value,
      String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.headlineSmall),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }

  // ----- Conquistas -----
  Widget _achievements(ThemeData theme) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Suas Conquistas', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
            children: gamificationLevels.map((lvl) {
              final unlocked = _reviews.length >= lvl.min;
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: unlocked
                      ? lvl.color.withValues(alpha: 0.1)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: unlocked ? lvl.color : theme.colorScheme.outline,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: unlocked ? 1 : 0.35,
                      child: Text(lvl.icon,
                          style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lvl.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: unlocked
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ----- Abas -----
  Widget _tabBar(ThemeData theme) {
    const labels = ['Atividade', 'Informações', 'Avaliações'];
    return Row(
      children: List.generate(labels.length, (i) {
        final selected = _tab == i;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: selected
                  ? AppColors.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                onTap: () => setState(() => _tab = i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: selected
                            ? Colors.white
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _tabContent(
      ThemeData theme, String name, String email, int favCount) {
    return switch (_tab) {
      1 => _infoTab(theme, name, email),
      2 => _reviewsTab(theme),
      _ => _activityTab(theme),
    };
  }

  // Atividade
  Widget _activityTab(ThemeData theme) {
    if (_reviews.isEmpty) {
      return const EmptyState(
        icon: Icons.timeline,
        title: 'Nada por aqui ainda',
        description: 'Avalie restaurantes e acompanhe sua atividade.',
      );
    }
    return Column(
      children: _reviews.map((r) {
        return AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0x1AF59E0B),
                child: Icon(Icons.star, color: AppColors.rating),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.restaurantName ?? 'Restaurante',
                        style: theme.textTheme.titleSmall),
                    Text('Você avaliou • ${r.rating}★',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Informações
  Widget _infoTab(ThemeData theme, String name, String email) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoField(theme, 'Nome completo', name),
          const Divider(height: 24),
          _infoField(theme, 'E-mail', email),
          const Divider(height: 24),
          _editableField(
            theme,
            'Sobre mim',
            _bio,
            onEdit: _editBio,
          ),
          const Divider(height: 24),
          _editableField(
            theme,
            'Data de nascimento',
            _dob.isEmpty ? 'Não informada' : _dob,
            onEdit: _editDob,
          ),
          const Divider(height: 24),
          TextButton.icon(
            onPressed: _changePassword,
            icon: const Icon(Icons.lock_outline, size: 18),
            label: const Text('Trocar de senha'),
          ),
        ],
      ),
    );
  }

  Widget _infoField(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.bodyLarge),
      ],
    );
  }

  Widget _editableField(ThemeData theme, String label, String value,
      {required VoidCallback onEdit}) {
    return Row(
      children: [
        Expanded(child: _infoField(theme, label, value)),
        IconButton(
          icon: const Icon(Icons.edit, size: 18),
          onPressed: onEdit,
        ),
      ],
    );
  }

  // Avaliações
  Widget _reviewsTab(ThemeData theme) {
    if (_reviews.isEmpty) {
      return const EmptyState(
        icon: Icons.star_border,
        title: 'Sem avaliações',
        description: 'Você ainda não avaliou nenhum restaurante.',
      );
    }
    return Column(
      children: _reviews.map((r) {
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(r.restaurantName ?? 'Restaurante',
                        style: theme.textTheme.titleSmall),
                  ),
                  RatingBadge(rating: r.rating.toDouble(), compact: true),
                ],
              ),
              if (r.comment.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('"${r.comment}"',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // ----- Modais/edições -----
  Future<void> _editBio() async {
    final ctrl = TextEditingController(text: _bio);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sobre mim'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Fale sobre você...'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Salvar')),
        ],
      ),
    );
    if (result != null) {
      await _prefs.setBio(result);
      if (mounted) setState(() => _bio = result);
    }
  }

  Future<void> _editDob() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
    );
    if (picked != null) {
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      await _prefs.setDob(formatted);
      if (mounted) setState(() => _dob = formatted);
    }
  }

  Future<void> _changePassword() async {
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Trocar de senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nova senha'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirmar nova senha'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                if (newCtrl.text.length < 6) {
                  AppToast.show(ctx, 'A senha deve ter ao menos 6 caracteres.',
                      type: ToastType.error);
                  return;
                }
                if (newCtrl.text != confirmCtrl.text) {
                  AppToast.show(ctx, 'As senhas não coincidem.',
                      type: ToastType.error);
                  return;
                }
                Navigator.pop(ctx);
                AppToast.show(context, 'Senha atualizada!',
                    type: ToastType.success);
              },
              child: const Text('Atualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openBackgroundModal() async {
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Escolha seu fundo', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Novos fundos são liberados ao escrever mais avaliações.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: _backgrounds.map((bg) {
                  final unlocked = _reviews.length >= bg.requiredReviews;
                  final selected = _bg == bg.url;
                  return GestureDetector(
                    onTap: unlocked
                        ? () async {
                            await _prefs.setBackground(bg.url);
                            if (mounted) setState(() => _bg = bg.url);
                            if (ctx.mounted) Navigator.pop(ctx);
                          }
                        : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                              imageUrl: bg.url, fit: BoxFit.cover),
                          if (selected)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.primary, width: 3),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMd),
                              ),
                            ),
                          if (!unlocked)
                            Container(
                              color: Colors.black.withValues(alpha: 0.55),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.lock,
                                        color: Colors.white, size: 18),
                                    Text('${bg.requiredReviews}+ avaliações',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

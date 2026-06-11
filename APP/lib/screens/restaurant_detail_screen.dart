import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../models/place_models.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../services/geolocation_service.dart';
import '../services/places_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import '../widgets/favorite_button.dart';
import '../widgets/ui/ui.dart';

/// Tela de detalhe do restaurante (completa): galeria + lightbox, avaliações
/// (listar + criar com fotos), mapa, distância, compartilhar e favoritar.
class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key, required this.restaurantId});

  final String restaurantId;

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final _places = PlacesService();
  final _api = ApiService();

  RestaurantDetails? _details;
  List<ReviewItem> _reviews = [];
  bool _loading = true;
  bool _error = false;

  String? _distanceText;
  bool _calculatingDistance = false;
  String _activePhoto = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final details = await _places.details(widget.restaurantId);
      if (details == null) {
        if (mounted) {
          setState(() {
            _loading = false;
            _error = true;
          });
        }
        return;
      }
      // Avaliações da API .NET (best-effort).
      List<ReviewItem> reviews = const [];
      try {
        reviews = await _api.getReviewItems(widget.restaurantId);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _details = details;
        _reviews = reviews;
        _activePhoto = details.photos.isNotEmpty ? details.photos.first : details.image;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  double get _displayRating {
    if (_reviews.isNotEmpty) {
      final avg = _reviews.fold<int>(0, (a, r) => a + r.rating) / _reviews.length;
      return avg;
    }
    return _details?.rating ?? 0;
  }

  // ----- ações -----
  Future<void> _share() async {
    final d = _details;
    if (d == null) return;
    await SharePlus.instance.share(
      ShareParams(
        text: 'Conheça ${d.name} no Prato Ideal! ${d.address}',
        subject: d.name,
      ),
    );
  }

  Future<void> _openDirections() async {
    final d = _details;
    if (d == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${d.lat},${d.lng}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      AppToast.show(context, 'Não foi possível abrir o mapa.',
          type: ToastType.error);
    }
  }

  Future<void> _calculateDistance() async {
    final d = _details;
    if (d == null) return;
    setState(() => _calculatingDistance = true);
    final res = await GeolocationService.instance.getCurrentPosition();
    if (!mounted) return;
    setState(() => _calculatingDistance = false);
    if (!res.ok) {
      AppToast.show(context, 'Não foi possível obter sua localização.',
          type: ToastType.error);
      return;
    }
    final meters = GeolocationService.instance.distanceMeters(
        res.position!.latitude, res.position!.longitude, d.lat, d.lng);
    setState(() => _distanceText =
        GeolocationService.instance.formatDistance(meters));
  }

  void _openLightbox(int initialIndex) {
    final photos = _details?.photos ?? const [];
    if (photos.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _Lightbox(photos: photos, initialIndex: initialIndex),
      ),
    );
  }

  Future<void> _openReviewForm() async {
    final user = context.read<UserProvider>();
    if (!user.isAuthenticated) {
      AppToast.show(context, 'Faça login para avaliar.', type: ToastType.info);
      return;
    }
    final created = await showModalBottomSheet<ReviewItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReviewForm(
        restaurantId: widget.restaurantId,
        restaurantName: _details?.name ?? '',
        token: user.token!,
        userName: user.currentUser?.name ?? 'Visitante',
      ),
    );
    if (created != null && mounted) {
      setState(() => _reviews = [created, ..._reviews]);
      AppToast.show(context, 'Avaliação publicada!', type: ToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: AppLoading());
    if (_error || _details == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.error_outline,
          title: 'Restaurante não encontrado',
          description: 'Não foi possível carregar os detalhes.',
        ),
      );
    }

    final d = _details!;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _appBar(theme, d),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _actionButtons(),
                  const SizedBox(height: 24),
                  Text('Sobre o Restaurante', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(d.description,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
                  if (d.photos.length > 1) ...[
                    const SizedBox(height: 24),
                    Text('Fotos', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    _gallery(d),
                  ],
                  const SizedBox(height: 24),
                  _infoCard(theme, d),
                  const SizedBox(height: 24),
                  _reviewsSection(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar(ThemeData theme, RestaurantDetails d) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _share,
        ),
        FavoriteButton(placeId: d.id, name: d.name, light: true),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(imageUrl: _activePhoto, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.displaySmall
                          ?.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(Icons.place, '${d.city}, ${d.state}'),
                      _chip(Icons.star, _displayRating.toStringAsFixed(1),
                          color: AppColors.rating),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            label: 'Como chegar',
            icon: Icons.navigation,
            onPressed: _openDirections,
          ),
        ),
      ],
    );
  }

  Widget _gallery(RestaurantDetails d) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: d.photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final photo = d.photos[index];
          return GestureDetector(
            onTap: () {
              setState(() => _activePhoto = photo);
              _openLightbox(index);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: CachedNetworkImage(
                imageUrl: photo,
                height: 90,
                width: 110,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chip(IconData icon, String label, {Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _infoCard(ThemeData theme, RestaurantDetails d) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informações', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          _infoRow(theme, Icons.schedule, 'Horário',
              d.openingHours.isNotEmpty
                  ? d.openingHours.join('\n')
                  : 'Aberto até ${d.openUntil}'),
          const Divider(height: 24),
          _infoRow(theme, Icons.phone, 'Contato', d.phone),
          const Divider(height: 24),
          _infoRow(theme, Icons.place, 'Endereço', d.address),
          const SizedBox(height: 16),
          if (_distanceText != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.navigation, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('A $_distanceText de você',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: AppColors.primary)),
                ],
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: _calculatingDistance ? null : _calculateDistance,
              icon: _calculatingDistance
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.navigation, size: 16),
              label: Text(_calculatingDistance
                  ? 'Calculando...'
                  : 'Calcular distância da minha localização'),
            ),
          if (AppConfig.enableMaps) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(d.lat, d.lng),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId(d.id),
                      position: LatLng(d.lat, d.lng),
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openDirections,
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Abrir no Google Maps'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Avaliações', style: theme.textTheme.headlineSmall),
            TextButton.icon(
              onPressed: _openReviewForm,
              icon: const Icon(Icons.rate_review_outlined, size: 18),
              label: const Text('Avaliar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_reviews.isEmpty)
          const EmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'Seja o primeiro a avaliar!',
            description: 'Compartilhe sua experiência neste restaurante.',
          )
        else
          ..._reviews.map((r) => _reviewTile(theme, r)),
      ],
    );
  }

  Widget _reviewTile(ThemeData theme, ReviewItem r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage:
                      r.userImage != null ? NetworkImage(r.userImage!) : null,
                  child: r.userImage == null
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.userName, style: theme.textTheme.titleSmall),
                      if (r.date.isNotEmpty)
                        Text(r.date,
                            style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                RatingBadge(rating: r.rating.toDouble(), compact: true),
              ],
            ),
            if (r.comment.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(r.comment, style: theme.textTheme.bodyMedium),
            ],
            if (r.photos.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: r.photos.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: r.photos[i],
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lightbox (galeria em tela cheia)
// ---------------------------------------------------------------------------
class _Lightbox extends StatefulWidget {
  const _Lightbox({required this.photos, required this.initialIndex});
  final List<String> photos;
  final int initialIndex;

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('${_index + 1} / ${widget.photos.length}'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.photos.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: CachedNetworkImage(
              imageUrl: widget.photos[i],
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Formulário de avaliação (bottom sheet)
// ---------------------------------------------------------------------------
class _ReviewForm extends StatefulWidget {
  const _ReviewForm({
    required this.restaurantId,
    required this.restaurantName,
    required this.token,
    required this.userName,
  });

  final String restaurantId;
  final String restaurantName;
  final String token;
  final String userName;

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  final _api = ApiService();
  final _commentCtrl = TextEditingController();
  final _picker = ImagePicker();

  int _rating = 5;
  final List<XFile> _photos = [];
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picked = await _picker.pickMultiImage(limit: 5);
    if (picked.isEmpty) return;
    setState(() {
      _photos
        ..clear()
        ..addAll(picked.take(5));
    });
  }

  Future<void> _submit() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await _api.createReviewWithPhotos(
        restaurantId: widget.restaurantId,
        restaurantName: widget.restaurantName,
        rating: _rating,
        comment: _commentCtrl.text.trim(),
        token: widget.token,
        photoPaths: _photos.map((x) => x.path).toList(),
      );
      if (!mounted) return;
      Navigator.pop(
        context,
        ReviewItem(
          id: 'local-${DateTime.now().microsecondsSinceEpoch}',
          userName: widget.userName,
          rating: _rating,
          comment: _commentCtrl.text.trim(),
          date: _today(),
          restaurantId: widget.restaurantId,
          photos: _photos.map((x) => x.path).toList(),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        AppToast.show(context, 'Erro ao publicar avaliação. Tente novamente.',
            type: ToastType.error);
      }
    }
  }

  String _today() {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2, '0')}/${n.month.toString().padLeft(2, '0')}/${n.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sua avaliação', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: List.generate(5, (i) {
              final star = i + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = star),
                icon: Icon(
                  star <= _rating ? Icons.star : Icons.star_border,
                  color: AppColors.rating,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Conte-nos sobre sua experiência...',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickPhotos,
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Anexar fotos'),
              ),
              const SizedBox(width: 12),
              if (_photos.isNotEmpty)
                Text('${_photos.length} foto(s)',
                    style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Publicar Avaliação',
            icon: Icons.send,
            isLoading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

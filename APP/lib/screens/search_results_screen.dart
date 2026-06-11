import 'package:flutter/material.dart';

import '../models/place_models.dart';
import '../services/places_service.dart';
import '../widgets/restaurant_card_widget.dart';
import '../widgets/ui/ui.dart';
import 'restaurant_detail_screen.dart';

/// Tela de resultados de busca em grade. Usada por coleções/categorias na Home
/// (será enriquecida com a omnibox na Fase 4).
class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({
    super.key,
    required this.title,
    this.query,
    this.locationName = 'São Paulo',
    this.lat,
    this.lng,
  });

  final String title;
  final String? query;
  final String locationName;

  /// Quando informados, a busca usa proximidade (`places:searchNearby`).
  final double? lat;
  final double? lng;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _places = PlacesService();
  final _scroll = ScrollController();

  final List<RestaurantCard> _items = [];
  String? _nextPageToken;
  bool _loading = true;
  bool _loadingMore = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  bool get _isNearby => widget.lat != null && widget.lng != null;

  Future<PlacesPage> _fetch({String? pageToken}) {
    if (_isNearby) {
      return _places.nearby(widget.lat!, widget.lng!,
          locationName: widget.locationName, pageToken: pageToken);
    }
    return _places.searchText(widget.locationName,
        query: widget.query, pageToken: pageToken);
  }

  Future<void> _load() async {
    try {
      final page = await _fetch();
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(page.restaurants);
        _nextPageToken = page.nextPageToken;
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

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _nextPageToken == null) return;
    setState(() => _loadingMore = true);
    try {
      final page = await _fetch(pageToken: _nextPageToken);
      if (!mounted) return;
      setState(() {
        _items.addAll(page.restaurants);
        _nextPageToken = page.nextPageToken;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _openDetail(RestaurantCard r) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(restaurantId: r.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const AppLoading();
    if (_error) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Erro ao carregar',
        description: 'Não foi possível buscar restaurantes. Tente novamente.',
        action: PrimaryButton(
          label: 'Tentar de novo',
          expand: false,
          onPressed: () {
            setState(() {
              _loading = true;
              _error = false;
            });
            _load();
          },
        ),
      );
    }
    if (_items.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'Nenhum resultado',
        description: 'Tente buscar por outra categoria ou cidade.',
      );
    }

    return GridView.builder(
      controller: _scroll,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisExtent: 290,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final r = _items[index];
        return RestaurantCardWidget(restaurant: r, onTap: () => _openDetail(r));
      },
    );
  }
}

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/search_models.dart';
import '../services/autocomplete_service.dart';
import '../services/geolocation_service.dart';
import '../services/recent_search_store.dart';
import '../utils/app_colors.dart';
import '../widgets/ui/ui.dart';
import 'restaurant_detail_screen.dart';
import 'search_results_screen.dart';

/// Omnibox de busca: autocomplete com debounce, agrupado em categorias,
/// regiões e restaurantes; buscas recentes persistidas; detectar localização.
/// Porta do `SearchBar.tsx` do web.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.locationName = 'São Paulo'});

  final String locationName;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _autocomplete = AutocompleteService();
  final _recentStore = RecentSearchStore();

  Timer? _debounce;
  AutocompleteResult _result = const AutocompleteResult();
  List<RecentSearch> _recent = [];
  bool _loading = false;
  bool _detecting = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final recent = await _recentStore.load();
    if (mounted) setState(() => _recent = recent);
  }

  void _onChanged(String value) {
    setState(() => _query = value.trim());
    _debounce?.cancel();
    if (_query.length < 2) {
      setState(() {
        _result = const AutocompleteResult();
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 300), _runSearch);
  }

  Future<void> _runSearch() async {
    final q = _query;
    try {
      final result = await _autocomplete.search(q);
      if (!mounted || q != _query) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _detecting = true);
    final res = await GeolocationService.instance.getCurrentPosition();
    if (!mounted) return;
    setState(() => _detecting = false);
    if (!res.ok) {
      AppToast.show(context, _geoError(res.error!), type: ToastType.error);
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(
          title: 'Restaurantes próximos a você',
          lat: res.position!.latitude,
          lng: res.position!.longitude,
          locationName: widget.locationName,
        ),
      ),
    );
  }

  String _geoError(GeoError e) => switch (e) {
        GeoError.serviceDisabled => 'Ative o GPS para usar a localização.',
        GeoError.denied => 'Permissão de localização negada.',
        GeoError.deniedForever =>
          'Permissão negada. Habilite nas configurações do sistema.',
        GeoError.unknown => 'Não foi possível obter sua localização.',
      };

  // ----- ações de seleção -----
  Future<void> _selectText(String query) async {
    _recent = await _recentStore.add(
      RecentSearch(type: RecentSearchType.text, label: query),
    );
    _goToResults(title: 'Resultados para "$query"', query: query);
  }

  Future<void> _selectRegion(RegionSuggestion region) async {
    _recent = await _recentStore.add(RecentSearch(
      type: RecentSearchType.region,
      label: region.name,
      id: region.id,
      subtitle: region.address,
    ));
    _goToResults(
      title: 'Restaurantes em ${region.name}',
      locationName: region.name,
    );
  }

  Future<void> _selectRestaurant(String id, String name, String subtitle) async {
    _recent = await _recentStore.add(RecentSearch(
      type: RecentSearchType.restaurant,
      label: name,
      id: id,
      subtitle: subtitle,
    ));
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurantId: id)),
    );
  }

  void _goToResults({
    required String title,
    String? query,
    String? locationName,
  }) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(
          title: title,
          query: query,
          locationName: locationName ?? widget.locationName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _searchField(),
        actions: [
          IconButton(
            tooltip: 'Usar minha localização',
            icon: _detecting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location, color: AppColors.primary),
            onPressed: _detecting ? null : _detectLocation,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _ctrl,
      autofocus: true,
      textInputAction: TextInputAction.search,
      onChanged: _onChanged,
      onSubmitted: (v) {
        if (v.trim().isNotEmpty) _selectText(v.trim());
      },
      decoration: InputDecoration(
        hintText: 'Cidade, restaurante ou prato...',
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _ctrl.clear();
                  _onChanged('');
                },
              )
            : null,
      ),
    );
  }

  Widget _buildBody() {
    if (_query.isEmpty) return _recentList();
    if (_loading) return const AppLoading();
    if (_result.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'Nenhum resultado encontrado',
        description: 'Tente um prato, região ou restaurante diferente.',
      );
    }
    return _suggestionsList();
  }

  Widget _recentList() {
    if (_recent.isEmpty) {
      return const EmptyState(
        icon: Icons.search,
        title: 'Busque restaurantes',
        description: 'Digite uma cidade, prato ou nome de restaurante.',
      );
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Buscas recentes',
                  style: Theme.of(context).textTheme.labelSmall),
              TextButton(
                onPressed: () async {
                  await _recentStore.clear();
                  setState(() => _recent = []);
                },
                child: const Text('LIMPAR'),
              ),
            ],
          ),
        ),
        ..._recent.map(_recentTile),
      ],
    );
  }

  Widget _recentTile(RecentSearch item) {
    final icon = switch (item.type) {
      RecentSearchType.text => Icons.history,
      RecentSearchType.region => Icons.place_outlined,
      RecentSearchType.restaurant => Icons.restaurant,
    };
    return ListTile(
      leading: Icon(icon),
      title: Text(item.label),
      subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
      onTap: () {
        switch (item.type) {
          case RecentSearchType.text:
            _selectText(item.label);
          case RecentSearchType.region:
            _selectRegion(RegionSuggestion(
                id: item.id ?? '',
                name: item.label,
                address: item.subtitle ?? ''));
          case RecentSearchType.restaurant:
            _selectRestaurant(item.id ?? '', item.label, item.subtitle ?? '');
        }
      },
    );
  }

  Widget _suggestionsList() {
    final theme = Theme.of(context);
    return ListView(
      children: [
        if (_result.categories.isNotEmpty) ...[
          _sectionHeader('Categorias e Pratos'),
          ..._result.categories.map((c) => ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x1AF59E0B),
                  child: Icon(Icons.restaurant_menu, color: AppColors.rating),
                ),
                title: Text('Busca por categoria: $c'),
                onTap: () => _selectText(c),
              )),
        ],
        if (_result.regions.isNotEmpty) ...[
          _sectionHeader('Cidades e Regiões'),
          ..._result.regions.map((r) => ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x1AEF4444),
                  child: Icon(Icons.place, color: AppColors.primary),
                ),
                title: Text(r.name),
                subtitle: r.address.isNotEmpty ? Text(r.address) : null,
                onTap: () => _selectRegion(r),
              )),
        ],
        if (_result.restaurants.isNotEmpty) ...[
          _sectionHeader('Restaurantes'),
          ..._result.restaurants.map((r) => ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 44,
                    width: 44,
                    child: CachedNetworkImage(
                      imageUrl: r.image,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.restaurant, size: 20),
                      ),
                    ),
                  ),
                ),
                title: Text(r.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${r.city}, ${r.state}'),
                trailing: r.rating > 0
                    ? RatingBadge(rating: r.rating, compact: true)
                    : null,
                onTap: () =>
                    _selectRestaurant(r.id, r.name, '${r.city}, ${r.state}'),
              )),
        ],
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0x1AEF4444),
            child: Icon(Icons.search, color: AppColors.primary),
          ),
          title: Text('Pesquisar por "$_query"'),
          onTap: () => _selectText(_query),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

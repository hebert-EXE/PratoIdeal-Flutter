import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/place_models.dart';
import '../providers/theme_provider.dart';
import '../services/places_service.dart';
import '../widgets/collections_section.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/promo_banner.dart';
import '../widgets/restaurant_carousel.dart';
import '../widgets/ui/ui.dart';
import 'restaurant_detail_screen.dart';
import 'search_results_screen.dart';
import 'search_screen.dart';

/// Categoria de carrossel: rótulo, subtítulo e query enviada ao Places.
class _Cat {
  final String title;
  final String subtitle;
  final String query;
  final bool openNow;
  const _Cat(this.title, this.subtitle, this.query, {this.openNow = false});
}

const _location = 'São Paulo';

const _categories = <_Cat>[
  _Cat('Abertos Agora & Bem Avaliados', 'Os melhores locais abertos neste momento.',
      'Melhores bem avaliados', openNow: true),
  _Cat('Mais Populares na Região', 'Os queridinhos da galera.', 'Melhores restaurantes'),
  _Cat('Churrascarias e Carnes', 'Para os apaixonados por um bom corte.', 'Churrascaria e Carnes'),
  _Cat('Hambúrgueres Incríveis', 'Para matar a fome de um bom artesanal.', 'Hambúrguer'),
  _Cat('Culinária Italiana', 'Massas frescas e o sabor da Itália.', 'Restaurante Italiano'),
  _Cat('Noite da Pizza', 'Clássicas, diferentonas e deliciosas.', 'Pizzaria'),
  _Cat('Festival Japonês', 'Sushis frescos e comida oriental.', 'Japonês'),
  _Cat('Frutos do Mar e Peixes', 'Direto do litoral.', 'Frutos do mar'),
  _Cat('Cafeterias e Docerias', 'Café da tarde e sobremesas.', 'Cafeteria e Doceria'),
  _Cat('Opções Saudáveis', 'Saladas, bowls e refeições leves.', 'Saudável'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _places = PlacesService();

  Map<int, List<RestaurantCard>> _byCategory = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait(
      _categories.map((c) => _places
          .searchText(_location, query: '${c.query} em $_location', openNow: c.openNow)
          .then((p) => p.restaurants)
          .catchError((_) => <RestaurantCard>[])),
    );
    if (!mounted) return;
    setState(() {
      _byCategory = {for (var i = 0; i < results.length; i++) i: results[i]};
      _loading = false;
    });
  }

  void _openDetail(RestaurantCard r) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(restaurantId: r.id),
      ),
    );
  }

  void _openSearch(String query, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(
          title: title,
          query: query,
          locationName: _location,
        ),
      ),
    );
  }

  void _openOmnibox() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchScreen(locationName: _location),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const BrandWordmark(fontSize: 20),
        actions: [
          IconButton(
            tooltip: 'Buscar',
            icon: const Icon(Icons.search),
            onPressed: _openOmnibox,
          ),
          IconButton(
            tooltip: 'Alternar tema',
            icon: Icon(themeProvider.isDark(context)
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            onPressed: () => context.read<ThemeProvider>().toggle(context),
          ),
        ],
      ),
      body: _loading
          ? const AppLoading()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  _hero(theme),
                  _searchField(),
                  CollectionsSection(onSelectQuery: _openSearch),
                  for (var i = 0; i < _categories.length; i++)
                    if ((_byCategory[i] ?? const []).isNotEmpty) ...[
                      RestaurantCarousel(
                        title: _categories[i].title,
                        subtitle: _categories[i].subtitle,
                        restaurants: _byCategory[i]!,
                        onTapRestaurant: _openDetail,
                      ),
                      if (i == 1) const PromoBanner(),
                    ],
                  if (_byCategory.values.every((l) => l.isEmpty))
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: EmptyState(
                        icon: Icons.restaurant,
                        title: 'Nenhum restaurante encontrado',
                        description: 'Tente novamente mais tarde.',
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _hero(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Descubra os melhores sabores em '),
                TextSpan(
                  text: _location,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ],
            ),
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Explore restaurantes bem avaliados, de lanches rápidos a jantares sofisticados.',
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _openOmnibox,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pesquise por restaurante ou prato...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

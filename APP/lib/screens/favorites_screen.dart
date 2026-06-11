import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/place_models.dart';
import '../providers/favorites_provider.dart';
import '../services/places_service.dart';
import '../widgets/restaurant_card_widget.dart';
import '../widgets/ui/ui.dart';
import 'restaurant_detail_screen.dart';

/// Página de favoritos do usuário. Lê os place_ids do [FavoritesProvider] e
/// busca os detalhes de cada um no Places para montar os cards.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _places = PlacesService();
  final Map<String, RestaurantCard> _cache = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final ids = context.read<FavoritesProvider>().ids.toList();
    await Future.wait(ids.map((id) async {
      if (_cache.containsKey(id)) return;
      final d = await _places.details(id).catchError((_) => null);
      if (d != null) {
        _cache[id] = RestaurantCard(
          id: d.id,
          name: d.name,
          city: d.city,
          state: d.state,
          rating: d.rating,
          distance: d.distance,
          image: d.image,
          openUntil: d.openUntil,
          openingHours: d.openingHours,
        );
      }
    }));
    if (mounted) setState(() => _loading = false);
  }

  void _openDetail(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(restaurantId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favIds = context.watch<FavoritesProvider>().ids;
    final items = favIds
        .map((id) => _cache[id])
        .whereType<RestaurantCard>()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Favoritos')),
      body: _loading
          ? const AppLoading()
          : favIds.isEmpty
              ? const EmptyState(
                  icon: Icons.favorite_border,
                  title: 'Nenhum favorito ainda',
                  description:
                      'Toque no coração dos restaurantes para salvá-los aqui.',
                )
              : RefreshIndicator(
                  onRefresh: _loadAll,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 280,
                      mainAxisExtent: 290,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final r = items[index];
                      return RestaurantCardWidget(
                        restaurant: r,
                        onTap: () => _openDetail(r.id),
                      );
                    },
                  ),
                ),
    );
  }
}

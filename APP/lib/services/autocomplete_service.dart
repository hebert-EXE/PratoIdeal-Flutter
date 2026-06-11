import '../models/search_models.dart';
import '../utils/string_utils.dart';
import 'places_service.dart';

/// Agrega categorias (estáticas), regiões e restaurantes para o autocomplete,
/// espelhando o BFF `/api/autocomplete` do web.
class AutocompleteService {
  AutocompleteService({PlacesService? places})
      : _places = places ?? PlacesService();

  final PlacesService _places;

  static const _knownCategories = [
    'Pizza',
    'Hambúrguer',
    'Sushi',
    'Japonês',
    'Italiano',
    'Churrasco',
    'Saudável',
    'Café',
    'Doces',
    'Frutos do Mar',
    'Vegetariano',
  ];

  Future<AutocompleteResult> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const AutocompleteResult();

    final nq = normalize(q);
    final categories = _knownCategories
        .where((c) => normalize(c).contains(nq))
        .take(3)
        .toList();

    // Restaurantes e regiões em paralelo.
    final results = await Future.wait([
      _places.searchText('Brasil', query: q).then((p) => p.restaurants),
      _places.regions(q),
    ]);

    final restaurants = (results[0] as List).cast<dynamic>();
    final regions = (results[1] as List).cast<RegionSuggestion>();

    return AutocompleteResult(
      categories: categories,
      regions: regions,
      restaurants: restaurants.take(5).toList().cast(),
    );
  }
}

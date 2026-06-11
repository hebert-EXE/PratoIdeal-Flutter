import '../models/place_models.dart';

/// Sugestão de cidade/região retornada pelo autocomplete.
class RegionSuggestion {
  final String id;
  final String name;
  final String address;
  const RegionSuggestion({
    required this.id,
    required this.name,
    required this.address,
  });
}

/// Resultado agrupado do autocomplete (categorias, regiões, restaurantes),
/// espelhando a resposta do BFF `/api/autocomplete` do web.
class AutocompleteResult {
  final List<String> categories;
  final List<RegionSuggestion> regions;
  final List<RestaurantCard> restaurants;

  const AutocompleteResult({
    this.categories = const [],
    this.regions = const [],
    this.restaurants = const [],
  });

  bool get isEmpty =>
      categories.isEmpty && regions.isEmpty && restaurants.isEmpty;
}

/// Tipo de uma busca recente persistida.
enum RecentSearchType { text, region, restaurant }

/// Item de busca recente (persistido em shared_preferences).
class RecentSearch {
  final RecentSearchType type;
  final String label; // texto exibido (query, nome da cidade ou do restaurante)
  final String? id; // place_id (restaurante) ou region id
  final String? subtitle; // cidade/estado ou endereço

  const RecentSearch({
    required this.type,
    required this.label,
    this.id,
    this.subtitle,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'label': label,
        if (id != null) 'id': id,
        if (subtitle != null) 'subtitle': subtitle,
      };

  factory RecentSearch.fromJson(Map<String, dynamic> json) {
    return RecentSearch(
      type: RecentSearchType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => RecentSearchType.text,
      ),
      label: json['label']?.toString() ?? '',
      id: json['id']?.toString(),
      subtitle: json['subtitle']?.toString(),
    );
  }
}

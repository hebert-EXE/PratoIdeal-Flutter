import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/place_models.dart';
import '../models/search_models.dart';
import '../utils/string_utils.dart';
import 'mock_restaurants.dart';

/// Página de resultados da busca (lista + token de próxima página).
class PlacesPage {
  final List<RestaurantCard> restaurants;
  final String? nextPageToken;
  const PlacesPage(this.restaurants, [this.nextPageToken]);
}

/// Integração com a **Google Places API (New)**, portada do
/// `src/services/restaurantService.ts` do web.
///
/// Quando [AppConfig.useMock] é `true`, retorna dados mockados filtrados,
/// permitindo desenvolvimento sem billing.
class PlacesService {
  static const _base = 'https://places.googleapis.com/v1';
  static const _fallbackImage =
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&q=80&w=800';

  final http.Client _client;
  PlacesService({http.Client? client}) : _client = client ?? http.Client();

  String get _key => AppConfig.googleMapsApiKey;

  // ---------------------------------------------------------------------------
  // Busca por proximidade (geolocalização)
  // ---------------------------------------------------------------------------
  Future<PlacesPage> nearby(
    double lat,
    double lng, {
    String? locationName,
    String? pageToken,
  }) async {
    if (AppConfig.useMock) {
      return PlacesPage(_filterMockByCity(locationName));
    }

    final res = await _client.post(
      Uri.parse('$_base/places:searchNearby'),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _key,
        'X-Goog-FieldMask':
            'places.id,places.displayName,places.location,places.rating,places.photos,places.addressComponents,places.regularOpeningHours,nextPageToken',
      },
      body: jsonEncode({
        'includedTypes': ['restaurant'],
        'maxResultCount': 20,
        'languageCode': 'pt-BR',
        'locationRestriction': {
          'circle': {
            'center': {'latitude': lat, 'longitude': lng},
            'radius': 3000.0,
          },
        },
        if (pageToken != null) 'pageToken': pageToken,
      }),
    );

    if (res.statusCode != 200) {
      return const PlacesPage([]);
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return _mapPlaces(data, defaultCity: locationName);
  }

  // ---------------------------------------------------------------------------
  // Busca textual (categorias / queries)
  // ---------------------------------------------------------------------------
  Future<PlacesPage> searchText(
    String locationName, {
    String? query,
    bool openNow = false,
    String? pageToken,
  }) async {
    if (AppConfig.useMock) {
      return PlacesPage(_filterMock(locationName, query, openNow));
    }

    // Mesma heurística do web: queries curtas viram "restaurantes em X".
    final textQuery = query != null && query.isNotEmpty
        ? (query.split(' ').length == 1 &&
                !query.toLowerCase().contains('restaurante')
            ? 'restaurantes em $query'
            : query)
        : 'Restaurantes em $locationName';

    final res = await _client.post(
      Uri.parse('$_base/places:searchText'),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _key,
        'X-Goog-FieldMask':
            'places.id,places.displayName,places.rating,places.photos,places.addressComponents,places.regularOpeningHours,nextPageToken',
      },
      body: jsonEncode({
        'textQuery': textQuery,
        'includedType': 'restaurant',
        'maxResultCount': 20,
        'languageCode': 'pt-BR',
        if (openNow) 'openNow': true,
        if (pageToken != null) 'pageToken': pageToken,
      }),
    );

    if (res.statusCode != 200) {
      return const PlacesPage([]);
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return _mapPlaces(data, defaultCity: locationName);
  }

  // ---------------------------------------------------------------------------
  // Regiões/cidades (para autocomplete)
  // ---------------------------------------------------------------------------
  static const _regionTypes = {
    'locality',
    'sublocality',
    'administrative_area_level_2',
    'administrative_area_level_3',
    'neighborhood',
    'political',
  };

  Future<List<RegionSuggestion>> regions(String query) async {
    if (AppConfig.useMock) {
      final q = normalize(query);
      return kMockRestaurants
          .map((r) => r.city)
          .toSet()
          .where((city) => normalize(city).contains(q))
          .take(3)
          .map((city) => RegionSuggestion(
              id: 'reg-${normalize(city)}', name: city, address: '$city, SP'))
          .toList();
    }

    final res = await _client.post(
      Uri.parse('$_base/places:searchText'),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _key,
        'X-Goog-FieldMask':
            'places.id,places.displayName,places.types,places.formattedAddress',
      },
      body: jsonEncode({
        'textQuery': query,
        'maxResultCount': 3,
        'languageCode': 'pt-BR',
      }),
    );
    if (res.statusCode != 200) return const [];

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final places = (data['places'] as List?) ?? const [];
    final out = <RegionSuggestion>[];
    for (final raw in places) {
      final p = raw as Map<String, dynamic>;
      final types = ((p['types'] as List?) ?? const []).cast<dynamic>();
      if (types.any(_regionTypes.contains)) {
        out.add(RegionSuggestion(
          id: p['id']?.toString() ?? '',
          name: _displayName(p) ?? '',
          address: p['formattedAddress']?.toString() ?? '',
        ));
      }
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  // Detalhes de um restaurante
  // ---------------------------------------------------------------------------
  Future<RestaurantDetails?> details(String id) async {
    if (AppConfig.useMock || id.startsWith('mock-')) {
      return _mockDetails(id);
    }

    final res = await _client.get(
      Uri.parse('$_base/places/$id?languageCode=pt-BR'),
      headers: {
        'X-Goog-Api-Key': _key,
        'X-Goog-FieldMask':
            'id,displayName,rating,photos,formattedAddress,nationalPhoneNumber,location,addressComponents,regularOpeningHours,editorialSummary',
      },
    );

    if (res.statusCode != 200) return null;
    final place = jsonDecode(res.body) as Map<String, dynamic>;

    final (city, state) = _parseCityState(place['addressComponents']);
    final photos = _photoUrls(place['photos'], maxH: 1080, maxW: 1920);
    final loc = place['location'] as Map<String, dynamic>?;

    return RestaurantDetails(
      id: place['id']?.toString() ?? id,
      name: _displayName(place) ?? 'Restaurante',
      city: city,
      state: state,
      rating: _toDouble(place['rating']),
      distance: 'Consulte no mapa',
      image: photos.isNotEmpty ? photos.first : _fallbackImage,
      openUntil: '23:00',
      openingHours: _weekdayDescriptions(place['regularOpeningHours']),
      address: place['formattedAddress']?.toString() ?? '$city, $state',
      phone: place['nationalPhoneNumber']?.toString() ?? 'Não informado',
      lat: _toDouble(loc?['latitude'], fallback: -23.5505),
      lng: _toDouble(loc?['longitude'], fallback: -46.6333),
      photos: photos.isNotEmpty ? photos : [_fallbackImage],
      reviews: const [],
      description: (place['editorialSummary']?['text'])?.toString() ??
          'Um ambiente acolhedor oferecendo uma experiência gastronômica única.',
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers de mapeamento
  // ---------------------------------------------------------------------------
  PlacesPage _mapPlaces(Map<String, dynamic> data, {String? defaultCity}) {
    final places = (data['places'] as List?) ?? const [];
    final nextPageToken = data['nextPageToken']?.toString();

    final mapped = <RestaurantCard>[];
    for (final raw in places) {
      final place = raw as Map<String, dynamic>;
      final name = _displayName(place) ?? 'Restaurante';
      if (_isGasStation(name)) continue;

      final (city, state) = _parseCityState(
        place['addressComponents'],
        defaultCity: defaultCity,
      );
      final photos = _photoUrls(place['photos'], maxH: 800, maxW: 800);

      mapped.add(RestaurantCard(
        id: place['id']?.toString() ?? '',
        name: name,
        city: city,
        state: state,
        rating: _toDouble(place['rating']),
        distance: 'Próximo a você',
        image: photos.isNotEmpty ? photos.first : _fallbackImage,
        openingHours: _weekdayDescriptions(place['regularOpeningHours']),
      ));
    }
    return PlacesPage(mapped, nextPageToken);
  }

  String? _displayName(Map<String, dynamic> place) {
    final dn = place['displayName'];
    if (dn is Map) return dn['text']?.toString();
    return null;
  }

  bool _isGasStation(String name) {
    final n = name.toLowerCase();
    return n.contains('posto ') ||
        n.contains('ipiranga') ||
        n.contains('petrobras') ||
        n.contains('shell') ||
        n.contains('auto posto');
  }

  (String, String) _parseCityState(dynamic components, {String? defaultCity}) {
    String city = defaultCity ?? 'São Paulo';
    String state = 'SP';
    if (components is List) {
      for (final raw in components) {
        final c = raw as Map<String, dynamic>;
        final types = (c['types'] as List?)?.cast<dynamic>() ?? const [];
        if (types.contains('locality') ||
            types.contains('administrative_area_level_2')) {
          city = c['longText']?.toString() ?? city;
        }
        if (types.contains('administrative_area_level_1')) {
          state = c['shortText']?.toString() ?? state;
        }
      }
    }
    return (city, state);
  }

  List<String> _photoUrls(dynamic photos, {required int maxH, required int maxW}) {
    if (photos is! List) return const [];
    return photos
        .take(4)
        .map((p) {
          final name = (p as Map<String, dynamic>)['name']?.toString();
          if (name == null) return null;
          return '$_base/$name/media?maxHeightPx=$maxH&maxWidthPx=$maxW&key=$_key';
        })
        .whereType<String>()
        .toList();
  }

  List<String> _weekdayDescriptions(dynamic openingHours) {
    if (openingHours is Map && openingHours['weekdayDescriptions'] is List) {
      return (openingHours['weekdayDescriptions'] as List)
          .map((e) => e.toString())
          .toList();
    }
    return const [];
  }

  double _toDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  // ---------------------------------------------------------------------------
  // Mock helpers
  // ---------------------------------------------------------------------------
  List<RestaurantCard> _filterMockByCity(String? locationName) {
    if (locationName == null || locationName.isEmpty) return kMockRestaurants;
    final loc = normalize(locationName);
    return kMockRestaurants
        .where((r) =>
            normalize(r.city).contains(loc) || loc.contains(normalize(r.city)))
        .toList();
  }

  List<RestaurantCard> _filterMock(
    String locationName,
    String? query,
    bool openNow,
  ) {
    var results = _filterMockByCity(locationName);
    if (query != null && query.isNotEmpty) {
      final q = normalize(query);
      results = results
          .where((r) =>
              normalize(r.name).contains(q) ||
              normalize(r.city).contains(q) ||
              (r.category != null && normalize(r.category!).contains(q)))
          .toList();
    }
    return results;
  }

  RestaurantDetails? _mockDetails(String id) {
    final base = kMockRestaurants.where((r) => r.id == id).firstOrNull ??
        (kMockRestaurants.isNotEmpty ? kMockRestaurants.first : null);
    if (base == null) return null;
    return RestaurantDetails(
      id: base.id,
      name: base.name,
      city: base.city,
      state: base.state,
      rating: base.rating,
      distance: base.distance,
      image: base.image,
      openUntil: base.openUntil,
      openingHours: const [],
      address: 'Rua Principal, 1000 - Centro, ${base.city} - ${base.state}',
      phone: '(11) 99999-9999',
      lat: -23.5505,
      lng: -46.6333,
      photos: [base.image, _fallbackImage],
      reviews: const [],
      description:
          'Um ambiente acolhedor e moderno, com ingredientes selecionados (dados de demonstração).',
    );
  }
}

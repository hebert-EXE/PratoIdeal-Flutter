import 'package:flutter_test/flutter_test.dart';

import 'package:app/services/places_service.dart';
import 'package:app/utils/string_utils.dart';

void main() {
  group('normalize', () {
    test('remove acentos e baixa caixa', () {
      expect(normalize('São Paulo'), 'sao paulo');
      expect(normalize('Japonês'), 'japones');
      expect(normalize('  CAFÉ  '), 'cafe');
    });
  });

  group('PlacesService (modo mock)', () {
    // Sem GOOGLE_MAPS_API_KEY nos testes, AppConfig.useMock == true.
    final service = PlacesService();

    test('searchText filtra por cidade', () async {
      final page = await service.searchText('Santos');
      expect(page.restaurants, isNotEmpty);
      expect(
        page.restaurants.every((r) => r.city.toLowerCase().contains('santos')),
        isTrue,
      );
    });

    test('searchText filtra por query/categoria', () async {
      final page = await service.searchText('São Paulo', query: 'pizza');
      expect(page.restaurants, isNotEmpty);
      expect(
        page.restaurants.any((r) => normalize(r.name).contains('pizza') ||
            (r.category != null && normalize(r.category!).contains('pizza'))),
        isTrue,
      );
    });

    test('details retorna restaurante mock por id', () async {
      final details = await service.details('mock-1');
      expect(details, isNotNull);
      expect(details!.name, 'La Bella Italia');
      expect(details.photos, isNotEmpty);
    });
  });
}

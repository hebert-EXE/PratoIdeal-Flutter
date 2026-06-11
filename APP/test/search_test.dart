import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/models/search_models.dart';
import 'package:app/services/autocomplete_service.dart';
import 'package:app/services/recent_search_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutocompleteService (mock)', () {
    test('retorna categorias, regiões e restaurantes', () async {
      final result = await AutocompleteService().search('pizza');
      expect(result.categories, contains('Pizza'));
      expect(result.restaurants.length, lessThanOrEqualTo(5));
    });

    test('query de cidade retorna região', () async {
      final result = await AutocompleteService().search('Santos');
      expect(result.regions.any((r) => r.name.contains('Santos')), isTrue);
    });

    test('query vazia retorna vazio', () async {
      final result = await AutocompleteService().search('   ');
      expect(result.isEmpty, isTrue);
    });
  });

  group('RecentSearchStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('adiciona, deduplica e limita a 5', () async {
      final store = RecentSearchStore();
      for (var i = 0; i < 7; i++) {
        await store.add(
          RecentSearch(type: RecentSearchType.text, label: 'busca $i'),
        );
      }
      // Duplicado deve ir ao topo sem crescer a lista.
      final list = await store.add(
        const RecentSearch(type: RecentSearchType.text, label: 'busca 6'),
      );
      expect(list.length, 5);
      expect(list.first.label, 'busca 6');
    });

    test('clear limpa tudo', () async {
      final store = RecentSearchStore();
      await store.add(
        const RecentSearch(type: RecentSearchType.text, label: 'x'),
      );
      await store.clear();
      expect(await store.load(), isEmpty);
    });
  });
}

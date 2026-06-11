import 'package:flutter_test/flutter_test.dart';

import 'package:app/providers/favorites_provider.dart';

void main() {
  group('FavoritesProvider', () {
    test('estado inicial vazio e não carregado', () {
      final p = FavoritesProvider();
      expect(p.isLoaded, isFalse);
      expect(p.ids, isEmpty);
      expect(p.isFavorite('x'), isFalse);
    });

    test('clear reseta estado', () {
      final p = FavoritesProvider();
      p.clear();
      expect(p.isLoaded, isFalse);
      expect(p.ids, isEmpty);
    });

    test('notifica listeners ao limpar', () {
      final p = FavoritesProvider();
      var notified = 0;
      p.addListener(() => notified++);
      p.clear();
      expect(notified, greaterThan(0));
    });
  });
}

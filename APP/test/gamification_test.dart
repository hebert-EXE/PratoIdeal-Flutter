import 'package:flutter_test/flutter_test.dart';

import 'package:app/utils/gamification.dart';

void main() {
  group('getUserLevelData', () {
    test('nível inicial (0 avaliações)', () {
      final d = getUserLevelData(0);
      expect(d.currentTitle, 'Só vim pelo Wi-Fi');
      expect(d.nextAt, 6);
      expect(d.remaining, 6);
      expect(d.progress, 0);
    });

    test('progresso intermediário', () {
      final d = getUserLevelData(3); // entre 0 e 6
      expect(d.currentTitle, 'Só vim pelo Wi-Fi');
      expect(d.progress, 50);
      expect(d.remaining, 3);
    });

    test('sobe de nível', () {
      final d = getUserLevelData(11);
      expect(d.currentTitle, 'Caçador de Rodízios');
    });

    test('nível máximo', () {
      final d = getUserLevelData(150);
      expect(d.currentTitle, 'Imperador da Gastronomia');
      expect(d.nextAt, isNull);
      expect(d.progress, 100);
    });
  });
}

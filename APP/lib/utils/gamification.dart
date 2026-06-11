import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Sistema de gamificação portado de `src/lib/gamification.ts`.
/// Os níveis são determinados pela quantidade de avaliações do usuário.
class GamificationLevel {
  final int min;
  final String title;
  final String colorKey;
  final String icon; // emoji
  final String humor;
  final int? nextAt;

  const GamificationLevel({
    required this.min,
    required this.title,
    required this.colorKey,
    required this.icon,
    required this.humor,
    required this.nextAt,
  });

  Color get color => switch (colorKey) {
        'blue' => const Color(0xFF3B82F6),
        'green' => AppColors.success,
        'purple' => const Color(0xFF8B5CF6),
        'red' => AppColors.primary,
        'orange' => const Color(0xFFF97316),
        'amber' => AppColors.rating,
        _ => const Color(0xFF9CA3AF), // gray
      };
}

const gamificationLevels = <GamificationLevel>[
  GamificationLevel(min: 0, title: 'Só vim pelo Wi-Fi', colorKey: 'gray', icon: '📶', humor: 'PENDURADO NO ROTEADOR', nextAt: 6),
  GamificationLevel(min: 6, title: 'Marmiteiro de Elite', colorKey: 'blue', icon: '🍱', humor: 'ESPECIALISTA EM MISTURA', nextAt: 11),
  GamificationLevel(min: 11, title: 'Caçador de Rodízios', colorKey: 'green', icon: '🍕', humor: 'PREJUÍZO DA PIZZARIA', nextAt: 21),
  GamificationLevel(min: 21, title: 'Sommelier de PF', colorKey: 'purple', icon: '🍛', humor: 'AVALIADOR DE FAROFA', nextAt: 36),
  GamificationLevel(min: 36, title: 'Terror do Buffet Livre', colorKey: 'red', icon: '🍽️', humor: 'BALANÇA QUEBRADA', nextAt: 51),
  GamificationLevel(min: 51, title: 'Crítico de Boteco', colorKey: 'orange', icon: '🍻', humor: 'RAIZ DEMAIS', nextAt: 101),
  GamificationLevel(min: 101, title: 'Imperador da Gastronomia', colorKey: 'amber', icon: '👑', humor: 'GORDON RAMSAY BR', nextAt: null),
];

class UserLevelData {
  final String currentTitle;
  final Color currentColor;
  final String currentColorKey;
  final int? nextAt;
  final int progress; // 0-100
  final int remaining;

  const UserLevelData({
    required this.currentTitle,
    required this.currentColor,
    required this.currentColorKey,
    required this.nextAt,
    required this.progress,
    required this.remaining,
  });
}

UserLevelData getUserLevelData(int count) {
  final current = gamificationLevels.reversed.firstWhere(
    (l) => count >= l.min,
    orElse: () => gamificationLevels.first,
  );
  final currentIndex = gamificationLevels.indexWhere((l) => l.min == current.min);
  final next = currentIndex + 1 < gamificationLevels.length
      ? gamificationLevels[currentIndex + 1]
      : null;

  final progress = next != null
      ? ((count - current.min) / (next.min - current.min) * 100)
          .clamp(0, 100)
          .round()
      : 100;

  return UserLevelData(
    currentTitle: current.title,
    currentColor: current.color,
    currentColorKey: current.colorKey,
    nextAt: next?.min,
    progress: progress,
    remaining: next != null ? next.min - count : 0,
  );
}

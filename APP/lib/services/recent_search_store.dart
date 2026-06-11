import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/search_models.dart';

/// Persiste as buscas recentes em `shared_preferences` (latência zero, sem I/O
/// no backend), como o `localStorage` do web. Mantém no máximo 5 itens.
class RecentSearchStore {
  static const _key = 'pratoideal_recent_searches';
  static const _max = 5;

  Future<List<RecentSearch>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<dynamic>();
      return list
          .map((e) => RecentSearch.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<RecentSearch>> add(RecentSearch item) async {
    final current = await load();
    // Remove duplicado por (type,label) e joga o novo no topo.
    current.removeWhere((s) => s.type == item.type && s.label == item.label);
    final updated = [item, ...current].take(_max).toList();
    await _save(updated);
    return updated;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _save(List<RecentSearch> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}

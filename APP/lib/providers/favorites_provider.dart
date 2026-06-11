import 'package:flutter/foundation.dart';

import '../services/api_service.dart';

/// Estado global de favoritos (place_ids), sincronizado com a API .NET
/// (`/Usuario/favoritos`). Espelha o `FavoritesProvider` do web.
class FavoritesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  final Set<String> _ids = {};
  bool _loaded = false;

  Set<String> get ids => _ids;
  bool get isLoaded => _loaded;
  bool isFavorite(String id) => _ids.contains(id);

  /// Carrega os favoritos do usuário (lista de place_ids em `Usuario.favoritos`).
  Future<void> load(String userId, String token) async {
    try {
      final user = await _api.getUser(userId);
      _ids
        ..clear()
        ..addAll(user.favorites);
    } catch (_) {
      // mantém vazio em caso de falha
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  void clear() {
    _ids.clear();
    _loaded = false;
    notifyListeners();
  }

  /// Alterna favorito de forma otimista. Lança em caso de erro (após rollback)
  /// para o chamador exibir feedback.
  Future<void> toggle(String placeId, String token) async {
    final wasFav = _ids.contains(placeId);
    _applyLocal(placeId, add: !wasFav);
    try {
      if (wasFav) {
        await _api.removeFavorite(placeId, token);
      } else {
        await _api.addFavorite(placeId, token);
      }
    } catch (e) {
      _applyLocal(placeId, add: wasFav); // rollback
      rethrow;
    }
  }

  void _applyLocal(String placeId, {required bool add}) {
    if (add) {
      _ids.add(placeId);
    } else {
      _ids.remove(placeId);
    }
    notifyListeners();
  }
}

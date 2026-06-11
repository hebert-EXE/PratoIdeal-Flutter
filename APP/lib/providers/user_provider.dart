import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';

/// Estado de autenticação resolvido no bootstrap.
enum AuthStatus { unknown, authenticated, unauthenticated }

class UserProvider extends ChangeNotifier {
  static const _tokenKey = 'auth_token';
  static const _storage = FlutterSecureStorage();

  final ApiService _apiService = ApiService();

  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  AuthStatus _status = AuthStatus.unknown;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Restaura a sessão a partir do token salvo. Chamado no `AuthGate`.
  Future<void> bootstrap() async {
    try {
      final stored = await _storage.read(key: _tokenKey);
      if (stored == null || stored.isEmpty || JwtDecoder.isExpired(stored)) {
        await _clearToken();
        _setStatus(AuthStatus.unauthenticated);
        return;
      }
      _token = stored;
      final userId = _userIdFromToken(stored);
      if (userId == null) {
        await _clearToken();
        _setStatus(AuthStatus.unauthenticated);
        return;
      }
      _currentUser = await _apiService.getUser(userId);
      _setStatus(AuthStatus.authenticated);
    } catch (_) {
      // Token inválido ou backend indisponível → exige novo login.
      await _clearToken();
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final token = await _apiService.login(email, password);
      await _completeLogin(token);
    } finally {
      _setLoading(false);
    }
  }

  /// Retorna `false` se o usuário cancelar o fluxo do Google.
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    try {
      final idToken = await GoogleAuthService.instance.signInAndGetIdToken();
      if (idToken == null) return false; // cancelado
      final token = await _apiService.loginWithGoogle(idToken);
      await _completeLogin(token);
      return true;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String name, String email, String password) {
    return _apiService.register(name, email, password);
  }

  /// Recarrega os dados do usuário atual (ex.: após atualizar a foto).
  Future<void> refreshUser() async {
    final token = _token;
    if (token == null) return;
    final userId = _userIdFromToken(token);
    if (userId == null) return;
    _currentUser = await _apiService.getUser(userId);
    notifyListeners();
  }

  Future<void> logout() async {
    await GoogleAuthService.instance.signOut();
    await _clearToken();
    _currentUser = null;
    _setStatus(AuthStatus.unauthenticated);
  }

  // ----- internos -----

  Future<void> _completeLogin(String token) async {
    final userId = _userIdFromToken(token);
    if (userId == null) {
      throw Exception('Token inválido: id do usuário não encontrado.');
    }
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
    _currentUser = await _apiService.getUser(userId);
    _setStatus(AuthStatus.authenticated);
  }

  String? _userIdFromToken(String token) {
    try {
      final decoded = JwtDecoder.decode(token);
      final id = decoded['nameid'] ??
          decoded['sub'] ??
          decoded['userId'] ??
          decoded['Id'] ??
          decoded['id'] ??
          decoded[
              'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
      return id?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearToken() async {
    _token = null;
    await _storage.delete(key: _tokenKey);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setStatus(AuthStatus value) {
    _status = value;
    notifyListeners();
  }
}

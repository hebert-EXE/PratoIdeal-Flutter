import 'package:google_sign_in/google_sign_in.dart';

import '../config/app_config.dart';

/// Encapsula o fluxo do `google_sign_in` 7.x.
///
/// Responsável apenas por obter o `idToken` do Google; a troca por JWT do
/// backend é feita pelo [ApiService].
class GoogleAuthService {
  GoogleAuthService._();
  static final GoogleAuthService instance = GoogleAuthService._();

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: AppConfig.googleIosClientId.isEmpty
          ? null
          : AppConfig.googleIosClientId,
      serverClientId: AppConfig.googleServerClientId.isEmpty
          ? null
          : AppConfig.googleServerClientId,
    );
    _initialized = true;
  }

  /// Dispara o fluxo interativo e retorna o `idToken`, ou `null` se o usuário
  /// cancelar. Lança [GoogleAuthException] em erros de configuração/plataforma.
  Future<String?> signInAndGetIdToken() async {
    if (!AppConfig.isGoogleConfigured) {
      throw const GoogleAuthException(
        'Login com Google ainda não está configurado neste build.',
      );
    }

    await _ensureInitialized();

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw const GoogleAuthException(
        'Login com Google não é suportado nesta plataforma.',
      );
    }

    try {
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const GoogleAuthException(
          'Não foi possível obter o token do Google.',
        );
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null; // usuário cancelou
      }
      throw GoogleAuthException('Erro no login com Google: ${e.description ?? e.code.name}');
    }
  }

  Future<void> signOut() async {
    if (!_initialized) return;
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // ignora falhas de signOut
    }
  }
}

class GoogleAuthException implements Exception {
  const GoogleAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

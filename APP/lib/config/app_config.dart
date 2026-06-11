/// Configuração central do app (chaves/endpoints sensíveis a ambiente).
///
/// Valores podem ser injetados em build/run via `--dart-define`, ex.:
/// `flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com`
class AppConfig {
  AppConfig._();

  /// Base da API .NET (Render).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://apirestaurantes.onrender.com/api',
  );

  /// OAuth Client ID do tipo **Web**. Usado como `serverClientId` para que o
  /// `idToken` gerado tenha o `aud` esperado pelo backend (`/Usuario/login/google`).
  /// Configure no Google Cloud Console e injete via --dart-define.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  /// OAuth Client ID do tipo **iOS** (necessário no iOS). No Android o ID é
  /// resolvido pelo `google-services`/assinatura; deixe vazio fora do iOS.
  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '',
  );

  /// Indica se o login com Google está configurado o suficiente para tentar.
  static bool get isGoogleConfigured => googleServerClientId.isNotEmpty;

  /// Chave da **Google Places API (New)**, usada no cliente para buscar
  /// restaurantes. Injete via --dart-define=GOOGLE_MAPS_API_KEY=...
  ///
  /// Restrinja a chave por package name (Android) / bundle id (iOS) no Console.
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static bool get hasPlacesKey => googleMapsApiKey.isNotEmpty;

  /// Habilita o mapa embutido (`google_maps_flutter`). Requer também a chave
  /// nativa do Maps SDK no AndroidManifest/AppDelegate. Quando desligado,
  /// a tela de detalhe oferece apenas o botão "Abrir no Google Maps".
  static const bool _enableMapsEnv =
      bool.fromEnvironment('ENABLE_MAPS', defaultValue: false);
  static bool get enableMaps => _enableMapsEnv;

  /// Quando `true`, usa dados mockados em vez de bater na Places API
  /// (útil para desenvolvimento sem billing). Padrão liga automaticamente
  /// quando não há chave configurada.
  static const bool _useMockEnv = bool.fromEnvironment('USE_MOCK', defaultValue: false);
  static bool get useMock => _useMockEnv || !hasPlacesKey;
}

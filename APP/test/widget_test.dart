// Smoke test: garante que o app inicializa e, sem sessão salva, cai na
// tela de autenticação (AuthGate -> AuthScreen).

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/main.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/providers/accessibility_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock do flutter_secure_storage: sem token salvo.
  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      if (call.method == 'read' || call.method == 'delete') return null;
      if (call.method == 'readAll') return <String, String>{};
      return null;
    });
  });

  testWidgets('App inicializa e mostra a tela de login sem sessão',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final themeProvider = ThemeProvider();
    final a11yProvider = AccessibilityProvider();
    await themeProvider.load();
    await a11yProvider.load();

    await tester.pumpWidget(
      MyApp(themeProvider: themeProvider, a11yProvider: a11yProvider),
    );
    // Deixa o bootstrap (postFrameCallback + leitura do storage) resolver,
    // sem usar pumpAndSettle por causa do spinner animado.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Sem token salvo → AuthScreen com o botão "Entrar".
    expect(find.text('Entrar'), findsOneWidget);
  });
}

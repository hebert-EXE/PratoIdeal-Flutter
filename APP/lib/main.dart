import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/auth_gate.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/accessibility_provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  final a11yProvider = AccessibilityProvider();
  await Future.wait([themeProvider.load(), a11yProvider.load()]);
  runApp(MyApp(themeProvider: themeProvider, a11yProvider: a11yProvider));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.themeProvider,
    required this.a11yProvider,
  });

  final ThemeProvider themeProvider;
  final AccessibilityProvider a11yProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: a11yProvider),
      ],
      child: Consumer2<ThemeProvider, AccessibilityProvider>(
        builder: (context, theme, a11y, _) {
          return MaterialApp(
            title: 'Prato Ideal',
            theme: AppTheme.themeFor(
              brightness: Brightness.light,
              highContrast: a11y.highContrast,
              dyslexia: a11y.dyslexiaFriendly,
            ),
            darkTheme: AppTheme.themeFor(
              brightness: Brightness.dark,
              highContrast: a11y.highContrast,
              dyslexia: a11y.dyslexiaFriendly,
            ),
            // Em alto contraste forçamos o tema escuro (paleta WCAG).
            themeMode: a11y.highContrast ? ThemeMode.dark : theme.themeMode,
            debugShowCheckedModeBanner: false,
            home: const AuthGate(),
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  textScaler: TextScaler.linear(a11y.fontScale),
                  boldText: a11y.boldText,
                  disableAnimations: a11y.reduceMotion,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

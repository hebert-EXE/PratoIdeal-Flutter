import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/ui/ui.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

/// Decide, de forma reativa, qual tela mostrar conforme o estado de auth.
/// Dispara o `bootstrap()` (restauração de sessão) uma única vez.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final favorites = context.read<FavoritesProvider>();

    switch (user.status) {
      case AuthStatus.unknown:
        return const Scaffold(body: AppLoading());
      case AuthStatus.authenticated:
        if (!favorites.isLoaded &&
            user.currentUser != null &&
            user.token != null) {
          final id = user.currentUser!.id;
          final token = user.token!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            favorites.load(id, token);
          });
        }
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        if (favorites.isLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) => favorites.clear());
        }
        return const AuthScreen();
    }
  }
}

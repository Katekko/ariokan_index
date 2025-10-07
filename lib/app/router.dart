import 'package:ariokan_index/features/auth_signup/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ariokan_index/features/auth_login/ui/login_page.dart';
import 'package:ariokan_index/shared/services/firebase_auth_service.dart';

/// Creates the application router.
/// Routes:
///  /signup  -> AuthSignupPage
///  /decks   -> Placeholder deck list page
GoRouter createRouter() {
  return GoRouter(
    initialLocation: Routes.login,
    routes: [
      GoRoute(
        path: Routes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.signup,
        name: 'signup',
        builder: (context, state) => const AuthSignupPage(),
      ),
      GoRoute(
        path: Routes.decks,
        name: 'decks',
        builder: (context, state) => const _DecksPlaceholderPage(),
      ),
    ],
  );
}

class _DecksPlaceholderPage extends StatelessWidget {
  const _DecksPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // TODO: Use dependency injection for AuthService
              // For now, create a new instance
              final auth = FirebaseAuthService();
              await auth.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const Center(child: Text('Deck list placeholder')),
    );
  }
}

sealed class Routes {
  static const signup = '/signup';
  static const decks = '/decks';
  static const login = '/login';
}

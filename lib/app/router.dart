import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ariokan_index/features/auth_signup/ui/signup_page_setup.dart';
// Login page stub (to be implemented in auth_login feature slice, T005+)
import 'package:ariokan_index/features/auth_login/ui/login_page.dart';
import 'package:ariokan_index/shared/services/firebase_auth_service.dart';

/// Creates the application router.
/// Routes:
///  /signup  -> AuthSignupPage
///  /decks   -> Placeholder deck list page
GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const AuthSignupPageSetup(),
      ),
      GoRoute(
        path: '/decks',
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ariokan_index/features/auth_signup/ui/signup_page_setup.dart';
// Login page stub (to be implemented in auth_login feature slice, T005+)
import 'package:flutter/widgets.dart' show Widget; // minimal import to allow typedef without implementation yet

/// Stub class placeholder so router compiles before implementation (T005 will add real file).
class LoginPageStub extends StatelessWidget {
  const LoginPageStub({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Login Page (stub)')),
    );
  }
}

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
        builder: (context, state) => const LoginPageStub(),
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
      appBar: AppBar(title: const Text('Decks')),
      body: const Center(child: Text('Deck list placeholder')),
    );
  }
}

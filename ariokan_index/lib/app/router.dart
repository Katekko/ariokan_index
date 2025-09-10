import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:ariokan_index/pages/auth_signup_page/auth_signup_page.dart';

/// Creates the application router.
/// Routes:
///  /signup  -> AuthSignupPage
///  /decks   -> Placeholder deck list page
GoRouter createRouter(SignupController signupController) {
  return GoRouter(
    initialLocation: '/signup',
    routes: [
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => AuthSignupPage(controller: signupController),
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

import 'package:ariokan_index/features/auth_login/presentation/pages/login_page.dart';
import 'package:ariokan_index/features/auth_signup/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Creates the application router with authentication-aware redirects.
///
/// Route Protection (FR-011):
/// - Authenticated users are redirected from /login and /signup to /decks
/// - Unauthenticated users are redirected from protected routes to /login
/// - Initial route is determined by authentication state
GoRouter createRouter(FirebaseAuth auth) {
  return GoRouter(
    // Determine initial location based on auth state
    initialLocation: auth.currentUser != null ? Routes.decks : Routes.login,
    
    // Global redirect logic for route protection
    redirect: (context, state) {
      final isAuthenticated = auth.currentUser != null;
      final isGoingToLogin = state.matchedLocation == Routes.login;
      final isGoingToSignup = state.matchedLocation == Routes.signup;
      final isGoingToProtected = state.matchedLocation == Routes.decks;

      // If user is authenticated and trying to access login/signup
      // redirect them to decks (FR-011)
      if (isAuthenticated && (isGoingToLogin || isGoingToSignup)) {
        return Routes.decks;
      }

      // If user is not authenticated and trying to access protected routes
      // redirect them to login (FR-001)
      if (!isAuthenticated && isGoingToProtected) {
        return Routes.login;
      }

      // No redirect needed
      return null;
    },
    
    // Refresh router when auth state changes
    refreshListenable: _AuthStateNotifier(auth),
    
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

/// Notifies GoRouter when Firebase Auth state changes.
/// This triggers the redirect logic to re-evaluate.
class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(this._auth) {
    _auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  final FirebaseAuth _auth;
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
              // final auth = FirebaseAuthService();
              // await auth.signOut();
              // if (context.mounted) {
              //   context.go('/login');
              // }
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

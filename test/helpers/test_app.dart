import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ariokan_index/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'mock_go_router.dart';

/// Creates a simple localized MaterialApp for widget tests with a direct child.
Widget localizedTestApp(Widget child, {Locale? locale}) => MaterialApp(
  locale: locale,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

/// Builds a localized MaterialApp.router for routing-based tests.
///
/// Provide a list of [routes]; the first route path is used as [initialLocation]
/// unless overridden. Supply [observers] to inspect navigation events.
Widget localizedTestRouterApp({
  required List<GoRoute> routes,
  String? initialLocation,
  Locale? locale,
  List<NavigatorObserver>? observers,
}) {
  final router = GoRouter(
    initialLocation: initialLocation ?? routes.first.path,
    routes: routes,
    observers: observers,
  );
  return MaterialApp.router(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}

Widget mockedRouterApp(Widget child, {MockGoRouter? mockRouter}) {
  return MockGoRouterProvider(
    goRouter: mockRouter ?? MockGoRouter(),
    child: child,
  );
}

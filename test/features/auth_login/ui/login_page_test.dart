// T008 failing login page widget test skeleton.
import 'package:ariokan_index/app/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginPage', () {
    testWidgets('renders idle state & button disabled when fields empty', (
      tester,
    ) async {
      final router = createRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      // Expect login page visible
      expect(
        find.text('Login Page (stub)'),
        findsOneWidget,
      ); // will change when implemented
      // Future: find Login button and assert disabled
    });

    testWidgets('navigates to decks on success', (tester) async {
      final router = createRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      // Simulate filling form & success (will fail until implemented)
      // After implementation expect decks page
      await tester.pumpAndSettle();
      expect(find.text('Deck list placeholder'), findsOneWidget);
    });

    testWidgets('bypass when session present', (tester) async {
      // TODO: Inject signed-in state via AuthService mock once DI available.
      final router = createRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      // Should land on decks directly when session present (will fail until logic added)
      expect(find.text('Decks'), findsOneWidget);
    });
  });
}

import 'package:ariokan_index/app/app.dart';
import 'package:ariokan_index/app/di/di.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('App widget', () {
    // Create mock instances directly, not using late
    final mockAuth = MockFirebaseAuth(signedIn: false);
    final fakeFirestore = FakeFirebaseFirestore();

    setUpAll(() async {
      // Reset DI and setup all app dependencies once for all tests
      di.reset(dispose: false);
      await setupDependencies(
        auth: mockAuth,
        firestore: fakeFirestore,
      );
    });

    testWidgets('initState gets FirebaseAuth from DI', (tester) async {
      // Arrange - ensure auth is registered
      expect(di.isRegistered<FirebaseAuth>(), isTrue);

      // Act - pump just the widget, don't settle (don't navigate)
      await tester.pumpWidget(const App());

      // Assert - App widget was created and initState was called
      expect(find.byType(App), findsOneWidget);
    });

    testWidgets('initState calls createRouter with FirebaseAuth',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(const App());

      // Assert - router was created successfully in initState
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.routerConfig, isNotNull);
      expect(materialApp.routerConfig, isA<GoRouter>());
    });

    testWidgets('builds MaterialApp.router with localization',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(const App());

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // Verify localization delegates are set up
      expect(materialApp.localizationsDelegates, isNotNull);
      expect(materialApp.localizationsDelegates!.length, greaterThan(0));
      
      // Verify supported locales
      expect(materialApp.supportedLocales, isNotEmpty);
      
      // Verify onGenerateTitle is set
      expect(materialApp.onGenerateTitle, isNotNull);
    });
  });
}

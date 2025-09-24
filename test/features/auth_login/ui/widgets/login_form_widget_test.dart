// T009 failing login form widget test skeleton (mirrors production path ui/widgets/)
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ariokan_index/features/auth_login/ui/login_form.dart';

void main() {
  const goldenSize = Size(400, 300);

  Widget widgetBuilder() => MaterialApp(
        home: Scaffold(body: const LoginForm()),
      );

  group('Interfaces', () {
    testWidgets('renders placeholder form', (tester) async {
      await tester.pumpWidget(widgetBuilder());
      expect(find.byType(LoginForm), findsOneWidget);
    });
  });

  group('Interactions', () {
    testWidgets('spinner during submit (future)', (tester) async {
      await tester.pumpWidget(widgetBuilder());
      // Will be replaced with real interaction once form implemented.
      fail('Not implemented');
    });
  });
}
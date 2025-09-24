import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ariokan_index/features/auth_login/ui/login_form.dart';

void main() {
  testWidgets('Login button enables/disables and shows spinner', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginForm()));
    final button = find.byType(ElevatedButton);
    expect(tester.widget<ElevatedButton>(button).enabled, isFalse);
    await tester.enterText(find.byKey(const Key('username')), 'user');
    await tester.enterText(find.byKey(const Key('password')), 'pass');
    await tester.pump();
    expect(tester.widget<ElevatedButton>(button).enabled, isTrue);
    await tester.tap(button);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Shows error messages and navigates on success', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginForm()));
    // TODO: Simulate error and success states
    // This will fail until implemented
    expect(find.text('Username or password wrong'), findsNothing);
  });
}

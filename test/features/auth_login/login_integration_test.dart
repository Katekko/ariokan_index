import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/main.dart' as app;

void main() {
  testWidgets('Login flow: session persistence, navigation, retries, logging', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    // TODO: Simulate login, check navigation, session, retries, logging
    // This will fail until implemented
    expect(find.text('Decks'), findsOneWidget);
  });
}

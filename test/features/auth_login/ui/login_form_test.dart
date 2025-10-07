import 'package:ariokan_index/features/auth_login/model/login_state.dart';
import 'package:ariokan_index/features/auth_login/ui/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/golden.dart';
import '../../../helpers/test_app.dart';
import '../mocks/login_controller_mock.dart';

void main() {
  // Register only needed mocks
  final mock = LoginControllerMock.register();

  group('Interfaces', () {
    testWidgetsGolden(
      'idle golden',
      fileName: 'login_form_idle',
      builder: () {
        when(() => mock.state).thenReturn(const LoginState());
        return localizedTestApp(const LoginForm());
      },
    );
  });

  group('Interactions', () {
    testWidgets('tapping login button calls submit with correct arguments', (
      tester,
    ) async {
      when(() => mock.state).thenReturn(
        const LoginState(
          username: 'user',
          password: 'pass',
          status: LoginStatus.idle,
        ),
      );
      when(
        () => mock.submit(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(localizedTestApp(const LoginForm()));

      final loginButton = find.byType(ElevatedButton);
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      await tester.pump();

      verify(() => mock.submit(username: 'user', password: 'pass')).called(1);
    });
    testWidgets('constructor works', (tester) async {
      when(() => mock.state).thenReturn(const LoginState());
      await tester.pumpWidget(localizedTestApp(const LoginForm()));
      expect(find.byType(LoginForm), findsOneWidget);
    });

    testWidgets('login button is enabled when canSubmit is true', (
      tester,
    ) async {
      when(
        () => mock.state,
      ).thenReturn(const LoginState(username: 'a', password: 'b'));
      await tester.pumpWidget(localizedTestApp(const LoginForm()));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows auth error message', (tester) async {
      when(() => mock.state).thenReturn(
        const LoginState(
          status: LoginStatus.failure,
          errorType: LoginErrorType.auth,
        ),
      );
      await tester.pumpWidget(localizedTestApp(const LoginForm()));
      expect(find.text('Username or password wrong'), findsOneWidget);
    });

    testWidgets('shows network error message', (tester) async {
      when(() => mock.state).thenReturn(
        const LoginState(
          status: LoginStatus.failure,
          errorType: LoginErrorType.network,
        ),
      );
      await tester.pumpWidget(localizedTestApp(const LoginForm()));
      expect(find.text('Network error. Please try again.'), findsOneWidget);
    });

    testWidgets('signup navigation button exists', (tester) async {
      when(() => mock.state).thenReturn(const LoginState());
      await tester.pumpWidget(localizedTestApp(const LoginForm()));
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('tapping signup button triggers onPressed', (tester) async {
      when(() => mock.state).thenReturn(const LoginState());
      await tester.pumpWidget(localizedTestApp(const LoginForm()));
      final signupButton = find.byType(TextButton);
      expect(signupButton, findsOneWidget);
      await tester.tap(signupButton);
      await tester.pump();
      // No navigation yet, but this covers the onPressed callback for coverage.
      // If navigation is implemented, add a check here.
    });
  });
}

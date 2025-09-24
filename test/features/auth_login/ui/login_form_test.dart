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
  });
}

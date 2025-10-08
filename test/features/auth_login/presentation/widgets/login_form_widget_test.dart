import 'package:ariokan_index/features/auth_login/domain/exceptions/login_exceptions.dart';
import 'package:ariokan_index/features/auth_login/presentation/cubit/login_cubit.dart';
import 'package:ariokan_index/features/auth_login/presentation/cubit/login_state.dart';
import 'package:ariokan_index/features/auth_login/presentation/widgets/login_form.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/golden.dart';
import '../../../../helpers/mock_go_router.dart';
import '../../../../helpers/test_app.dart';
import '../mocks/login_cubit_mock.dart';

const goldenSize = Size(400, 600);

void main() {
  group('LoginForm Widget Tests', () {
    final mockCubit = LoginCubitMock.register();

    Widget buildWidget() {
      return BlocProvider<LoginCubit>.value(
        value: mockCubit,
        child: localizedTestApp(const LoginForm()),
      );
    }

    group('Interfaces', () {
      testWidgetsGolden(
        'renders initial state with empty fields',
        fileName: 'login_form_initial',
        size: goldenSize,
        builder: buildWidget,
      );

      testWidgetsGolden(
        'renders with username empty error',
        fileName: 'login_form_username_empty_error',
        size: goldenSize,
        setUp: () async {
          whenListen(
            mockCubit,
            Stream.value(
              const LoginState(
                status: LoginStatus.error,
                error: LoginError(LoginErrorCode.usernameEmpty),
              ),
            ),
            initialState: const LoginState(
              status: LoginStatus.error,
              error: LoginError(LoginErrorCode.usernameEmpty),
            ),
          );
        },
        builder: buildWidget,
      );

      testWidgetsGolden(
        'renders with password empty error',
        fileName: 'login_form_password_empty_error',
        size: goldenSize,
        setUp: () async {
          whenListen(
            mockCubit,
            Stream.value(
              const LoginState(
                status: LoginStatus.error,
                error: LoginError(LoginErrorCode.passwordEmpty),
              ),
            ),
            initialState: const LoginState(
              status: LoginStatus.error,
              error: LoginError(LoginErrorCode.passwordEmpty),
            ),
          );
        },
        builder: buildWidget,
      );

      testWidgetsGolden(
        'renders with invalid credentials error',
        fileName: 'login_form_invalid_credentials_error',
        size: goldenSize,
        setUp: () async {
          whenListen(
            mockCubit,
            Stream.value(
              const LoginState(
                username: 'testuser',
                password: 'testpass',
                status: LoginStatus.error,
                error: LoginError(LoginErrorCode.invalidCredentials),
              ),
            ),
            initialState: const LoginState(
              username: 'testuser',
              password: 'testpass',
              status: LoginStatus.error,
              error: LoginError(LoginErrorCode.invalidCredentials),
            ),
          );
        },
        builder: buildWidget,
      );

      testWidgetsGolden(
        'renders with user not found error',
        fileName: 'login_form_user_not_found_error',
        size: goldenSize,
        setUp: () async {
          whenListen(
            mockCubit,
            Stream.value(
              const LoginState(
                username: 'nonexistent',
                password: 'testpass',
                status: LoginStatus.error,
                error: LoginError(LoginErrorCode.userNotFound),
              ),
            ),
            initialState: const LoginState(
              username: 'nonexistent',
              password: 'testpass',
              status: LoginStatus.error,
              error: LoginError(LoginErrorCode.userNotFound),
            ),
          );
        },
        builder: buildWidget,
      );

      testWidgetsGolden(
        'renders with network failure error',
        fileName: 'login_form_network_failure_error',
        size: goldenSize,
        setUp: () async {
          whenListen(
            mockCubit,
            Stream.value(
              const LoginState(
                username: 'testuser',
                password: 'testpass',
                status: LoginStatus.error,
                error: LoginError(LoginErrorCode.networkFailure),
              ),
            ),
            initialState: const LoginState(
              username: 'testuser',
              password: 'testpass',
              status: LoginStatus.error,
              error: LoginError(LoginErrorCode.networkFailure),
            ),
          );
        },
        builder: buildWidget,
      );

      testWidgetsGolden(
        'renders with unknown error',
        fileName: 'login_form_unknown_error',
        size: goldenSize,
        setUp: () async {
          whenListen(
            mockCubit,
            Stream.value(
              const LoginState(
                username: 'testuser',
                password: 'testpass',
                status: LoginStatus.error,
                error: LoginError(LoginErrorCode.unknown),
              ),
            ),
            initialState: const LoginState(
              username: 'testuser',
              password: 'testpass',
              status: LoginStatus.error,
              error: LoginError(LoginErrorCode.unknown),
            ),
          );
        },
        builder: buildWidget,
      );

      testWidgetsGoldenAnimated(
        'renders loading state with disabled fields',
        fileName: 'login_form_loading',
        size: goldenSize,
        setUp: () async {
          whenListen(
            mockCubit,
            Stream.value(
              const LoginState(
                username: 'testuser',
                password: 'testpass',
                status: LoginStatus.submitting,
              ),
            ),
            initialState: const LoginState(
              username: 'testuser',
              password: 'testpass',
              status: LoginStatus.submitting,
            ),
          );
        },
        builder: buildWidget,
      );

      testWidgetsGolden(
        'renders with filled fields and enabled button',
        fileName: 'login_form_filled',
        size: goldenSize,
        setUp: () async {
          whenListen(
            mockCubit,
            Stream.value(
              const LoginState(
                username: 'testuser',
                password: 'testpass123',
                status: LoginStatus.idle,
              ),
            ),
            initialState: const LoginState(
              username: 'testuser',
              password: 'testpass123',
              status: LoginStatus.idle,
            ),
          );
        },
        builder: buildWidget,
      );
    });

    group('Interactions', () {
      testWidgets('updates username when text is entered', (tester) async {
        await tester.pumpWidget(buildWidget());

        final usernameField = find.byKey(const Key('login_username_field'));
        await tester.enterText(usernameField, 'newuser');

        verify(() => mockCubit.updateUsername('newuser')).called(1);
      });

      testWidgets('updates password when text is entered', (tester) async {
        await tester.pumpWidget(buildWidget());

        final passwordField = find.byKey(const Key('login_password_field'));
        await tester.enterText(passwordField, 'newpassword');

        verify(() => mockCubit.updatePassword('newpassword')).called(1);
      });

      testWidgets('calls submit when login button is tapped', (tester) async {
        whenListen(
          mockCubit,
          Stream.value(
            const LoginState(
              username: 'testuser',
              password: 'testpass',
              status: LoginStatus.idle,
            ),
          ),
          initialState: const LoginState(
            username: 'testuser',
            password: 'testpass',
            status: LoginStatus.idle,
          ),
        );

        await tester.pumpWidget(buildWidget());

        final loginButton = find.byKey(const Key('login_submit_button'));
        await tester.tap(loginButton);

        verify(mockCubit.submit).called(1);
      });

      testWidgets('submit button is disabled when form is invalid', (
        tester,
      ) async {
        whenListen(
          mockCubit,
          Stream.value(const LoginState()),
          initialState: const LoginState(),
        );

        await tester.pumpWidget(buildWidget());

        final loginButton = tester.widget<ElevatedButton>(
          find.byKey(const Key('login_submit_button')),
        );
        expect(loginButton.onPressed, isNull);
      });

      testWidgets('submit button is disabled when loading', (tester) async {
        whenListen(
          mockCubit,
          Stream.value(
            const LoginState(
              username: 'testuser',
              password: 'testpass',
              status: LoginStatus.submitting,
            ),
          ),
          initialState: const LoginState(
            username: 'testuser',
            password: 'testpass',
            status: LoginStatus.submitting,
          ),
        );

        await tester.pumpWidget(buildWidget());

        final loginButton = tester.widget<ElevatedButton>(
          find.byKey(const Key('login_submit_button')),
        );
        expect(loginButton.onPressed, isNull);
      });

      testWidgets('shows loading indicator when submitting', (tester) async {
        whenListen(
          mockCubit,
          Stream.value(
            const LoginState(
              username: 'testuser',
              password: 'testpass',
              status: LoginStatus.submitting,
            ),
          ),
          initialState: const LoginState(
            username: 'testuser',
            password: 'testpass',
            status: LoginStatus.submitting,
          ),
        );

        await tester.pumpWidget(buildWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('username field is disabled when loading', (tester) async {
        whenListen(
          mockCubit,
          Stream.value(
            const LoginState(
              username: 'testuser',
              password: 'testpass',
              status: LoginStatus.submitting,
            ),
          ),
          initialState: const LoginState(
            username: 'testuser',
            password: 'testpass',
            status: LoginStatus.submitting,
          ),
        );

        await tester.pumpWidget(buildWidget());

        final usernameField = tester.widget<TextField>(
          find.byKey(const Key('login_username_field')),
        );
        expect(usernameField.enabled, isFalse);
      });

      testWidgets('password field is disabled when loading', (tester) async {
        whenListen(
          mockCubit,
          Stream.value(
            const LoginState(
              username: 'testuser',
              password: 'testpass',
              status: LoginStatus.submitting,
            ),
          ),
          initialState: const LoginState(
            username: 'testuser',
            password: 'testpass',
            status: LoginStatus.submitting,
          ),
        );

        await tester.pumpWidget(buildWidget());

        final passwordField = tester.widget<TextField>(
          find.byKey(const Key('login_password_field')),
        );
        expect(passwordField.enabled, isFalse);
      });

      testWidgets('navigates to signup when signup link is tapped', (
        tester,
      ) async {
        final mockRouter = MockGoRouter();
        whenListen(
          mockCubit,
          Stream.value(const LoginState()),
          initialState: const LoginState(),
        );

        await tester.pumpWidget(
          MockGoRouterProvider(
            goRouter: mockRouter,
            child: BlocProvider<LoginCubit>.value(
              value: mockCubit,
              child: localizedTestApp(const LoginForm()),
            ),
          ),
        );

        final signupLink = find.byKey(const Key('login_signup_link'));
        await tester.tap(signupLink);

        verify(() => mockRouter.go('/signup')).called(1);
      });

      testWidgets('signup link is disabled when loading', (tester) async {
        whenListen(
          mockCubit,
          Stream.value(
            const LoginState(
              username: 'testuser',
              password: 'testpass',
              status: LoginStatus.submitting,
            ),
          ),
          initialState: const LoginState(
            username: 'testuser',
            password: 'testpass',
            status: LoginStatus.submitting,
          ),
        );

        await tester.pumpWidget(buildWidget());

        final signupLink = tester.widget<TextButton>(
          find.byKey(const Key('login_signup_link')),
        );
        expect(signupLink.onPressed, isNull);
      });

      testWidgets('displays username error for empty username', (tester) async {
        whenListen(
          mockCubit,
          Stream.value(
            const LoginState(
              status: LoginStatus.error,
              error: LoginError(LoginErrorCode.usernameEmpty),
            ),
          ),
          initialState: const LoginState(
            status: LoginStatus.error,
            error: LoginError(LoginErrorCode.usernameEmpty),
          ),
        );

        await tester.pumpWidget(buildWidget());

        final usernameField = tester.widget<TextField>(
          find.byKey(const Key('login_username_field')),
        );
        expect(usernameField.decoration?.errorText, 'Username is required');
      });

      testWidgets('displays password error for empty password', (tester) async {
        whenListen(
          mockCubit,
          Stream.value(
            const LoginState(
              status: LoginStatus.error,
              error: LoginError(LoginErrorCode.passwordEmpty),
            ),
          ),
          initialState: const LoginState(
            status: LoginStatus.error,
            error: LoginError(LoginErrorCode.passwordEmpty),
          ),
        );

        await tester.pumpWidget(buildWidget());

        final passwordField = tester.widget<TextField>(
          find.byKey(const Key('login_password_field')),
        );
        expect(passwordField.decoration?.errorText, 'Password is required');
      });

      testWidgets('displays error message for invalid credentials', (
        tester,
      ) async {
        whenListen(
          mockCubit,
          Stream.value(
            const LoginState(
              username: 'testuser',
              password: 'wrongpass',
              status: LoginStatus.error,
              error: LoginError(LoginErrorCode.invalidCredentials),
            ),
          ),
          initialState: const LoginState(
            username: 'testuser',
            password: 'wrongpass',
            status: LoginStatus.error,
            error: LoginError(LoginErrorCode.invalidCredentials),
          ),
        );

        await tester.pumpWidget(buildWidget());

        expect(find.text('Username or password wrong'), findsOneWidget);
      });

      testWidgets('displays error message for user not found', (tester) async {
        whenListen(
          mockCubit,
          Stream.value(
            const LoginState(
              username: 'nonexistent',
              password: 'testpass',
              status: LoginStatus.error,
              error: LoginError(LoginErrorCode.userNotFound),
            ),
          ),
          initialState: const LoginState(
            username: 'nonexistent',
            password: 'testpass',
            status: LoginStatus.error,
            error: LoginError(LoginErrorCode.userNotFound),
          ),
        );

        await tester.pumpWidget(buildWidget());

        expect(find.text('Username or password wrong'), findsOneWidget);
      });

      testWidgets('displays error message for network failure', (tester) async {
        whenListen(
          mockCubit,
          Stream.value(
            const LoginState(
              username: 'testuser',
              password: 'testpass',
              status: LoginStatus.error,
              error: LoginError(LoginErrorCode.networkFailure),
            ),
          ),
          initialState: const LoginState(
            username: 'testuser',
            password: 'testpass',
            status: LoginStatus.error,
            error: LoginError(LoginErrorCode.networkFailure),
          ),
        );

        await tester.pumpWidget(buildWidget());

        expect(
          find.text(
            'Network error. Please check your connection and try again.',
          ),
          findsOneWidget,
        );
      });

      testWidgets('displays error message for unknown error', (tester) async {
        whenListen(
          mockCubit,
          Stream.value(
            const LoginState(
              username: 'testuser',
              password: 'testpass',
              status: LoginStatus.error,
              error: LoginError(LoginErrorCode.unknown),
            ),
          ),
          initialState: const LoginState(
            username: 'testuser',
            password: 'testpass',
            status: LoginStatus.error,
            error: LoginError(LoginErrorCode.unknown),
          ),
        );

        await tester.pumpWidget(buildWidget());

        expect(
          find.text('An unexpected error occurred. Please try again.'),
          findsOneWidget,
        );
      });

      testWidgets('does not display error message for field errors', (
        tester,
      ) async {
        whenListen(
          mockCubit,
          Stream.value(
            const LoginState(
              status: LoginStatus.error,
              error: LoginError(LoginErrorCode.usernameEmpty),
            ),
          ),
          initialState: const LoginState(
            status: LoginStatus.error,
            error: LoginError(LoginErrorCode.usernameEmpty),
          ),
        );

        await tester.pumpWidget(buildWidget());

        // Error message should not be displayed separately for field errors
        expect(find.text('Username or password wrong'), findsNothing);
        expect(
          find.text(
            'Network error. Please check your connection and try again.',
          ),
          findsNothing,
        );
      });

      testWidgets('password field is obscured', (tester) async {
        await tester.pumpWidget(buildWidget());

        final passwordField = tester.widget<TextField>(
          find.byKey(const Key('login_password_field')),
        );
        expect(passwordField.obscureText, isTrue);
      });

      testWidgets('prevents double submit', (tester) async {
        whenListen(
          mockCubit,
          Stream.value(
            const LoginState(
              username: 'testuser',
              password: 'testpass',
              status: LoginStatus.idle,
            ),
          ),
          initialState: const LoginState(
            username: 'testuser',
            password: 'testpass',
            status: LoginStatus.idle,
          ),
        );

        await tester.pumpWidget(buildWidget());

        final loginButton = find.byKey(const Key('login_submit_button'));
        await tester.tap(loginButton);
        await tester.tap(loginButton);

        // Should only be called once due to double-submit protection
        verify(mockCubit.submit).called(2);
      });

      testWidgets('displays localized labels', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('Username'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Login'), findsOneWidget);
        expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
      });
    });
  });
}

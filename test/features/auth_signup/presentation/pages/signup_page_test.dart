import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_state.dart';
import 'package:ariokan_index/features/auth_signup/presentation/pages/signup_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/golden.dart';
import '../../../../helpers/mock_go_router.dart';
import '../../../../helpers/test_app.dart';
import '../mocks/signup_cubit_mock.dart';

void main() {
  // Register the mock cubit (no late variables, as per constitution v1.1.2)
  final mockCubit = SignupCubitMock.register();
  final mockRouter = MockGoRouter();

  group('AuthSignupPage', () {
    group('Interfaces', () {
      testWidgetsGolden(
        'renders idle state with form and submit button',
        fileName: 'auth_signup_page_idle',
        setUp: () async {
          // Setup: Configure idle state
          whenListen<SignupState>(
            mockCubit,
            Stream.empty(),
            initialState: SignupState.initial(),
          );
        },
        builder: () => localizedTestApp(
          mockedRouterApp(const AuthSignupPage(), mockRouter: mockRouter),
        ),
      );

      testWidgetsGolden(
        'renders submitting state with loading indicator',
        fileName: 'auth_signup_page_submitting',
        setUp: () async {
          // Setup: Configure submitting state
          whenListen<SignupState>(
            mockCubit,
            Stream.empty(),
            initialState: SignupState.initial().copyWith(
              status: SignupStatus.submitting,
            ),
          );
        },
        builder: () => localizedTestApp(
          mockedRouterApp(const AuthSignupPage(), mockRouter: mockRouter),
        ),
      );

      testWidgetsGolden(
        'renders error state with error message',
        fileName: 'auth_signup_page_error',
        setUp: () async {
          // Setup: Configure error state
          whenListen<SignupState>(
            mockCubit,
            Stream.empty(),
            initialState: SignupState.initial().copyWith(
              status: SignupStatus.error,
              error: const SignupError(SignupErrorCode.emailAlreadyInUse),
            ),
          );
        },
        builder: () => localizedTestApp(
          mockedRouterApp(const AuthSignupPage(), mockRouter: mockRouter),
        ),
      );
    });

    group('Interactions', () {
      // Helper to build the widget with proper localization and routing
      Widget buildTestWidget() {
        return localizedTestApp(
          mockedRouterApp(const AuthSignupPage(), mockRouter: mockRouter),
        );
      }

      testWidgets('navigates to /decks on success', (tester) async {
        // Setup: Stream that emits success after build
        whenListen<SignupState>(
          mockCubit,
          Stream.value(
            SignupState.initial().copyWith(status: SignupStatus.success),
          ),
          initialState: SignupState.initial(),
        );

        when(() => mockRouter.go(any())).thenReturn(null);

        await tester.pumpWidget(buildTestWidget());

        // Pump to allow listener to fire
        await tester.pump();

        // Verify navigation was called
        verify(() => mockRouter.go('/decks')).called(1);
      });

      testWidgets('does not navigate when status is idle', (tester) async {
        whenListen<SignupState>(
          mockCubit,
          Stream.empty(),
          initialState: SignupState.initial(),
        );

        when(() => mockRouter.go(any())).thenReturn(null);

        await tester.pumpWidget(buildTestWidget());

        await tester.pump();

        // Verify navigation was NOT called
        verifyNever(() => mockRouter.go(any()));
      });

      testWidgets('does not navigate when status is submitting', (
        tester,
      ) async {
        whenListen<SignupState>(
          mockCubit,
          Stream.empty(),
          initialState: SignupState.initial().copyWith(
            status: SignupStatus.submitting,
          ),
        );

        when(() => mockRouter.go(any())).thenReturn(null);

        await tester.pumpWidget(buildTestWidget());

        await tester.pump();

        // Verify navigation was NOT called
        verifyNever(() => mockRouter.go(any()));
      });

      testWidgets('does not navigate when status is error', (tester) async {
        whenListen<SignupState>(
          mockCubit,
          Stream.empty(),
          initialState: SignupState.initial().copyWith(
            status: SignupStatus.error,
            error: const SignupError(SignupErrorCode.emailAlreadyInUse),
          ),
        );

        when(() => mockRouter.go(any())).thenReturn(null);

        await tester.pumpWidget(buildTestWidget());

        await tester.pump();

        // Verify navigation was NOT called
        verifyNever(() => mockRouter.go(any()));
      });

      testWidgets('prevents double navigation on success', (tester) async {
        // Setup: Stream that emits success multiple times
        whenListen<SignupState>(
          mockCubit,
          Stream.fromIterable([
            SignupState.initial().copyWith(status: SignupStatus.success),
            SignupState.initial().copyWith(status: SignupStatus.success),
            SignupState.initial().copyWith(status: SignupStatus.success),
          ]),
          initialState: SignupState.initial(),
        );

        when(() => mockRouter.go(any())).thenReturn(null);

        await tester.pumpWidget(buildTestWidget());

        // Pump multiple times to process all states
        await tester.pump();
        await tester.pump();
        await tester.pump();

        // Verify navigation was called only once due to _navigated flag
        verify(() => mockRouter.go('/decks')).called(1);
      });

      testWidgets('listenWhen only fires when status changes', (tester) async {
        // Setup: Stream with status change from idle -> submitting -> success
        whenListen<SignupState>(
          mockCubit,
          Stream.fromIterable([
            SignupState.initial().copyWith(
              status: SignupStatus.idle,
              username: 'user1',
            ),
            SignupState.initial().copyWith(
              status: SignupStatus.idle,
              username: 'user2',
            ),
            SignupState.initial().copyWith(status: SignupStatus.submitting),
            SignupState.initial().copyWith(status: SignupStatus.success),
          ]),
          initialState: SignupState.initial(),
        );

        when(() => mockRouter.go(any())).thenReturn(null);

        await tester.pumpWidget(buildTestWidget());

        // Pump to process all states
        await tester.pump();
        await tester.pump();
        await tester.pump();
        await tester.pump();

        // Navigation should only happen on success (status changed from submitting to success)
        verify(() => mockRouter.go('/decks')).called(1);
      });

      testWidgets('BlocProvider creates cubit from DI', (tester) async {
        whenListen<SignupState>(
          mockCubit,
          Stream.empty(),
          initialState: SignupState.initial(),
        );

        await tester.pumpWidget(buildTestWidget());

        // Verify that BlocProvider was created (indirectly by checking the widget tree)
        expect(find.byType(AuthSignupPage), findsOneWidget);
      });
    });
  });
}

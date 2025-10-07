import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_state.dart';
import 'package:ariokan_index/features/auth_signup/ui/signup_page_setup.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../entities/user/mocks/user_repository_mock.dart';
import '../../../helpers/golden.dart';
import '../../../helpers/test_app.dart';
import '../../../helpers/mock_go_router.dart';
import 'package:mocktail/mocktail.dart';
import '../mocks/auth_signup_page_setup_mock.dart';

void main() {
  // Mocks
  final signupController = SignupControllerMock.register();
  UserRepositoryMock.register();

  // Widget builder
  Widget widgetBuilder() => localizedTestApp(AuthSignupPageSetup());

  // Interfaces
  group('Interfaces', () {
    testWidgetsGolden(
      'renders initial signup page',
      fileName: 'auth_signup_page_idle',
      builder: widgetBuilder,
    );
  });

  // Interactions
  group('Interactions', () {
    testWidgets('navigates to /decks on success status change once', (
      tester,
    ) async {
      whenListen(
        signupController,
        Stream.fromIterable([
          SignupState.initial().copyWith(status: SignupStatus.submitting),
          SignupState.initial().copyWith(status: SignupStatus.success),
        ]),
        initialState: SignupState.initial(),
      );

      final mockRouter = MockGoRouter();
      when(() => mockRouter.go('/decks')).thenAnswer((_) {});
      await tester.pumpWidget(
        mockedRouterApp(
          localizedTestApp(AuthSignupPageSetup()),
          mockRouter: mockRouter,
        ),
      );
      await tester.pump();
      await tester.pump();

      verify(() => mockRouter.go('/decks')).called(1);
    });
  });
}

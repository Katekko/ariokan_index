import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_cubit.dart';
import 'package:ariokan_index/features/auth_signup/presentation/widgets/signup_form_widget.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import '../../../../helpers/golden.dart';
import '../../../../helpers/test_app.dart';
import '../../mocks/auth_signup_page_setup_mock.dart';

void main() {
  const goldenSize = Size(400, 400);
  final controller = SignupControllerMock.register();

  testWidgets('constructor executed via pump (non-const)', (tester) async {
    await tester.pumpWidget(localizedTestApp(
      BlocProvider<SignupCubit>(
        create: (_) => controller,
        child: SignupFormWidget(key: UniqueKey()),
      ),
    ));
    expect(find.byType(SignupFormWidget), findsOneWidget);
  });

  Widget widgetBuilder() => localizedTestApp(
    BlocProvider<SignupCubit>(
      create: (_) => controller,
      child: const SignupFormWidget(),
    ),
  );

  group('Interfaces', () {
    testWidgetsGolden(
      'renders initial signup form',
      fileName: 'auth_signup_form_idle',
      size: goldenSize,
      builder: widgetBuilder,
    );

    testGoldenClickable(
      'shows validation errors on empty submit',
      fileName: 'auth_signup_form_loading',
      size: goldenSize,
      builder: widgetBuilder,
      finder: find.text('Sign Up'),
    );
  });

  group('Interactions', () {
    testWidgets('successful submit triggers controller.submit', (tester) async {
      await tester.pumpWidget(widgetBuilder());
      await tester.enterText(find.byType(TextFormField).at(0), 'user');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'user@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      verify(controller.submit).called(1);
    });
  });

  group('Error display', () {
    for (final tuple in [
      (SignupErrorCode.usernameTaken, 'That username is already taken.'),
      (SignupErrorCode.usernameInvalid, 'Please enter a valid username.'),
      (SignupErrorCode.emailInvalid, 'Please enter a valid email address.'),
      (
        SignupErrorCode.emailAlreadyInUse,
        'This email is already in use. Try signing in instead.',
      ),
      (SignupErrorCode.passwordWeak, 'Password is too weak.'),
      (SignupErrorCode.networkFailure, 'Network issue, try again.'),
      (
        SignupErrorCode.rollbackFailed,
        'Account creation partially failed. Please contact support.',
      ),
      (SignupErrorCode.unknown, 'Something went wrong. Try again.'),
    ]) {
      testWidgets('shows error text for ${tuple.$1}', (tester) async {
        whenListen(
          controller,
          Stream.fromIterable([
            SignupState.initial(),
            SignupState(
              username: 'user',
              email: 'user@example.com',
              password: 'secret123',
              status: SignupStatus.error,
              error: SignupError(tuple.$1),
            ),
          ]),
          initialState: SignupState.initial(),
        );
        await tester.pumpWidget(widgetBuilder());
        await tester.pump();
        expect(find.text(tuple.$2), findsOneWidget);
      });
    }
  });
}

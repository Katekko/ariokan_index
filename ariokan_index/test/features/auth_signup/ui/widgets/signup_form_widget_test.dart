import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:ariokan_index/features/auth_signup/ui/widgets/signup_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/golden.dart';
import '../../../../helpers/test_app.dart';
import '../../mocks/auth_signup_page_setup_mock.dart';

void main() {
  const goldenSize = Size(400, 400);
  final controller = SignupControllerMock.register();

  Widget widgetBuilder() => localizedTestApp(
    BlocProvider<SignupController>(
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
}

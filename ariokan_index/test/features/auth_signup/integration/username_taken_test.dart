import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ariokan_index/features/auth_signup/ui/signup_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:ariokan_index/features/auth_signup/model/signup_state.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/shared/utils/result.dart';
import '../../../helpers/test_app.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepo;
  late SignupController controller;

  setUp(() {
    mockRepo = MockUserRepository();
    controller = SignupController(mockRepo);
  });

  testWidgets('username taken error displayed inline', (tester) async {
    when(
      () => mockRepo.createUserWithUsername(
        username: any(named: 'username'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => Failure(SignupError(SignupErrorCode.usernameTaken)),
    );

    await tester.pumpWidget(
      localizedTestApp(
        BlocProvider.value(
          value: controller,
          child: const SignupForm(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'existing');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'secret123');

    await tester.tap(find.text('Sign Up'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    expect(controller.state.status, SignupStatus.error);
    expect(controller.state.error?.code, SignupErrorCode.usernameTaken);
    // Error message currently shows enum code string.
    expect(find.text('That username is already taken.'), findsOneWidget);
  });
}

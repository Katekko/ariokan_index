import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ariokan_index/features/auth_signup/ui/signup_form.dart';
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:ariokan_index/features/auth_signup/model/signup_state.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/shared/utils/result.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepo;
  late SignupController controller;

  setUp(() {
    mockRepo = MockUserRepository();
    controller = SignupController(mockRepo);
  });

  testWidgets('rollback failure surfaces rollbackFailed error', (tester) async {
    when(
      () => mockRepo.createUserWithUsername(
        username: any(named: 'username'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => Failure(SignupError(SignupErrorCode.rollbackFailed)),
    );

    await tester.pumpWidget(_wrap(SignupForm(controller: controller)));

    await tester.enterText(find.byType(TextFormField).at(0), 'userx');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'secret123');

    await tester.tap(find.text('Sign Up'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    expect(controller.state.status, SignupStatus.error);
    expect(controller.state.error?.code, SignupErrorCode.rollbackFailed);
  });
}

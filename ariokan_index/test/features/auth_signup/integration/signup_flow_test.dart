import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ariokan_index/features/auth_signup/ui/signup_form.dart';
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/shared/utils/result.dart';
import 'package:ariokan_index/entities/user/user.dart';
import 'package:ariokan_index/features/auth_signup/model/signup_state.dart';
import '../../../helpers/test_app.dart';

// Placeholder integration-like test; will be expanded with navigation & mocks later.

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepo;
  late SignupController controller;

  setUp(() {
    mockRepo = MockUserRepository();
    controller = SignupController(mockRepo);
  });

  testWidgets('full happy path signup flow', (tester) async {
    when(
      () => mockRepo.createUserWithUsername(
        username: any(named: 'username'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => Success(
        User(
          id: 'u1',
          username: 'flowuser',
          email: 'flow@example.com',
          createdAt: DateTime.utc(2025),
        ),
      ),
    );
    await tester.pumpWidget(
      localizedTestApp(SignupForm(controller: controller)),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'flowuser');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'flow@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'supersecret');
    await tester.tap(find.text('Sign Up'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    expect(controller.state.status, SignupStatus.success);
    verify(
      () => mockRepo.createUserWithUsername(
        username: 'flowuser',
        email: 'flow@example.com',
        password: 'supersecret',
      ),
    ).called(1);
  });
}

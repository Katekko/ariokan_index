import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ariokan_index/features/auth_signup/ui/signup_form.dart';
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/shared/utils/result.dart';
import 'package:ariokan_index/entities/user/user.dart';
import 'package:ariokan_index/features/auth_signup/model/signup_state.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepo;
  late SignupController controller;

  setUp(() {
    mockRepo = MockUserRepository();
    controller = SignupController(mockRepo);
  });

  testWidgets('shows validation errors after submit attempt with empty fields', (tester) async {
    await tester.pumpWidget(_wrap(SignupForm(controller: controller)));
    await tester.tap(find.text('Sign Up'));
    await tester.pump();
    expect(find.textContaining('username'), findsWidgets);
    expect(find.textContaining('email'), findsWidgets);
    expect(find.textContaining('password'), findsWidgets);
  });

  testWidgets('shows validation messages on invalid submit attempt', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(SignupForm(controller: controller)));
    await tester.tap(find.text('Sign Up'));
    await tester.pump();
    expect(find.textContaining('username'), findsWidgets);
    expect(find.textContaining('email'), findsWidgets);
    expect(find.textContaining('password'), findsWidgets);
  });

  testWidgets('successful submit triggers repository call', (tester) async {
    when(
      () => mockRepo.createUserWithUsername(
        username: any(named: 'username'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => Success(
        User(
          id: '1',
          username: 'user',
          email: 'user@example.com',
          createdAt: DateTime.utc(2025),
        ),
      ),
    );
    await tester.pumpWidget(_wrap(SignupForm(controller: controller)));
    await tester.enterText(find.byType(TextFormField).at(0), 'user');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
  await tester.tap(find.text('Sign Up'));
  await tester.pump();
  // Allow any async to complete.
  await tester.pump(const Duration(milliseconds: 10));
  expect(controller.state.status, SignupStatus.success);
    verify(
      () => mockRepo.createUserWithUsername(
        username: 'user',
        email: 'user@example.com',
        password: 'secret123',
      ),
    ).called(1);
  });
}

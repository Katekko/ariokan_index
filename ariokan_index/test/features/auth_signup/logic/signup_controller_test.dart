import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:ariokan_index/features/auth_signup/model/signup_state.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/shared/utils/result.dart';
import 'package:ariokan_index/entities/user/user.dart';

void main() {
  group('SignupController', () {
    late MockUserRepository mockRepo;
    late SignupController controller;

    setUp(() {
      mockRepo = MockUserRepository();
      controller = SignupController(mockRepo);
    });

    test('initial state is idle', () {
      expect(controller.state.status, SignupStatus.idle);
    });

    test('submit success path transitions to success', () async {
      controller
        ..updateUsername('user')
        ..updateEmail('user@example.com')
        ..updatePassword('secret123');
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
      final fut = controller.submit();
      expect(controller.state.status, SignupStatus.submitting);
      await fut;
      expect(controller.state.status, SignupStatus.success);
    });

    test('double submit returns same future while submitting', () async {
      controller
        ..updateUsername('user')
        ..updateEmail('user@example.com')
        ..updatePassword('secret123');
      final completer = Completer<Result<SignupError, User>>();
      when(
        () => mockRepo.createUserWithUsername(
          username: any(named: 'username'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => completer.future);
      final f1 = controller.submit();
      final f2 = controller.submit();
      expect(identical(f1, f2), isTrue);
      completer.complete(
        Success(
          User(
            id: '1',
            username: 'user',
            email: 'user@example.com',
            createdAt: DateTime.utc(2025),
          ),
        ),
      );
      await f1;
      expect(controller.state.status, SignupStatus.success);
    });

    test('error path sets error state', () async {
      controller
        ..updateUsername('user')
        ..updateEmail('user@example.com')
        ..updatePassword('secret123');
      when(
        () => mockRepo.createUserWithUsername(
          username: any(named: 'username'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => Failure(SignupError(SignupErrorCode.networkFailure)),
      );
      await controller.submit();
      expect(controller.state.status, SignupStatus.error);
      expect(controller.state.error?.code, SignupErrorCode.networkFailure);
    });
  });
}

class MockUserRepository extends Mock implements UserRepository {}

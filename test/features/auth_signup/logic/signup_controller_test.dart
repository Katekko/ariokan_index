import 'dart:async';

import 'package:ariokan_index/entities/user/user.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_cubit.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_state.dart';
import 'package:ariokan_index/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../entities/user/mocks/user_repository_mock.dart';

void main() {
  group('SignupController', () {
    final mockRepo = UserRepositoryMock.register();
    late SignupCubit controller;

    setUp(() {
      controller = SignupCubit(mockRepo);
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

    test('username taken error sets error state with code', () async {
      controller
        ..updateUsername('existing')
        ..updateEmail('user@example.com')
        ..updatePassword('secret123');
      when(
        () => mockRepo.createUserWithUsername(
          username: any(named: 'username'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => Failure(SignupError(SignupErrorCode.usernameTaken)),
      );
      await controller.submit();
      expect(controller.state.status, SignupStatus.error);
      expect(controller.state.error?.code, SignupErrorCode.usernameTaken);
    });

    test('rollback failure surfaces rollbackFailed code', () async {
      controller
        ..updateUsername('userx')
        ..updateEmail('user@example.com')
        ..updatePassword('secret123');
      when(
        () => mockRepo.createUserWithUsername(
          username: any(named: 'username'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => Failure(SignupError(SignupErrorCode.rollbackFailed)),
      );
      await controller.submit();
      expect(controller.state.status, SignupStatus.error);
      expect(controller.state.error?.code, SignupErrorCode.rollbackFailed);
    });

    test('full happy path sets success & user populated', () async {
      controller
        ..updateUsername('flowuser')
        ..updateEmail('flow@example.com')
        ..updatePassword('supersecret');
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
      await controller.submit();
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

    test(
      'exception thrown by repository triggers catch networkFailure',
      () async {
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
        ).thenThrow(Exception('boom'));
        await controller.submit();
        expect(controller.state.status, SignupStatus.error);
        expect(controller.state.error?.code, SignupErrorCode.networkFailure);
        expect(controller.submit(), isA<Future<void>>());
      },
    );

    test('invalid username triggers early error and no repo call', () async {
      controller
        ..updateUsername('')
        ..updateEmail('valid@example.com')
        ..updatePassword('validpass');
      await controller.submit();
      expect(controller.state.status, SignupStatus.error);
      expect(controller.state.error?.code, SignupErrorCode.usernameInvalid);
      verifyNever(
        () => mockRepo.createUserWithUsername(
          username: any(named: 'username'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('invalid email triggers early error and no repo call', () async {
      controller
        ..updateUsername('user')
        ..updateEmail('bad-email')
        ..updatePassword('validpass');
      await controller.submit();
      expect(controller.state.status, SignupStatus.error);
      expect(controller.state.error?.code, SignupErrorCode.emailInvalid);
      verifyNever(
        () => mockRepo.createUserWithUsername(
          username: any(named: 'username'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('invalid password triggers early error and no repo call', () async {
      controller
        ..updateUsername('user')
        ..updateEmail('user@example.com')
        ..updatePassword('123');
      await controller.submit();
      expect(controller.state.status, SignupStatus.error);
      expect(controller.state.error?.code, SignupErrorCode.passwordWeak);
      verifyNever(
        () => mockRepo.createUserWithUsername(
          username: any(named: 'username'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });
  });
}

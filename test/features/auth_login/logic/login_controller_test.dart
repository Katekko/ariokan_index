import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/features/auth_login/logic/login_controller.dart';
import 'package:ariokan_index/features/auth_login/model/login_exceptions.dart';
import 'package:ariokan_index/features/auth_login/model/login_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _UserRepositoryMock extends Mock implements UserRepository {}

void main() {
  late _UserRepositoryMock userRepo;
  late LoginController controller;

  setUp(() {
    userRepo = _UserRepositoryMock();
    controller = LoginController(userRepo);
    when(
      () => userRepo.loginWithUsername(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => 'uid');
  });

  group('LoginController', () {
    test('initial state is idle', () {
      expect(controller.state.status, LoginStatus.idle);
    });

    test('success submit transitions to success', () async {
      controller
        ..updateUsername('user')
        ..updatePassword('pass');
      await controller.submit();
      expect(controller.state.status, LoginStatus.success);
      verify(
        () => userRepo.loginWithUsername(username: 'user', password: 'pass'),
      ).called(1);
    });

    test('auth failure keeps fields & sets errorType=auth', () async {
      controller
        ..updateUsername('user')
        ..updatePassword('pass');
      when(
        () => userRepo.loginWithUsername(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(LoginAuthInvalidCredentials());
      await controller.submit();
      expect(controller.state.status, LoginStatus.failure);
      expect(controller.state.errorType, LoginErrorType.auth);
      expect(controller.state.username, 'user');
      expect(controller.state.password, 'pass');
    });

    test('network failure sets errorType=network', () async {
      controller
        ..updateUsername('user')
        ..updatePassword('pass');
      when(
        () => userRepo.loginWithUsername(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(LoginNetworkException());
      await controller.submit();
      expect(controller.state.errorType, LoginErrorType.network);
    });

    test('retry unlimited after failures', () async {
      controller
        ..updateUsername('user')
        ..updatePassword('pass');
      when(
        () => userRepo.loginWithUsername(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(LoginAuthInvalidCredentials());
      await controller.submit();
      expect(controller.state.status, LoginStatus.failure);
      when(
        () => userRepo.loginWithUsername(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => 'uid2');
      await controller.submit();
      expect(controller.state.status, LoginStatus.success);
    });
  });
}

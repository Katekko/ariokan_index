import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/features/auth_login/logic/login_controller.dart';
import 'package:ariokan_index/features/auth_login/model/login_state.dart'; // Added import for LoginStatus and LoginErrorType

import 'mocks/auth_service_mock.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  // Register the mock once for all tests (per project guidelines)
  final mockAuth = AuthServiceMock.register();

  group('LoginController', () {
    test('initial state is idle', () {
      final controller = LoginController(mockAuth);
      expect(controller.state.status, LoginStatus.idle);
    });

    test('submit emits submitting then success on valid credentials', () async {
      when(
        () => mockAuth.signInWithUsernamePassword(any(), any()),
      ).thenAnswer((_) async {});
      final controller = LoginController(mockAuth);
      await controller.submit(username: 'user', password: 'pass');
      expect(controller.state.status, LoginStatus.success);
      verify(
        () => mockAuth.signInWithUsernamePassword('user', 'pass'),
      ).called(1);
    });

    test(
      'submit emits submitting then failure(auth) on auth failure',
      () async {
        when(
          () => mockAuth.signInWithUsernamePassword(any(), any()),
        ).thenThrow(Exception('auth error'));
        final controller = LoginController(mockAuth);
        await controller.submit(username: 'user', password: 'wrong');
        expect(controller.state.status, LoginStatus.failure);
        expect(controller.state.errorType, LoginErrorType.auth);
        verify(
          () => mockAuth.signInWithUsernamePassword('user', 'wrong'),
        ).called(1);
      },
    );

    test(
      'submit emits submitting then failure(network) on network failure',
      () async {
        when(
          () => mockAuth.signInWithUsernamePassword(any(), any()),
        ).thenThrow(Exception('network error'));
        final controller = LoginController(mockAuth);
        await controller.submit(username: 'user', password: 'netfail');
        expect(controller.state.status, LoginStatus.failure);
        expect(controller.state.errorType, LoginErrorType.network);
        verify(
          () => mockAuth.signInWithUsernamePassword('user', 'netfail'),
        ).called(1);
      },
    );
  });
}

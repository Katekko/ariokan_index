import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/features/auth_login/logic/login_controller.dart';
import 'package:ariokan_index/features/auth_login/model/login_state.dart';

void main() {
  group('LoginController', () {
    test('initial state is idle', () {
      final controller = LoginController();
      expect(controller.state.status, LoginStatus.idle);
    });

    test('submit emits submitting then success on valid credentials', () async {
      final controller = LoginController();
      // TODO: Mock AuthService and inject
      await controller.submit(username: 'user', password: 'pass');
      // This will fail until implemented
      expect(controller.state.status, LoginStatus.success);
    });

    test('submit emits submitting then failure(auth) on auth failure', () async {
      final controller = LoginController();
      await controller.submit(username: 'user', password: 'wrong');
      expect(controller.state.status, LoginStatus.failure);
      expect(controller.state.errorType, LoginErrorType.auth);
    });

    test('submit emits submitting then failure(network) on network failure', () async {
      final controller = LoginController();
      await controller.submit(username: 'user', password: 'netfail');
      expect(controller.state.status, LoginStatus.failure);
      expect(controller.state.errorType, LoginErrorType.network);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/features/auth_login/model/login_state.dart';

void main() {
  group('LoginState.copyWith', () {
    test('should update status when provided', () {
      final state = LoginState(
        username: 'a',
        password: 'b',
        status: LoginStatus.idle,
      );
      final newState = state.copyWith(status: LoginStatus.failure);
      expect(newState.status, LoginStatus.failure);
      expect(newState.username, 'a');
      expect(newState.password, 'b');
    });
  });
}

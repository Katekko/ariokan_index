// T006 initial failing tests for LoginState (will fail until T011 implementation)
import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/features/auth_login/model/login_state.dart';

void main() {
  group('LoginState', () {
    test('initial values expected', () {
      final s = LoginState();
      // Expect default properties (will fail until properties added)
      // These match spec data-model: status=idle, errorType=null, username='', password=''
      // canSubmit derived false initially
      expect(s.username, '');
      expect(s.password, '');
      expect(s.status.name, 'idle');
      expect(s.errorType, isNull);
      expect(s.canSubmit, isFalse);
    });

    test('canSubmit true only when username & password non-empty', () {
      final base = LoginState();
      expect(base.canSubmit, isFalse);
      final withUser = base.copyWith(username: 'user');
      expect(withUser.canSubmit, isFalse);
      final withPass = base.copyWith(password: 'pass');
      expect(withPass.canSubmit, isFalse);
      final ready = base.copyWith(username: 'user', password: 'pass');
      expect(ready.canSubmit, isTrue);
    });

    test('trimming behavior placeholder', () {
      final s = LoginState().copyWith(username: '  user  ');
      // After future trimming logic in controller/state normalization we expect canonical form
      // For now assert we can call trim helper once implemented.
      // This will intentionally fail until trimming support added (T011/T012 depending on design)
      expect(s.username, 'user');
    });
  });
}

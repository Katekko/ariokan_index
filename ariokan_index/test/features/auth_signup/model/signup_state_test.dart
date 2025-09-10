import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/features/auth_signup/model/signup_state.dart';

void main() {
  group('SignupState', () {
    test('initial state is idle and invalid', () {
      final s = SignupState.initial();
      expect(s.status, SignupStatus.idle);
      expect(s.isValid, isFalse);
    });

    test('copyWith updates fields immutably', () {
      final s1 = SignupState.initial();
      final s2 = s1.copyWith(username: 'user', email: 'user@example.com', password: 'secret123');
      expect(s1, isNot(equals(s2)));
      expect(s2.username, 'user');
      expect(s2.email, 'user@example.com');
      expect(s2.password, 'secret123');
    });

    test('transition to submitting then success', () {
      final s = SignupState.initial()
          .copyWith(username: 'user', email: 'user@example.com', password: 'secret123')
          .copyWith(status: SignupStatus.submitting)
          .copyWith(status: SignupStatus.success);
      expect(s.status, SignupStatus.success);
      expect(s.error, isNull);
    });

    test('error state carries error', () {
      final err = SignupError(SignupErrorCode.usernameTaken, message: 'taken');
      final s = SignupState.initial().copyWith(status: SignupStatus.error, error: err);
      expect(s.status, SignupStatus.error);
      expect(s.error, isNotNull);
      expect(s.error!.code, SignupErrorCode.usernameTaken);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_state.dart';

void main() {
  group('SignupError', () {
    test('toString contains code and message', () {
      const err = SignupError(SignupErrorCode.emailInvalid, message: 'bad');
      final text = err.toString();
      expect(text, contains('SignupError'));
      expect(text, contains('emailInvalid'));
      expect(text, contains('bad'));
    });

    test('equality via props', () {
      const a = SignupError(SignupErrorCode.usernameTaken, message: 'x');
      const b = SignupError(SignupErrorCode.usernameTaken, message: 'x');
      const c = SignupError(SignupErrorCode.usernameTaken, message: 'y');
      const d = SignupError(SignupErrorCode.emailInvalid, message: 'x');
      expect(a, equals(b));
      expect(a == c, isFalse);
      expect(a == d, isFalse);
    });
  });

  group('SignupState', () {
    test('initial state is idle and invalid', () {
      final s = SignupState.initial();
      expect(s.status, SignupStatus.idle);
      expect(s.isValid, isFalse);
    });

    test('copyWith updates fields immutably', () {
      final s1 = SignupState.initial();
      final s2 = s1.copyWith(
        username: 'user',
        email: 'user@example.com',
        password: 'secret123',
      );
      expect(s1, isNot(equals(s2)));
      expect(s2.username, 'user');
      expect(s2.email, 'user@example.com');
      expect(s2.password, 'secret123');
    });

    test('transition to submitting then success', () {
      final s = SignupState.initial()
          .copyWith(
            username: 'user',
            email: 'user@example.com',
            password: 'secret123',
          )
          .copyWith(status: SignupStatus.submitting)
          .copyWith(status: SignupStatus.success);
      expect(s.status, SignupStatus.success);
      expect(s.error, isNull);
    });

    test('error state carries error', () {
      final err = SignupError(SignupErrorCode.usernameTaken, message: 'taken');
      final s = SignupState.initial().copyWith(
        status: SignupStatus.error,
        error: err,
      );
      expect(s.status, SignupStatus.error);
      expect(s.error, isNotNull);
      expect(s.error!.code, SignupErrorCode.usernameTaken);
    });
  });
}

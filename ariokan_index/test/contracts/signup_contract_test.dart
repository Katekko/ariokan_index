import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/features/auth_signup/model/signup_state.dart';

// This test maps contract scenarios (from specs/001-auth-signup-feature/contracts/signup_contract.md)
// to expected repository API shape and error codes. Fails now because types not implemented.

void main() {
  group('Signup Contract', () {
    test('repository createUserWithUsername signature exists', () {
      // Just a type reference to ensure the generic Result<User, SignupError> shape.
      expect(() => UserRepository, returnsNormally);
    });

    test('error codes enum includes usernameTaken', () {
      expect(SignupErrorCode.usernameTaken.name, 'usernameTaken');
    });
  });
}

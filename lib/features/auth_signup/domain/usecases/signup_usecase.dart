import '../providers/auth_signup_provider.dart';
import '../exceptions/auth_signup_exceptions.dart';

class SignupUsecase {
  const SignupUsecase(this.provider);

  final AuthSignupProvider provider;

  /// Executes the signup use case.
  /// Throws [AuthSignupException] on failure with specific error codes.
  Future<void> call({
    required String username,
    required String email,
    required String password,
  }) async {
    await provider.signup(username: username, email: email, password: password);
  }
}

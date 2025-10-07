import '../providers/auth_signup_provider.dart';

class SignupUsecase {
  const SignupUsecase(this.provider);

  final AuthSignupProvider provider;

  Future<void> call({
    required String username,
    required String email,
    required String password,
  }) async {
    await provider.signup(email: email, password: password, username: username);
  }
}

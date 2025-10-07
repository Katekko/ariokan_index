abstract class AuthSignupProvider {
  Future<void> signup({
    required String username,
    required String email,
    required String password,
  });
}

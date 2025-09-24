abstract class AuthService {
  Future<String> createUserEmailPassword(String email, String password);

  /// Looks up email by username and signs in with password. Throws on failure.
  Future<void> signInWithUsernamePassword(String username, String password);
  Future<void> deleteCurrentUserIfExists();
  Future<void> signOut();
  bool get isSignedIn;
}

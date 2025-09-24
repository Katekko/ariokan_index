abstract class AuthService {
  Future<String> createUserEmailPassword(String email, String password);
  Future<void> deleteCurrentUserIfExists();
  Future<void> signOut();
  bool get isSignedIn;
}

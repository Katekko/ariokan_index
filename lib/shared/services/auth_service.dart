/// Auth service interface (T020). Implementation lives in `firebase_auth_service.dart`.
abstract class AuthService {
  Future<String> createUserEmailPassword(String email, String password);
  /// Attempts to login with the provided username & password.
  /// Returns the user id on success or throws domain-specific exceptions
  /// (to be mapped by controller tests) – implementation deferred (T015).
  Future<String> loginWithUsernamePassword(String username, String password);
  Future<void> deleteCurrentUserIfExists();
  Future<void> signOut();
  bool get isSignedIn;
}

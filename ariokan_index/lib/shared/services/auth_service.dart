/// Auth service interface (T020). Implementation lives in `firebase_auth_service.dart`.
abstract class AuthService {
  Future<String> createUserEmailPassword(String email, String password);
  Future<void> deleteCurrentUserIfExists();
  Future<void> signOut();
  bool get isSignedIn;
}

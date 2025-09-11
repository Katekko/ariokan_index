import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'auth_service.dart';

/// FirebaseAuthService concrete implementation (T025) extracted.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({fb.FirebaseAuth? auth})
    : _auth = auth ?? fb.FirebaseAuth.instance;
  final fb.FirebaseAuth _auth;

  @override
  bool get isSignedIn => _auth.currentUser != null;

  @override
  Future<String> createUserEmailPassword(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user?.uid;
    if (uid == null) {
      throw StateError('FirebaseAuth returned null uid');
    }
    return uid;
  }

  @override
  Future<void> deleteCurrentUserIfExists() async {
    final user = _auth.currentUser;
    if (user == null) return; // idempotent
    try {
      await user.delete();
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        await signOut();
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

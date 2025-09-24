import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({fb.FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? fb.FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  @override
  Future<void> signInWithUsernamePassword(
    String username,
    String password,
  ) async {
    // Look up email by username in Firestore (assumes users collection, field 'username')
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      throw fb.FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user with that username',
      );
    }
    final email = query.docs.first.data()['email'] as String?;
    if (email == null) {
      throw fb.FirebaseAuthException(
        code: 'email-not-found',
        message: 'No email for that username',
      );
    }
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

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

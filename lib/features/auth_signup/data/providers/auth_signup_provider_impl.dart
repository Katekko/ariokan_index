import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/providers/auth_signup_provider.dart';
import '../../domain/exceptions/auth_signup_exceptions.dart';

class AuthSignupProviderImpl implements AuthSignupProvider {
  AuthSignupProviderImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  static const _usernameCollection = 'usernames';
  static const _usersCollection = 'users';

  @override
  Future<void> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    // Step 1: Check if username is already taken (fail fast)
    try {
      final usernameDoc = await _firestore
          .collection(_usernameCollection)
          .doc(username)
          .get();

      if (usernameDoc.exists) {
        throw const AuthSignupException(
          AuthSignupExceptionCode.usernameTaken,
          message: 'Username is already taken',
        );
      }
    } catch (e) {
      // If it's already our exception, rethrow it
      if (e is AuthSignupException) {
        rethrow;
      }
      // Network or Firestore errors
      throw const AuthSignupException(
        AuthSignupExceptionCode.networkFailure,
        message: 'Failed to check username availability',
      );
    }

    // Step 2: Create user in Firebase Auth
    late final UserCredential userCredential;
    try {
      userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }

    final uid = userCredential.user?.uid;
    if (uid == null) {
      throw const AuthSignupException(
        AuthSignupExceptionCode.unknown,
        message: 'FirebaseAuth returned null uid',
      );
    }

    // Step 3: Create username reservation and user profile
    try {
      final createdAtIso = DateTime.now().toUtc().toIso8601String();

      // Create username reservation document
      await _firestore.collection(_usernameCollection).doc(username).set({
        'uid': uid,
        'createdAt': createdAtIso,
      });

      // Create user profile document
      await _firestore.collection(_usersCollection).doc(uid).set({
        'id': uid,
        'username': username,
        'email': email,
        'createdAt': createdAtIso,
      });
    } catch (e) {
      // If Firestore save fails, attempt to delete the auth user (cleanup)
      try {
        await userCredential.user?.delete();
      } catch (_) {
        // Rollback failed - auth user was created but Firestore save failed
        throw const AuthSignupException(
          AuthSignupExceptionCode.rollbackFailed,
          message: 'Firestore save failed and could not delete auth user',
        );
      }

      // Firestore save failed but rollback succeeded
      throw const AuthSignupException(
        AuthSignupExceptionCode.networkFailure,
        message: 'Failed to save user data',
      );
    }
  }

  /// Maps Firebase Auth exceptions to domain exceptions
  AuthSignupException _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const AuthSignupException(
          AuthSignupExceptionCode.emailAlreadyInUse,
          message: 'Email is already in use',
        );
      case 'invalid-email':
        return const AuthSignupException(
          AuthSignupExceptionCode.emailInvalid,
          message: 'Email is invalid',
        );
      case 'weak-password':
        return const AuthSignupException(
          AuthSignupExceptionCode.passwordWeak,
          message: 'Password is too weak',
        );
      case 'network-request-failed':
        return const AuthSignupException(
          AuthSignupExceptionCode.networkFailure,
          message: 'Network request failed',
        );
      default:
        return AuthSignupException(
          AuthSignupExceptionCode.unknown,
          message: e.code,
        );
    }
  }
}

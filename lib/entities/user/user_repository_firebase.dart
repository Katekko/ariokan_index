import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/shared/utils/result.dart';
import 'package:ariokan_index/entities/user/user.dart' as domain;
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_state.dart';
import 'package:ariokan_index/shared/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';

/// Firebase implementation (T024) of [UserRepository].
///
/// Atomicity strategy (Option B from design notes):
/// 1. Create Firebase Auth user (email/password) -> uid.
/// 2. Run a Firestore transaction that fails if the username doc already exists.
///    In the same transaction create:
///       - usernames/{username}  (reservation doc with uid)
///       - users/{uid} (user profile data)
/// 3. If transaction fails with username taken, delete the just-created auth user (rollback) and return usernameTaken error.
/// 4. If transaction fails for any other reason, attempt rollback (delete auth user). If rollback deletion also fails, surface rollbackFailed.
///
/// This gives at-most-one successful pairing of (username, uid) even under racing requests.
/// NOTE: Requires prior Firebase initialization via initFirebase().
class UserRepositoryFirebase extends UserRepository {
  UserRepositoryFirebase({required this.auth, required this.firestore});

  @visibleForTesting
  final fb.FirebaseAuth auth;

  @visibleForTesting
  final FirebaseFirestore firestore;

  static const _usernameCollection = 'usernames';
  static const _usersCollection = 'users';
  static const _usernameTakenSentinel = 'USERNAME_TAKEN_SENTINEL';

  @override
  Future<Result<SignupError, domain.User>> createUserWithUsername({
    required String username,
    required String email,
    required String password,
  }) async {
    late final fb.UserCredential cred;
    try {
      cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      AppLogger.error(
        'UserRepositoryFirebase',
        'Auth createUser failed',
        error: e,
        stack: e.stackTrace,
      );

      return Failure(_mapAuthError(e));
    } catch (_) {
      AppLogger.error('UserRepositoryFirebase', 'Unknown auth exception');
      return Failure(const SignupError(SignupErrorCode.networkFailure));
    }

    final uid = cred.user?.uid;
    if (uid == null) {
      // Extremely unlikely, treat as unknown and abort.
      AppLogger.error(
        'UserRepositoryFirebase',
        'Firebase credential missing uid',
      );
      return Failure(const SignupError(SignupErrorCode.unknown));
    }

    bool authRollbackNeeded = true;
    try {
      final createdAtIso = DateTime.now().toUtc().toIso8601String();
      await firestore.runTransaction((tx) async {
        final usernameRef = firestore
            .collection(_usernameCollection)
            .doc(username);
        final usernameSnap = await tx.get(usernameRef);
        if (usernameSnap.exists) {
          AppLogger.info('Username already exists', username);
          throw _usernameTakenSentinel; // abort path
        }
        final userRef = firestore.collection(_usersCollection).doc(uid);
        // Prepare docs
        tx.set(usernameRef, {'uid': uid, 'createdAt': createdAtIso});
        tx.set(userRef, {
          'id': uid,
          'username': username,
          'email': email,
          'createdAt': createdAtIso,
        });
      });
      authRollbackNeeded = false; // success, keep auth user
      final user = domain.User(
        id: uid,
        username: username,
        email: email,
        createdAt: DateTime.now().toUtc(),
      );
      return Success(user);
    } catch (e) {
      // Attempt rollback (delete auth user) if Firestore transaction failed.
      if (authRollbackNeeded) {
        try {
          await cred.user?.delete();
        } catch (_) {
          AppLogger.error(
            'UserRepositoryFirebase',
            'Rollback delete auth user failed',
            error: e,
          );
          if (e == _usernameTakenSentinel) {
            // If deletion failed and username was taken, escalate to rollbackFailed
            return Failure(const SignupError(SignupErrorCode.rollbackFailed));
          }
          // Generic rollback failure
          return Failure(const SignupError(SignupErrorCode.rollbackFailed));
        }
      }
      if (e == _usernameTakenSentinel) {
        AppLogger.warn('Username taken detected after transaction', username);
        return Failure(const SignupError(SignupErrorCode.usernameTaken));
      }
      AppLogger.error(
        'UserRepositoryFirebase',
        'Transaction/network failure',
        error: e is Exception ? e : null,
      );
      return Failure(const SignupError(SignupErrorCode.networkFailure));
    }
  }

  SignupError _mapAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const SignupError(SignupErrorCode.emailAlreadyInUse);
      case 'invalid-email':
        return const SignupError(SignupErrorCode.emailInvalid);
      case 'weak-password':
        return const SignupError(SignupErrorCode.passwordWeak);
      case 'network-request-failed':
        return const SignupError(SignupErrorCode.networkFailure);
      default:
        return SignupError(SignupErrorCode.unknown, message: e.code);
    }
  }
}

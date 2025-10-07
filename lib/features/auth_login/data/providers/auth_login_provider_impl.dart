import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:ariokan_index/features/auth_login/data/models/login_body.dart';
import 'package:ariokan_index/features/auth_login/domain/providers/auth_login_provider.dart';
import 'package:ariokan_index/features/auth_login/domain/exceptions/login_exceptions.dart';
import 'package:ariokan_index/core/utils/app_logger.dart';

/// Firebase implementation of [AuthLoginProvider].
///
/// Login flow:
/// 1. Query Firestore `usernames/{username}` to get the user's email
/// 2. Use Firebase Auth signInWithEmailAndPassword with email and password
///
/// Error mapping (per FR-006 and FR-012):
/// - Username not found / wrong password → LoginErrorCode.invalidCredentials
/// - Network issues → LoginErrorCode.networkFailure
class AuthLoginProviderImpl implements AuthLoginProvider {
  AuthLoginProviderImpl({
    required fb.FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const _usernameCollection = 'usernames';
  static const _usersCollection = 'users';

  @override
  Future<void> login(LoginBody body) async {
    // Trim username as per FR-004
    final username = body.username.trim().toLowerCase();
    final password = body.password;

    try {
      // Step 1: Get user email from username
      final usernameDoc = await _firestore
          .collection(_usernameCollection)
          .doc(username)
          .get();

      if (!usernameDoc.exists) {
        AppLogger.warn('AuthLoginProvider', 'Login failed: username not found');
        throw const LoginError(
          LoginErrorCode.userNotFound,
          message: 'Username not found',
        );
      }

      final uid = usernameDoc.data()?['uid'] as String?;
      if (uid == null) {
        AppLogger.error('AuthLoginProvider', 'Username document missing uid');
        throw const LoginError(
          LoginErrorCode.unknown,
          message: 'Invalid username data',
        );
      }

      // Step 2: Get user email from users collection
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        AppLogger.error('AuthLoginProvider', 'User document not found for uid');
        throw const LoginError(
          LoginErrorCode.userNotFound,
          message: 'User document not found',
        );
      }

      final email = userDoc.data()?['email'] as String?;
      if (email == null) {
        AppLogger.error('AuthLoginProvider', 'User document missing email');
        throw const LoginError(
          LoginErrorCode.unknown,
          message: 'Invalid user data',
        );
      }

      // Step 3: Sign in with Firebase Auth using email and password
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      AppLogger.info('Login successful', 'username: $username');
    } on LoginError {
      // Re-throw domain errors
      rethrow;
    } on fb.FirebaseAuthException catch (e) {
      AppLogger.error('AuthLoginProvider', 'Login failed: ${e.code}', error: e);
      throw _mapAuthError(e);
    } catch (e, s) {
      AppLogger.error(
        'AuthLoginProvider',
        'Unexpected login error',
        error: e,
        stack: s,
      );
      throw const LoginError(
        LoginErrorCode.unknown,
        message: 'An unexpected error occurred during login',
      );
    }
  }

  /// Maps Firebase Auth exceptions to domain LoginError.
  /// Per FR-006: All auth failures map to invalidCredentials for security.
  /// Per FR-012: Network errors are distinguished.
  LoginError _mapAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'user-disabled':
        // Generic message for security (FR-006)
        return const LoginError(LoginErrorCode.invalidCredentials);
      case 'network-request-failed':
      case 'too-many-requests':
        return const LoginError(LoginErrorCode.networkFailure);
      default:
        return LoginError(LoginErrorCode.unknown, message: e.code);
    }
  }
}

import 'package:equatable/equatable.dart';

/// Error codes for login operations.
///
/// These codes align with the login spec requirements:
/// - FR-006: Generic "Username or password wrong" for invalid credentials
/// - FR-012: Distinguish network errors from authentication failures
enum LoginErrorCode {
  /// Invalid username or password (maps to FR-006).
  /// Shows generic message: "Username or password wrong"
  invalidCredentials,

  /// Username not found in the system.
  /// Treated as invalidCredentials in UI for security.
  userNotFound,

  /// Network connectivity issues during authentication (FR-012).
  /// Shows: "Network error. Please check your connection and try again."
  networkFailure,

  /// Username field is empty (caught by local validation).
  usernameEmpty,

  /// Password field is empty (caught by local validation).
  passwordEmpty,

  /// Unexpected/unmapped error.
  unknown,
}

/// Represents a login error with a code and optional message.
class LoginError extends Equatable {
  const LoginError(this.code, {this.message});

  final LoginErrorCode code;
  final String? message;

  @override
  String toString() => 'LoginError(code: $code, message: $message)';

  @override
  List<Object?> get props => [code, message];
}

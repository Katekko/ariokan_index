import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_state.dart';

/// Domain exceptions for auth signup feature
class AuthSignupException implements Exception {
  const AuthSignupException(this.code, {this.message});

  final AuthSignupExceptionCode code;
  final String? message;

  @override
  String toString() => 'AuthSignupException(code: $code, message: $message)';
}

enum AuthSignupExceptionCode {
  usernameTaken,
  emailAlreadyInUse,
  emailInvalid,
  passwordWeak,
  networkFailure,
  rollbackFailed,
  unknown,
}

extension AuthSignupExceptionCodeMapper on AuthSignupExceptionCode {
  SignupErrorCode toSignupErrorCode() {
    switch (this) {
      case AuthSignupExceptionCode.usernameTaken:
        return SignupErrorCode.usernameTaken;
      case AuthSignupExceptionCode.emailInvalid:
        return SignupErrorCode.emailInvalid;
      case AuthSignupExceptionCode.emailAlreadyInUse:
        return SignupErrorCode.emailAlreadyInUse;
      case AuthSignupExceptionCode.passwordWeak:
        return SignupErrorCode.passwordWeak;
      case AuthSignupExceptionCode.networkFailure:
        return SignupErrorCode.networkFailure;
      case AuthSignupExceptionCode.rollbackFailed:
        return SignupErrorCode.rollbackFailed;
      default:
        return SignupErrorCode.unknown;
    }
  }
}

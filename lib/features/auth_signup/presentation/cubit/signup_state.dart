import 'package:equatable/equatable.dart';

class SignupError extends Equatable {
  const SignupError(this.code, {this.message});

  final SignupErrorCode code;
  final String? message;

  @override
  String toString() => 'SignupError(code: $code, message: $message)';

  @override
  List<Object?> get props => [code, message];
}

enum SignupStatus { idle, submitting, success, error }

class SignupState extends Equatable {
  const SignupState({
    required this.username,
    required this.email,
    required this.password,
    required this.status,
    this.error,
  });

  factory SignupState.initial() => const SignupState(
    username: '',
    email: '',
    password: '',
    status: SignupStatus.idle,
  );

  final String username;
  final String email;
  final String password;
  final SignupStatus status;
  final SignupError? error;

  bool get isValid =>
      username.isNotEmpty && email.isNotEmpty && password.isNotEmpty;

  SignupState copyWith({
    String? username,
    String? email,
    String? password,
    SignupStatus? status,
    SignupError? error,
    bool clearError = false,
  }) => SignupState(
    username: username ?? this.username,
    email: email ?? this.email,
    password: password ?? this.password,
    status: status ?? this.status,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [username, email, password, status, error];
}

enum SignupErrorCode {
  usernameTaken,
  usernameInvalid,
  emailInvalid,
  emailAlreadyInUse,
  passwordWeak,
  networkFailure,
  rollbackFailed,
  unknown,
}

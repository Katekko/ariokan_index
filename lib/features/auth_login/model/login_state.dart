import 'package:equatable/equatable.dart';

enum LoginStatus { idle, submitting, success, failure }

enum LoginErrorType { auth, network }

class LoginState extends Equatable {
  const LoginState({
    this.username = '',
    this.password = '',
    this.status = LoginStatus.idle,
    this.errorType,
  });

  final String username;
  final String password;
  final LoginStatus status;
  final LoginErrorType? errorType;

  bool get isLoading => status == LoginStatus.submitting;
  bool get canSubmit =>
      username.trim().isNotEmpty && password.isNotEmpty && !isLoading;

  LoginState copyWith({
    String? username,
    String? password,
    LoginStatus? status,
    LoginErrorType? errorType,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
      errorType: errorType,
    );
  }

  @override
  List<Object?> get props => [username, password, status, errorType];
}

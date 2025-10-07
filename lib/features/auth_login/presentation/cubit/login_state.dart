import 'package:equatable/equatable.dart';
import 'package:ariokan_index/features/auth_login/domain/exceptions/login_exceptions.dart';

enum LoginStatus { idle, submitting, success, error }

class LoginState extends Equatable {
  const LoginState({
    this.username = '',
    this.password = '',
    this.status = LoginStatus.idle,
    this.error,
  });

  final String username;
  final String password;
  final LoginStatus status;
  final LoginError? error;

  bool get isLoading => status == LoginStatus.submitting;
  bool get canSubmit =>
      username.trim().isNotEmpty && password.isNotEmpty && !isLoading;

  LoginState copyWith({
    String? username,
    String? password,
    LoginStatus? status,
    LoginError? error,
    bool clearError = false,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [username, password, status, error];
}

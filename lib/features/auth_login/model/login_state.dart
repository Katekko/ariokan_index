// T011 Implementation of LoginState

enum LoginStatus { idle, submitting, success, failure }

enum LoginErrorType { auth, network }

class LoginState {
  const LoginState({
    this.username = '',
    this.password = '',
    this.status = LoginStatus.idle,
    this.errorType,
  });

  factory LoginState.initial() => const LoginState();

  final String username;
  final String password;
  final LoginStatus status;
  final LoginErrorType? errorType;

  bool get canSubmit =>
      username.isNotEmpty &&
      password.isNotEmpty &&
      status != LoginStatus.submitting;

  LoginState copyWith({
    String? username,
    String? password,
    LoginStatus? status,
    LoginErrorType? errorType,
    bool clearError = false,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
      errorType: clearError ? null : (errorType ?? this.errorType),
    );
  }

  @override
  String toString() =>
      'LoginState(username: $username, status: $status, errorType: $errorType)';

  @override
  bool operator ==(Object other) {
    return other is LoginState &&
        other.username == username &&
        other.password == password &&
        other.status == status &&
        other.errorType == errorType;
  }

  @override
  int get hashCode => Object.hash(username, password, status, errorType);
}

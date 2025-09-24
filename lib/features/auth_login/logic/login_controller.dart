// T012 refactor follow-up: decouple controller from service by depending on repository.
import 'dart:async';

import 'package:ariokan_index/features/auth_login/model/login_exceptions.dart';
import 'package:ariokan_index/features/auth_login/model/login_state.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';

class LoginController {
  LoginController(this._userRepo);

  final UserRepository _userRepo;
  LoginState _state = LoginState.initial();
  LoginState get state => _state;
  Future<void>? _inflight;

  void updateUsername(String value) {
    _state = _state.copyWith(username: value.trim(), clearError: true);
  }

  void updatePassword(String value) {
    _state = _state.copyWith(password: value, clearError: true);
  }

  Future<void> submit() {
    if (!_state.canSubmit) return Future.value();
    if (_inflight != null) return _inflight!; // idempotent while submitting

    final completer = Completer<void>();
    _state = _state.copyWith(status: LoginStatus.submitting, clearError: true);
    _inflight = completer.future;

    () async {
      try {
        await _userRepo.loginWithUsername(
          username: _state.username,
          password: _state.password,
        );
        _state = _state.copyWith(status: LoginStatus.success, clearError: true);
      } on LoginAuthFailure {
        _state = _state.copyWith(
          status: LoginStatus.failure,
          errorType: LoginErrorType.auth,
        );
      } on LoginNetworkFailure {
        _state = _state.copyWith(
          status: LoginStatus.failure,
          errorType: LoginErrorType.network,
        );
      } catch (_) {
        // Default to network for unknown exceptions per spec requirement to distinguish
        _state = _state.copyWith(
          status: LoginStatus.failure,
          errorType: LoginErrorType.network,
        );
      } finally {
        _inflight = null;
        completer.complete();
      }
    }();

    return _inflight!;
  }
}

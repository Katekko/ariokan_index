import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_state.dart';
import 'package:ariokan_index/shared/utils/validators.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';

/// SignupCubit manages form state & submission lifecycle.
class SignupCubit extends Cubit<SignupState> {
  SignupCubit(this._repo) : super(SignupState.initial());

  final UserRepository _repo;
  Future<void>? _inFlight;

  void updateUsername(String v) =>
      emit(state.copyWith(username: v, clearError: true));
  void updateEmail(String v) =>
      emit(state.copyWith(email: v, clearError: true));
  void updatePassword(String v) =>
      emit(state.copyWith(password: v, clearError: true));

  Future<void> submit() {
    if (_inFlight != null) return _inFlight!; // already running
    // Perform sync validations first; return early on failure.
    final usernameErr = validateUsername(state.username);
    if (usernameErr != null) {
      final s = state.copyWith(
        status: SignupStatus.error,
        error: const SignupError(SignupErrorCode.usernameInvalid),
      );
      emit(s);
      return Future.value();
    }

    final emailErr = validateEmail(state.email);
    if (emailErr != null) {
      final s = state.copyWith(
        status: SignupStatus.error,
        error: const SignupError(SignupErrorCode.emailInvalid),
      );
      emit(s);
      return Future.value();
    }

    final passwordErr = validatePassword(state.password);
    if (passwordErr != null) {
      final s = state.copyWith(
        status: SignupStatus.error,
        error: const SignupError(SignupErrorCode.passwordWeak),
      );
      emit(s);
      return Future.value();
    }

    _inFlight = _doSubmit();
    return _inFlight!;
  }

  Future<void> _doSubmit() async {
    final submitting = state.copyWith(
      status: SignupStatus.submitting,
      clearError: true,
    );
    emit(submitting);
    try {
      final result = await _repo.createUserWithUsername(
        username: submitting.username,
        email: submitting.email,
        password: submitting.password,
      );
      final next = result.fold(
        failure: (e) =>
            submitting.copyWith(status: SignupStatus.error, error: e),
        success: (_) => submitting.copyWith(status: SignupStatus.success),
      );
      emit(next);
    } catch (_) {
      final errState = submitting.copyWith(
        status: SignupStatus.error,
        error: const SignupError(SignupErrorCode.networkFailure),
      );
      emit(errState);
    } finally {
      _inFlight = null;
    }
  }
}

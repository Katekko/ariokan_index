import 'dart:async';
import 'package:ariokan_index/features/auth_signup/domain/exceptions/auth_signup_exceptions.dart';
import 'package:ariokan_index/features/auth_signup/domain/usecases/signup_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_state.dart';
import 'package:ariokan_index/core/utils/validators.dart';

/// SignupCubit manages form state & submission lifecycle.
class SignupCubit extends Cubit<SignupState> {
  SignupCubit({required SignupUsecase signupUsecase})
    : _signupUsecase = signupUsecase,
      super(SignupState.initial());

  final SignupUsecase _signupUsecase;
  Future<void>? _inFlight;

  void updateUsername(String v) =>
      emit(state.copyWith(username: v, clearError: true));
  void updateEmail(String v) =>
      emit(state.copyWith(email: v, clearError: true));
  void updatePassword(String v) =>
      emit(state.copyWith(password: v, clearError: true));

  Future<void> submit() {
    if (_inFlight != null) return _inFlight!;

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
      await _signupUsecase.call(
        username: submitting.username,
        email: submitting.email,
        password: submitting.password,
      );

      final success = submitting.copyWith(status: SignupStatus.success);
      emit(success);
    } on AuthSignupException catch (err) {
      final errState = submitting.copyWith(
        status: SignupStatus.error,
        error: SignupError(err.code.toSignupErrorCode()),
      );

      emit(errState);
    } catch (_) {
      rethrow;
    } finally {
      _inFlight = null;
    }
  }
}

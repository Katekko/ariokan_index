import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ariokan_index/features/auth_login/presentation/cubit/login_state.dart';
import 'package:ariokan_index/features/auth_login/domain/usecases/sign_in_with_username_password_usecase.dart';
import 'package:ariokan_index/features/auth_login/domain/exceptions/login_exceptions.dart';
import 'package:ariokan_index/core/utils/app_logger.dart';

/// LoginCubit manages form state & submission lifecycle.
///
/// Follows the same pattern as SignupCubit:
/// - Local validation before submission (FR-003)
/// - Double-submit protection via _inFlight guard
/// - Maps domain exceptions to presentation errors
class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required SignInWithUsernamePasswordUseCase signInUseCase})
    : _signInUseCase = signInUseCase,
      super(const LoginState());

  final SignInWithUsernamePasswordUseCase _signInUseCase;
  Future<void>? _inFlight;

  void updateUsername(String v) =>
      emit(state.copyWith(username: v, clearError: true));

  void updatePassword(String v) =>
      emit(state.copyWith(password: v, clearError: true));

  Future<void> submit() {
    if (_inFlight != null) return _inFlight!; // Prevent double submission

    // Local validation (FR-003)
    final username = state.username.trim();
    final password = state.password;

    if (username.isEmpty) {
      emit(
        state.copyWith(
          status: LoginStatus.error,
          error: const LoginError(LoginErrorCode.usernameEmpty),
        ),
      );
      return Future.value();
    }

    if (password.isEmpty) {
      emit(
        state.copyWith(
          status: LoginStatus.error,
          error: const LoginError(LoginErrorCode.passwordEmpty),
        ),
      );
      return Future.value();
    }

    _inFlight = _doSubmit();
    return _inFlight!;
  }

  Future<void> _doSubmit() async {
    final submitting = state.copyWith(
      status: LoginStatus.submitting,
      clearError: true,
    );
    emit(submitting);

    try {
      AppLogger.info(
        'Login attempt',
        'username: ${_maskUsername(submitting.username)}',
      );

      await _signInUseCase.call(
        username: submitting.username,
        password: submitting.password,
      );

      AppLogger.info(
        'Login successful',
        'username: ${_maskUsername(submitting.username)}',
      );

      emit(submitting.copyWith(status: LoginStatus.success));
    } on LoginError catch (err) {
      AppLogger.warn(
        'Login failed',
        'code: ${err.code}, username: ${_maskUsername(submitting.username)}',
      );

      emit(
        submitting.copyWith(
          status: LoginStatus.error,
          error: err,
        ),
      );
    } catch (e, s) {
      AppLogger.error(
        'LoginCubit',
        'Unexpected login error',
        error: e,
        stack: s,
      );

      emit(
        submitting.copyWith(
          status: LoginStatus.error,
          error: const LoginError(LoginErrorCode.unknown),
        ),
      );
    } finally {
      _inFlight = null;
    }
  }

  /// Masks username for logging (shows first 2 chars + asterisks)
  String _maskUsername(String username) {
    if (username.isEmpty) return '(empty)';
    if (username.length <= 2) return '**';
    return '${username.substring(0, 2)}${'*' * (username.length - 2)}';
  }
}

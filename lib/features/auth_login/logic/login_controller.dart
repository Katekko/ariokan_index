import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/login_state.dart';
import 'package:ariokan_index/shared/utils/app_logger.dart';

class LoginController extends Cubit<LoginState> {
  LoginController() : super(const LoginState());

  void setUsername(String username) {
    emit(state.copyWith(username: username));
  }

  void setPassword(String password) {
    emit(state.copyWith(password: password));
  }

  Future<void> submit({
    required String username,
    required String password,
  }) async {
    AppLogger.info(
      'submit_start',
      'username: ${username.isNotEmpty ? "${username[0]}***" : ""}',
    );
    emit(state.copyWith(status: LoginStatus.submitting, errorType: null));
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate async
    // TODO: Integrate with AuthService and error mapping
    if (password == 'pass') {
      AppLogger.info(
        'submit_success',
        'username: ${username.isNotEmpty ? "${username[0]}***" : ""}',
      );
      emit(state.copyWith(status: LoginStatus.success));
    } else if (password == 'netfail') {
      AppLogger.info(
        'submit_failure_network',
        'username: ${username.isNotEmpty ? "${username[0]}***" : ""}',
      );
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorType: LoginErrorType.network,
        ),
      );
    } else {
      AppLogger.info(
        'submit_failure_auth',
        'username: ${username.isNotEmpty ? "${username[0]}***" : ""}',
      );
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorType: LoginErrorType.auth,
        ),
      );
    }
  }
}

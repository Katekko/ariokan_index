// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../model/login_state.dart';

// import 'package:ariokan_index/shared/utils/app_logger.dart';
// import 'package:ariokan_index/shared/services/auth_service.dart';

// class LoginController extends Cubit<LoginState> {
//   LoginController(this._authService) : super(const LoginState());

//   final AuthService _authService;

//   void setUsername(String username) {
//     emit(state.copyWith(username: username));
//   }

//   void setPassword(String password) {
//     emit(state.copyWith(password: password));
//   }

//   Future<void> submit({
//     required String username,
//     required String password,
//   }) async {
//     AppLogger.info(
//       'submit_start',
//       'username: ${username.isNotEmpty ? "${username[0]}***" : ""}',
//     );
//     emit(state.copyWith(status: LoginStatus.submitting, errorType: null));
//     try {
//       await _authService.signInWithUsernamePassword(username, password);
//       AppLogger.info(
//         'submit_success',
//         'username: ${username.isNotEmpty ? "${username[0]}***" : ""}',
//       );
//       emit(state.copyWith(status: LoginStatus.success));
//     } on Exception catch (e) {
//       // Map error type
//       final errorType = _mapErrorType(e);
//       AppLogger.info(
//         'submit_failure_${errorType == LoginErrorType.network ? 'network' : 'auth'}',
//         'username: ${username.isNotEmpty ? "${username[0]}***" : ""}',
//       );
//       emit(state.copyWith(status: LoginStatus.failure, errorType: errorType));
//     }
//   }

//   LoginErrorType _mapErrorType(Object e) {
//     final msg = e.toString().toLowerCase();
//     if (msg.contains('network') || msg.contains('timeout')) {
//       return LoginErrorType.network;
//     }
//     return LoginErrorType.auth;
//   }
// }

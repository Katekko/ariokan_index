import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/features/auth_login/logic/login_controller.dart';
import 'package:ariokan_index/features/auth_login/model/login_state.dart';

class LoginControllerMock extends MockCubit<LoginState> implements LoginController {
  LoginControllerMock._();

  static LoginControllerMock register() {
    final mock = LoginControllerMock._();
    setUpAll(() => di.registerFactory<LoginController>(() => mock));
    setUp(() {
      // Stub intent methods
      when(() => mock.setUsername(any())).thenReturn(null);
      when(() => mock.setPassword(any())).thenReturn(null);
      when(() => mock.submit(username: any(named: 'username'), password: any(named: 'password'))).thenAnswer((_) async {});
      // Deterministic initial state
      whenListen<LoginState>(
        mock,
        Stream<LoginState>.empty(),
        initialState: const LoginState(),
      );
    });
    tearDown(() => reset(mock));
    return mock;
  }
}

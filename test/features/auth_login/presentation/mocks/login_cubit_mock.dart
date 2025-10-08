import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/features/auth_login/presentation/cubit/login_cubit.dart';
import 'package:ariokan_index/features/auth_login/presentation/cubit/login_state.dart';

/// Mock for LoginCubit to be used in widget/page tests
class LoginCubitMock extends MockCubit<LoginState> implements LoginCubit {
  LoginCubitMock._();

  /// Register the mock in DI and return it for test-specific stubbing
  static LoginCubit register() {
    final mock = LoginCubitMock._();

    setUpAll(() => di.registerFactory<LoginCubit>(() => mock));

    setUp(() {
      // Stub intent methods with benign defaults
      when(() => mock.updateUsername(any())).thenReturn(null);
      when(() => mock.updatePassword(any())).thenReturn(null);
      when(mock.submit).thenAnswer((_) async {});
      when(mock.close).thenAnswer((_) async {});

      // Deterministic initial state
      whenListen<LoginState>(
        mock,
        Stream.empty(),
        initialState: const LoginState(),
      );
    });

    tearDown(() => reset(mock));

    return mock;
  }
}

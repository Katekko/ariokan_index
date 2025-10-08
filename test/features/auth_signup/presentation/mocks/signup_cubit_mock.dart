import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_cubit.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_state.dart';

/// Mock for SignupCubit to be used in widget/page tests
class SignupCubitMock extends MockCubit<SignupState> implements SignupCubit {
  SignupCubitMock._();

  /// Register the mock in DI and return it for test-specific stubbing
  static SignupCubit register() {
    final mock = SignupCubitMock._();

    setUpAll(() => di.registerFactory<SignupCubit>(() => mock));

    setUp(() {
      // Stub intent methods with benign defaults
      when(() => mock.updateUsername(any())).thenReturn(null);
      when(() => mock.updateEmail(any())).thenReturn(null);
      when(() => mock.updatePassword(any())).thenReturn(null);
      when(mock.submit).thenAnswer((_) async {});
      when(mock.close).thenAnswer((_) async {});

      // Deterministic initial state
      whenListen<SignupState>(
        mock,
        Stream.empty(),
        initialState: SignupState.initial(),
      );
    });

    tearDown(() => reset(mock));

    return mock;
  }
}

import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_cubit.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class SignupControllerMock extends MockCubit<SignupState>
    implements SignupCubit {
  SignupControllerMock._();

  static SignupCubit register() {
    final mock = SignupControllerMock._();

    setUpAll(() => di.registerFactory<SignupCubit>(() => mock));

    setUp(() {
      when(mock.close).thenAnswer((_) async {});
      when(mock.submit).thenAnswer((_) async {});
      whenListen<SignupState>(
        mock,
        Stream.empty(),
        initialState: SignupState.initial(),
      );
    });

    tearDown(() {
      reset(mock);
    });

    return mock;
  }
}

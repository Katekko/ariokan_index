import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:ariokan_index/features/auth_signup/model/signup_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class SignupControllerMock extends Mock implements SignupController {
  SignupControllerMock._();

  static void register() {
    final mock = SignupControllerMock._();
    
    setUpAll(() => di.registerFactory<SignupController>(() => mock));

    setUp(() {
      when(mock.submit).thenAnswer((_) async {});
      whenListen(mock, Stream.empty(), initialState: SignupState.initial());
    });

    tearDown(() {
      reset(mock);
    });
  }
}

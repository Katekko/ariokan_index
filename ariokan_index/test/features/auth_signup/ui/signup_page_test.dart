import 'package:ariokan_index/features/auth_signup/ui/signup_page_setup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../entities/user/mocks/user_repository_mock.dart';
import '../../../helpers/golden.dart';
import '../mocks/auth_signup_page_setup_mock.dart';

void main() {
  SignupControllerMock.register();
  UserRepositoryMock.register();

  Widget widgetBuilder() => AuthSignupPageSetup();

  group('AuthSignupPage golden', () {
    testWidgetsGolden(
      'renders initial signup page',
      fileName: 'auth_signup_page_idle',
      builder: widgetBuilder,
    );
  });
}

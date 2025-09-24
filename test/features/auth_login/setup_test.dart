import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/features/auth_login/logic/login_controller.dart';
import 'package:ariokan_index/features/auth_login/setup.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks/auth_service_mock.dart';

void main() {
  group('LoginSetup', () {
    AuthServiceMock.register();

    test('init registers LoginController factory', () {
      LoginSetup.init();
      final controller = di<LoginController>();
      expect(controller, isA<LoginController>());
    });
  });
}

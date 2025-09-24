import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/test_app.dart';
import '../../../helpers/golden.dart';
import '../mocks/auth_service_mock.dart';
import '../mocks/login_controller_mock.dart';
import 'package:ariokan_index/features/auth_login/ui/login_page.dart';

void main() {
  // Register only needed mocks
  AuthServiceMock.register();
  LoginControllerMock.register();

  group('Interfaces', () {
    testWidgetsGolden(
      'idle golden',
      fileName: 'login_page_idle',
      builder: () => localizedTestApp(const LoginPage()),
    );
  });

  group('Interactions', () {
    // Add interaction tests here as needed
  });
}

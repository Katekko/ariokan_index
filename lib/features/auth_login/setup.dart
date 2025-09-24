import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/shared/services/auth_service.dart';
import 'package:ariokan_index/features/auth_login/logic/login_controller.dart';

sealed class LoginSetup {
  static void init() {
    di.registerFactory<LoginController>(
      () => LoginController(di<AuthService>()),
    );
  }
}

import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';

sealed class SignupSetup {
  static void init() {
    di.registerFactory<SignupController>(
      () => SignupController(di<UserRepository>()),
    );
  }
}

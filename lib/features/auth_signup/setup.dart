import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_cubit.dart';

sealed class SignupSetup {
  static void init() {
    di.registerFactory<SignupCubit>(
      () => SignupCubit(di<UserRepository>()),
    );
  }
}

import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/features/auth_signup/data/providers/auth_signup_provider_impl.dart';
import 'package:ariokan_index/features/auth_signup/domain/providers/auth_signup_provider.dart';
import 'package:ariokan_index/features/auth_signup/domain/usecases/signup_usecase.dart';

import 'presentation/cubit/signup_cubit.dart';

sealed class SignupSetup {
  static void init() {
    di.registerFactory<AuthSignupProvider>(AuthSignupProviderImpl.new);

    di.registerFactory<SignupUsecase>(
      () => SignupUsecase(di<AuthSignupProvider>()),
    );

    di.registerFactory<SignupCubit>(
      () => SignupCubit(signupUsecase: di<SignupUsecase>()),
    );
  }
}

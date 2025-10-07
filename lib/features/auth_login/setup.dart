import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/features/auth_login/data/providers/auth_login_provider_impl.dart';
import 'package:ariokan_index/features/auth_login/domain/providers/auth_login_provider.dart';
import 'package:ariokan_index/features/auth_login/domain/usecases/sign_in_with_username_password_usecase.dart';
import 'package:ariokan_index/features/auth_login/presentation/cubit/login_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

sealed class LoginSetup {
  static void init() {
    // Register provider (data layer)
    di.registerFactory<AuthLoginProvider>(
      () => AuthLoginProviderImpl(
        auth: di<FirebaseAuth>(),
        firestore: di<FirebaseFirestore>(),
      ),
    );

    // Register use case (domain layer)
    di.registerFactory<SignInWithUsernamePasswordUseCase>(
      () => SignInWithUsernamePasswordUseCase(di<AuthLoginProvider>()),
    );

    // Register cubit (presentation layer)
    di.registerFactory<LoginCubit>(
      () => LoginCubit(signInUseCase: di<SignInWithUsernamePasswordUseCase>()),
    );
  }
}

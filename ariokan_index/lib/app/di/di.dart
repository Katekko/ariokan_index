import 'package:ariokan_index/features/auth_signup/ui/setup.dart';
import 'package:get_it/get_it.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/entities/user/user_repository_firebase.dart';

final GetIt di = GetIt.instance;

/// Registers app-wide dependencies. Call before runApp.
Future<void> setupDependencies() async {
  // Repositories (abstract -> concrete binding)
  di.registerLazySingleton<UserRepository>(UserRepositoryFirebase.new);

  // Features
  SignupSetup.init();
}

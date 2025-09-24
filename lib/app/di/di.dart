import 'package:ariokan_index/features/auth_signup/setup.dart';
import 'package:ariokan_index/features/auth_login/setup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/entities/user/user_repository_firebase.dart';

final GetIt di = GetIt.instance;

/// Registers app-wide dependencies. Call before runApp.
Future<void> setupDependencies({
  FirebaseAuth? auth,
  FirebaseFirestore? firestore,
}) async {
  _setupInfra(auth: auth, firestore: firestore);
  _setupRepositories();
  _setupFeatures();
}

void _setupInfra({FirebaseAuth? auth, FirebaseFirestore? firestore}) {
  if (!di.isRegistered<FirebaseAuth>()) {
    di.registerLazySingleton<FirebaseAuth>(() => auth ?? FirebaseAuth.instance);
  }
  if (!di.isRegistered<FirebaseFirestore>()) {
    di.registerLazySingleton<FirebaseFirestore>(
      () => firestore ?? FirebaseFirestore.instance,
    );
  }
}

void _setupRepositories() {
  if (!di.isRegistered<UserRepository>()) {
    di.registerLazySingleton<UserRepository>(
      () => UserRepositoryFirebase(
        auth: di<FirebaseAuth>(),
        firestore: di<FirebaseFirestore>(),
      ),
    );
  }
}

void _setupFeatures() {
  SignupSetup.init();
  LoginSetup.init();
}

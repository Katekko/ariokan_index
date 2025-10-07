import 'package:ariokan_index/features/auth_signup/setup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

final GetIt di = GetIt.instance;

/// Registers app-wide dependencies. Call before runApp.
Future<void> setupDependencies({
  FirebaseAuth? auth,
  FirebaseFirestore? firestore,
}) async {
  _setupInfra(auth: auth, firestore: firestore);
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

void _setupFeatures() {
  SignupSetup.init();
  // LoginSetup.init();
}

import 'package:firebase_core/firebase_core.dart';
import 'package:ariokan_index/firebase_options.dart';

bool _firebaseInitialized = false;

/// Idempotent Firebase initialization.
/// Provide your real FirebaseOptions (copy from Firebase console) replacing the TODO section.
Future<void> initFirebase() async {
  if (_firebaseInitialized) return;
  if (Firebase.apps.isNotEmpty) {
    _firebaseInitialized = true;
    return;
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _firebaseInitialized = true;
}

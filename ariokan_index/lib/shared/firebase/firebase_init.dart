/// Firebase initialization placeholder (T003).
/// Will be implemented with actual FirebaseOptions after configuration.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

bool _firebaseInitialized = false;

/// Idempotent Firebase initialization.
/// Provide your real FirebaseOptions (copy from Firebase console) replacing the TODO section.
Future<void> initFirebase() async {
  if (_firebaseInitialized) return;
  // If already initialized by integration tests or elsewhere, skip.
  if (Firebase.apps.isNotEmpty) {
    _firebaseInitialized = true;
    return;
  }
  try {
    if (kIsWeb) {
      // TODO: Replace with actual web FirebaseOptions
      const options = FirebaseOptions(
        apiKey: 'TODO',
        appId: 'TODO',
        messagingSenderId: 'TODO',
        projectId: 'TODO',
      );
      await Firebase.initializeApp(options: options);
    } else {
      // Mobile/desktop: if you add generated firebase_options.dart later, import and call DefaultFirebaseOptions.currentPlatform
      await Firebase.initializeApp();
    }
    _firebaseInitialized = true;
  } catch (e) {
    // In early development we swallow errors to not block local testing; consider rethrow/log later.
    _firebaseInitialized = true; // Avoid retry loop
  }
}

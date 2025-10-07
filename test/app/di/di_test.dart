import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/entities/user/user_repository_firebase.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDownAll(di.reset);

  group('DI setup', () {
    test('injected mocks cover infra + repository closures', () async {
      di.reset();
      final mockAuth = MockFirebaseAuth();
      final fakeFs = FakeFirebaseFirestore();

      await setupDependencies(auth: mockAuth, firestore: fakeFs);

      expect(
        di<UserRepository>(),
        isA<UserRepositoryFirebase>()
            .having((r) => r.auth, 'auth', isA<fb.FirebaseAuth>())
            .having((r) => r.firestore, 'firestore', isA<FirebaseFirestore>()),
      );

      expect(di.isRegistered<SignupCubit>(), isTrue);
    });
  });
}

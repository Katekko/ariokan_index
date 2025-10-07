import 'package:ariokan_index/entities/user/user_repository_firebase.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_state.dart';
import 'package:ariokan_index/shared/utils/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements fb.FirebaseAuth {}

class MockUserCredential extends Mock implements fb.UserCredential {}

class MockAuthUser extends Mock implements fb.User {}

class MockFirestore extends Mock implements FirebaseFirestore {}

void main() {
  group('auth error mapping', () {
    late MockFirebaseAuth auth;
    late FirebaseFirestore fs; // fake
    late UserRepositoryFirebase repo;

    setUp(() {
      auth = MockFirebaseAuth();
      fs = FakeFirebaseFirestore();
      repo = UserRepositoryFirebase(auth: auth, firestore: fs);
    });

    Future<Failure<SignupError, dynamic>> invoke(String code) async {
      when(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(fb.FirebaseAuthException(code: code));
      final r = await repo.createUserWithUsername(
        username: 'u',
        email: 'u@e',
        password: 'pw123456',
      );
      return r as Failure<SignupError, dynamic>;
    }

    test(
      'email-already-in-use',
      () async => expect(
        (await invoke('email-already-in-use')).error.code,
        SignupErrorCode.emailAlreadyInUse,
      ),
    );
    test(
      'invalid-email',
      () async => expect(
        (await invoke('invalid-email')).error.code,
        SignupErrorCode.emailInvalid,
      ),
    );
    test(
      'weak-password',
      () async => expect(
        (await invoke('weak-password')).error.code,
        SignupErrorCode.passwordWeak,
      ),
    );
    test(
      'network-request-failed',
      () async => expect(
        (await invoke('network-request-failed')).error.code,
        SignupErrorCode.networkFailure,
      ),
    );
    test(
      'unknown default',
      () async =>
          expect((await invoke('other')).error.code, SignupErrorCode.unknown),
    );
    test('unknown non-auth exception -> networkFailure', () async {
      when(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('boom'));
      final r = await repo.createUserWithUsername(
        username: 'u',
        email: 'u@e',
        password: 'pw123456',
      );
      expect((r as Failure).error.code, SignupErrorCode.networkFailure);
    });
  });

  group('createUserWithUsername flows', () {
    late MockFirebaseAuth auth;
    late FirebaseFirestore fs;
    late UserRepositoryFirebase repo;
    late MockUserCredential cred;
    late MockAuthUser authUser;

    setUp(() {
      auth = MockFirebaseAuth();
      fs = FakeFirebaseFirestore();
      repo = UserRepositoryFirebase(auth: auth, firestore: fs);
      cred = MockUserCredential();
      authUser = MockAuthUser();
    });

    void stubAuth({bool withUser = true, String uid = 'uid123'}) {
      when(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => cred);
      if (withUser) {
        when(() => cred.user).thenReturn(authUser);
        when(() => authUser.uid).thenReturn(uid);
        when(() => authUser.delete()).thenAnswer((_) async {});
      } else {
        when(() => cred.user).thenReturn(null);
      }
    }

    test('success path returns Success', () async {
      stubAuth();
      final r = await repo.createUserWithUsername(
        username: 'user',
        email: 'user@example.com',
        password: 'pw123456',
      );
      expect(r, isA<Success>());
    });

    test('uid null -> unknown failure', () async {
      stubAuth(withUser: false);
      final r = await repo.createUserWithUsername(
        username: 'user',
        email: 'user@example.com',
        password: 'pw123456',
      );
      expect((r as Failure).error.code, SignupErrorCode.unknown);
    });

    test('username taken -> usernameTaken', () async {
      stubAuth();
      await fs.collection('usernames').doc('user').set({'uid': 'existing'});
      final r = await repo.createUserWithUsername(
        username: 'user',
        email: 'user@example.com',
        password: 'pw123456',
      );
      expect((r as Failure).error.code, SignupErrorCode.usernameTaken);
    });

    test('username taken and delete fails -> rollbackFailed', () async {
      stubAuth();
      when(() => authUser.delete()).thenThrow(Exception('del'));
      await fs.collection('usernames').doc('user').set({'uid': 'existing'});
      final r = await repo.createUserWithUsername(
        username: 'user',
        email: 'user@example.com',
        password: 'pw123456',
      );
      expect((r as Failure).error.code, SignupErrorCode.rollbackFailed);
    });

    test('generic transaction failure -> networkFailure', () async {
      stubAuth();
      // Force runTransaction to throw by throwing inside a security rule simulation: use collection.get with invalid doc? Simpler: override runTransaction using a mock wrapper.
      final mockFs = MockFirestore();
      repo = UserRepositoryFirebase(auth: auth, firestore: mockFs);
      when(() => mockFs.runTransaction(any())).thenThrow(Exception('tx'));
      final r = await repo.createUserWithUsername(
        username: 'user',
        email: 'user@example.com',
        password: 'pw123456',
      );
      expect((r as Failure).error.code, SignupErrorCode.networkFailure);
    });

    test(
      'generic transaction failure + delete fails -> rollbackFailed',
      () async {
        stubAuth();
        when(() => authUser.delete()).thenThrow(Exception('del'));
        final mockFs = MockFirestore();
        repo = UserRepositoryFirebase(auth: auth, firestore: mockFs);
        when(() => mockFs.runTransaction(any())).thenThrow(Exception('tx'));
        final r = await repo.createUserWithUsername(
          username: 'user',
          email: 'user@example.com',
          password: 'pw123456',
        );
        expect((r as Failure).error.code, SignupErrorCode.rollbackFailed);
      },
    );
  });
}

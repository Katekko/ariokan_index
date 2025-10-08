import 'package:ariokan_index/features/auth_login/data/models/login_body.dart';
import 'package:ariokan_index/features/auth_login/data/providers/auth_login_provider_impl.dart';
import 'package:ariokan_index/features/auth_login/domain/exceptions/login_exceptions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements fb.FirebaseAuth {}

class _MockUserCredential extends Mock implements fb.UserCredential {}

void main() {
  group('AuthLoginProviderImpl', () {
    group('constructor', () {
      test('accepts auth and firestore parameters', () {
        final mockAuth = _MockFirebaseAuth();
        final fakeFirestore = FakeFirebaseFirestore();

        final provider = AuthLoginProviderImpl(
          auth: mockAuth,
          firestore: fakeFirestore,
        );

        expect(provider, isNotNull);
        expect(provider, isA<AuthLoginProviderImpl>());
      });
    });

    group('login success path', () {
      // Create fresh instances for this group - Constitution rule: no late variables
      final mockAuth = _MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();
      final provider = AuthLoginProviderImpl(
        auth: mockAuth,
        firestore: fakeFirestore,
      );

      tearDown(() {
        // Reset mocks after each test - Constitution rule
        reset(mockAuth);
      });

      setUp(() async {
        // Setup username document
        await fakeFirestore.collection('usernames').doc('testuser').set({
          'uid': 'user123',
        });

        // Setup user document
        await fakeFirestore.collection('users').doc('user123').set({
          'email': 'test@example.com',
          'username': 'testuser',
          'createdAt': DateTime.now().toIso8601String(),
        });

        // Mock successful auth
        final mockCred = _MockUserCredential();
        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => mockCred);
      });

      test('successfully logs in with valid credentials', () async {
        await provider.login(
          const LoginBody(username: 'testuser', password: 'password123'),
        );

        verify(
          () => mockAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).called(1);
      });

      test('trims and lowercases username before lookup', () async {
        await provider.login(
          const LoginBody(username: '  TestUser  ', password: 'password123'),
        );

        verify(
          () => mockAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).called(1);
      });
    });

    group('login error cases - username lookup', () {
      // Fresh instances for this group
      final mockAuth = _MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();
      final provider = AuthLoginProviderImpl(
        auth: mockAuth,
        firestore: fakeFirestore,
      );

      tearDown(() {
        reset(mockAuth);
      });

      test('throws userNotFound when username does not exist', () async {
        expect(
          () => provider.login(
            const LoginBody(username: 'nonexistent', password: 'password123'),
          ),
          throwsA(
            isA<LoginError>()
                .having((e) => e.code, 'code', LoginErrorCode.userNotFound)
                .having((e) => e.message, 'message', 'Username not found'),
          ),
        );
      });

      test('throws unknown error when username document has no uid', () async {
        await fakeFirestore.collection('usernames').doc('baduser').set({
          'wrongField': 'value',
        });

        expect(
          () => provider.login(
            const LoginBody(username: 'baduser', password: 'password123'),
          ),
          throwsA(
            isA<LoginError>()
                .having((e) => e.code, 'code', LoginErrorCode.unknown)
                .having((e) => e.message, 'message', 'Invalid username data'),
          ),
        );
      });
    });

    group('login error cases - user document', () {
      // Fresh instances for this group
      final mockAuth = _MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();
      final provider = AuthLoginProviderImpl(
        auth: mockAuth,
        firestore: fakeFirestore,
      );

      tearDown(() {
        reset(mockAuth);
      });

      test('throws userNotFound when user document does not exist', () async {
        // Setup username document that points to non-existent user
        await fakeFirestore.collection('usernames').doc('orphanuser').set({
          'uid': 'orphan123',
        });

        expect(
          () => provider.login(
            const LoginBody(username: 'orphanuser', password: 'password123'),
          ),
          throwsA(
            isA<LoginError>()
                .having((e) => e.code, 'code', LoginErrorCode.userNotFound)
                .having((e) => e.message, 'message', 'User document not found'),
          ),
        );
      });

      test('throws unknown error when user document has no email', () async {
        await fakeFirestore.collection('users').doc('nomail123').set({
          'username': 'nomail',
          'createdAt': DateTime.now().toIso8601String(),
        });

        await fakeFirestore.collection('usernames').doc('nomail').set({
          'uid': 'nomail123',
        });

        expect(
          () => provider.login(
            const LoginBody(username: 'nomail', password: 'password123'),
          ),
          throwsA(
            isA<LoginError>()
                .having((e) => e.code, 'code', LoginErrorCode.unknown)
                .having((e) => e.message, 'message', 'Invalid user data'),
          ),
        );
      });
    });

    group('login error cases - Firebase Auth', () {
      // Fresh instances for this group
      final mockAuth = _MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();
      final provider = AuthLoginProviderImpl(
        auth: mockAuth,
        firestore: fakeFirestore,
      );

      tearDown(() {
        reset(mockAuth);
      });

      setUp(() async {
        // Setup valid username and user documents
        await fakeFirestore.collection('usernames').doc('testuser').set({
          'uid': 'user123',
        });

        await fakeFirestore.collection('users').doc('user123').set({
          'email': 'test@example.com',
          'username': 'testuser',
          'createdAt': DateTime.now().toIso8601String(),
        });
      });

      test('maps wrong-password to invalidCredentials', () async {
        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(fb.FirebaseAuthException(code: 'wrong-password'));

        expect(
          () => provider.login(
            const LoginBody(username: 'testuser', password: 'wrongpass'),
          ),
          throwsA(
            isA<LoginError>().having(
              (e) => e.code,
              'code',
              LoginErrorCode.invalidCredentials,
            ),
          ),
        );
      });

      test('maps user-not-found to invalidCredentials', () async {
        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(fb.FirebaseAuthException(code: 'user-not-found'));

        expect(
          () => provider.login(
            const LoginBody(username: 'testuser', password: 'password123'),
          ),
          throwsA(
            isA<LoginError>().having(
              (e) => e.code,
              'code',
              LoginErrorCode.invalidCredentials,
            ),
          ),
        );
      });

      test('maps invalid-credential to invalidCredentials', () async {
        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(fb.FirebaseAuthException(code: 'invalid-credential'));

        expect(
          () => provider.login(
            const LoginBody(username: 'testuser', password: 'password123'),
          ),
          throwsA(
            isA<LoginError>().having(
              (e) => e.code,
              'code',
              LoginErrorCode.invalidCredentials,
            ),
          ),
        );
      });

      test('maps user-disabled to invalidCredentials', () async {
        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(fb.FirebaseAuthException(code: 'user-disabled'));

        expect(
          () => provider.login(
            const LoginBody(username: 'testuser', password: 'password123'),
          ),
          throwsA(
            isA<LoginError>().having(
              (e) => e.code,
              'code',
              LoginErrorCode.invalidCredentials,
            ),
          ),
        );
      });

      test('maps network-request-failed to networkFailure', () async {
        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(fb.FirebaseAuthException(code: 'network-request-failed'));

        expect(
          () => provider.login(
            const LoginBody(username: 'testuser', password: 'password123'),
          ),
          throwsA(
            isA<LoginError>().having(
              (e) => e.code,
              'code',
              LoginErrorCode.networkFailure,
            ),
          ),
        );
      });

      test('maps too-many-requests to networkFailure', () async {
        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(fb.FirebaseAuthException(code: 'too-many-requests'));

        expect(
          () => provider.login(
            const LoginBody(username: 'testuser', password: 'password123'),
          ),
          throwsA(
            isA<LoginError>().having(
              (e) => e.code,
              'code',
              LoginErrorCode.networkFailure,
            ),
          ),
        );
      });

      test('maps unknown auth error code to unknown', () async {
        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(fb.FirebaseAuthException(code: 'some-unknown-error'));

        expect(
          () => provider.login(
            const LoginBody(username: 'testuser', password: 'password123'),
          ),
          throwsA(
            isA<LoginError>()
                .having((e) => e.code, 'code', LoginErrorCode.unknown)
                .having((e) => e.message, 'message', 'some-unknown-error'),
          ),
        );
      });
    });

    group('login error cases - unexpected errors', () {
      // Fresh instances for this group
      final mockAuth = _MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();
      final provider = AuthLoginProviderImpl(
        auth: mockAuth,
        firestore: fakeFirestore,
      );

      tearDown(() {
        reset(mockAuth);
      });

      setUp(() async {
        // Setup valid username and user documents
        await fakeFirestore.collection('usernames').doc('testuser').set({
          'uid': 'user123',
        });

        await fakeFirestore.collection('users').doc('user123').set({
          'email': 'test@example.com',
          'username': 'testuser',
          'createdAt': DateTime.now().toIso8601String(),
        });
      });

      test('maps unexpected exception to unknown error', () async {
        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('Unexpected error'));

        expect(
          () => provider.login(
            const LoginBody(username: 'testuser', password: 'password123'),
          ),
          throwsA(
            isA<LoginError>()
                .having((e) => e.code, 'code', LoginErrorCode.unknown)
                .having(
                  (e) => e.message,
                  'message',
                  'An unexpected error occurred during login',
                ),
          ),
        );
      });
    });

    group('login re-throws domain errors', () {
      // Fresh instances for this group
      final mockAuth = _MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();
      final provider = AuthLoginProviderImpl(
        auth: mockAuth,
        firestore: fakeFirestore,
      );

      tearDown(() {
        reset(mockAuth);
      });

      test('re-throws LoginError without modification', () async {
        // Create a scenario that throws LoginError (username not found)
        expect(
          () => provider.login(
            const LoginBody(username: 'nonexistent', password: 'password123'),
          ),
          throwsA(
            isA<LoginError>().having(
              (e) => e.code,
              'code',
              LoginErrorCode.userNotFound,
            ),
          ),
        );
      });
    });
  });
}

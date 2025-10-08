import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/features/auth_signup/data/providers/auth_signup_provider_impl.dart';
import 'package:ariokan_index/features/auth_signup/domain/providers/auth_signup_provider.dart';
import 'package:ariokan_index/features/auth_signup/domain/usecases/signup_usecase.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_cubit.dart';
import 'package:ariokan_index/features/auth_signup/setup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  group('SignupSetup', () {
    final mockFirebaseAuth = _MockFirebaseAuth();
    final mockFirebaseFirestore = _MockFirebaseFirestore();

    setUp(() {
      // Register Firebase dependencies that SignupSetup expects
      di.registerFactory<FirebaseAuth>(() => mockFirebaseAuth);
      di.registerFactory<FirebaseFirestore>(() => mockFirebaseFirestore);
    });

    tearDown(() {
      // Reset mocks after each test
      reset(mockFirebaseAuth);
      reset(mockFirebaseFirestore);
      // Clean up DI registrations
      di.reset();
    });

    group('init', () {
      test('registers AuthSignupProvider as factory', () {
        SignupSetup.init();

        final provider = di<AuthSignupProvider>();

        expect(provider, isNotNull);
        expect(provider, isA<AuthSignupProviderImpl>());
      });

      test('registers SignupUsecase as factory', () {
        SignupSetup.init();

        final usecase = di<SignupUsecase>();

        expect(usecase, isNotNull);
        expect(usecase, isA<SignupUsecase>());
      });

      test('registers SignupCubit as factory', () {
        SignupSetup.init();

        final cubit = di<SignupCubit>();

        expect(cubit, isNotNull);
        expect(cubit, isA<SignupCubit>());
      });

      test('creates new instances for each factory call', () {
        SignupSetup.init();

        final provider1 = di<AuthSignupProvider>();
        final provider2 = di<AuthSignupProvider>();
        final usecase1 = di<SignupUsecase>();
        final usecase2 = di<SignupUsecase>();
        final cubit1 = di<SignupCubit>();
        final cubit2 = di<SignupCubit>();

        expect(identical(provider1, provider2), isFalse);
        expect(identical(usecase1, usecase2), isFalse);
        expect(identical(cubit1, cubit2), isFalse);
      });

      test('can be called multiple times without error', () {
        expect(SignupSetup.init, returnsNormally);
        expect(SignupSetup.init, returnsNormally);
      });
    });
  });
}

import 'package:ariokan_index/features/auth_signup/domain/exceptions/auth_signup_exceptions.dart';
import 'package:ariokan_index/features/auth_signup/domain/usecases/signup_usecase.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_cubit.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSignupUsecase extends Mock implements SignupUsecase {}

void main() {
  group('SignupCubit', () {
    group('constructor', () {
      test('creates instance with initial state', () {
        final mockUsecase = _MockSignupUsecase();

        final cubit = SignupCubit(signupUsecase: mockUsecase);

        expect(cubit.state, equals(SignupState.initial()));
        expect(cubit.state.username, isEmpty);
        expect(cubit.state.email, isEmpty);
        expect(cubit.state.password, isEmpty);
        expect(cubit.state.status, equals(SignupStatus.idle));
        expect(cubit.state.error, isNull);

        cubit.close();
      });
    });

    group('updateUsername', () {
      final mockUsecase = _MockSignupUsecase();
      late SignupCubit cubit;

      setUp(() {
        cubit = SignupCubit(signupUsecase: mockUsecase);
      });

      tearDown(() {
        cubit.close();
      });

      blocTest<SignupCubit, SignupState>(
        'updates username and clears error',
        build: () => cubit,
        act: (cubit) => cubit.updateUsername('testuser'),
        expect: () => [SignupState.initial().copyWith(username: 'testuser')],
      );

      blocTest<SignupCubit, SignupState>(
        'clears existing error when updating username',
        build: () => cubit,
        seed: () => SignupState.initial().copyWith(
          status: SignupStatus.error,
          error: const SignupError(SignupErrorCode.usernameInvalid),
        ),
        act: (cubit) => cubit.updateUsername('newuser'),
        expect: () => [
          SignupState.initial().copyWith(
            username: 'newuser',
            status: SignupStatus.error,
            error: null,
          ),
        ],
      );
    });

    group('updateEmail', () {
      final mockUsecase = _MockSignupUsecase();
      late SignupCubit cubit;

      setUp(() {
        cubit = SignupCubit(signupUsecase: mockUsecase);
      });

      tearDown(() {
        cubit.close();
      });

      blocTest<SignupCubit, SignupState>(
        'updates email and clears error',
        build: () => cubit,
        act: (cubit) => cubit.updateEmail('test@example.com'),
        expect: () => [
          SignupState.initial().copyWith(email: 'test@example.com'),
        ],
      );

      blocTest<SignupCubit, SignupState>(
        'clears existing error when updating email',
        build: () => cubit,
        seed: () => SignupState.initial().copyWith(
          status: SignupStatus.error,
          error: const SignupError(SignupErrorCode.emailInvalid),
        ),
        act: (cubit) => cubit.updateEmail('new@example.com'),
        expect: () => [
          SignupState.initial().copyWith(
            email: 'new@example.com',
            status: SignupStatus.error,
            error: null,
          ),
        ],
      );
    });

    group('updatePassword', () {
      final mockUsecase = _MockSignupUsecase();
      late SignupCubit cubit;

      setUp(() {
        cubit = SignupCubit(signupUsecase: mockUsecase);
      });

      tearDown(() {
        cubit.close();
      });

      blocTest<SignupCubit, SignupState>(
        'updates password and clears error',
        build: () => cubit,
        act: (cubit) => cubit.updatePassword('password123'),
        expect: () => [SignupState.initial().copyWith(password: 'password123')],
      );

      blocTest<SignupCubit, SignupState>(
        'clears existing error when updating password',
        build: () => cubit,
        seed: () => SignupState.initial().copyWith(
          status: SignupStatus.error,
          error: const SignupError(SignupErrorCode.passwordWeak),
        ),
        act: (cubit) => cubit.updatePassword('newpassword'),
        expect: () => [
          SignupState.initial().copyWith(
            password: 'newpassword',
            status: SignupStatus.error,
            error: null,
          ),
        ],
      );
    });

    group('submit - validation', () {
      final mockUsecase = _MockSignupUsecase();
      late SignupCubit cubit;

      setUp(() {
        cubit = SignupCubit(signupUsecase: mockUsecase);
      });

      tearDown(() {
        cubit.close();
        reset(mockUsecase);
      });

      blocTest<SignupCubit, SignupState>(
        'emits usernameInvalid error when username is too short',
        build: () => cubit,
        seed: () => SignupState.initial().copyWith(
          username: 'ab',
          email: 'test@example.com',
          password: 'password123',
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          SignupState.initial().copyWith(
            username: 'ab',
            email: 'test@example.com',
            password: 'password123',
            status: SignupStatus.error,
            error: const SignupError(SignupErrorCode.usernameInvalid),
          ),
        ],
        verify: (_) {
          verifyNever(
            () => mockUsecase.call(
              username: any(named: 'username'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          );
        },
      );

      blocTest<SignupCubit, SignupState>(
        'emits usernameInvalid error when username is too long',
        build: () => cubit,
        seed: () => SignupState.initial().copyWith(
          username: 'a' * 31, // 31 chars, max is 30
          email: 'test@example.com',
          password: 'password123',
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          SignupState.initial().copyWith(
            username: 'a' * 31,
            email: 'test@example.com',
            password: 'password123',
            status: SignupStatus.error,
            error: const SignupError(SignupErrorCode.usernameInvalid),
          ),
        ],
      );

      blocTest<SignupCubit, SignupState>(
        'emits emailInvalid error when email format is invalid',
        build: () => cubit,
        seed: () => SignupState.initial().copyWith(
          username: 'testuser',
          email: 'invalid-email',
          password: 'password123',
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          SignupState.initial().copyWith(
            username: 'testuser',
            email: 'invalid-email',
            password: 'password123',
            status: SignupStatus.error,
            error: const SignupError(SignupErrorCode.emailInvalid),
          ),
        ],
      );

      blocTest<SignupCubit, SignupState>(
        'emits passwordWeak error when password is too short',
        build: () => cubit,
        seed: () => SignupState.initial().copyWith(
          username: 'testuser',
          email: 'test@example.com',
          password: 'short',
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          SignupState.initial().copyWith(
            username: 'testuser',
            email: 'test@example.com',
            password: 'short',
            status: SignupStatus.error,
            error: const SignupError(SignupErrorCode.passwordWeak),
          ),
        ],
      );

      blocTest<SignupCubit, SignupState>(
        'emits passwordWeak error when password is too long',
        build: () => cubit,
        seed: () => SignupState.initial().copyWith(
          username: 'testuser',
          email: 'test@example.com',
          password: 'a' * 129, // 129 chars, max is 128
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          SignupState.initial().copyWith(
            username: 'testuser',
            email: 'test@example.com',
            password: 'a' * 129,
            status: SignupStatus.error,
            error: const SignupError(SignupErrorCode.passwordWeak),
          ),
        ],
      );
    });

    group('submit - success', () {
      final mockUsecase = _MockSignupUsecase();
      late SignupCubit cubit;

      setUp(() {
        cubit = SignupCubit(signupUsecase: mockUsecase);
        when(
          () => mockUsecase.call(
            username: any(named: 'username'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async {});
      });

      tearDown(() {
        cubit.close();
        reset(mockUsecase);
      });

      blocTest<SignupCubit, SignupState>(
        'emits submitting then success on successful signup',
        build: () => cubit,
        seed: () => SignupState.initial().copyWith(
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          SignupState.initial().copyWith(
            username: 'testuser',
            email: 'test@example.com',
            password: 'password123',
            status: SignupStatus.submitting,
          ),
          SignupState.initial().copyWith(
            username: 'testuser',
            email: 'test@example.com',
            password: 'password123',
            status: SignupStatus.success,
          ),
        ],
        verify: (_) {
          verify(
            () => mockUsecase.call(
              username: 'testuser',
              email: 'test@example.com',
              password: 'password123',
            ),
          ).called(1);
        },
      );

      blocTest<SignupCubit, SignupState>(
        'calls usecase with correct parameters',
        build: () => cubit,
        seed: () => SignupState.initial().copyWith(
          username: 'validuser',
          email: 'valid@example.com',
          password: 'validpassword123',
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          SignupState.initial().copyWith(
            username: 'validuser',
            email: 'valid@example.com',
            password: 'validpassword123',
            status: SignupStatus.submitting,
          ),
          SignupState.initial().copyWith(
            username: 'validuser',
            email: 'valid@example.com',
            password: 'validpassword123',
            status: SignupStatus.success,
          ),
        ],
        verify: (_) {
          verify(
            () => mockUsecase.call(
              username: 'validuser',
              email: 'valid@example.com',
              password: 'validpassword123',
            ),
          ).called(1);
        },
      );
    });

    group('submit - errors', () {
      final mockUsecase = _MockSignupUsecase();
      late SignupCubit cubit;

      setUp(() {
        cubit = SignupCubit(signupUsecase: mockUsecase);
      });

      tearDown(() {
        cubit.close();
        reset(mockUsecase);
      });

      blocTest<SignupCubit, SignupState>(
        'emits error state when usecase throws usernameTaken',
        build: () => cubit,
        setUp: () {
          when(
            () => mockUsecase.call(
              username: any(named: 'username'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(
            const AuthSignupException(
              AuthSignupExceptionCode.usernameTaken,
              message: 'Username is already taken',
            ),
          );
        },
        seed: () => SignupState.initial().copyWith(
          username: 'takenuser',
          email: 'test@example.com',
          password: 'password123',
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          SignupState.initial().copyWith(
            username: 'takenuser',
            email: 'test@example.com',
            password: 'password123',
            status: SignupStatus.submitting,
          ),
          SignupState.initial().copyWith(
            username: 'takenuser',
            email: 'test@example.com',
            password: 'password123',
            status: SignupStatus.error,
            error: const SignupError(SignupErrorCode.usernameTaken),
          ),
        ],
      );

      blocTest<SignupCubit, SignupState>(
        'emits error state when usecase throws emailAlreadyInUse',
        build: () => cubit,
        setUp: () {
          when(
            () => mockUsecase.call(
              username: any(named: 'username'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(
            const AuthSignupException(
              AuthSignupExceptionCode.emailAlreadyInUse,
              message: 'Email is already in use',
            ),
          );
        },
        seed: () => SignupState.initial().copyWith(
          username: 'newuser',
          email: 'existing@example.com',
          password: 'password123',
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          SignupState.initial().copyWith(
            username: 'newuser',
            email: 'existing@example.com',
            password: 'password123',
            status: SignupStatus.submitting,
          ),
          SignupState.initial().copyWith(
            username: 'newuser',
            email: 'existing@example.com',
            password: 'password123',
            status: SignupStatus.error,
            error: const SignupError(SignupErrorCode.emailAlreadyInUse),
          ),
        ],
      );

      blocTest<SignupCubit, SignupState>(
        'emits error state when usecase throws emailInvalid',
        build: () => cubit,
        setUp: () {
          when(
            () => mockUsecase.call(
              username: any(named: 'username'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(
            const AuthSignupException(
              AuthSignupExceptionCode.emailInvalid,
              message: 'Email is invalid',
            ),
          );
        },
        seed: () => SignupState.initial().copyWith(
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          SignupState.initial().copyWith(
            username: 'testuser',
            email: 'test@example.com',
            password: 'password123',
            status: SignupStatus.submitting,
          ),
          SignupState.initial().copyWith(
            username: 'testuser',
            email: 'test@example.com',
            password: 'password123',
            status: SignupStatus.error,
            error: const SignupError(SignupErrorCode.emailInvalid),
          ),
        ],
      );

      blocTest<SignupCubit, SignupState>(
        'emits error state when usecase throws passwordWeak',
        build: () => cubit,
        setUp: () {
          when(
            () => mockUsecase.call(
              username: any(named: 'username'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(
            const AuthSignupException(
              AuthSignupExceptionCode.passwordWeak,
              message: 'Password is too weak',
            ),
          );
        },
        seed: () => SignupState.initial().copyWith(
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          SignupState.initial().copyWith(
            username: 'testuser',
            email: 'test@example.com',
            password: 'password123',
            status: SignupStatus.submitting,
          ),
          SignupState.initial().copyWith(
            username: 'testuser',
            email: 'test@example.com',
            password: 'password123',
            status: SignupStatus.error,
            error: const SignupError(SignupErrorCode.passwordWeak),
          ),
        ],
      );

      blocTest<SignupCubit, SignupState>(
        'emits error state when usecase throws networkFailure',
        build: () => cubit,
        setUp: () {
          when(
            () => mockUsecase.call(
              username: any(named: 'username'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(
            const AuthSignupException(
              AuthSignupExceptionCode.networkFailure,
              message: 'Network request failed',
            ),
          );
        },
        seed: () => SignupState.initial().copyWith(
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          SignupState.initial().copyWith(
            username: 'testuser',
            email: 'test@example.com',
            password: 'password123',
            status: SignupStatus.submitting,
          ),
          SignupState.initial().copyWith(
            username: 'testuser',
            email: 'test@example.com',
            password: 'password123',
            status: SignupStatus.error,
            error: const SignupError(SignupErrorCode.networkFailure),
          ),
        ],
      );
    });

    group('submit - double submission prevention', () {
      final mockUsecase = _MockSignupUsecase();
      late SignupCubit cubit;

      setUp(() {
        cubit = SignupCubit(signupUsecase: mockUsecase);
      });

      tearDown(() {
        cubit.close();
        reset(mockUsecase);
      });

      test('prevents double submission while request is in flight', () async {
        when(
          () => mockUsecase.call(
            username: any(named: 'username'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
        });

        cubit.emit(
          SignupState.initial().copyWith(
            username: 'testuser',
            email: 'test@example.com',
            password: 'password123',
          ),
        );

        // Start first submission
        final future1 = cubit.submit();
        // Try second submission immediately
        final future2 = cubit.submit();

        // Both futures should be the same
        expect(identical(future1, future2), isTrue);

        await future1;

        // Verify usecase was only called once
        verify(
          () => mockUsecase.call(
            username: any(named: 'username'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).called(1);
      });
    });
  });
}

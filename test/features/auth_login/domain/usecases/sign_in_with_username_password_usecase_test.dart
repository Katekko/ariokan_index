import 'package:ariokan_index/features/auth_login/data/models/login_body.dart';
import 'package:ariokan_index/features/auth_login/domain/exceptions/login_exceptions.dart';
import 'package:ariokan_index/features/auth_login/domain/providers/auth_login_provider.dart';
import 'package:ariokan_index/features/auth_login/domain/usecases/sign_in_with_username_password_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthLoginProvider extends Mock implements AuthLoginProvider {}

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(
      const LoginBody(username: 'fallback', password: 'fallback'),
    );
  });

  group('SignInWithUsernamePasswordUseCase', () {
    group('constructor', () {
      test('creates instance with provided provider', () {
        final mockProvider = _MockAuthLoginProvider();

        final usecase = SignInWithUsernamePasswordUseCase(mockProvider);

        expect(usecase, isNotNull);
      });
    });

    group('call', () {
      final mockProvider = _MockAuthLoginProvider();
      late SignInWithUsernamePasswordUseCase usecase;

      tearDown(() {
        reset(mockProvider);
      });

      setUp(() {
        usecase = SignInWithUsernamePasswordUseCase(mockProvider);
      });

      test('calls provider.login with correct LoginBody', () async {
        when(() => mockProvider.login(any())).thenAnswer((_) async {});

        await usecase.call(username: 'testuser', password: 'password123');

        final captured = verify(
          () => mockProvider.login(captureAny()),
        ).captured;

        expect(captured.length, equals(1));
        final body = captured.first as LoginBody;
        expect(body.username, equals('testuser'));
        expect(body.password, equals('password123'));
      });

      test('completes successfully when provider succeeds', () async {
        when(() => mockProvider.login(any())).thenAnswer((_) async {});

        await expectLater(
          usecase.call(username: 'successuser', password: 'password123'),
          completes,
        );

        verify(() => mockProvider.login(any())).called(1);
      });

      test(
        'throws LoginError when provider throws invalid credentials',
        () async {
          const error = LoginError(
            LoginErrorCode.invalidCredentials,
            message: 'Invalid credentials',
          );

          when(() => mockProvider.login(any())).thenThrow(error);

          expect(
            () =>
                usecase.call(username: 'wronguser', password: 'wrongpassword'),
            throwsA(
              isA<LoginError>()
                  .having(
                    (e) => e.code,
                    'code',
                    LoginErrorCode.invalidCredentials,
                  )
                  .having((e) => e.message, 'message', 'Invalid credentials'),
            ),
          );

          verify(() => mockProvider.login(any())).called(1);
        },
      );

      test('throws LoginError when provider throws user not found', () async {
        const error = LoginError(
          LoginErrorCode.userNotFound,
          message: 'User not found',
        );

        when(() => mockProvider.login(any())).thenThrow(error);

        expect(
          () => usecase.call(username: 'nonexistent', password: 'password123'),
          throwsA(
            isA<LoginError>()
                .having((e) => e.code, 'code', LoginErrorCode.userNotFound)
                .having((e) => e.message, 'message', 'User not found'),
          ),
        );

        verify(() => mockProvider.login(any())).called(1);
      });

      test('throws LoginError when provider throws network failure', () async {
        const error = LoginError(
          LoginErrorCode.networkFailure,
          message: 'Network error',
        );

        when(() => mockProvider.login(any())).thenThrow(error);

        expect(
          () => usecase.call(username: 'testuser', password: 'password123'),
          throwsA(
            isA<LoginError>()
                .having((e) => e.code, 'code', LoginErrorCode.networkFailure)
                .having((e) => e.message, 'message', 'Network error'),
          ),
        );

        verify(() => mockProvider.login(any())).called(1);
      });

      test('throws LoginError when provider throws unknown error', () async {
        const error = LoginError(
          LoginErrorCode.unknown,
          message: 'Unknown error',
        );

        when(() => mockProvider.login(any())).thenThrow(error);

        expect(
          () => usecase.call(username: 'testuser', password: 'password123'),
          throwsA(
            isA<LoginError>()
                .having((e) => e.code, 'code', LoginErrorCode.unknown)
                .having((e) => e.message, 'message', 'Unknown error'),
          ),
        );

        verify(() => mockProvider.login(any())).called(1);
      });

      test('creates LoginBody with empty strings when provided', () async {
        when(() => mockProvider.login(any())).thenAnswer((_) async {});

        await usecase.call(username: '', password: '');

        final captured = verify(
          () => mockProvider.login(captureAny()),
        ).captured;

        expect(captured.length, equals(1));
        final body = captured.first as LoginBody;
        expect(body.username, equals(''));
        expect(body.password, equals(''));
      });
    });
  });
}

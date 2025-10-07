import 'package:ariokan_index/features/auth_signup/data/models/signup_body.dart';
import 'package:ariokan_index/features/auth_signup/domain/exceptions/auth_signup_exceptions.dart';
import 'package:ariokan_index/features/auth_signup/domain/providers/auth_signup_provider.dart';
import 'package:ariokan_index/features/auth_signup/domain/usecases/signup_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthSignupProvider extends Mock implements AuthSignupProvider {}

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(
      const SignupBody(
        username: 'fallback',
        email: 'fallback@example.com',
        password: 'fallback',
      ),
    );
  });

  group('SignupUsecase', () {
    group('constructor', () {
      test('creates instance with provided provider', () {
        final mockProvider = _MockAuthSignupProvider();
        
        final usecase = SignupUsecase(mockProvider);

        expect(usecase, isNotNull);
        expect(usecase.provider, equals(mockProvider));
      });
    });

    group('call', () {
      final mockProvider = _MockAuthSignupProvider();
      late SignupUsecase usecase;

      tearDown(() {
        reset(mockProvider);
      });

      setUp(() {
        usecase = SignupUsecase(mockProvider);
      });

      test('calls provider.signup with correct SignupBody', () async {
        when(() => mockProvider.signup(any())).thenAnswer((_) async {});

        await usecase.call(
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
        );

        final captured = verify(
          () => mockProvider.signup(captureAny()),
        ).captured;

        expect(captured.length, equals(1));
        final body = captured.first as SignupBody;
        expect(body.username, equals('testuser'));
        expect(body.email, equals('test@example.com'));
        expect(body.password, equals('password123'));
      });

      test('completes successfully when provider succeeds', () async {
        when(() => mockProvider.signup(any())).thenAnswer((_) async {});

        await expectLater(
          usecase.call(
            username: 'successuser',
            email: 'success@example.com',
            password: 'password123',
          ),
          completes,
        );

        verify(() => mockProvider.signup(any())).called(1);
      });

      test('throws AuthSignupException when provider throws', () async {
        const exception = AuthSignupException(
          AuthSignupExceptionCode.usernameTaken,
          message: 'Username is already taken',
        );

        when(() => mockProvider.signup(any())).thenThrow(exception);

        expect(
          () => usecase.call(
            username: 'takenuser',
            email: 'taken@example.com',
            password: 'password123',
          ),
          throwsA(
            isA<AuthSignupException>()
                .having((e) => e.code, 'code', AuthSignupExceptionCode.usernameTaken)
                .having((e) => e.message, 'message', 'Username is already taken'),
          ),
        );
      });

      test('propagates emailAlreadyInUse exception', () async {
        const exception = AuthSignupException(
          AuthSignupExceptionCode.emailAlreadyInUse,
          message: 'Email is already in use',
        );

        when(() => mockProvider.signup(any())).thenThrow(exception);

        expect(
          () => usecase.call(
            username: 'newuser',
            email: 'existing@example.com',
            password: 'password123',
          ),
          throwsA(
            isA<AuthSignupException>().having(
              (e) => e.code,
              'code',
              AuthSignupExceptionCode.emailAlreadyInUse,
            ),
          ),
        );
      });

      test('propagates emailInvalid exception', () async {
        const exception = AuthSignupException(
          AuthSignupExceptionCode.emailInvalid,
          message: 'Email is invalid',
        );

        when(() => mockProvider.signup(any())).thenThrow(exception);

        expect(
          () => usecase.call(
            username: 'testuser',
            email: 'invalid-email',
            password: 'password123',
          ),
          throwsA(
            isA<AuthSignupException>().having(
              (e) => e.code,
              'code',
              AuthSignupExceptionCode.emailInvalid,
            ),
          ),
        );
      });

      test('propagates passwordWeak exception', () async {
        const exception = AuthSignupException(
          AuthSignupExceptionCode.passwordWeak,
          message: 'Password is too weak',
        );

        when(() => mockProvider.signup(any())).thenThrow(exception);

        expect(
          () => usecase.call(
            username: 'testuser',
            email: 'test@example.com',
            password: '123',
          ),
          throwsA(
            isA<AuthSignupException>().having(
              (e) => e.code,
              'code',
              AuthSignupExceptionCode.passwordWeak,
            ),
          ),
        );
      });

      test('propagates networkFailure exception', () async {
        const exception = AuthSignupException(
          AuthSignupExceptionCode.networkFailure,
          message: 'Network request failed',
        );

        when(() => mockProvider.signup(any())).thenThrow(exception);

        expect(
          () => usecase.call(
            username: 'testuser',
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(
            isA<AuthSignupException>().having(
              (e) => e.code,
              'code',
              AuthSignupExceptionCode.networkFailure,
            ),
          ),
        );
      });

      test('creates SignupBody with all parameters in correct order', () async {
        when(() => mockProvider.signup(any())).thenAnswer((_) async {});

        await usecase.call(
          username: 'ordertest',
          email: 'order@example.com',
          password: 'orderpass123',
        );

        final captured = verify(
          () => mockProvider.signup(captureAny()),
        ).captured.first as SignupBody;

        expect(captured.username, equals('ordertest'));
        expect(captured.email, equals('order@example.com'));
        expect(captured.password, equals('orderpass123'));
      });

      test('handles special characters in parameters', () async {
        when(() => mockProvider.signup(any())).thenAnswer((_) async {});

        await usecase.call(
          username: 'user_123',
          email: 'test+special@example.com',
          password: 'P@ssw0rd!',
        );

        final captured = verify(
          () => mockProvider.signup(captureAny()),
        ).captured.first as SignupBody;

        expect(captured.username, equals('user_123'));
        expect(captured.email, equals('test+special@example.com'));
        expect(captured.password, equals('P@ssw0rd!'));
      });
    });
  });
}

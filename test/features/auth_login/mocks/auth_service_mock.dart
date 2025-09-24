import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/shared/services/auth_service.dart';

class AuthServiceMock extends Mock implements AuthService {
  AuthServiceMock._();

  static AuthServiceMock register() {
    final mock = AuthServiceMock._();

    setUpAll(() => di.registerFactory<AuthService>(() => mock));

    setUp(() {
      // Provide benign defaults for all methods
      when(
        () => mock.signInWithUsernamePassword(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => mock.createUserEmailPassword(any(), any()),
      ).thenAnswer((_) async => 'mock-uid');
      when(mock.deleteCurrentUserIfExists).thenAnswer((_) async {});
      when(mock.signOut).thenAnswer((_) async {});
      when(() => mock.isSignedIn).thenReturn(false);
    });
    tearDown(() => reset(mock));
    return mock;
  }
}

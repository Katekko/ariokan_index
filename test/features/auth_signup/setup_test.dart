import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:ariokan_index/features/auth_signup/setup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _UserRepositoryMock extends Mock implements UserRepository {}

void main() {
  group('SignupSetup.init', () {
    setUp(() {
      di.reset(dispose: false);
    });

    test(
      'registers factory producing controller with injected UserRepository',
      () {
        final repo = _UserRepositoryMock();
        di.registerLazySingleton<UserRepository>(() => repo);

        SignupSetup.init();

        final c1 = di<SignupController>();
        final c2 = di<SignupController>();

        expect(c1, isA<SignupController>());
        expect(
          identical(c1, c2),
          isFalse,
          reason: 'Factory should create new instance each call',
        );

        expect(di<UserRepository>(), same(repo));
      },
    );
  });
}

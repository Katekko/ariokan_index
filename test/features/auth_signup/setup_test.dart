import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_cubit.dart';
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

        final c1 = di<SignupCubit>();
        final c2 = di<SignupCubit>();

        expect(c1, isA<SignupCubit>());
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

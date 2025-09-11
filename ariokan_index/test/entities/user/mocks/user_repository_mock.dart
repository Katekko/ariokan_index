import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/shared/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/entities_faker.dart';

class UserRepositoryMock extends Mock implements UserRepository {
  UserRepositoryMock._();

  static UserRepository register() {
    final mock = UserRepositoryMock._();

    setUpAll(() => di.registerFactory<UserRepository>(() => mock));

    setUp(() {
      when(
        () => mock.createUserWithUsername(
          username: any(named: 'username'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Success(userFake()));
    });

    tearDown(() => reset(mock));

    return mock;
  }
}

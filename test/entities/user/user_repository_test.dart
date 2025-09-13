import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/features/auth_signup/model/signup_state.dart';
import 'package:ariokan_index/shared/utils/result.dart';
import 'package:ariokan_index/entities/user/user.dart';

// Failing test placeholder enforcing atomic behavior expectations.
class InMemoryUserRepository extends UserRepository {
  final Map<String, User> _usersById = {};
  final Map<String, String> _usernameToId = {};
  int _id = 0;
  bool failAfterAuth = false;
  int rollbackCount = 0;

  // Instrumentation helpers
  bool debugIsUsernameReserved(String username) =>
      _usernameToId.containsKey(username);

  @override
  Future<Result<SignupError, User>> createUserWithUsername({
    required String username,
    required String email,
    required String password,
  }) async {
    if (_usernameToId.containsKey(username)) {
      return Failure(
        SignupError(SignupErrorCode.usernameTaken, message: 'taken'),
      );
    }
    final id = (++_id).toString();
    // Simulate atomic reservation
    _usernameToId[username] = id;
    if (failAfterAuth) {
      // Simulated failure after creating auth user but before committing user doc.
      // Proper behavior: rollback the username reservation so it becomes free again.
      final removed = _usernameToId.remove(username); // rollback
      if (removed != null) rollbackCount++;
      // Auto-reset flag so subsequent attempts proceed normally.
      failAfterAuth = false;
      return Failure(
        SignupError(
          SignupErrorCode.networkFailure,
          message: 'simulated post-auth failure rolled back',
        ),
      );
    }
    final user = User(
      id: id,
      username: username,
      email: email,
      createdAt: DateTime.utc(2025),
    );
    _usersById[id] = user;
    return Success(user);
  }
}

void main() {
  group('UserRepository atomic behavior', () {
    test('creates user successfully', () async {
      final repo = InMemoryUserRepository();
      final r = await repo.createUserWithUsername(
        username: 'alice',
        email: 'a@b.c',
        password: 'pw',
      );
      expect(r.isSuccess, isTrue);
    });

    test('prevents duplicate usernames', () async {
      final repo = InMemoryUserRepository();
      await repo.createUserWithUsername(
        username: 'alice',
        email: 'a@b.c',
        password: 'pw',
      );
      final r2 = await repo.createUserWithUsername(
        username: 'alice',
        email: 'x@y.z',
        password: 'pw',
      );
      expect(r2.isFailure, isTrue);
      expect((r2 as Failure).error.code, SignupErrorCode.usernameTaken);
    });

    test(
      'failure after auth creation rollbacks reservation freeing username',
      () async {
        final repo = InMemoryUserRepository()..failAfterAuth = true;
        final r = await repo.createUserWithUsername(
          username: 'alice',
          email: 'a@b.c',
          password: 'pw',
        );
        expect(r.isFailure, isTrue);
        expect(
          repo.rollbackCount,
          1,
          reason: 'rollback should increment counter',
        );
        expect(
          repo.debugIsUsernameReserved('alice'),
          isFalse,
          reason: 'username reservation should be cleared',
        );
        // Username should be free after rollback.
        final r2 = await repo.createUserWithUsername(
          username: 'alice',
          email: 'x@y.z',
          password: 'pw',
        );
        expect(
          r2.isSuccess,
          isTrue,
          reason: 'username should be free after rollback',
        );
      },
    );
  });
}

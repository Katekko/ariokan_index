import 'package:ariokan_index/shared/utils/result.dart';
import 'package:ariokan_index/entities/user/user.dart';
import 'package:ariokan_index/features/auth_signup/model/signup_state.dart';

/// Repository responsible for atomic creation of a user + username uniqueness enforcement.
abstract class UserRepository {
  Future<Result<SignupError, User>> createUserWithUsername({
    required String username,
    required String email,
    required String password,
  });

  /// Logs a user in, returning uid/token string on success.
  /// Throws typed login exceptions (see login_exceptions.dart) for failures.
  Future<String> loginWithUsername({
    required String username,
    required String password,
  });
}

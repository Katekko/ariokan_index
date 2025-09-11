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
}

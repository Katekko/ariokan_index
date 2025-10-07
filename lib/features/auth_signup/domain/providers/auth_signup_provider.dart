import 'package:ariokan_index/features/auth_signup/data/models/signup_body.dart';

abstract class AuthSignupProvider {
  Future<void> signup(SignupBody body);
}

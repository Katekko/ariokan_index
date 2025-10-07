import 'package:ariokan_index/features/auth_login/data/models/login_body.dart';

abstract class AuthLoginProvider {
  Future<void> login(LoginBody body);
}

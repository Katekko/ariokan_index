import 'package:ariokan_index/features/auth_login/data/models/login_body.dart';

import '../providers/auth_login_provider.dart';

class SignInWithUsernamePasswordUseCase {
  SignInWithUsernamePasswordUseCase(this._provider);

  final AuthLoginProvider _provider;

  Future<void> call({
    required String username,
    required String password,
  }) async {
    final body = LoginBody(username: username, password: password);

    await _provider.login(body);
  }
}

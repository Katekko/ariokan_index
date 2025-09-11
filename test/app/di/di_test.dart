import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DI setup', () {
    test('setupDependencies registers types without instantiation', () async {
      di.reset();
      await setupDependencies();
      expect(di.isRegistered<UserRepository>(), isTrue);
      expect(di.isRegistered<SignupController>(), isTrue);
      // Do NOT resolve to avoid hitting real Firebase impl in test env.
    });
  });
}

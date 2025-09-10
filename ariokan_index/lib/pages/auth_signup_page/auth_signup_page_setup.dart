import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:ariokan_index/pages/auth_signup_page/auth_signup_page.dart';
import 'package:ariokan_index/app/di/di.dart';
import 'package:ariokan_index/entities/user/user_repository.dart';

/// Provides dependencies for AuthSignupPage via BlocProvider.
class AuthSignupPageSetup extends StatelessWidget {
  const AuthSignupPageSetup({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignupController>(
      create: (_) => SignupController(di<UserRepository>()),
      child: const AuthSignupPage(),
    );
  }
}

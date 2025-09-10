import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:ariokan_index/features/auth_signup/model/signup_state.dart';
import 'package:ariokan_index/features/auth_signup/ui/signup_form.dart';
import 'package:ariokan_index/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// AuthSignupPage (T028)
/// Embeds [SignupForm] and performs redirect to '/decks' when
/// [SignupStatus.success] is reached. Navigation is idempotent.
class AuthSignupPage extends StatefulWidget {
  const AuthSignupPage({super.key});

  @override
  State<AuthSignupPage> createState() => _AuthSignupPageState();
}

class _AuthSignupPageState extends State<AuthSignupPage> {
  bool _navigated = false;

  bool _listenWhenStatusChanged(SignupState previous, SignupState next) =>
      previous.status != next.status;

  void _onStatusChanged(BuildContext context, SignupState state) {
    if (!_navigated && state.status == SignupStatus.success) {
      _navigated = true;
      context.go('/decks');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<SignupController>();
    return BlocListener<SignupController, SignupState>(
      bloc: controller,
      listenWhen: _listenWhenStatusChanged,
      listener: _onStatusChanged,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.signup_title)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: const SignupForm(),
            ),
          ),
        ),
      ),
    );
  }
}

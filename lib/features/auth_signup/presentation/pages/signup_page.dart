export '../cubit/signup_cubit.dart';
import 'package:ariokan_index/app/di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_cubit.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_state.dart';
import 'package:ariokan_index/features/auth_signup/presentation/widgets/signup_form_widget.dart';
import 'package:ariokan_index/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

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
    final controller = context.read<SignupCubit>();
    return BlocProvider(
      create: (_) => di.get<SignupCubit>(),
      child: BlocListener<SignupCubit, SignupState>(
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
                child: const SignupFormWidget(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

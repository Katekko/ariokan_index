import 'package:ariokan_index/app/di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ariokan_index/features/auth_login/presentation/cubit/login_cubit.dart';
import 'package:ariokan_index/features/auth_login/presentation/cubit/login_state.dart';
import 'package:ariokan_index/features/auth_login/presentation/widgets/login_form.dart';
import 'package:ariokan_index/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _navigated = false;

  bool _listenWhenStatusChanged(LoginState previous, LoginState next) =>
      previous.status != next.status;

  void _onStatusChanged(BuildContext context, LoginState state) {
    if (!_navigated && state.status == LoginStatus.success) {
      _navigated = true;
      context.go('/decks');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => di.get<LoginCubit>(),
      child: Builder(
        builder: (context) {
          return BlocListener<LoginCubit, LoginState>(
            bloc: context.read<LoginCubit>(),
            listenWhen: _listenWhenStatusChanged,
            listener: _onStatusChanged,
            child: Scaffold(
              appBar: AppBar(title: Text(l10n.login_title)),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: const SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: LoginForm(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

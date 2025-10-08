import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ariokan_index/features/auth_login/presentation/cubit/login_cubit.dart';
import 'package:ariokan_index/features/auth_login/presentation/cubit/login_state.dart';
import 'package:ariokan_index/features/auth_login/domain/exceptions/login_exceptions.dart';
import 'package:ariokan_index/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final cubit = context.read<LoginCubit>();

        return Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Username field
              TextField(
                key: const Key('login_username_field'),
                onChanged: cubit.updateUsername,
                enabled: !state.isLoading,
                decoration: InputDecoration(
                  labelText: l10n.login_username_label,
                  border: const OutlineInputBorder(),
                  errorText: _getUsernameError(state, l10n),
                ),
              ),
              const SizedBox(height: 16),

              // Password field
              TextField(
                key: const Key('login_password_field'),
                onChanged: cubit.updatePassword,
                obscureText: true,
                enabled: !state.isLoading,
                decoration: InputDecoration(
                  labelText: l10n.login_password_label,
                  border: const OutlineInputBorder(),
                  errorText: _getPasswordError(state, l10n),
                ),
              ),
              const SizedBox(height: 24),

              // Error message (for auth/network errors)
              if (state.error != null &&
                  state.error!.code != LoginErrorCode.usernameEmpty &&
                  state.error!.code != LoginErrorCode.passwordEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _getErrorMessage(state.error!, l10n),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Login button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  key: const Key('login_submit_button'),
                  onPressed: state.canSubmit && !state.isLoading
                      ? cubit.submit
                      : null,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.login_button),
                ),
              ),
              const SizedBox(height: 16),

              // Sign up link
              TextButton(
                key: const Key('login_signup_link'),
                onPressed: state.isLoading ? null : () => context.go('/signup'),
                child: Text(l10n.login_signup),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Returns username field error or null
  String? _getUsernameError(LoginState state, AppLocalizations l10n) {
    if (state.status != LoginStatus.error) return null;
    if (state.error?.code == LoginErrorCode.usernameEmpty) {
      return l10n.login_error_usernameEmpty;
    }
    return null;
  }

  /// Returns password field error or null
  String? _getPasswordError(LoginState state, AppLocalizations l10n) {
    if (state.status != LoginStatus.error) return null;
    if (state.error?.code == LoginErrorCode.passwordEmpty) {
      return l10n.login_error_passwordEmpty;
    }
    return null;
  }

  /// Maps LoginError to localized error message
  String _getErrorMessage(LoginError error, AppLocalizations l10n) {
    switch (error.code) {
      case LoginErrorCode.invalidCredentials:
      case LoginErrorCode.userNotFound:
        return l10n.login_error_invalidCredentials;
      case LoginErrorCode.networkFailure:
        return l10n.login_error_networkFailure;
      case LoginErrorCode.unknown:
        return l10n.login_error_unknown;
      case LoginErrorCode.usernameEmpty:
      case LoginErrorCode.passwordEmpty:
        // These are shown in field errors
        return '';
    }
  }
}

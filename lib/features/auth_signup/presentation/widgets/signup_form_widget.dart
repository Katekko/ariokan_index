import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_cubit.dart';
import 'package:ariokan_index/features/auth_signup/presentation/cubit/signup_state.dart';
import 'package:ariokan_index/l10n/app_localizations.dart';

class SignupFormWidget extends StatefulWidget {
  const SignupFormWidget({super.key});

  @override
  State<SignupFormWidget> createState() => _SignupFormWidgetState();
}

class _SignupFormWidgetState extends State<SignupFormWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  String? _usernameValidator(String? v) {
    final l10n = AppLocalizations.of(context)!;
    if ((v ?? '').isEmpty) return l10n.signup_field_error_username_required;
    if (v!.length < 3) return l10n.signup_error_usernameInvalid;
    return null;
  }

  String? _emailValidator(String? v) {
    final l10n = AppLocalizations.of(context)!;
    if ((v ?? '').isEmpty) return l10n.signup_field_error_email_required;
    if (!v!.contains('@')) return l10n.signup_error_emailInvalid;
    return null;
  }

  String? _passwordValidator(String? v) {
    final l10n = AppLocalizations.of(context)!;
    if ((v ?? '').isEmpty) return l10n.signup_field_error_password_required;
    if (v!.length < 6) return l10n.signup_error_passwordWeak;
    return null;
  }

  void _onSubmit() {
    setState(() => _submitted = true);
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    context.read<SignupCubit>().submit();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<SignupCubit>();
    return BlocBuilder<SignupCubit, SignupState>(
      bloc: controller,
      builder: (context, state) {
        final busy = state.status == SignupStatus.submitting;
        final success = state.status == SignupStatus.success;
        final error = state.error;
        final l10n = AppLocalizations.of(context)!;
        return AbsorbPointer(
          absorbing: busy || success,
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.signup_username_label,
                  ),
                  onChanged: controller.updateUsername,
                  validator: _usernameValidator,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.signup_email_label,
                  ),
                  onChanged: controller.updateEmail,
                  validator: _emailValidator,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.signup_password_label,
                  ),
                  obscureText: true,
                  onChanged: controller.updatePassword,
                  validator: _passwordValidator,
                ),
                const SizedBox(height: 16),
                if (error != null)
                  Text(
                    _mapError(l10n, error),
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: busy ? null : _onSubmit,
                  child: Text(
                    success ? l10n.signup_submit_done : l10n.signup_submit,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _mapError(AppLocalizations l10n, SignupError error) {
    return switch (error.code) {
      SignupErrorCode.usernameTaken => l10n.signup_error_usernameTaken,
      SignupErrorCode.usernameInvalid => l10n.signup_error_usernameInvalid,
      SignupErrorCode.emailInvalid => l10n.signup_error_emailInvalid,
      SignupErrorCode.emailAlreadyInUse => l10n.signup_error_emailAlreadyInUse,
      SignupErrorCode.passwordWeak => l10n.signup_error_passwordWeak,
      SignupErrorCode.networkFailure => l10n.signup_error_networkFailure,
      SignupErrorCode.rollbackFailed => l10n.signup_error_rollbackFailed,
      SignupErrorCode.unknown => l10n.signup_error_unknown,
    };
  }
}

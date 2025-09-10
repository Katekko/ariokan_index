import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:ariokan_index/features/auth_signup/model/signup_state.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key, required this.controller});
  final SignupController controller;

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
  }

  String? _usernameValidator(String? v) {
    if ((v ?? '').isEmpty) return 'username required';
    if (v!.length < 3) return 'username too short';
    return null;
  }

  String? _emailValidator(String? v) {
    if ((v ?? '').isEmpty) return 'email required';
    if (!v!.contains('@')) return 'email invalid';
    return null;
  }

  String? _passwordValidator(String? v) {
    if ((v ?? '').isEmpty) return 'password required';
    if (v!.length < 6) return 'password too short';
    return null;
  }

  void _onSubmit() {
    setState(() => _submitted = true);
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    widget.controller.submit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupController, SignupState>(
      bloc: widget.controller,
      builder: (context, state) {
        final busy = state.status == SignupStatus.submitting;
        final success = state.status == SignupStatus.success;
        final error = state.error;
        return AbsorbPointer(
          absorbing: busy || success,
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  onChanged: widget.controller.updateUsername,
                  validator: _usernameValidator,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  onChanged: widget.controller.updateEmail,
                  validator: _emailValidator,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onChanged: widget.controller.updatePassword,
                  validator: _passwordValidator,
                ),
                const SizedBox(height: 16),
                if (error != null)
                  Text(
                    error.message ?? error.code.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: busy ? null : _onSubmit,
                  child: Text(success ? 'Done' : 'Sign Up'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

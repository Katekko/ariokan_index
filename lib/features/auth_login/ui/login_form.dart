import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/login_controller.dart';
import '../model/login_state.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginController(),
      child: BlocBuilder<LoginController, LoginState>(
        builder: (context, state) {
          final controller = context.read<LoginController>();
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  key: const Key('username'),
                  onChanged: controller.setUsername,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  key: const Key('password'),
                  onChanged: controller.setPassword,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.canSubmit
                        ? () => controller.submit(
                            username: state.username.trim(),
                            password: state.password,
                          )
                        : null,
                    child: state.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
                ),
                if (state.status == LoginStatus.failure &&
                    state.errorType == LoginErrorType.auth)
                  const Text(
                    'Username or password wrong',
                    style: TextStyle(color: Colors.red),
                  ),
                if (state.status == LoginStatus.failure &&
                    state.errorType == LoginErrorType.network)
                  const Text(
                    'Network error. Please try again.',
                    style: TextStyle(color: Colors.red),
                  ),
                TextButton(
                  onPressed: () {
                    // TODO: Implement navigation to signup
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../logic/login_controller.dart';
// import '../model/login_state.dart';
// import 'package:ariokan_index/l10n/app_localizations.dart';
// import 'package:ariokan_index/app/di/di.dart';

// class LoginForm extends StatelessWidget {
//   const LoginForm({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;

//     return BlocProvider(
//       create: (_) => di<LoginController>(),
//       child: BlocBuilder<LoginController, LoginState>(
//         builder: (context, state) {
//           final controller = context.read<LoginController>();
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TextField(
//                   key: const Key('username'),
//                   onChanged: controller.setUsername,
//                   decoration: InputDecoration(
//                     labelText: l10n.signup_username_label,
//                   ),
//                 ),
//                 TextField(
//                   key: const Key('password'),
//                   onChanged: controller.setPassword,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: l10n.signup_password_label,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: state.canSubmit
//                         ? () => controller.submit(
//                             username: state.username.trim(),
//                             password: state.password,
//                           )
//                         : null,
//                     child: state.isLoading
//                         ? const CircularProgressIndicator()
//                         : Text(l10n.login_button),
//                   ),
//                 ),
//                 if (state.status == LoginStatus.failure &&
//                     state.errorType == LoginErrorType.auth)
//                   Text(
//                     l10n.login_error_auth,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 if (state.status == LoginStatus.failure &&
//                     state.errorType == LoginErrorType.network)
//                   Text(
//                     l10n.login_error_network,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 TextButton(
//                   onPressed: () {
//                     // TODO: Implement navigation to signup
//                   },
//                   child: Text(l10n.login_signup),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

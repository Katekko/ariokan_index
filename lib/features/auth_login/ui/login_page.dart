import 'package:flutter/material.dart';
import 'login_form.dart';
import 'package:ariokan_index/l10n/app_localizations.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.login_title)),
      body: const Center(child: SingleChildScrollView(child: LoginForm())),
    );
  }
}

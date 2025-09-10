import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:ariokan_index/entities/user/user_repository_firebase.dart';
import 'package:ariokan_index/app/router.dart';
import 'package:ariokan_index/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Root App widget (T029)
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final SignupController _signupController;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final repo = UserRepositoryFirebase();
    _signupController = SignupController(repo);
    _router = createRouter(_signupController);
  }

  @override
  void dispose() {
    _signupController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}

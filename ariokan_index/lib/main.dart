import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ariokan_index/shared/firebase/firebase_init.dart';
import 'package:ariokan_index/shared/utils/app_logger.dart';
import 'l10n/app_localizations.dart';
// Signup feature imports
import 'package:ariokan_index/features/auth_signup/logic/signup_controller.dart';
import 'package:ariokan_index/entities/user/user_repository_firebase.dart';
import 'package:ariokan_index/app/router.dart';

Future<void> main() async {
  // Ensure bindings and logger
  AppLogger.init();
  AppLogger.runGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initFirebase();
    runApp(const MainApp());
  });
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final SignupController _signupController;

  @override
  void initState() {
    super.initState();
    final repo = UserRepositoryFirebase();
    _signupController = SignupController(repo);
  }

  @override
  void dispose() {
    _signupController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = createRouter(_signupController);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}

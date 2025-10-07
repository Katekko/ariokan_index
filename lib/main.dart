import 'package:flutter/material.dart';
import 'package:ariokan_index/core/firebase/firebase_init.dart';
import 'package:ariokan_index/core/utils/app_logger.dart';
import 'package:ariokan_index/app/app.dart';
import 'package:ariokan_index/app/di/di.dart';

Future<void> main() async {
  AppLogger.init();
  AppLogger.runGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initFirebase();
    await setupDependencies();
    runApp(const App());
  });
}

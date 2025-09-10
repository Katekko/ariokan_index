import 'package:flutter/material.dart';
import 'package:ariokan_index/shared/firebase/firebase_init.dart';
import 'package:ariokan_index/shared/utils/app_logger.dart';
import 'package:ariokan_index/app/app.dart';

Future<void> main() async {
  AppLogger.init();
  AppLogger.runGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initFirebase();
    runApp(const App());
  });
}

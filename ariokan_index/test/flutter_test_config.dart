import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GetIt.I.allowReassignment = true;

  return AlchemistConfig.runWithConfig(
    run: testMain,
    config: AlchemistConfig(
      ciGoldensConfig: const CiGoldensConfig(enabled: false),
      platformGoldensConfig: PlatformGoldensConfig(
        platforms: {HostPlatform.linux},
        filePathResolver: (fileName, environmentName) =>
            './goldens/$fileName.png',
      ),
      goldenTestTheme: GoldenTestTheme(
        backgroundColor: Colors.grey[200]!,
        borderColor: Colors.transparent,
        padding: const EdgeInsetsGeometry.all(16),
        nameTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ),
  );
}

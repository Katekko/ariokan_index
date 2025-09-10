import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';

Future<void> testWidgetsGolden(
  String description, {
  required String fileName,
  required Widget Function() builder,
  Future<void> Function()? setUp,
}) async {
  return goldenTest(
    description,
    fileName: fileName,
    builder: () {
      setUp?.call();

      return GoldenTestScenario(
        name: 'web',
        constraints: BoxConstraints(maxWidth: 1280, maxHeight: 720),
        child: builder(),
      );
    },
  );
}

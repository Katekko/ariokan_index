import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testWidgetsGolden(
  String description, {
  required String fileName,
  required Widget Function() builder,
  Future<void> Function()? setUp,
  Size? size,
}) async {
  return goldenTest(
    description,
    fileName: fileName,

    builder: () {
      setUp?.call();

      return GoldenTestScenario(
        name: 'web',
        constraints: BoxConstraints(
          maxWidth: size?.width ?? 1280,
          maxHeight: size?.height ?? 720,
        ),
        child: builder(),
      );
    },
  );
}

Future<void> testGoldenClickable(
  String description, {
  required String fileName,
  required Widget Function() builder,
  required Finder finder,
  Future<void> Function()? setUp,
}) async {
  return goldenTest(
    description,
    fileName: fileName,
    whilePerforming: (tester) async {
      await tester.tap(finder);
      await tester.pumpAndSettle();

      return;
    },
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

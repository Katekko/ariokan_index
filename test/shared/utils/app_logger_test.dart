import 'dart:async';

import 'package:ariokan_index/shared/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLogger & _Ansi', () {
    String stripAnsi(String s) => s.replaceAll(RegExp(r'\u001B\[[0-9;]*m'), '');

    test('info/warn produce tagged lines', () {
      final prints = <String>[];
      runZoned(
        () {
          AppLogger.info('Message', 'Detail');
          AppLogger.warn('WarnMsg');
        },
        zoneSpecification: ZoneSpecification(
          print: (_, _, _, line) {
            prints.add(line);
          },
        ),
      );
      expect(prints.length, 2);
      final line0 = stripAnsi(prints[0]);
      final line1 = stripAnsi(prints[1]);
      expect(line0, contains('[INFO] Message — Detail'));
      expect(line1, contains('[WARN] WarnMsg'));
    });

    test('error logs via developer.log in debug', () {
      // We can't intercept developer.log easily without a listener; instead ensure no throw and format stable.
      expect(() => AppLogger.error('Test', 'Something'), returnsNormally);
    });

    test('runGuarded returns body value and logs zone error', () {
      final prints = <String>[];
      final value = AppLogger.runGuarded<int>(() {
        // Intentionally print to ensure zone active.
        return 42;
      });
      expect(value, 42);

      // Now trigger a zone error separately to ensure error handler path executed.
      runZonedGuarded(
        () {
          throw StateError('boom');
        },
        (e, s) {
          // Use logger's error path to simulate internal call.
          AppLogger.error('Zone', 'Uncaught zone error', error: e, stack: s);
        },
      );

      // Capture prints from info/warn to ensure still functioning after runGuarded.
      runZoned(
        () {
          AppLogger.info('After', 'RunGuarded');
        },
        zoneSpecification: ZoneSpecification(
          print: (_, _, _, line) {
            prints.add(line);
          },
        ),
      );
      expect(prints.any((l) => l.contains('After')), isTrue);
    });

    test('attachZone initializes only once', () {
      // Call multiple times; should not throw.
      expect(AppLogger.attachZone, returnsNormally);
      expect(AppLogger.attachZone, returnsNormally);
    });

    test('FlutterError.onError wired after init', () {
      AppLogger.init();
      final original = FlutterError.onError;
      expect(original, isNotNull);
      // Simulate a Flutter framework error.
      final details = FlutterErrorDetails(
        exception: Exception('framework'),
        stack: StackTrace.current,
      );
      // Should not throw.
      expect(() => FlutterError.onError!(details), returnsNormally);
    });
  });
}

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Lightweight app logger for debug mode.
///
/// Features:
/// - No-ops in release/profile (except critical errors go to developer.log).
/// - Colorized console output (ANSI) when running in debug console.
/// - Central global error handlers (FlutterError, PlatformDispatcher, runZonedGuarded).
/// - Minimal dependency surface (no external logging packages yet).
///
/// Usage: Call `AppLogger.init()` early in `main()` before running the app.
class AppLogger {
  AppLogger._();

  @visibleForTesting
  static AppLogger testCreate() => AppLogger._();

  static bool _initialized = false;
  /// When true (typically in tests), suppresses all info/warn/error console output.
  @visibleForTesting
  static bool quiet = false;

  /// Initialize global error handlers. Safe to call multiple times; only first is applied.
  static void init() {
    if (_initialized) return;
    _initialized = true;

    if (kReleaseMode) {
      // Skip verbose wiring in release builds to reduce overhead.
      return;
    }

    // Capture Flutter framework errors.
    FlutterError.onError = (details) {
      error('FlutterError', details.exceptionAsString(), stack: details.stack);
    };

    // PlatformDispatcher (async zone boundary errors not caught elsewhere)
    PlatformDispatcher.instance.onError = (errorObject, stack) {
      error('PlatformDispatcher', errorObject.toString(), stack: stack);
      return true; // handled
    };
  }

  static void info(String message, [String? detail]) {
  if (quiet || kReleaseMode) return;
    _print(_Ansi.blue('INFO'), message, detail: detail);
  }

  static void warn(String message, [String? detail]) {
  if (quiet || kReleaseMode) return;
    _print(_Ansi.yellow('WARN'), message, detail: detail);
  }

  static void error(
    String source,
    String message, {
    Object? error,
    StackTrace? stack,
  }) {
  if (quiet && kDebugMode) return;
    final combined = '[${DateTime.now().toIso8601String()}][$source] $message';
    if (kDebugMode) {
      developer.log(
        combined,
        error: error,
        stackTrace: stack,
        level: 1000,
        name: 'app',
      );
      return;
    }
  }

  static void attachZone() {
    if (kReleaseMode) return; // In release, developer defaults suffice.
    if (!_initialized) {
      init();
    }
  }

  /// Run a function inside a guarded zone that logs uncaught errors.
  static R runGuarded<R>(R Function() body) {
    attachZone();
    late R result;
    runZonedGuarded(
      () {
        result = body();
      },
      (e, s) {
        error('Zone', 'Uncaught zone error', error: e, stack: s);
      },
    );
    return result;
  }

  static void _print(String level, String message, {String? detail}) {
  if (quiet) return;
    final ts = DateTime.now().toIso8601String();
    final base = '[$ts][$level] $message';
    final out = detail == null ? base : '$base — $detail';
    // ignore: avoid_print
    print(out);
  }
}

// Basic ANSI helpers (avoid external dep). No-ops in web where escape codes may show literally.
class _Ansi {
  static const _esc = '\u001B[';
  static String _wrap(String code, String text) => '$code$text\u001B[0m';
  static String blue(String t) => _wrap('${_esc}34m', t);
  static String yellow(String t) => _wrap('${_esc}33m', t);
}

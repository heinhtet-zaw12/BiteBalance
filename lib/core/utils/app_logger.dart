import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Singleton logger for the entire app.
/// Debug mode: all logs with stack traces, colors, emojis.
/// Release mode: errors only, no stack traces.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: kDebugMode ? 2 : 0,
      errorMethodCount: kDebugMode ? 5 : 0,
      lineLength: 80,
      colors: kDebugMode,
      printEmojis: true,
      dateTimeFormat:
          kDebugMode ? DateTimeFormat.onlyTimeAndSinceStart : DateTimeFormat.none,
    ),
    level: kDebugMode ? Level.debug : Level.error,
    output: ConsoleOutput(),
  );

  /// Debug-level log. Only shown in debug mode.
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Info-level log. Only shown in debug mode.
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Warning-level log. Only shown in debug mode.
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Error-level log. Shown in both debug and release modes.
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

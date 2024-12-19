import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class AppLogger {
  static final Logger _logger = Logger('ZhiTrendTimeCapsule');

  static void init() {
    // 配置日志级别和处理器
    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen((record) {
      print(
        '${record.level.name}: ${record.time}: ${record.message}',
      );
    });
  }

  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.fine(message, error, stackTrace);
  }

  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.info(message, error, stackTrace);
  }

  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.warning(message, error, stackTrace);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.severe(message, error, stackTrace);
  }

  static void critical(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.shout(message, error, stackTrace);
  }
}

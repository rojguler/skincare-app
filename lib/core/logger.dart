import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Professional logging system for the application
class AppLogger {
  static const String _tag = 'GlowSun';
  static bool _isInitialized = false;
  static bool _isDebugMode = false;
  static bool _isProductionMode = false;

  /// Initialize the logger
  static Future<void> initialize() async {
    if (_isInitialized) return;

    _isDebugMode = kDebugMode;
    _isProductionMode = kReleaseMode;

    // Initialize logging preferences
    final prefs = await SharedPreferences.getInstance();
    final logLevel = prefs.getString('log_level') ?? 'INFO';
    
    _isInitialized = true;
    
    info('Logger initialized', data: {
      'debug_mode': _isDebugMode,
      'production_mode': _isProductionMode,
      'log_level': logLevel,
    });
  }

  /// Log debug information
  static void debug(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    if (!_isDebugMode) return;
    
    _log('DEBUG', message, data: data, error: error, stackTrace: stackTrace);
  }

  /// Log information
  static void info(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log('INFO', message, data: data, error: error, stackTrace: stackTrace);
  }

  /// Log warnings
  static void warning(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log('WARNING', message, data: data, error: error, stackTrace: stackTrace);
  }

  /// Log errors
  static void error(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, data: data, error: error, stackTrace: stackTrace);
    
    // In production, send to crash reporting service
    if (_isProductionMode) {
      _sendToCrashReporting(message, data, error, stackTrace);
    }
  }

  /// Log critical errors
  static void critical(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log('CRITICAL', message, data: data, error: error, stackTrace: stackTrace);
    
    // Always send critical errors to crash reporting
    _sendToCrashReporting(message, data, error, stackTrace);
  }

  /// Log performance metrics
  static void performance(String operation, Duration duration, {Map<String, dynamic>? data}) {
    _log('PERFORMANCE', '$operation completed in ${duration.inMilliseconds}ms', data: data);
  }

  /// Log user actions
  static void userAction(String action, {Map<String, dynamic>? data}) {
    _log('USER_ACTION', action, data: data);
  }

  /// Log API calls
  static void apiCall(String endpoint, String method, {Map<String, dynamic>? data, Object? error}) {
    _log('API_CALL', '$method $endpoint', data: data, error: error);
  }

  /// Log database operations
  static void database(String operation, {Map<String, dynamic>? data, Object? error}) {
    _log('DATABASE', operation, data: data, error: error);
  }

  /// Log authentication events
  static void auth(String event, {Map<String, dynamic>? data, Object? error}) {
    _log('AUTH', event, data: data, error: error);
  }

  /// Log navigation events
  static void navigation(String route, {Map<String, dynamic>? data}) {
    _log('NAVIGATION', 'Navigated to $route', data: data);
  }

  /// Internal logging method
  static void _log(String level, String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] $message';
    
    // Console logging
    if (_isDebugMode) {
      developer.log(
        logMessage,
        name: _tag,
        error: error,
        stackTrace: stackTrace,
      );
      
      // Additional data logging
      if (data != null && data.isNotEmpty) {
        developer.log(
          'Data: $data',
          name: _tag,
        );
      }
    }

    // Production logging (to file or remote service)
    if (_isProductionMode) {
      _logToFile(level, message, data: data, error: error, stackTrace: stackTrace);
    }
  }

  /// Log to file (for production)
  static void _logToFile(String level, String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    // TODO: Implement file logging for production
    // This could write to a local file or send to a remote logging service
  }

  /// Send to crash reporting service
  static void _sendToCrashReporting(String message, Map<String, dynamic>? data, Object? error, StackTrace? stackTrace) {
    // TODO: Implement crash reporting integration
    // This could integrate with Firebase Crashlytics, Sentry, or similar services
  }

  /// Start performance timer
  static Stopwatch startTimer() {
    return Stopwatch()..start();
  }

  /// End performance timer and log
  static void endTimer(Stopwatch stopwatch, String operation, {Map<String, dynamic>? data}) {
    stopwatch.stop();
    performance(operation, stopwatch.elapsed, data: data);
  }

  /// Log method execution time
  static T logExecutionTime<T>(String methodName, T Function() method, {Map<String, dynamic>? data}) {
    final stopwatch = startTimer();
    try {
      final result = method();
      endTimer(stopwatch, methodName, data: data);
      return result;
    } catch (e, stackTrace) {
      endTimer(stopwatch, methodName, data: data);
      error('Error in $methodName', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Log async method execution time
  static Future<T> logAsyncExecutionTime<T>(String methodName, Future<T> Function() method, {Map<String, dynamic>? data}) async {
    final stopwatch = startTimer();
    try {
      final result = await method();
      endTimer(stopwatch, methodName, data: data);
      return result;
    } catch (e, stackTrace) {
      endTimer(stopwatch, methodName, data: data);
      error('Error in $methodName', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Create a scoped logger for a specific feature
  static ScopedLogger createScopedLogger(String scope) {
    return ScopedLogger(scope);
  }
}

/// Scoped logger for specific features
class ScopedLogger {
  final String scope;

  ScopedLogger(this.scope);

  void debug(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    AppLogger.debug('[$scope] $message', data: data, error: error, stackTrace: stackTrace);
  }

  void info(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    AppLogger.info('[$scope] $message', data: data, error: error, stackTrace: stackTrace);
  }

  void warning(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    AppLogger.warning('[$scope] $message', data: data, error: error, stackTrace: stackTrace);
  }

  void error(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    AppLogger.error('[$scope] $message', data: data, error: error, stackTrace: stackTrace);
  }

  void critical(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    AppLogger.critical('[$scope] $message', data: data, error: error, stackTrace: stackTrace);
  }
}

/// Performance monitoring utility
class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};

  /// Start monitoring a specific operation
  static void startMonitoring(String operation) {
    _timers[operation] = Stopwatch()..start();
    AppLogger.debug('Started monitoring: $operation');
  }

  /// End monitoring and log the result
  static void endMonitoring(String operation, {Map<String, dynamic>? data}) {
    final timer = _timers.remove(operation);
    if (timer != null) {
      timer.stop();
      AppLogger.performance(operation, timer.elapsed, data: data);
    }
  }

  /// Get current monitoring time
  static Duration? getCurrentTime(String operation) {
    final timer = _timers[operation];
    return timer?.elapsed;
  }

  /// Clear all timers
  static void clearAll() {
    _timers.clear();
  }
}

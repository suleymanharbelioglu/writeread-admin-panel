import 'package:flutter/foundation.dart';

/// Debug/terminal logging for unexpected errors (kDebugMode only for spam control
/// on stacks; messages always print in debug).
class AppLog {
  AppLog._();

  static void error(
    String where,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    debugPrint('ERROR [$where]: $error');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }

  static void info(String message) {
    debugPrint('INFO: $message');
  }
}

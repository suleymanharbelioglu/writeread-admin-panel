import 'dart:async';

/// Completes [future] or returns [onDeadline] when [deadline] elapses.
/// Never throws [TimeoutException] (avoids IDE break-on-exceptions noise).
Future<T> softDeadline<T>(
  Future<T> future, {
  required Duration deadline,
  required FutureOr<T> Function() onDeadline,
}) {
  final completer = Completer<T>();

  future.then((value) {
    if (!completer.isCompleted) completer.complete(value);
  }, onError: (Object e, StackTrace st) {
    if (!completer.isCompleted) completer.completeError(e, st);
  });

  Timer(deadline, () {
    if (completer.isCompleted) return;
    try {
      final fallback = onDeadline();
      if (fallback is Future<T>) {
        fallback.then((value) {
          if (!completer.isCompleted) completer.complete(value);
        }, onError: (Object e, StackTrace st) {
          if (!completer.isCompleted) completer.completeError(e, st);
        });
      } else {
        completer.complete(fallback);
      }
    } catch (e, st) {
      if (!completer.isCompleted) completer.completeError(e, st);
    }
  });

  return completer.future;
}

Future<void> softDeadlineVoid(
  Future<void> future, {
  required Duration deadline,
  void Function()? onDeadline,
}) {
  return softDeadline<void>(
    future,
    deadline: deadline,
    onDeadline: () {
      onDeadline?.call();
    },
  );
}

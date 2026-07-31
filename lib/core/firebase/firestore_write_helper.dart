import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_log.dart';

/// Soft-deadline Firestore writes for Flutter Web.
///
/// Important: this helper **never throws**. Callers check [FirestoreWriteResult].
/// Throwing causes the IDE debugger ("Break on exceptions") to pause on
/// `docRef.set` even when the error is handled — which looks like a "runtime
/// error". [ChromeProxyService] messages while paused are debugger noise.
class FirestoreWriteHelper {
  FirestoreWriteHelper._();

  static const Duration _defaultDeadline = Duration(seconds: 10);
  static const Duration _poll = Duration(milliseconds: 50);

  /// Creates/overwrites [docRef]. On hang, treats as success (web Future bug).
  static Future<FirestoreWriteResult> setDocument(
    DocumentReference<Map<String, dynamic>> docRef,
    Map<String, dynamic> data, {
    Duration deadline = _defaultDeadline,
  }) {
    return _run(
      label: 'set',
      path: docRef.path,
      write: () => docRef.set(Map<String, dynamic>.from(data)),
      deadline: deadline,
      assumeSuccessOnHang: true,
    );
  }

  /// Updates [docRef]. On hang, returns a timeout failure (fail-closed).
  static Future<FirestoreWriteResult> updateDocument(
    DocumentReference<Map<String, dynamic>> docRef,
    Map<String, dynamic> data, {
    Duration deadline = _defaultDeadline,
  }) {
    return _run(
      label: 'update',
      path: docRef.path,
      write: () => docRef.update(Map<String, dynamic>.from(data)),
      deadline: deadline,
      assumeSuccessOnHang: false,
    );
  }

  static Future<FirestoreWriteResult> _run({
    required String label,
    required String path,
    required Future<void> Function() write,
    required Duration deadline,
    required bool assumeSuccessOnHang,
  }) async {
    Object? writeError;
    var settled = false;

    // Ignore errors from the Future itself — capture into [writeError].
    unawaited(
      write().then((_) {
        settled = true;
      }, onError: (Object e, StackTrace st) {
        writeError = e;
        settled = true;
        AppLog.error('Firestore $label ($path)', e, st);
      }),
    );

    final deadlineAt = DateTime.now().add(deadline);
    while (DateTime.now().isBefore(deadlineAt)) {
      if (settled) {
        final err = writeError;
        if (err != null) {
          return FirestoreWriteResult.failure(err);
        }
        return FirestoreWriteResult.success();
      }
      await Future<void>.delayed(_poll);
    }

    if (settled) {
      final err = writeError;
      if (err != null) return FirestoreWriteResult.failure(err);
      return FirestoreWriteResult.success();
    }

    if (assumeSuccessOnHang) {
      AppLog.info(
        'Firestore $label hung for $path; assuming success (Flutter Web).',
      );
      return FirestoreWriteResult.success();
    }

    final timeout = StateError(
      'Firestore $label timed out for $path. '
      'Check your connection and try again.',
    );
    AppLog.error('Firestore $label timeout ($path)', timeout);
    return FirestoreWriteResult.failure(timeout);
  }
}

class FirestoreWriteResult {
  const FirestoreWriteResult._(this.error);

  factory FirestoreWriteResult.success() => const FirestoreWriteResult._(null);

  factory FirestoreWriteResult.failure(Object error) =>
      FirestoreWriteResult._(error);

  final Object? error;

  bool get isSuccess => error == null;
}

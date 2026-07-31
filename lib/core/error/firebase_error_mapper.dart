import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_log.dart';

/// Maps Firebase / unexpected errors to short user-facing messages.
class FirebaseErrorMapper {
  FirebaseErrorMapper._();

  static String map(
    Object error, {
    required String action,
    StackTrace? stackTrace,
  }) {
    AppLog.error(action, error, stackTrace);

    if (error is TimeoutException) {
      return '$action timed out. Check your connection and try again.';
    }
    if (error is FirebaseAuthException) {
      return _authMessage(error, action);
    }
    if (error is FirebaseException) {
      return _firebaseMessage(error, action);
    }

    final raw = error.toString();
    if (_isPermissionDenied(raw)) {
      return '$action failed: permission denied. '
          'Sign in again and check Firebase rules.';
    }
    if (raw.contains('network') ||
        raw.contains('unavailable') ||
        raw.contains('SocketException') ||
        raw.contains('TimeoutException') ||
        raw.toLowerCase().contains('timed out')) {
      return '$action failed: network error. Check your connection.';
    }
    return '$action failed. Please try again.';
  }

  static String _authMessage(FirebaseAuthException e, String action) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return '$action failed: ${e.message ?? e.code}';
    }
  }

  static String _firebaseMessage(FirebaseException e, String action) {
    switch (e.code) {
      case 'permission-denied':
        return '$action failed: permission denied. '
            'Your account needs an admins/{uid} document in Firestore, '
            'and firestore.rules must be deployed.';
      case 'unauthenticated':
        return '$action failed: not signed in. Sign in and try again.';
      case 'not-found':
      case 'object-not-found':
        return '$action failed: resource not found.';
      case 'already-exists':
        return '$action failed: already exists.';
      case 'unavailable':
      case 'deadline-exceeded':
        return '$action failed: service unavailable. Try again.';
      case 'canceled':
        return '$action canceled.';
      case 'unauthorized':
        return '$action failed: storage permission denied. '
            'Check Firebase Storage rules.';
      default:
        return '$action failed: ${e.message ?? e.code}';
    }
  }

  static bool _isPermissionDenied(String raw) {
    final lower = raw.toLowerCase();
    return lower.contains('permission-denied') ||
        lower.contains('permission_denied');
  }
}

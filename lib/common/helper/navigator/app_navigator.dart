import 'package:flutter/material.dart';

class AppNavigator {
  const AppNavigator._();

  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(_route<T>(page));
  }

  static Future<T?> pushReplacement<T>(BuildContext context, Widget page) {
    return Navigator.of(context).pushReplacement<T, dynamic>(_route<T>(page));
  }

  static Future<T?> pushAndRemove<T>(BuildContext context, Widget page) {
    return Navigator.of(
      context,
    ).pushAndRemoveUntil<T>(_route<T>(page), (route) => false);
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  static MaterialPageRoute<T> _route<T>(Widget page) =>
      MaterialPageRoute<T>(builder: (_) => page);
}

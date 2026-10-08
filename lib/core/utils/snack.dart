import 'package:flutter/material.dart';

void showAppSnack(BuildContext context, String message, {bool error = false}) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: error ? scheme.onError : null),
        ),
        backgroundColor: error ? scheme.error : null,
      ),
    );
}

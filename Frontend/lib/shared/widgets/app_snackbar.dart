import 'package:flutter/material.dart';

class AppSnackBar {
  const AppSnackBar._();

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message,
      background: Theme.of(context).colorScheme.errorContainer,
      foreground: Theme.of(context).colorScheme.onErrorContainer,
      icon: Icons.error_outline,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message,
      background: Theme.of(context).colorScheme.primaryContainer,
      foreground: Theme.of(context).colorScheme.onPrimaryContainer,
      icon: Icons.check_circle_outline,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color background,
    required Color foreground,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: background,
          content: Row(
            children: [
              Icon(icon, color: foreground),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: foreground),
                ),
              ),
            ],
          ),
        ),
      );
  }
}



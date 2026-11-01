import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Widget permissionDenied({
  required IconData icon,
  required String message,
  required Function()? onPressed,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onPressed,
            child: const Text('Grant Permission'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: openAppSettings,
            child: const Text('Open App Settings'),
          ),
        ],
      ),
    ),
  );
}

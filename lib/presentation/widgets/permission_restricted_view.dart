import 'package:flutter/material.dart';

class PermissionRestrictedView extends StatelessWidget {
  final String message;
  final VoidCallback? onRequestPermission;

  const PermissionRestrictedView({
    Key? key,
    required this.message,
    this.onRequestPermission,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (onRequestPermission != null)
            ElevatedButton(
              onPressed: onRequestPermission,
              child: const Text('Request Permission'),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PermissionCard extends StatelessWidget {
  final bool hasPermission;
  final VoidCallback onRequestPermission;

  const PermissionCard({
    super.key,
    required this.hasPermission,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permission',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  hasPermission ? Icons.check_circle : Icons.cancel,
                  color: hasPermission ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(hasPermission ? 'Location permitted' : 'Location not permitted'),
              ],
            ),
            if (!hasPermission)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: onRequestPermission,
                  child: const Text('Request Permission'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

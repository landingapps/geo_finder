import 'package:flutter/material.dart';

class StreamControlCard extends StatelessWidget {
  final bool hasPermission;
  final bool isStreaming;
  final VoidCallback onToggleStreams;

  const StreamControlCard({
    super.key,
    required this.hasPermission,
    required this.isStreaming,
    required this.onToggleStreams,
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
              'Real-time Updates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: hasPermission ? onToggleStreams : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isStreaming ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isStreaming ? 'Stop' : 'Start'),
                ),
                const SizedBox(width: 16),
                Icon(
                  isStreaming ? Icons.sensors : Icons.sensors_off,
                  color: isStreaming ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(isStreaming ? 'Streaming' : 'Stopped'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:geo_finder/geo_finder.dart';

class OrientationCard extends StatelessWidget {
  final GeoDeviceOrientation? orientation;
  final VoidCallback onGetOrientation;

  const OrientationCard({
    super.key,
    required this.orientation,
    required this.onGetOrientation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Device Orientation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: onGetOrientation,
                  child: const Text('Get'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (orientation != null) ...[
              Text('Pitch (X-axis): ${orientation!.pitch.toStringAsFixed(1)}°'),
              Text('Roll (Y-axis): ${orientation!.roll.toStringAsFixed(1)}°'),
              Text('Yaw (Z-axis): ${orientation!.yaw.toStringAsFixed(1)}°'),
            ] else
              const Text('No data'),
          ],
        ),
      ),
    );
  }
}

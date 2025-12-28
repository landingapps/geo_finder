import 'package:flutter/material.dart';
import 'package:geo_finder/geo_finder.dart';

class HeadingCard extends StatelessWidget {
  final Heading? heading;
  final VoidCallback onGetHeading;

  const HeadingCard({
    super.key,
    required this.heading,
    required this.onGetHeading,
  });

  String _getDirectionName(double heading) {
    if (heading >= 337.5 || heading < 22.5) return 'N';
    if (heading >= 22.5 && heading < 67.5) return 'NE';
    if (heading >= 67.5 && heading < 112.5) return 'E';
    if (heading >= 112.5 && heading < 157.5) return 'SE';
    if (heading >= 157.5 && heading < 202.5) return 'S';
    if (heading >= 202.5 && heading < 247.5) return 'SW';
    if (heading >= 247.5 && heading < 292.5) return 'W';
    if (heading >= 292.5 && heading < 337.5) return 'NW';
    return '';
  }

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
                  'Heading (Compass)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: onGetHeading,
                  child: const Text('Get'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (heading != null) ...[
              Text('True North: ${heading!.trueHeading.toStringAsFixed(1)}°'),
              Text('Magnetic North: ${heading!.magneticHeading.toStringAsFixed(1)}°'),
              Text('Accuracy: ${heading!.accuracy.toStringAsFixed(1)}°'),
              Text('Direction: ${_getDirectionName(heading!.trueHeading)}'),
            ] else
              const Text('No data'),
          ],
        ),
      ),
    );
  }
}

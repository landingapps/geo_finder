import 'package:flutter/material.dart';
import 'package:geo_finder/geo_finder.dart';

class LocationCard extends StatelessWidget {
  final GeoLocation? location;
  final bool hasPermission;
  final VoidCallback onGetLocation;

  const LocationCard({
    super.key,
    required this.location,
    required this.hasPermission,
    required this.onGetLocation,
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
                  'Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: hasPermission ? onGetLocation : null,
                  child: const Text('Get'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (location != null) ...[
              Text('Latitude: ${location!.latitude.toStringAsFixed(6)}'),
              Text('Longitude: ${location!.longitude.toStringAsFixed(6)}'),
              Text('Altitude: ${location!.altitude.toStringAsFixed(2)} m'),
              Text('Accuracy: ${location!.accuracy.toStringAsFixed(2)} m'),
            ] else
              const Text('No data'),
          ],
        ),
      ),
    );
  }
}

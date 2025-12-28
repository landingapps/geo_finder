/// Represents location data (latitude, longitude, altitude)
class GeoLocation {
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final DateTime timestamp;

  GeoLocation({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.timestamp,
  });

  factory GeoLocation.fromMap(Map<String, dynamic> map) {
    return GeoLocation(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      altitude: (map['altitude'] as num).toDouble(),
      accuracy: (map['accuracy'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as num).toInt(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'GeoLocation(lat: $latitude, lng: $longitude, alt: $altitude, accuracy: $accuracy)';
  }
}

/// Represents compass heading data
class Heading {
  /// Heading relative to true north (0-360 degrees)
  final double trueHeading;

  /// Heading relative to magnetic north (0-360 degrees)
  final double magneticHeading;

  /// Accuracy in degrees
  final double accuracy;

  final DateTime timestamp;

  Heading({
    required this.trueHeading,
    required this.magneticHeading,
    required this.accuracy,
    required this.timestamp,
  });

  factory Heading.fromMap(Map<String, dynamic> map) {
    return Heading(
      trueHeading: (map['trueHeading'] as num).toDouble(),
      magneticHeading: (map['magneticHeading'] as num).toDouble(),
      accuracy: (map['accuracy'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as num).toInt(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trueHeading': trueHeading,
      'magneticHeading': magneticHeading,
      'accuracy': accuracy,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'Heading(true: $trueHeading°, magnetic: $magneticHeading°, accuracy: $accuracy°)';
  }
}

/// Represents device orientation (rotation angles)
class GeoDeviceOrientation {
  /// X-axis rotation (pitch) - front/back tilt (-180 to 180 degrees)
  final double pitch;

  /// Y-axis rotation (roll) - left/right tilt (-90 to 90 degrees)
  final double roll;

  /// Z-axis rotation (yaw/azimuth) - horizontal rotation (0 to 360 degrees)
  final double yaw;

  final DateTime timestamp;

  GeoDeviceOrientation({
    required this.pitch,
    required this.roll,
    required this.yaw,
    required this.timestamp,
  });

  factory GeoDeviceOrientation.fromMap(Map<String, dynamic> map) {
    return GeoDeviceOrientation(
      pitch: (map['pitch'] as num).toDouble(),
      roll: (map['roll'] as num).toDouble(),
      yaw: (map['yaw'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as num).toInt(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pitch': pitch,
      'roll': roll,
      'yaw': yaw,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'GeoDeviceOrientation(pitch: $pitch°, roll: $roll°, yaw: $yaw°)';
  }
}

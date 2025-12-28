# GeoFinder

A Flutter plugin for accessing device location, compass heading, altitude, and device orientation (pitch, roll, yaw) on iOS and Android.

## Features

- **Location**: Get current latitude, longitude, and altitude
- **Compass**: Get device heading (true north and magnetic north)
- **Device Orientation**: Get device rotation angles (pitch, roll, yaw) on X, Y, Z axes
- **Real-time Streams**: Subscribe to continuous updates for all sensor data
- **Permission Handling**: Built-in methods for requesting and checking location permissions

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  geo_finder:
    git:
      url: https://github.com/landingapps/geo_finder.git
```

## Platform Setup

### iOS

Add the following keys to your `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location to show your current position.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to location to show your current position.</string>
<key>NSMotionUsageDescription</key>
<string>This app needs access to motion sensors to detect device orientation.</string>
```

### Android

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

## Usage

### Import

```dart
import 'package:geo_finder/geo_finder.dart';
```

### Initialize

```dart
final geoFinder = GeoFinder();
```

### Request Permission

```dart
// Check if permission is granted
bool hasPermission = await geoFinder.checkLocationPermission();

// Request permission
bool granted = await geoFinder.requestLocationPermission();
```

### Get Current Location

```dart
try {
  GeoLocation location = await geoFinder.getCurrentLocation();
  print('Latitude: ${location.latitude}');
  print('Longitude: ${location.longitude}');
  print('Altitude: ${location.altitude} meters');
  print('Accuracy: ${location.accuracy} meters');
} catch (e) {
  print('Error: $e');
}
```

### Get Compass Heading

```dart
try {
  Heading heading = await geoFinder.getHeading();
  print('True North: ${heading.trueHeading}°');
  print('Magnetic North: ${heading.magneticHeading}°');
  print('Accuracy: ${heading.accuracy}°');
} catch (e) {
  print('Error: $e');
}
```

### Get Device Orientation

```dart
try {
  GeoDeviceOrientation orientation = await geoFinder.getDeviceOrientation();
  print('Pitch (X): ${orientation.pitch}°');
  print('Roll (Y): ${orientation.roll}°');
  print('Yaw (Z): ${orientation.yaw}°');
} catch (e) {
  print('Error: $e');
}
```

### Real-time Streams

```dart
// Location stream
geoFinder.getLocationStream().listen((location) {
  print('Location updated: ${location.latitude}, ${location.longitude}');
});

// Heading stream
geoFinder.getHeadingStream().listen((heading) {
  print('Heading updated: ${heading.trueHeading}°');
});

// Orientation stream
geoFinder.getOrientationStream().listen((orientation) {
  print('Orientation: pitch=${orientation.pitch}, roll=${orientation.roll}, yaw=${orientation.yaw}');
});
```

## API Reference

### GeoFinder

| Method | Return Type | Description |
|--------|-------------|-------------|
| `getCurrentLocation()` | `Future<GeoLocation>` | Get current location (latitude, longitude, altitude) |
| `getHeading()` | `Future<Heading>` | Get current compass heading |
| `getDeviceOrientation()` | `Future<GeoDeviceOrientation>` | Get current device orientation angles |
| `getLocationStream()` | `Stream<GeoLocation>` | Stream of location updates |
| `getHeadingStream()` | `Stream<Heading>` | Stream of heading updates |
| `getOrientationStream()` | `Stream<GeoDeviceOrientation>` | Stream of orientation updates |
| `requestLocationPermission()` | `Future<bool>` | Request location permission |
| `checkLocationPermission()` | `Future<bool>` | Check if location permission is granted |

### GeoLocation

| Property | Type | Description |
|----------|------|-------------|
| `latitude` | `double` | Latitude in degrees |
| `longitude` | `double` | Longitude in degrees |
| `altitude` | `double` | Altitude in meters |
| `accuracy` | `double` | Horizontal accuracy in meters |
| `timestamp` | `DateTime` | Timestamp of the reading |

### Heading

| Property | Type | Description |
|----------|------|-------------|
| `trueHeading` | `double` | Heading relative to true north (0-360°) |
| `magneticHeading` | `double` | Heading relative to magnetic north (0-360°) |
| `accuracy` | `double` | Accuracy in degrees |
| `timestamp` | `DateTime` | Timestamp of the reading |

### GeoDeviceOrientation

| Property | Type | Description |
|----------|------|-------------|
| `pitch` | `double` | Rotation around X-axis (front/back tilt, -180° to 180°) |
| `roll` | `double` | Rotation around Y-axis (left/right tilt, -90° to 90°) |
| `yaw` | `double` | Rotation around Z-axis (compass direction, 0° to 360°) |
| `timestamp` | `DateTime` | Timestamp of the reading |

## Platform Implementation

### iOS
- Uses `CoreLocation` for location, altitude, and compass heading
- Uses `CoreMotion` for device orientation (gyroscope/accelerometer)

### Android
- Uses `FusedLocationProviderClient` (Google Play Services) for location
- Uses `SensorManager` with accelerometer and magnetometer for compass
- Uses `SensorManager` with rotation vector sensor for device orientation

## Requirements

- iOS 12.0 or later
- Android API 21 (Android 5.0) or later

## License

MIT License

## Author

Landing Apps Inc.

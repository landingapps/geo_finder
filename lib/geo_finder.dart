import 'geo_finder_platform_interface.dart';
import 'src/models.dart';

export 'src/models.dart';

class GeoFinder {
  /// Get current location (latitude, longitude, altitude)
  Future<GeoLocation> getCurrentLocation() {
    return GeoFinderPlatform.instance.getCurrentLocation();
  }

  /// Get device heading (compass direction)
  Future<Heading> getHeading() {
    return GeoFinderPlatform.instance.getHeading();
  }

  /// Get device orientation (rotation angles on X, Y, Z axes)
  Future<GeoDeviceOrientation> getDeviceOrientation() {
    return GeoFinderPlatform.instance.getDeviceOrientation();
  }

  /// Get location stream (real-time updates)
  Stream<GeoLocation> getLocationStream() {
    return GeoFinderPlatform.instance.getLocationStream();
  }

  /// Get heading stream (real-time updates)
  Stream<Heading> getHeadingStream() {
    return GeoFinderPlatform.instance.getHeadingStream();
  }

  /// Get device orientation stream (real-time updates)
  Stream<GeoDeviceOrientation> getOrientationStream() {
    return GeoFinderPlatform.instance.getOrientationStream();
  }

  /// Request location permission
  Future<bool> requestLocationPermission() {
    return GeoFinderPlatform.instance.requestLocationPermission();
  }

  /// Check if location permission is granted
  Future<bool> checkLocationPermission() {
    return GeoFinderPlatform.instance.checkLocationPermission();
  }
}

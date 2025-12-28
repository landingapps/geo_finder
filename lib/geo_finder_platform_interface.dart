import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'geo_finder_method_channel.dart';
import 'src/models.dart';

abstract class GeoFinderPlatform extends PlatformInterface {
  GeoFinderPlatform() : super(token: _token);

  static final Object _token = Object();

  static GeoFinderPlatform _instance = MethodChannelGeoFinder();

  static GeoFinderPlatform get instance => _instance;

  static set instance(GeoFinderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Get current location (latitude, longitude, altitude)
  Future<GeoLocation> getCurrentLocation() {
    throw UnimplementedError('getCurrentLocation() has not been implemented.');
  }

  /// Get device heading (compass direction)
  Future<Heading> getHeading() {
    throw UnimplementedError('getHeading() has not been implemented.');
  }

  /// Get device orientation (rotation angles on X, Y, Z axes)
  Future<GeoDeviceOrientation> getDeviceOrientation() {
    throw UnimplementedError(
        'getDeviceOrientation() has not been implemented.');
  }

  /// Get location stream
  Stream<GeoLocation> getLocationStream() {
    throw UnimplementedError('getLocationStream() has not been implemented.');
  }

  /// Get heading stream
  Stream<Heading> getHeadingStream() {
    throw UnimplementedError('getHeadingStream() has not been implemented.');
  }

  /// Get device orientation stream
  Stream<GeoDeviceOrientation> getOrientationStream() {
    throw UnimplementedError(
        'getOrientationStream() has not been implemented.');
  }

  /// Request location permission
  Future<bool> requestLocationPermission() {
    throw UnimplementedError(
        'requestLocationPermission() has not been implemented.');
  }

  /// Check if location permission is granted
  Future<bool> checkLocationPermission() {
    throw UnimplementedError(
        'checkLocationPermission() has not been implemented.');
  }
}

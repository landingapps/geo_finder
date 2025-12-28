import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'geo_finder_platform_interface.dart';
import 'src/models.dart';

class MethodChannelGeoFinder extends GeoFinderPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('geo_finder');

  @visibleForTesting
  final locationEventChannel = const EventChannel('geo_finder/location');

  @visibleForTesting
  final headingEventChannel = const EventChannel('geo_finder/heading');

  @visibleForTesting
  final orientationEventChannel = const EventChannel('geo_finder/orientation');

  @override
  Future<GeoLocation> getCurrentLocation() async {
    final result =
        await methodChannel.invokeMapMethod<String, dynamic>('getCurrentLocation');
    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'Failed to get current location',
      );
    }
    return GeoLocation.fromMap(result);
  }

  @override
  Future<Heading> getHeading() async {
    final result =
        await methodChannel.invokeMapMethod<String, dynamic>('getHeading');
    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'Failed to get heading',
      );
    }
    return Heading.fromMap(result);
  }

  @override
  Future<GeoDeviceOrientation> getDeviceOrientation() async {
    final result =
        await methodChannel.invokeMapMethod<String, dynamic>('getDeviceOrientation');
    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'Failed to get device orientation',
      );
    }
    return GeoDeviceOrientation.fromMap(result);
  }

  @override
  Stream<GeoLocation> getLocationStream() {
    return locationEventChannel.receiveBroadcastStream().map((event) {
      return GeoLocation.fromMap(Map<String, dynamic>.from(event as Map));
    });
  }

  @override
  Stream<Heading> getHeadingStream() {
    return headingEventChannel.receiveBroadcastStream().map((event) {
      return Heading.fromMap(Map<String, dynamic>.from(event as Map));
    });
  }

  @override
  Stream<GeoDeviceOrientation> getOrientationStream() {
    return orientationEventChannel.receiveBroadcastStream().map((event) {
      return GeoDeviceOrientation.fromMap(Map<String, dynamic>.from(event as Map));
    });
  }

  @override
  Future<bool> requestLocationPermission() async {
    final result =
        await methodChannel.invokeMethod<bool>('requestLocationPermission');
    return result ?? false;
  }

  @override
  Future<bool> checkLocationPermission() async {
    final result =
        await methodChannel.invokeMethod<bool>('checkLocationPermission');
    return result ?? false;
  }
}

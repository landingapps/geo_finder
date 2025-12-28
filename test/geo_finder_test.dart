import 'package:flutter_test/flutter_test.dart';
import 'package:geo_finder/geo_finder.dart';
import 'package:geo_finder/geo_finder_platform_interface.dart';
import 'package:geo_finder/geo_finder_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGeoFinderPlatform
    with MockPlatformInterfaceMixin
    implements GeoFinderPlatform {
  @override
  Future<GeoLocation> getCurrentLocation() {
    return Future.value(GeoLocation(
      latitude: 35.6762,
      longitude: 139.6503,
      altitude: 40.0,
      accuracy: 10.0,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Future<Heading> getHeading() {
    return Future.value(Heading(
      trueHeading: 90.0,
      magneticHeading: 88.0,
      accuracy: 5.0,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Future<GeoDeviceOrientation> getDeviceOrientation() {
    return Future.value(GeoDeviceOrientation(
      pitch: 10.0,
      roll: 5.0,
      yaw: 45.0,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Stream<GeoLocation> getLocationStream() {
    return Stream.value(GeoLocation(
      latitude: 35.6762,
      longitude: 139.6503,
      altitude: 40.0,
      accuracy: 10.0,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Stream<Heading> getHeadingStream() {
    return Stream.value(Heading(
      trueHeading: 90.0,
      magneticHeading: 88.0,
      accuracy: 5.0,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Stream<GeoDeviceOrientation> getOrientationStream() {
    return Stream.value(GeoDeviceOrientation(
      pitch: 10.0,
      roll: 5.0,
      yaw: 45.0,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Future<bool> requestLocationPermission() => Future.value(true);

  @override
  Future<bool> checkLocationPermission() => Future.value(true);
}

void main() {
  final GeoFinderPlatform initialPlatform = GeoFinderPlatform.instance;

  test('$MethodChannelGeoFinder is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelGeoFinder>());
  });

  test('getCurrentLocation', () async {
    GeoFinder geoFinderPlugin = GeoFinder();
    MockGeoFinderPlatform fakePlatform = MockGeoFinderPlatform();
    GeoFinderPlatform.instance = fakePlatform;

    final location = await geoFinderPlugin.getCurrentLocation();
    expect(location.latitude, 35.6762);
    expect(location.longitude, 139.6503);
    expect(location.altitude, 40.0);
  });

  test('getHeading', () async {
    GeoFinder geoFinderPlugin = GeoFinder();
    MockGeoFinderPlatform fakePlatform = MockGeoFinderPlatform();
    GeoFinderPlatform.instance = fakePlatform;

    final heading = await geoFinderPlugin.getHeading();
    expect(heading.trueHeading, 90.0);
    expect(heading.magneticHeading, 88.0);
  });

  test('getDeviceOrientation', () async {
    GeoFinder geoFinderPlugin = GeoFinder();
    MockGeoFinderPlatform fakePlatform = MockGeoFinderPlatform();
    GeoFinderPlatform.instance = fakePlatform;

    final orientation = await geoFinderPlugin.getDeviceOrientation();
    expect(orientation.pitch, 10.0);
    expect(orientation.roll, 5.0);
    expect(orientation.yaw, 45.0);
  });

  test('checkLocationPermission', () async {
    GeoFinder geoFinderPlugin = GeoFinder();
    MockGeoFinderPlatform fakePlatform = MockGeoFinderPlatform();
    GeoFinderPlatform.instance = fakePlatform;

    expect(await geoFinderPlugin.checkLocationPermission(), true);
  });
}

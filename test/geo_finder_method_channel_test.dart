import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_finder/geo_finder_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelGeoFinder platform = MethodChannelGeoFinder();
  const MethodChannel channel = MethodChannel('geo_finder');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getCurrentLocation':
            return {
              'latitude': 35.6762,
              'longitude': 139.6503,
              'altitude': 40.0,
              'accuracy': 10.0,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            };
          case 'getHeading':
            return {
              'trueHeading': 90.0,
              'magneticHeading': 88.0,
              'accuracy': 5.0,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            };
          case 'getDeviceOrientation':
            return {
              'pitch': 10.0,
              'roll': 5.0,
              'yaw': 45.0,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            };
          case 'requestLocationPermission':
            return true;
          case 'checkLocationPermission':
            return true;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getCurrentLocation', () async {
    final location = await platform.getCurrentLocation();
    expect(location.latitude, 35.6762);
    expect(location.longitude, 139.6503);
    expect(location.altitude, 40.0);
  });

  test('getHeading', () async {
    final heading = await platform.getHeading();
    expect(heading.trueHeading, 90.0);
    expect(heading.magneticHeading, 88.0);
  });

  test('getDeviceOrientation', () async {
    final orientation = await platform.getDeviceOrientation();
    expect(orientation.pitch, 10.0);
    expect(orientation.roll, 5.0);
    expect(orientation.yaw, 45.0);
  });

  test('checkLocationPermission', () async {
    expect(await platform.checkLocationPermission(), true);
  });

  test('requestLocationPermission', () async {
    expect(await platform.requestLocationPermission(), true);
  });
}

// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:geo_finder/geo_finder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('checkLocationPermission test', (WidgetTester tester) async {
    final GeoFinder plugin = GeoFinder();
    // Just verify the method can be called without throwing
    final bool hasPermission = await plugin.checkLocationPermission();
    expect(hasPermission, isA<bool>());
  });
}

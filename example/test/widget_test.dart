import 'package:flutter_test/flutter_test.dart';

import 'package:geo_finder_example/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed
    expect(find.text('GeoFinder Demo'), findsOneWidget);
  });
}

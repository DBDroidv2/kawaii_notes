// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kawaii_notes/main.dart';
import 'package:kawaii_notes/src/services/hive_service.dart';
// Note: For more complex tests, consider using a mocking framework like mockito
// to create a more robust mock HiveService. For this basic test, an empty instance is sufficient.
import 'package:hive/hive.dart'; // Need this for Hive initialization in test

void main() {
  // Ensure Hive is initialized for tests that might interact with it indirectly
  setUpAll(() async {
    // Use Hive.init() for testing, not Hive.initFlutter()
    // A temporary directory path is needed for testing
     Hive.init('test_path'); // You might need a platform-specific path or setup
  });

  testWidgets('HomeScreen renders smoke test', (WidgetTester tester) async {
    // Create a dummy HiveService instance for the test
    final dummyHiveService = HiveService();
    // You might need to open mock boxes if the service constructor or init logic requires it
    // await dummyHiveService.openBoxes(); // Not strictly needed if MyApp doesn't immediately use boxes

    // Build our app and trigger a frame, providing the required service.
    await tester.pumpWidget(MyApp(hiveService: dummyHiveService));

    // Verify that the HomeScreen renders with the correct AppBar title.
    expect(find.text('Kawaii Notes'), findsOneWidget);

    // Verify the placeholder body text is present
    expect(find.text('Your notes will appear here! (^_^)'), findsOneWidget);

    // Verify the FAB icon is present
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}

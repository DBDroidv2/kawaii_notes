import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kawaii_notes/src/models/folder.dart';
import 'package:kawaii_notes/src/models/note.dart';
import 'package:kawaii_notes/src/utils/theme.dart';
import 'package:kawaii_notes/src/screens/home_screen.dart'; // Import the actual HomeScreen
import 'package:kawaii_notes/src/services/hive_service.dart'; // Import HiveService
import 'package:kawaii_notes/src/services/service_locator.dart'; // Import locator setup

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(FolderAdapter());

  // Initialize and open Hive boxes using the service
  final hiveService = HiveService(); // Keep this instance for MyApp if needed, or remove if locator is used everywhere
  await hiveService.openBoxes();

  // Setup the service locator
  setupLocator();

  // Pass the initial instance if MyApp still needs it, or remove hiveService param later
  runApp(MyApp(hiveService: hiveService));
}

class MyApp extends StatelessWidget {
  final HiveService hiveService; // Add service instance

  const MyApp({super.key, required this.hiveService}); // Update constructor

  @override
  Widget build(BuildContext context) {
    // Consider using a Provider or other state management solution
    // to make the service available throughout the app instead of passing it down.
    // For simplicity now, we'll keep it basic.
    return MaterialApp(
      title: 'Kawaii Notes',
      theme: kawaiiTheme, // Apply the kawaii theme
      home: const HomeScreen(), // Use the actual HomeScreen
      debugShowCheckedModeBanner: false, // Hide debug banner
    );
  } // Add the missing closing brace for build method
}

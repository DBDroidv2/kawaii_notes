import 'package:get_it/get_it.dart'; // Need to add this dependency
import 'package:kawaii_notes/src/services/hive_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register HiveService as a lazy singleton. It will be created only when first requested.
  locator.registerLazySingleton(() => HiveService());
}

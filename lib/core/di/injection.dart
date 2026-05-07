import 'package:get_it/get_it.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'session_module.dart';
import 'home_module.dart';
import 'core_module.dart';
import 'notes_module.dart';

final getIt = GetIt.instance;

/// Konfiguruje wszystkie zależności aplikacji.
///
/// Wywoływane w main.dart przed runApp().
Future<void> configureDependencies({bool revenueCatEnabled = false}) async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  registerSessionModule(getIt, revenueCatEnabled: revenueCatEnabled);
  registerHomeModule(getIt);
  registerCoreModule(getIt);
  registerNotesModule(getIt);

  // Kolejne moduły będą dodawane w trakcie kursu:
  // - /database: registerSupabaseModule(getIt)
}

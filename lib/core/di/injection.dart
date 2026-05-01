import 'package:get_it/get_it.dart';

import 'session_module.dart';
import 'home_module.dart';
import 'core_module.dart';

final getIt = GetIt.instance;

/// Konfiguruje wszystkie zależności aplikacji.
///
/// Wywoływane w main.dart przed runApp().
void configureDependencies({bool revenueCatEnabled = false}) {
  registerSessionModule(getIt, revenueCatEnabled: revenueCatEnabled);
  registerHomeModule(getIt);
  registerCoreModule(getIt);

  // Kolejne moduły będą dodawane w trakcie kursu:
  // - /database: registerSupabaseModule(getIt)
}

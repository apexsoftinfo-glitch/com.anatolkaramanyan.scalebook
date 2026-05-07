// Copyright © 2026 Adam Smaka. All rights reserved.
// This source code is proprietary software.
// Unauthorized copying, sharing, redistribution, or use outside the licensed course is prohibited.
// See LICENSE.md for full terms.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'core/config/api_keys.dart';
import 'core/config/revenuecat_config.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase
  if (ApiKeys.supabaseUrl.isNotEmpty && ApiKeys.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: ApiKeys.supabaseUrl,
      anonKey: ApiKeys.supabaseAnonKey,
    );
  }

  // RevenueCat — anonymous mode (Purchases.logIn added in /auth)
  var rcEnabled = false;
  if (!kIsWeb) {
    final rcApiKey = defaultTargetPlatform == TargetPlatform.iOS
        ? ApiKeys.revenueCatAppleApiKey
        : ApiKeys.revenueCatGoogleApiKey;
    if (rcApiKey.isNotEmpty) {
      await Purchases.configure(PurchasesConfiguration(rcApiKey));
      RevenueCatConfig.isEnabled = true;
      rcEnabled = true;
    }
  }
  if (!rcEnabled) {
    debugPrint('[RC] RevenueCat disabled (web=$kIsWeb or empty API key)');
  }

  // Dependency Injection
  await configureDependencies(revenueCatEnabled: rcEnabled);

  runApp(const App());
}

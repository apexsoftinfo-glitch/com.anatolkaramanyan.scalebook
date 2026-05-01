import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../core/config/revenuecat_config.dart';

/// Shows the RevenueCat paywall if user doesn't have "pro" entitlement.
///
/// Call from anywhere: limits dialog, settings, upgrade button, etc.
/// On web or when RC is not configured, shows a placeholder dialog.
/// Returns the paywall result (purchased, cancelled, etc.).
Future<PaywallResult> showPaywall(BuildContext context) async {
  // RC not configured (missing API key) — silent no-op for developer
  if (!RevenueCatConfig.isEnabled) {
    debugPrint('[Paywall] RevenueCat not configured, skipping paywall');
    return PaywallResult.cancelled;
  }

  // Web — show info dialog for the user
  if (kIsWeb) {
    if (!context.mounted) return PaywallResult.cancelled;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Pro'), // L10N
        content: const Text(
          'In-app purchases are not available on web.\n'
          'Please use the iOS or Android app to upgrade.', // L10N
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'), // L10N
          ),
        ],
      ),
    );
    return PaywallResult.cancelled;
  }

  try {
    final result = await RevenueCatUI.presentPaywall();
    debugPrint('[Paywall] result: $result');
    return result;
  } on PlatformException catch (e) {
    debugPrint('[Paywall] PlatformException: ${e.code} — ${e.message}');
    return PaywallResult.error;
  }
}

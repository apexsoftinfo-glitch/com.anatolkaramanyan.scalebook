/// Global RevenueCat configuration state.
///
/// Set [isEnabled] in main.dart after Purchases.configure().
/// Check before any direct RC SDK call outside DI (e.g. showPaywall).
abstract class RevenueCatConfig {
  /// Whether RevenueCat SDK was successfully configured at startup.
  static bool isEnabled = false;
}

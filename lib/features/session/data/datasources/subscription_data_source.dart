/// Subscription data source interface.
///
/// Initially provides only isPro check (anonymous RC mode).
/// /auth adds: logIn(), logOut()
/// /subscription adds: full CustomerInfo stream, purchase(), getOfferings(), etc.
abstract class SubscriptionDataSource {
  /// Stream of whether user has active "pro" entitlement.
  Stream<bool> watchIsPro();

  /// One-time check of "pro" entitlement.
  Future<bool> getIsPro();
}

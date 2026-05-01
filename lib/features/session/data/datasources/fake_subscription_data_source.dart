import 'package:rxdart/rxdart.dart';

import 'subscription_data_source.dart';

/// Fake SubscriptionDataSource — always free tier (isPro = false).
/// Used for tests and development without RevenueCat API keys.
class FakeSubscriptionDataSource implements SubscriptionDataSource {
  @override
  Stream<bool> watchIsPro() => BehaviorSubject<bool>.seeded(false).stream;

  @override
  Future<bool> getIsPro() async => false;
}

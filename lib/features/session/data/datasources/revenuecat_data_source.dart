import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rxdart/rxdart.dart';

import 'subscription_data_source.dart';

/// RevenueCat implementation of SubscriptionDataSource.
///
/// Anonymous mode — no logIn/logOut (added in /auth).
/// Full CustomerInfo stream and purchase methods added in /subscription.
class RevenueCatDataSource implements SubscriptionDataSource {
  final _isProController = BehaviorSubject<bool>.seeded(false);

  RevenueCatDataSource();

  /// Must be called after Purchases.configure().
  void init() {
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    _fetchInitial();
  }

  void _onCustomerInfoUpdated(CustomerInfo info) {
    _isProController.add(_hasPro(info));
  }

  Future<void> _fetchInitial() async {
    try {
      final info = await Purchases.getCustomerInfo();
      _isProController.add(_hasPro(info));
    } catch (e) {
      debugPrint('[RevenueCatDS] Initial fetch failed: $e');
      // Keep false (free tier) — RC SDK will sync when possible
    }
  }

  bool _hasPro(CustomerInfo info) {
    return info.entitlements.active.containsKey('pro');
  }

  @override
  Stream<bool> watchIsPro() => _isProController.stream.distinct();

  @override
  Future<bool> getIsPro() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return _hasPro(info);
    } catch (e) {
      debugPrint('[RevenueCatDS] getIsPro failed: $e');
      return false;
    }
  }

  void dispose() {
    _isProController.close();
  }
}

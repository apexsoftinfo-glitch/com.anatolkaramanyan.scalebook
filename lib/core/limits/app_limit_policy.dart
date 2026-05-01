import 'limit_policy.dart';

/// App-specific limit policy.
/// Values are set in /start step based on IDEA.md.
const appLimitPolicy = LimitPolicy(
  type: LimitType.count,
  guestLimit: 3,
);

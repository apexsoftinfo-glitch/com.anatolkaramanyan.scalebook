import '../../features/session/domain/models/user_tier.dart';

enum LimitType { count, daily, weekly, monthly }

class LimitPolicy {
  final LimitType type;
  final int guestLimit;
  static const int registeredMultiplier = 3;

  const LimitPolicy({
    required this.type,
    required this.guestLimit,
  });

  int? getLimit(UserTier tier) {
    return switch (tier) {
      UserTier.guest => guestLimit,
      UserTier.registered => guestLimit * registeredMultiplier,
      UserTier.pro => null, // unlimited
    };
  }

  bool canAdd(UserTier tier, int currentCount) {
    final limit = getLimit(tier);
    if (limit == null) return true;
    return currentCount < limit;
  }

  int? remaining(UserTier tier, int currentCount) {
    final limit = getLimit(tier);
    if (limit == null) return null;
    return (limit - currentCount).clamp(0, limit);
  }

  UserTier? nextTier(UserTier currentTier) {
    return switch (currentTier) {
      UserTier.guest => UserTier.registered,
      UserTier.registered => UserTier.pro,
      UserTier.pro => null,
    };
  }
}

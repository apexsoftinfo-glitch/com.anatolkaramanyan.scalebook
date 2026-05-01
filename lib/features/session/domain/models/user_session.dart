import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../profiles/models/profile_model.dart';
import 'user_tier.dart';

import '../../../../core/limits/app_limit_policy.dart';

part 'user_session.freezed.dart';

/// Represents the current user session state.
///
/// Tier is ALWAYS computed, never stored:
/// - isPro comes from RevenueCat (added in /subscription)
/// - isAnonymous comes from Supabase Auth (added in /auth)
///
/// Evolution:
/// - /logic: FakeSessionRepository (tier = guest)
/// - /auth: partial SessionRepository (auth + profile + connectivity)
/// - /subscription: full SessionRepository (+ RevenueCat)
@freezed
class UserSession with _$UserSession {
  const UserSession._();

  const factory UserSession({
    required String? userId,
    required bool isAnonymous,
    required bool isOffline,
    required ProfileModel? profile,
    /// Whether user has active "pro" entitlement.
    /// Always false until /subscription step adds RevenueCat.
    @Default(false) bool isPro,
  }) = _UserSession;

  const factory UserSession.unauthenticated() = _Unauthenticated;
  const factory UserSession.initializing() = _Initializing;

  String? get userId => map(
        (s) => s.userId,
        unauthenticated: (_) => null,
        initializing: (_) => null,
      );

  bool get isAnonymous => map(
        (s) => s.isAnonymous,
        unauthenticated: (_) => true,
        initializing: (_) => true,
      );

  // === COMPUTED PROPERTIES ===

  UserTier get tier => map(
        (session) {
          if (session.isPro) return UserTier.pro;
          if (!session.isAnonymous) return UserTier.registered;
          return UserTier.guest;
        },
        unauthenticated: (_) => UserTier.guest,
        initializing: (_) => UserTier.guest,
      );

  int? get limit => switch (tier) {
        UserTier.guest => appLimitPolicy.guestLimit,
        UserTier.registered => null,
        UserTier.pro => null,
      };

  bool get needsOnboarding => map(
        (session) => session.userId != null && session.profile == null,
        unauthenticated: (_) => false,
        initializing: (_) => false,
      );

  bool get hasCompletedOnboarding => map(
        (session) => session.profile?.hasCompletedOnboarding ?? false,
        unauthenticated: (_) => false,
        initializing: (_) => false,
      );

  bool get shouldShowRegisterCTA => map(
        (session) => session.isAnonymous && session.isPro,
        unauthenticated: (_) => false,
        initializing: (_) => false,
      );

  String get displayName => map(
        (session) => session.profile?.firstName ?? 'Użytkownik', // L10N
        unauthenticated: (_) => 'Użytkownik', // L10N
        initializing: (_) => 'Użytkownik', // L10N
      );
}

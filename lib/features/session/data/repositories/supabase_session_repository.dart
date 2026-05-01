import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../../../profiles/models/profile_model.dart';
import '../datasources/auth_data_source.dart';
import '../datasources/connectivity_data_source.dart';
import '../datasources/profile_data_source.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/subscription_data_source.dart';
import '../../domain/models/user_session.dart';
import '../../domain/repositories/session_repository.dart';

class SupabaseSessionRepository implements SessionRepository {
  final AuthDataSource _authDataSource;
  final ProfileDataSource _profileDataSource;
  final ProfileLocalDataSource _profileLocalDataSource;
  final SubscriptionDataSource _subscriptionDataSource;
  final ConnectivityDataSource _connectivityDataSource;

  final _sessionController = BehaviorSubject<UserSession>.seeded(const UserSession.initializing());
  StreamSubscription? _authSubscription;
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _subscriptionStatusSubscription;

  SupabaseSessionRepository(
    this._authDataSource,
    this._profileDataSource,
    this._profileLocalDataSource,
    this._subscriptionDataSource,
    this._connectivityDataSource,
  );

  @override
  Stream<UserSession> get sessionStream => _sessionController.stream.distinct();

  @override
  UserSession get current => _sessionController.value;

  @override
  Future<void> initialize() async {
    // 1. Listen to connectivity
    _connectivitySubscription = _connectivityDataSource.watchIsOffline().listen((isOffline) {
      _updateSession(isOffline: isOffline);
    });

    // 2. Listen to subscription (RevenueCat)
    _subscriptionStatusSubscription = _subscriptionDataSource.watchIsPro().listen((isPro) {
      _updateSession(isPro: isPro);
    });

    // 3. Listen to auth state changes
    // We rely on the stream to give us the restored session.
    _authSubscription = _authDataSource.authStateChanges.listen((user) async {
      final isInitializing = _sessionController.value.map(
        (_) => false,
        unauthenticated: (_) => false,
        initializing: (_) => true,
      );

      if (user == null) {
        // If we are still initializing, don't immediately jump to unauthenticated.
        // Supabase often emits a null state while restoring the session.
        if (isInitializing) return;

        // Only emit unauthenticated if we are not already in that state
        final isUnauthenticated = _sessionController.value.map(
          (_) => false,
          unauthenticated: (_) => true,
          initializing: (_) => false,
        );
        if (!isUnauthenticated) {
          _sessionController.add(const UserSession.unauthenticated());
        }
      } else {
        // Fetch profile
        final profile = await _fetchProfile(user.id);
        _updateSession(
          userId: user.id,
          isAnonymous: user.isAnonymous,
          profile: profile,
        );
      }
    });

    // 4. Initial check (backup)
    final initialUser = _authDataSource.currentUser;
    if (initialUser != null) {
      final profile = await _fetchProfile(initialUser.id);
      _updateSession(
        userId: initialUser.id,
        isAnonymous: initialUser.isAnonymous,
        profile: profile,
      );
    } else {
      // Don't emit unauthenticated immediately, wait a bit for the stream
      // but if after 2 seconds we still have nothing, emit unauthenticated
      Future.delayed(const Duration(seconds: 2), () {
        final isStillInitializing = _sessionController.value.map(
          (_) => false,
          unauthenticated: (_) => false,
          initializing: (_) => true,
        );
        if (isStillInitializing) {
          _sessionController.add(const UserSession.unauthenticated());
        }
      });
    }
  }

  @override
  Future<void> refresh() async {
    final user = _authDataSource.currentUser;
    if (user != null) {
      final profile = await _fetchProfile(user.id);
      final isPro = await _subscriptionDataSource.getIsPro();
      _updateSession(
        userId: user.id,
        isAnonymous: user.isAnonymous,
        profile: profile,
        isPro: isPro,
      );
    }
  }

  @override
  Future<void> signInAnonymously() async {
    await _authDataSource.signInAnonymously();
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _authDataSource.signInWithEmail(email, password);
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    await _authDataSource.signUpWithEmail(email, password);
  }

  @override
  Future<void> signOut() async {
    await _authDataSource.signOut();
    _sessionController.add(const UserSession.unauthenticated());
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    await _profileDataSource.upsertProfile(profile);
    await _profileLocalDataSource.cacheProfile(profile);
    await refresh();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _subscriptionStatusSubscription?.cancel();
    _sessionController.close();
  }

  // === Private Helpers ===

  Future<ProfileModel?> _fetchProfile(String userId) async {
    try {
      // Try local cache first
      var profile = await _profileLocalDataSource.getCachedProfile(userId);
      if (profile != null && profile.id == userId) return profile;

      // Fetch from remote
      profile = await _profileDataSource.getProfile(userId);
      if (profile != null) {
        await _profileLocalDataSource.cacheProfile(profile);
      }
      return profile;
    } catch (e) {
      debugPrint('[SessionRepository] Profile fetch error: $e');
      return null;
    }
  }

  void _updateSession({
    String? userId,
    bool? isAnonymous,
    bool? isOffline,
    ProfileModel? profile,
    bool? isPro,
  }) {
    final prev = current.map(
      (s) => s,
      unauthenticated: (_) => null,
      initializing: (_) => null,
    );

    if (prev == null && userId == null) return;

    _sessionController.add(UserSession(
      userId: userId ?? prev?.userId,
      isAnonymous: isAnonymous ?? prev?.isAnonymous ?? true,
      isOffline: isOffline ?? prev?.isOffline ?? false,
      profile: profile ?? prev?.profile,
      isPro: isPro ?? prev?.isPro ?? false,
    ));
  }
}

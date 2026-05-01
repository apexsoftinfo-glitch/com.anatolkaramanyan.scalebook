import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/profiles/models/profile_model.dart';
import '../../features/session/data/datasources/auth_data_source.dart';
import '../../features/session/data/datasources/supabase_auth_data_source.dart';
import '../../features/session/data/datasources/connectivity_data_source.dart';
import '../../features/session/data/datasources/fake_connectivity_data_source.dart';
import '../../features/session/data/datasources/profile_data_source.dart';
import '../../features/session/data/datasources/supabase_profile_data_source.dart';
import '../../features/session/data/datasources/profile_local_data_source.dart';
import '../../features/session/data/datasources/shared_prefs_profile_local_data_source.dart';
import '../../features/session/data/datasources/fake_subscription_data_source.dart';
import '../../features/session/data/datasources/revenuecat_data_source.dart';
import '../../features/session/data/datasources/subscription_data_source.dart';
import '../../features/session/data/repositories/supabase_session_repository.dart';
import '../../features/session/domain/repositories/session_repository.dart';
import '../../features/session/presentation/cubit/session_cubit.dart';

import '../config/api_keys.dart';

void registerSessionModule(GetIt getIt, {bool revenueCatEnabled = false}) {
  final useSupabase = ApiKeys.supabaseUrl.isNotEmpty && ApiKeys.supabaseAnonKey.isNotEmpty;

  // DataSources
  if (useSupabase) {
    getIt.registerLazySingleton<AuthDataSource>(() => SupabaseAuthDataSource());
    getIt.registerLazySingleton<ProfileDataSource>(() => SupabaseProfileDataSource());
  } else {
    // Fallback if no keys provided to prevent crash
    getIt.registerLazySingleton<AuthDataSource>(() => _MockAuthDataSource());
    getIt.registerLazySingleton<ProfileDataSource>(() => _MockProfileDataSource());
  }
  getIt.registerLazySingleton<ProfileLocalDataSource>(() => SharedPrefsProfileLocalDataSource());
  getIt.registerLazySingleton<ConnectivityDataSource>(() => FakeConnectivityDataSource());

  // Subscription — RevenueCat or Fake fallback
  if (revenueCatEnabled) {
    getIt.registerLazySingleton<SubscriptionDataSource>(() {
      final ds = RevenueCatDataSource();
      ds.init();
      return ds;
    });
  } else {
    getIt.registerLazySingleton<SubscriptionDataSource>(
      () => FakeSubscriptionDataSource(),
    );
  }

  // Repository
  getIt.registerLazySingleton<SessionRepository>(
    () => SupabaseSessionRepository(
      getIt<AuthDataSource>(),
      getIt<ProfileDataSource>(),
      getIt<ProfileLocalDataSource>(),
      getIt<SubscriptionDataSource>(),
      getIt<ConnectivityDataSource>(),
    )..initialize(),
  );

  // Cubit — singleton (shared across app)
  getIt.registerLazySingleton<SessionCubit>(
    () => SessionCubit(getIt<SessionRepository>()),
  );
}

class _MockAuthDataSource implements AuthDataSource {
  final _controller = BehaviorSubject<User?>.seeded(null);

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _controller.value;

  @override
  Future<void> signInAnonymously() async {
    // Simulate anonymous user
    _controller.add(User(
      id: 'mock-guest-id',
      appMetadata: {},
      userMetadata: {},
      aud: '',
      createdAt: '',
      isAnonymous: true,
    ));
  }

  @override
  Future<void> signInWithEmail(String e, String p) async {
    _controller.add(User(
      id: 'mock-user-id',
      email: e,
      appMetadata: {},
      userMetadata: {},
      aud: '',
      createdAt: '',
      isAnonymous: false,
    ));
  }

  @override
  Future<void> signUpWithEmail(String e, String p) async => signInWithEmail(e, p);

  @override
  Future<void> signOut() async => _controller.add(null);

  @override
  Future<void> resetPassword(String e) async {}
  @override
  Future<void> linkEmailToAnonymous(String e, String p) async {}
  @override
  Future<void> deleteAccount() async => _controller.add(null);
}

class _MockProfileDataSource implements ProfileDataSource {
  final Map<String, ProfileModel> _profiles = {};

  @override
  Stream<ProfileModel?> watchProfile(String userId) => Stream.value(_profiles[userId]);

  @override
  Future<ProfileModel?> getProfile(String userId) async => _profiles[userId];

  @override
  Future<void> upsertProfile(ProfileModel profile) async {
    _profiles[profile.id] = profile;
  }

  @override
  Future<ProfileModel> ensureProfile(String userId) async {
    return _profiles.putIfAbsent(
      userId,
      () => ProfileModel(id: userId, firstName: 'Modelarz', hasCompletedOnboarding: false), // L10N
    );
  }
}

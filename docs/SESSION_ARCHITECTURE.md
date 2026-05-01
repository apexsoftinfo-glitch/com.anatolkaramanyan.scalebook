# Session Architecture: Supabase Auth + RevenueCat + Profile

> Dokument architektury dla Flutter template — zarządzanie sesją użytkownika z obsługą stanów Guest/Registered/Pro, offline mode i synchronizacją RevenueCat.

---

## 1. Założenia biznesowe

### 1.1 Macierz stanów użytkownika

| Auth State | Entitlement | Tier | Limit | Opis |
|------------|-------------|------|-------|------|
| anonymous | free | `guest` | 5 | Nowy użytkownik bez rejestracji |
| anonymous | pro | `pro` | ∞ | Gość który zapłacił (CTA: "zarejestruj się żeby nie stracić zakupu") |
| registered | free | `registered` | 15 | Zarejestrowany użytkownik |
| registered | pro | `pro` | ∞ | Pełny użytkownik premium |

**Kluczowa zasada:** Tier jest **zawsze wyliczany** (computed), nigdy nie jest przechowywany w bazie danych.

### 1.2 Flow użytkownika

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           WELCOME SCREEN                                │
│                                                                         │
│   [Rozpocznij]                              [Zaloguj się]               │
│       │                                          │                      │
│       ▼                                          ▼                      │
│   signInAnonymously()                     signIn(email/OAuth)           │
│       │                                          │                      │
│       ▼                                          │                      │
│   ONBOARDING (imię)                              │                      │
│       │                                          │                      │
│       ▼                                          │                      │
│   createProfile()                                │                      │
│       │                                          │                      │
│       └──────────────────┬───────────────────────┘                      │
│                          ▼                                              │
│                     HOME SCREEN                                         │
│                          │                                              │
│              ┌───────────┼───────────┐                                  │
│              ▼           ▼           ▼                                  │
│         limit 5      limit 15      limit ∞                              │
│         (guest)    (registered)    (pro)                                │
│              │           │                                              │
│              ▼           ▼                                              │
│         CTA: Register  CTA: Paywall                                     │
│              │           │                                              │
│              ▼           │                                              │
│      linkIdentity()      │                                              │
│      (user_id ZACHOWANY) │                                              │
│              │           │                                              │
│              └───────────┴──────────► RevenueCat Purchase               │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.3 Scenariusze auth

| Akcja | Metoda | user_id | Dane gościa |
|-------|--------|---------|-------------|
| Gość → Nowe konto | `linkIdentity()` / `updateUser()` | Zachowany | Zachowane |
| Gość → Istniejące konto | `signOut()` + `signIn()` | **Nowy** | **Porzucone** |
| Logout | `signOut()` | - | Clear cache → Welcome |

---

## 2. Architektura techniczna

### 2.1 Stack

- **Flutter** + **Bloc (Cubity)** + **Freezed** + **get_it/injectable**
- **Supabase** (Auth + Database + Realtime)
- **RevenueCat** (Subscriptions)
- **RxDart** (BehaviorSubject, combineLatest, switchMap)
- **flutter_secure_storage** (Cache)
- **Clean Architecture** (bez use-cases): `UI → Cubit → Repository → DataSource`

### 2.2 Diagram architektury streama

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SessionRepository                               │
│                    (Single Source of Truth)                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   AuthDataSource                                                        │
│   └─► onAuthStateChange ──┐                                             │
│                           │                                             │
│                           ▼                                             │
│                      switchMap(user)                                    │
│                           │                                             │
│            ┌──────────────┼──────────────┐                              │
│            │              │              │                              │
│            ▼              ▼              ▼                              │
│     ProfileDataSource  RCDataSource  ConnectivityDS                     │
│     (Supabase+Cache)   (RevenueCat)  (Network)                          │
│            │              │              │                              │
│            │   BehaviorSubject<T>        │                              │
│            │              │              │                              │
│            └──────────────┼──────────────┘                              │
│                           │                                             │
│                           ▼                                             │
│                  Rx.combineLatest3()                                    │
│                           │                                             │
│                           ▼                                             │
│              BehaviorSubject<UserSession>                               │
│                           │                                             │
│                           ▼                                             │
│                    [Cubits / UI]                                        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 2.3 Dlaczego switchMap + combineLatest?

**Problem z samym `combineLatest`:**
Przy wylogowaniu możesz dostać "glitch" — stary profil + brak usera przez ułamek sekundy.

**Rozwiązanie:**
```dart
authStateChanges
  .switchMap((user) {
    if (user == null) {
      return Stream.value(UserSession.unauthenticated());
    }
    return Rx.combineLatest3(
      profileStream(user.id),
      entitlementsStream(),
      connectivityStream(),
      (profile, entitlements, connectivity) => UserSession(...),
    );
  })
  .listen(_sessionSubject.add);
```

`switchMap` anuluje poprzednie subskrypcje przy zmianie usera — zero wycieków, zero niespójności.

### 2.4 Error handling w streamach (KRYTYCZNE)

**Problem:** Błąd wewnątrz `combineLatest` (np. błąd sieci przy pobieraniu profilu) może zabić cały stream sesji (stream termination).

**Rozwiązanie:** Error handling na poziomie źródeł — każdy stream sam obsługuje swoje błędy i emituje fallback. `combineLatest` dostaje "czyste" streamy które nigdy nie emitują error.

```dart
// Źródła — tylko error logging, fallback do cache/null
Stream<Profile?> watchProfile(String userId) {
  return _supabaseStream
    .doOnError((e, s) => debugPrint('[ProfileDS] Error: $e'))
    .onErrorResumeNext(_cachedProfileStream(userId));
}

Stream<CustomerInfo?> watchEntitlements() {
  return _rcStream
    .doOnError((e, s) => debugPrint('[SubscriptionDS] Error: $e'))
    .onErrorReturn(null); // null = treat as free tier
}

Stream<bool> watchConnectivity() {
  return _connectivityStream
    .doOnError((e, s) => debugPrint('[ConnectivityDS] Error: $e'))
    .onErrorReturn(false); // assume offline on error
}
```

**Zasada:** Streamy źródłowe **nigdy nie powinny emitować error** do `combineLatest`. Każdy sam obsługuje swoje błędy i emituje fallback (cached value / null).

### 2.5 Distinct — eliminacja duplikatów

Bez `distinct` możesz mieć spam emisji tej samej wartości:
- Supabase Realtime czasem emituje duplikaty
- RevenueCat listener może odpalić kilka razy z tym samym `CustomerInfo`
- `combineLatest` emituje przy **każdej** zmianie **dowolnego** źródła

**Gdzie dodać `distinct`:**

| Stream | distinct? | Uwaga |
|--------|-----------|-------|
| Profile | ✅ Tak | Freezed, działa out-of-box |
| CustomerInfo | ✅ Tak | Custom comparator (tylko entitlements) |
| Connectivity | ✅ Tak | bool, trivial |
| **Final UserSession** | ✅ Tak | Freezed, ostatnia linia obrony |

```dart
import 'package:collection/collection.dart'; // SetEquality

// CustomerInfo wymaga custom comparator (nie jest Freezed)
Stream<CustomerInfo?> watchEntitlements() {
  return _rcStream
    .distinct((a, b) => const SetEquality().equals(
      a?.entitlements.active.keys.toSet(),
      b?.entitlements.active.keys.toSet(),
    ))
    .doOnError((e, s) => debugPrint('[SubscriptionDS] Error: $e'))
    .onErrorReturn(null);
}
```

> **Dlaczego `SetEquality`?** `toString()` na `Iterable.keys` nie gwarantuje kolejności — dwa identyczne zestawy entitlements mogą dać różne stringi. `SetEquality` z pakietu `collection` porównuje zawartość niezależnie od kolejności.

### 2.6 Kompletny stream z logowaniem

```dart
authStateChanges
  .switchMap((user) {
    if (user == null) {
      return Stream.value(UserSession.unauthenticated());
    }
    return Rx.combineLatest3(
      profileStream(user.id),
      entitlementsStream(),
      connectivityStream(),
      (profile, entitlements, connectivity) => UserSession(
        userId: user.id,
        isAnonymous: user.isAnonymous,
        isOffline: !connectivity,
        profile: profile,
        customerInfo: entitlements,
      ),
    );
  })
  .distinct() // Freezed UserSession — działa out-of-box
  .doOnData((s) => debugPrint('[Session] ${s.tier} | offline=${s.isOffline} | pro=${s.isPro}'))
  .listen(_sessionSubject.add);
```

**Logowanie:**
- Źródła: tylko `doOnError` (błędy)
- Końcowy stream: `doOnData` po `distinct` (tylko unikalne zmiany stanu)

---

## 3. Model danych

### 3.1 UserSession (Freezed)

```dart
@freezed
class UserSession with _$UserSession {
  const UserSession._();
  
  const factory UserSession({
    required String? userId,
    required bool isAnonymous,
    required bool isOffline,
    required Profile? profile,
    required CustomerInfo? customerInfo,
  }) = _UserSession;
  
  const factory UserSession.unauthenticated() = _Unauthenticated;
  const factory UserSession.initializing() = _Initializing;

  // === COMPUTED PROPERTIES ===
  
  bool get isPro => customerInfo?.entitlements.active.containsKey('pro') ?? false;
  
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
    UserTier.guest => 5,
    UserTier.registered => 15,
    UserTier.pro => null, // unlimited
  };
  
  bool get needsOnboarding => 
    userId != null && profile == null;
    
  bool get shouldShowRegisterCTA =>
    isAnonymous && isPro; // "Zarejestruj się żeby nie stracić zakupu"
}

enum UserTier { guest, registered, pro }
```

### 3.2 Profile (Freezed)

```dart
@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String? firstName,
    required String? lastName,
    required String? city,
    required String? avatarUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Profile;
  
  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}
```

### 3.3 Tabela SQL

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name TEXT,
  last_name TEXT,
  city TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own profile" 
  ON profiles FOR SELECT 
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" 
  ON profiles FOR INSERT 
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
  ON profiles FOR UPDATE 
  USING (auth.uid() = id);
```

---

## 4. Synchronizacja RevenueCat

### 4.1 Zasada podstawowa

**`Purchases.logIn(supabaseUser.id)` zawsze po zmianie `user.id`.**

RevenueCat `appUserID` musi być identyczny z Supabase `user.id` — nawet dla anonymous users.

### 4.2 Sekwencja inicjalizacji (KRYTYCZNA)

```dart
// ❌ ŹLE - race condition
Future<void> initBad() async {
  Supabase.initialize(...);
  Purchases.configure(...);
  // RC nie wie kim jest user!
}

// ✅ DOBRZE - deterministyczna kolejność
Future<void> initGood() async {
  // 1. Supabase najpierw
  await Supabase.initialize(...);
  
  // 2. Sprawdź czy jest cached session
  final session = supabase.auth.currentSession;
  
  // 3. Konfiguruj RC
  await Purchases.configure(PurchasesConfiguration(apiKey));
  
  // 4. Jeśli jest user -> logIn do RC (fire & forget, nie blokuj startu)
  if (session != null) {
    try {
      await Purchases.logIn(session.user.id);
    } catch (e) {
      // Brak sieci przy starcie — kontynuuj z cached entitlements (free tier)
      debugPrint('[Init] RC logIn failed: $e — continuing with cached state');
    }
  }

  // 5. Dopiero teraz startuj SessionRepository
  getIt<SessionRepository>().initialize();
}
```

> **Dlaczego try/catch?** Jeśli `Purchases.logIn` rzuci wyjątek (brak sieci przy cold start), app się nie uruchomi. RC SDK ma wbudowany cache — user zobaczy ostatni znany stan entitlements, a sync nastąpi gdy wróci sieć.

### 4.3 Kiedy wywoływać Purchases.logIn/logOut

| Zdarzenie | Akcja RC |
|-----------|----------|
| `signInAnonymously()` | `Purchases.logIn(user.id)` |
| `signIn(email/OAuth)` | `Purchases.logIn(user.id)` |
| `linkIdentity()` | **NIC** (user.id się nie zmienia!) |
| `updateUser(email)` | **NIC** (user.id się nie zmienia!) |
| `signOut()` | `Purchases.logOut()` |

### 4.4 Listener vs Webhook

**Decyzja:** Client listener + refresh on app resume.

| Aspekt | Client Listener | Webhook → Supabase |
|--------|-----------------|-------------------|
| Złożoność | Niska | Wysoka |
| Multi-device instant sync | ❌ Nie | ✅ Tak |
| Wystarczy dla 99% userów | ✅ Tak | - |

**Implementacja:**
```dart
// W SubscriptionDataSource
void initialize() {
  Purchases.addCustomerInfoUpdateListener((info) {
    _customerInfoSubject.add(info);
  });
}

// Refresh on resume (w SessionRepository lub AppLifecycle observer)
void onAppResumed() {
  // Throttle: max raz na 30s
  if (_lastRefresh.difference(DateTime.now()) > Duration(seconds: 30)) {
    Purchases.getCustomerInfo().then(_customerInfoSubject.add);
    _profileRepository.refresh();
    _lastRefresh = DateTime.now();
  }
}
```

**TODO v2:** Webhook RC → Supabase Edge Function dla instant multi-device sync.

---

## 5. Obsługa offline

### 5.1 Strategia: Stale-While-Revalidate + Read-Only

| Źródło | Cache | Offline behavior |
|--------|-------|------------------|
| Supabase Auth | SDK (automatic) | ✅ Works |
| RevenueCat | SDK (automatic) | ✅ Works |
| Profile (DB) | flutter_secure_storage | ✅ Read cached |
| Realtime | - | ❌ Disconnected |
| Writes | - | ❌ Blocked |

### 5.2 ProfileDataSource — flow

```dart
Stream<Profile?> watchProfile(String userId) {
  // UWAGA: Nie używaj async* z yield* — nie anuluje subskrypcji poprawnie!
  // Zamiast tego: startWith (cache) + switchMap (realtime)

  final cacheStream = Stream.fromFuture(_loadCachedProfile(userId));

  final realtimeStream = _connectivity.isConnectedStream
    .switchMap((isConnected) {
      if (!isConnected) return Stream<Profile?>.empty();

      return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isEmpty ? null : Profile.fromJson(data.first))
        .doOnData((profile) => _cacheProfile(userId, profile));
    });

  return Rx.concat([cacheStream, realtimeStream])
    .doOnError((e, s) => debugPrint('[ProfileDS] Error: $e'))
    .onErrorResumeNext(cacheStream); // fallback do cache przy błędzie
}

Future<Profile?> _loadCachedProfile(String userId) async {
  final cached = await _secureStorage.read(key: 'profile_$userId');
  return cached != null ? Profile.fromJson(jsonDecode(cached)) : null;
}

void _cacheProfile(String userId, Profile? profile) {
  // TODO: dodaj 2s throttle na zapis
  if (profile != null) {
    _secureStorage.write(
      key: 'profile_$userId',
      value: jsonEncode(profile.toJson()),
    );
  }
}
```

> **Dlaczego nie `async*`?** Generator z `yield*` nie anuluje wewnętrznego streama poprawnie przy cancel. Jeśli `switchMap` anuluje stream między `yield cached` a `yield* realtime`, subskrypcja realtime nigdy się nie odpnie — memory leak.

### 5.3 Read-only mode

```dart
// W Cubit/Repository
Future<void> updateProfile(Profile profile) async {
  final session = _sessionRepository.current;
  
  if (session.isOffline) {
    throw OfflineException('Edycja profilu wymaga połączenia z internetem');
  }
  
  await _profileRepository.update(profile);
}
```

---

## 6. Error handling

### 6.1 Błąd tworzenia profilu (BLOCKING)

```dart
// W AuthRepository
Future<User> signInAnonymously() async {
  final response = await _supabase.auth.signInAnonymously();
  final user = response.user!;
  
  // RC logIn
  await Purchases.logIn(user.id);
  
  return user;
  // Profile tworzony osobno w Onboarding!
}

// W OnboardingCubit
Future<void> completeOnboarding(String firstName) async {
  emit(OnboardingState.loading());
  
  try {
    await _profileRepository.create(
      Profile(
        id: _authRepository.currentUser!.id,
        firstName: firstName,
        // ...
      ),
    );
    emit(OnboardingState.success());
  } catch (e) {
    emit(OnboardingState.error(
      message: 'Nie udało się utworzyć profilu. Spróbuj ponownie.',
      canRetry: true,
    ));
  }
}
```

### 6.2 Stan "zombie" (auth OK, profile brak)

Wykrywany przez `UserSession.needsOnboarding`:
```dart
// W MainCubit lub Router
void handleSessionChange(UserSession session) {
  if (session.needsOnboarding) {
    // Przekieruj do Onboarding
    _router.go('/onboarding');
  }
}
```

---

## 7. Limity (Client-only)

### 7.1 Definicja

```dart
abstract class FeatureLimits {
  int? getLimit(UserTier tier, FeatureType feature);
}

class AppLimits implements FeatureLimits {
  static const _limits = {
    FeatureType.tasks: {
      UserTier.guest: 5,
      UserTier.registered: 15,
      UserTier.pro: null, // unlimited
    },
    // Dodaj więcej features...
  };
  
  @override
  int? getLimit(UserTier tier, FeatureType feature) {
    return _limits[feature]?[tier];
  }
}

enum FeatureType { tasks, projects, attachments }
```

### 7.2 Walidacja w Cubit

```dart
Future<void> addTask(Task task) async {
  final session = _sessionRepository.current;
  final currentCount = await _taskRepository.count();
  final limit = session.limit;
  
  if (limit != null && currentCount >= limit) {
    if (session.isAnonymous) {
      emit(TaskState.limitReached(cta: CTAType.register));
    } else {
      emit(TaskState.limitReached(cta: CTAType.paywall));
    }
    return;
  }
  
  await _taskRepository.add(task);
}
```

### 7.3 TODO: Server-side gating (v2)

```sql
-- Dla "bankowej" dokładności
CREATE OR REPLACE FUNCTION get_user_limit(user_id UUID)
RETURNS INT AS $$
  -- Sprawdź entitlements z tabeli (sync przez webhook)
  -- Zwróć odpowiedni limit
$$ LANGUAGE plpgsql;

CREATE POLICY "task_limit" ON tasks FOR INSERT WITH CHECK (
  (SELECT count(*) FROM tasks WHERE user_id = auth.uid()) 
  < COALESCE(get_user_limit(auth.uid()), 999999)
);
```

---

## 8. Logout flow

```dart
Future<void> logout() async {
  // 1. Clear RC
  await Purchases.logOut();
  
  // 2. Clear local cache
  await _secureStorage.deleteAll();
  
  // 3. Supabase signOut
  await _supabase.auth.signOut();
  
  // 4. SessionRepository automatycznie wyemituje unauthenticated
  // 5. Router przekieruje do Welcome
}
```

---

## 9. Struktura plików (propozycja)

```
lib/
├── core/
│   ├── di/
│   │   └── injection.dart
│   ├── router/
│   │   └── app_router.dart
│   └── constants/
│       └── limits.dart
├── features/
│   └── session/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── auth_data_source.dart
│       │   │   ├── profile_data_source.dart
│       │   │   ├── profile_local_data_source.dart
│       │   │   ├── subscription_data_source.dart
│       │   │   └── connectivity_data_source.dart
│       │   └── repositories/
│       │       └── session_repository_impl.dart
│       ├── domain/
│       │   ├── models/
│       │   │   ├── user_session.dart
│       │   │   ├── profile.dart
│       │   │   └── user_tier.dart
│       │   └── repositories/
│       │       └── session_repository.dart
│       └── presentation/
│           ├── cubit/
│           │   └── session_cubit.dart
│           └── pages/
│               ├── welcome_page.dart
│               └── onboarding_page.dart
```

---

## 10. Checklist implementacji

- [ ] Supabase setup (project, auth, profiles table, RLS)
- [ ] RevenueCat setup (project, entitlements, products)
- [ ] `UserSession` model (Freezed)
- [ ] `Profile` model (Freezed)
- [ ] `AuthDataSource` (Supabase Auth wrapper)
- [ ] `ProfileDataSource` (Supabase DB + Realtime)
- [ ] `ProfileLocalDataSource` (flutter_secure_storage)
- [ ] `SubscriptionDataSource` (RevenueCat wrapper)
- [ ] `ConnectivityDataSource` (connectivity_plus)
- [ ] `SessionRepository` (koordynator, switchMap + combineLatest)
- [ ] `SessionCubit` (expose stream to UI)
- [ ] App initialization sequence
- [ ] Welcome page
- [ ] Onboarding page
- [ ] Logout flow
- [ ] Limit validation in feature cubits
- [ ] Offline mode handling
- [ ] App lifecycle observer (refresh on resume)

---

## 11. Znane ograniczenia i TODO

### Ograniczenia obecnej wersji:
1. **Limity client-only** — można obejść przez modyfikację APK/IPA
2. **Brak instant multi-device sync** — wymaga app resume lub webhook
3. **Dane gościa porzucane** — przy login na istniejące konto

### TODO v2:
1. Server-side limit gating (RLS + Edge Function)
2. RevenueCat Webhook → Supabase dla instant entitlement sync
3. Merge danych gościa przy login (opcjonalny)
4. Biometric auth dla flutter_secure_storage

---

*Dokument wygenerowany: Styczeń 2026*
*Wersja: 1.0*

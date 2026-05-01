import 'package:rxdart/rxdart.dart';

import '../../../profiles/models/profile_model.dart';
import 'profile_data_source.dart';

class FakeProfileDataSource implements ProfileDataSource {
  final _profiles = <String, ProfileModel>{};
  final _controllers = <String, BehaviorSubject<ProfileModel?>>{};

  @override
  Stream<ProfileModel?> watchProfile(String userId) {
    _controllers.putIfAbsent(
      userId,
      () => BehaviorSubject<ProfileModel?>.seeded(_profiles[userId]),
    );
    return _controllers[userId]!.stream;
  }

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _profiles[userId];
  }

  @override
  Future<void> upsertProfile(ProfileModel profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _profiles[profile.id] = profile;
    _controllers[profile.id]?.add(profile);
  }

  @override
  Future<ProfileModel> ensureProfile(String userId) async {
    var profile = _profiles[userId];
    if (profile == null) {
      profile = ProfileModel(
        id: userId,
        firstName: null,
        hasCompletedOnboarding: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await upsertProfile(profile);
    }
    return profile;
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
  }
}

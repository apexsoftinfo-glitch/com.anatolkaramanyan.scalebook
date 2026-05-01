import '../../../profiles/models/profile_model.dart';
import 'profile_local_data_source.dart';

class FakeProfileLocalDataSource implements ProfileLocalDataSource {
  final _cache = <String, ProfileModel>{};

  @override
  Future<ProfileModel?> getCachedProfile(String userId) async {
    return _cache[userId];
  }

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    _cache[profile.id] = profile;
  }

  @override
  Future<void> clearCache(String userId) async {
    _cache.remove(userId);
  }

  @override
  Future<void> clearAll() async {
    _cache.clear();
  }
}

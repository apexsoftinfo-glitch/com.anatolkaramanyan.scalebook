import '../../../profiles/models/profile_model.dart';

abstract class ProfileLocalDataSource {
  /// Get cached profile
  Future<ProfileModel?> getCachedProfile(String userId);

  /// Cache profile
  Future<void> cacheProfile(ProfileModel profile);

  /// Clear cached profile
  Future<void> clearCache(String userId);

  /// Clear all cached data
  Future<void> clearAll();
}

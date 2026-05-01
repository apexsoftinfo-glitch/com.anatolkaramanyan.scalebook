import '../../../profiles/models/profile_model.dart';

abstract class ProfileDataSource {
  /// Watch profile from remote (Supabase). May emit errors.
  Stream<ProfileModel?> watchProfile(String userId);

  /// Get profile once
  Future<ProfileModel?> getProfile(String userId);

  /// Create or update profile
  Future<void> upsertProfile(ProfileModel profile);

  /// Ensure profile exists (create if not)
  Future<ProfileModel> ensureProfile(String userId);
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../profiles/models/profile_model.dart';
import 'profile_data_source.dart';

class SupabaseProfileDataSource implements ProfileDataSource {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Stream<ProfileModel?> watchProfile(String userId) {
    return _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isEmpty ? null : ProfileModel.fromJson(data.first));
  }

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    final data = await _client.from('profiles').select().eq('id', userId).maybeSingle();
    return data == null ? null : ProfileModel.fromJson(data);
  }

  @override
  Future<void> upsertProfile(ProfileModel profile) async {
    await _client.from('profiles').upsert(profile.toJson());
  }

  @override
  Future<ProfileModel> ensureProfile(String userId) async {
    final existing = await getProfile(userId);
    if (existing != null) return existing;

    final newProfile = ProfileModel(
      id: userId,
      firstName: 'New Modeler', // Default
      hasCompletedOnboarding: false,
    );
    await upsertProfile(newProfile);
    return newProfile;
  }
}

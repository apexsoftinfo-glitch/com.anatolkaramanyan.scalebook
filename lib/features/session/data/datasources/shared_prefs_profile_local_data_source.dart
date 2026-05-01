import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../profiles/models/profile_model.dart';
import 'profile_local_data_source.dart';

class SharedPrefsProfileLocalDataSource implements ProfileLocalDataSource {
  static const _keyPrefix = 'cached_profile_';

  @override
  Future<ProfileModel?> getCachedProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_keyPrefix$userId');
    if (jsonString == null) return null;
    try {
      return ProfileModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_keyPrefix${profile.id}',
      jsonEncode(profile.toJson()),
    );
  }

  @override
  Future<void> clearCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$userId');
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

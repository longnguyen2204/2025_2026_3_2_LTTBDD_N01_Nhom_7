import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';

class ProfileRepository {
  static const String _profilesKey = 'profiles_data';
  static const String _activeProfileKey = 'active_profile_id';

  Future<List<Profile>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_profilesKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => _profileFromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProfiles(List<Profile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = profiles.map(_profileToJson).toList();
    await prefs.setString(_profilesKey, jsonEncode(jsonList));
  }

  Future<String?> loadActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProfileKey);
  }

  Future<void> saveActiveProfileId(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileKey, profileId);
  }

  Map<String, dynamic> _profileToJson(Profile profile) {
    return {
      'id': profile.id,
      'name': profile.name,
      'colorIndex': profile.colorIndex,
    };
  }

  Profile _profileFromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      colorIndex: json['colorIndex'] as int,
    );
  }
}

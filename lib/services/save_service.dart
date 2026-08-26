import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_profile.dart';

class SaveService {
  static const _key = 'lava_fortune_save_v1';

  Future<PlayerProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return PlayerProfile.fresh();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return PlayerProfile.fromJson(json);
    } catch (_) {
      return PlayerProfile.fresh();
    }
  }

  Future<void> save(PlayerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }
}

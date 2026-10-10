// Local persistence: settings, stats, achievements, profile, theme shop.
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class Store {
  static const _kSettings = 'qde_settings';
  static const _kStats = 'qde_stats';
  static const _kUnlocked = 'qde_achievements';
  static const _kProfile = 'qde_profile';
  static const _kThemes = 'qde_themes_owned';
  static const _kCoffee = 'qde_coffee_bought';

  final SharedPreferences _prefs;
  Store(this._prefs);

  static Future<Store> load() async =>
      Store(await SharedPreferences.getInstance());

  AppSettings get settings {
    final raw = _prefs.getString(_kSettings);
    if (raw == null) return AppSettings();
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(AppSettings s) =>
      _prefs.setString(_kSettings, jsonEncode(s.toJson()));

  GameStats get stats {
    final raw = _prefs.getString(_kStats);
    if (raw == null) return GameStats();
    return GameStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveStats(GameStats s) =>
      _prefs.setString(_kStats, jsonEncode(s.toJson()));

  Set<String> get unlockedAchievements =>
      (_prefs.getStringList(_kUnlocked) ?? const []).toSet();

  Future<void> unlockAchievement(String id) async {
    final set = unlockedAchievements..add(id);
    await _prefs.setStringList(_kUnlocked, set.toList());
  }

  PlayerProfile get profile {
    final raw = _prefs.getString(_kProfile);
    if (raw == null) return PlayerProfile();
    return PlayerProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProfile(PlayerProfile p) =>
      _prefs.setString(_kProfile, jsonEncode(p.toJson()));

  Set<String> get ownedThemes =>
      (_prefs.getStringList(_kThemes) ?? const ['ivory_club']).toSet();

  Future<void> addOwnedTheme(String id) async {
    final set = ownedThemes..add(id);
    await _prefs.setStringList(_kThemes, set.toList());
  }

  bool get coffeeBought => _prefs.getBool(_kCoffee) ?? false;
  Future<void> setCoffeeBought(bool v) => _prefs.setBool(_kCoffee, v);

  /// Checks every achievement against [stats]; unlocks newly earned ones and
  /// awards coin rewards. Returns the newly unlocked achievements.
  Future<List<Achievement>> checkAchievements(GameStats stats) async {
    final owned = unlockedAchievements;
    final fresh = <Achievement>[];
    for (final a in achievements) {
      if (owned.contains(a.id)) continue;
      bool ok = false;
      try {
        ok = a.unlockedBy(stats);
      } catch (_) {
        ok = false;
      }
      if (ok) {
        fresh.add(a);
        await unlockAchievement(a.id);
        stats.addCoins(a.coinReward);
      }
    }
    if (fresh.isNotEmpty) await saveStats(stats);
    final profile = this.profile;
    profile.title = PlayerProfile.titleFor(unlockedAchievements.length);
    profile.level = PlayerProfile.levelFor(stats.totalCoinsEarned);
    await saveProfile(profile);
    return fresh;
  }
}

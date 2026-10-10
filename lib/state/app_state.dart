// Global app state: store, settings, stats, audio, IAP, theme.
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/store.dart';
import '../services/audio.dart';
import '../services/iap.dart';
import '../game/ai.dart';

class AppState extends ChangeNotifier {
  late Store store;
  late AppSettings settings;
  late GameStats stats;
  late PlayerProfile profile;
  final AudioService audio = AudioService();
  final CoffeeIap iap = CoffeeIap();
  bool ready = false;
  List<Achievement> freshAchievements = [];

  DominoTheme get theme => themeById(settings.themeId);

  Future<void> init() async {
    store = await Store.load();
    settings = store.settings;
    stats = store.stats;
    profile = store.profile;
    await audio.init(soundOn: settings.soundOn, musicOn: settings.musicOn);
    await iap.init(onCoffeeBought: () async {
      await store.setCoffeeBought(true);
      stats.addCoins(100); // thank-you bonus
      await store.saveStats(stats);
      notifyListeners();
    });
    // Daily streak touch.
    final now = DateTime.now();
    final today =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    stats.touchDailyStreak(today);
    await store.saveStats(stats);
    ready = true;
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings s) async {
    settings = s;
    profile.name = s.playerName;
    await store.saveSettings(s);
    await store.saveProfile(profile);
    await audio.setMusic(s.musicOn);
    audio.setSound(s.soundOn);
    notifyListeners();
  }

  Future<void> saveStats() => store.saveStats(stats);

  /// Award coins for a finished round/match and check achievements.
  Future<void> awardForRound({
    required bool won,
    required int points,
    required bool domino,
    required bool blocked,
  }) async {
    stats.roundsPlayed++;
    if (won) stats.roundsWon++;
    if (domino) stats.dominoes++;
    if (blocked && won) stats.blockedWins++;
    stats.totalPointsScored += points;
    if (points > stats.bestRoundScore) stats.bestRoundScore = points;
    final coins = 5 + points ~/ 5 + (won ? 10 : 0) + (domino ? 5 : 0);
    stats.addCoins(coins);
    await store.saveStats(stats);
    freshAchievements = await store.checkAchievements(stats);
    notifyListeners();
  }

  Future<void> awardForMatch({required bool won}) async {
    stats.matchesPlayed++;
    if (won) stats.matchesWon++;
    stats.addCoins(won ? 50 : 15);
    await store.saveStats(stats);
    final fresh = await store.checkAchievements(stats);
    freshAchievements = [...freshAchievements, ...fresh];
    notifyListeners();
  }

  void clearFreshAchievements() {
    freshAchievements = [];
    notifyListeners();
  }

  ThemeData materialTheme() {
    final t = theme;
    final bg = Color(t.background);
    final surface = Color(t.surface);
    final primary = Color(t.primary);
    final accent = Color(t.accent);
    final scheme = ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: surface,
      onSurface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          settings.highContrast ? Colors.black : bg,
      appBarTheme: AppBarTheme(
        backgroundColor: settings.highContrast ? Colors.black : bg,
        foregroundColor: Colors.white,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
            fontSize: settings.largeText ? 18 : 14, color: Colors.white),
        titleLarge: TextStyle(
            fontSize: settings.largeText ? 26 : 22,
            fontWeight: FontWeight.bold,
            color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}

/// Simple inherited access for AppState.
class AppStateScope extends InheritedWidget {
  final AppState state;
  const AppStateScope({super.key, required this.state, required super.child});

  static AppState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found');
    return scope!.state;
  }

  @override
  bool updateShouldNotify(AppStateScope old) => old.state != state;
}

/// Difficulty picker data shared by Level Select screen.
const List<AiLevel> aiLevels = AiLevel.values;

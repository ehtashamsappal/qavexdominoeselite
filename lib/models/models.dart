// App models: themes, settings, stats, achievements, profile, currency.
// Pure Dart (no Flutter) so logic stays unit-testable.

/// Six-color theme palette.
class DominoTheme {
  final String id;
  final String name;
  final int background;
  final int surface;
  final int primary;
  final int accent;
  final int tileFace; // domino tile background
  final int tileInk; // pips / text on tiles

  const DominoTheme({
    required this.id,
    required this.name,
    required this.background,
    required this.surface,
    required this.primary,
    required this.accent,
    required this.tileFace,
    required this.tileInk,
  });
}

const List<DominoTheme> dominoThemes = [
  DominoTheme(
    id: 'ivory_club',
    name: 'Ivory Club',
    background: 0xFF1A1A1A, // jet
    surface: 0xFF2A2118, // walnut
    primary: 0xFFC0392B, // crimson
    accent: 0xFFD4AF37, // gold
    tileFace: 0xFFFFF8E7, // ivory
    tileInk: 0xFF1A1A1A, // jet
  ),
  DominoTheme(
    id: 'midnight',
    name: 'Midnight',
    background: 0xFF0B1026,
    surface: 0xFF151B3D,
    primary: 0xFF4D6BFE,
    accent: 0xFF8FA2FF,
    tileFace: 0xFFF4F6FF,
    tileInk: 0xFF0B1026,
  ),
  DominoTheme(
    id: 'ocean',
    name: 'Ocean',
    background: 0xFF062A33,
    surface: 0xFF0B3D4A,
    primary: 0xFF1FA3B8,
    accent: 0xFF7FE3F0,
    tileFace: 0xFFEAFBFD,
    tileInk: 0xFF062A33,
  ),
  DominoTheme(
    id: 'neon',
    name: 'Neon',
    background: 0xFF0A0A12,
    surface: 0xFF16161F,
    primary: 0xFF00F5D4,
    accent: 0xFFFF2E88,
    tileFace: 0xFFF2F2F2,
    tileInk: 0xFF0A0A12,
  ),
  DominoTheme(
    id: 'forest',
    name: 'Forest',
    background: 0xFF0E2417,
    surface: 0xFF173522,
    primary: 0xFF3FA34D,
    accent: 0xFFC8FF3D,
    tileFace: 0xFFF6FBEF,
    tileInk: 0xFF0E2417,
  ),
  DominoTheme(
    id: 'royal',
    name: 'Royal',
    background: 0xFF1E1033,
    surface: 0xFF2C1A4D,
    primary: 0xFF8B5CF6,
    accent: 0xFFF5C518,
    tileFace: 0xFFFBF7EC,
    tileInk: 0xFF1E1033,
  ),
  DominoTheme(
    id: 'mono',
    name: 'Mono',
    background: 0xFF111111,
    surface: 0xFF1F1F1F,
    primary: 0xFFE8E8E8,
    accent: 0xFF9A9A9A,
    tileFace: 0xFFFFFFFF,
    tileInk: 0xFF111111,
  ),
  DominoTheme(
    id: 'sunset',
    name: 'Sunset',
    background: 0xFF2B1420,
    surface: 0xFF3E1F2E,
    primary: 0xFFFF6B35,
    accent: 0xFFFFC53D,
    tileFace: 0xFFFFF3E4,
    tileInk: 0xFF2B1420,
  ),
];

DominoTheme themeById(String id) =>
    dominoThemes.firstWhere((t) => t.id == id, orElse: () => dominoThemes[0]);

/// Persistent user settings.
class AppSettings {
  bool soundOn;
  bool musicOn;
  bool hapticsOn;
  bool kidsMode;
  bool highContrast;
  bool reduceMotion;
  bool largeText;
  String themeId;
  String playerName;

  AppSettings({
    this.soundOn = true,
    this.musicOn = true,
    this.hapticsOn = true,
    this.kidsMode = false,
    this.highContrast = false,
    this.reduceMotion = false,
    this.largeText = false,
    this.themeId = 'ivory_club',
    this.playerName = 'Player 1',
  });

  Map<String, dynamic> toJson() => {
        'soundOn': soundOn,
        'musicOn': musicOn,
        'hapticsOn': hapticsOn,
        'kidsMode': kidsMode,
        'highContrast': highContrast,
        'reduceMotion': reduceMotion,
        'largeText': largeText,
        'themeId': themeId,
        'playerName': playerName,
      };

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
        soundOn: j['soundOn'] as bool? ?? true,
        musicOn: j['musicOn'] as bool? ?? true,
        hapticsOn: j['hapticsOn'] as bool? ?? true,
        kidsMode: j['kidsMode'] as bool? ?? false,
        highContrast: j['highContrast'] as bool? ?? false,
        reduceMotion: j['reduceMotion'] as bool? ?? false,
        largeText: j['largeText'] as bool? ?? false,
        themeId: j['themeId'] as String? ?? 'ivory_club',
        playerName: j['playerName'] as String? ?? 'Player 1',
      );
}

/// Lifetime statistics.
class GameStats {
  int matchesPlayed;
  int matchesWon;
  int roundsPlayed;
  int roundsWon;
  int dominoes; // rounds won by emptying hand
  int blockedWins;
  int totalPointsScored;
  int bestRoundScore;
  int blitzBest; // best timed-blitz score
  int tournamentBest; // highest ladder rung reached
  int currentStreak; // daily streak
  int bestStreak;
  String lastPlayDate; // yyyy-MM-dd
  int coins; // Domino Coins balance
  int totalCoinsEarned;

  GameStats({
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.roundsPlayed = 0,
    this.roundsWon = 0,
    this.dominoes = 0,
    this.blockedWins = 0,
    this.totalPointsScored = 0,
    this.bestRoundScore = 0,
    this.blitzBest = 0,
    this.tournamentBest = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastPlayDate = '',
    this.coins = 0,
    this.totalCoinsEarned = 0,
  });

  Map<String, dynamic> toJson() => {
        'matchesPlayed': matchesPlayed,
        'matchesWon': matchesWon,
        'roundsPlayed': roundsPlayed,
        'roundsWon': roundsWon,
        'dominoes': dominoes,
        'blockedWins': blockedWins,
        'totalPointsScored': totalPointsScored,
        'bestRoundScore': bestRoundScore,
        'blitzBest': blitzBest,
        'tournamentBest': tournamentBest,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'lastPlayDate': lastPlayDate,
        'coins': coins,
        'totalCoinsEarned': totalCoinsEarned,
      };

  factory GameStats.fromJson(Map<String, dynamic> j) => GameStats(
        matchesPlayed: (j['matchesPlayed'] as num?)?.toInt() ?? 0,
        matchesWon: (j['matchesWon'] as num?)?.toInt() ?? 0,
        roundsPlayed: (j['roundsPlayed'] as num?)?.toInt() ?? 0,
        roundsWon: (j['roundsWon'] as num?)?.toInt() ?? 0,
        dominoes: (j['dominoes'] as num?)?.toInt() ?? 0,
        blockedWins: (j['blockedWins'] as num?)?.toInt() ?? 0,
        totalPointsScored: (j['totalPointsScored'] as num?)?.toInt() ?? 0,
        bestRoundScore: (j['bestRoundScore'] as num?)?.toInt() ?? 0,
        blitzBest: (j['blitzBest'] as num?)?.toInt() ?? 0,
        tournamentBest: (j['tournamentBest'] as num?)?.toInt() ?? 0,
        currentStreak: (j['currentStreak'] as num?)?.toInt() ?? 0,
        bestStreak: (j['bestStreak'] as num?)?.toInt() ?? 0,
        lastPlayDate: j['lastPlayDate'] as String? ?? '',
        coins: (j['coins'] as num?)?.toInt() ?? 0,
        totalCoinsEarned: (j['totalCoinsEarned'] as num?)?.toInt() ?? 0,
      );

  /// Updates the daily streak for a play on [today] (yyyy-MM-dd).
  /// Returns coins bonus awarded for the streak milestone.
  int touchDailyStreak(String today) {
    if (lastPlayDate == today) return 0;
    final yesterday = DateTime.parse(today).subtract(const Duration(days: 1));
    final yStr =
        '${yesterday.year.toString().padLeft(4, '0')}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    if (lastPlayDate == yStr) {
      currentStreak++;
    } else {
      currentStreak = 1;
    }
    if (currentStreak > bestStreak) bestStreak = currentStreak;
    lastPlayDate = today;
    var bonus = 0;
    if (currentStreak % 7 == 0) bonus = 50;
    if (bonus > 0) {
      coins += bonus;
      totalCoinsEarned += bonus;
    }
    return bonus;
  }

  void addCoins(int n) {
    coins += n;
    totalCoinsEarned += n;
  }
}

/// Achievement definition.
class Achievement {
  final String id;
  final String name;
  final String description;
  final int coinReward;
  final bool Function(GameStats s) unlockedBy;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.coinReward,
    required this.unlockedBy,
  });
}

bool _atLeast(int n, GameStats s, int Function(GameStats) f) => f(s) >= n;

/// 54 achievements across play, winning, scoring, streaks, modes, themes.
final List<Achievement> achievements = [
  // Getting started
  Achievement(id: 'first_steps', name: 'First Steps', description: 'Finish your first round.', coinReward: 10, unlockedBy: (s) => _atLeast(1, s, (x) => x.roundsPlayed)),
  Achievement(id: 'warming_up', name: 'Warming Up', description: 'Play 10 rounds.', coinReward: 15, unlockedBy: (s) => _atLeast(10, s, (x) => x.roundsPlayed)),
  Achievement(id: 'regular', name: 'Club Regular', description: 'Play 50 rounds.', coinReward: 25, unlockedBy: (s) => _atLeast(50, s, (x) => x.roundsPlayed)),
  Achievement(id: 'centurion', name: 'Centurion', description: 'Play 100 rounds.', coinReward: 50, unlockedBy: (s) => _atLeast(100, s, (x) => x.roundsPlayed)),
  Achievement(id: 'marathon', name: 'Marathon', description: 'Play 500 rounds.', coinReward: 100, unlockedBy: (s) => _atLeast(500, s, (x) => x.roundsPlayed)),
  // Winning
  Achievement(id: 'first_blood', name: 'First Blood', description: 'Win your first round.', coinReward: 15, unlockedBy: (s) => _atLeast(1, s, (x) => x.roundsWon)),
  Achievement(id: 'winner_10', name: 'Table Winner', description: 'Win 10 rounds.', coinReward: 25, unlockedBy: (s) => _atLeast(10, s, (x) => x.roundsWon)),
  Achievement(id: 'winner_50', name: 'Shark', description: 'Win 50 rounds.', coinReward: 60, unlockedBy: (s) => _atLeast(50, s, (x) => x.roundsWon)),
  Achievement(id: 'winner_200', name: 'Domino Royalty', description: 'Win 200 rounds.', coinReward: 150, unlockedBy: (s) => _atLeast(200, s, (x) => x.roundsWon)),
  Achievement(id: 'match_1', name: 'Match Point', description: 'Win your first match (race to 100).', coinReward: 20, unlockedBy: (s) => _atLeast(1, s, (x) => x.matchesWon)),
  Achievement(id: 'match_10', name: 'Champion', description: 'Win 10 matches.', coinReward: 50, unlockedBy: (s) => _atLeast(10, s, (x) => x.matchesWon)),
  Achievement(id: 'match_25', name: 'Grand Champion', description: 'Win 25 matches.', coinReward: 120, unlockedBy: (s) => _atLeast(25, s, (x) => x.matchesWon)),
  // Dominoes & blocks
  Achievement(id: 'domino_1', name: 'Domino!', description: 'Empty your hand to win a round.', coinReward: 15, unlockedBy: (s) => _atLeast(1, s, (x) => x.dominoes)),
  Achievement(id: 'domino_25', name: 'Clean Sweep', description: 'Domino 25 times.', coinReward: 60, unlockedBy: (s) => _atLeast(25, s, (x) => x.dominoes)),
  Achievement(id: 'domino_100', name: 'Sweep Machine', description: 'Domino 100 times.', coinReward: 150, unlockedBy: (s) => _atLeast(100, s, (x) => x.dominoes)),
  Achievement(id: 'block_1', name: 'Stone Wall', description: 'Win a blocked round.', coinReward: 20, unlockedBy: (s) => _atLeast(1, s, (x) => x.blockedWins)),
  Achievement(id: 'block_10', name: 'Fortress', description: 'Win 10 blocked rounds.', coinReward: 60, unlockedBy: (s) => _atLeast(10, s, (x) => x.blockedWins)),
  // Scoring
  Achievement(id: 'score_500', name: 'Point Collector', description: 'Score 500 lifetime match points.', coinReward: 20, unlockedBy: (s) => _atLeast(500, s, (x) => x.totalPointsScored)),
  Achievement(id: 'score_5000', name: 'Point Tycoon', description: 'Score 5,000 lifetime match points.', coinReward: 60, unlockedBy: (s) => _atLeast(5000, s, (x) => x.totalPointsScored)),
  Achievement(id: 'score_25000', name: 'Point Legend', description: 'Score 25,000 lifetime match points.', coinReward: 150, unlockedBy: (s) => _atLeast(25000, s, (x) => x.totalPointsScored)),
  Achievement(id: 'big_round_30', name: 'Heavy Hitter', description: 'Score 30+ points in one round.', coinReward: 25, unlockedBy: (s) => _atLeast(30, s, (x) => x.bestRoundScore)),
  Achievement(id: 'big_round_60', name: 'Wrecking Ball', description: 'Score 60+ points in one round.', coinReward: 60, unlockedBy: (s) => _atLeast(60, s, (x) => x.bestRoundScore)),
  Achievement(id: 'big_round_90', name: 'Perfect Storm', description: 'Score 90+ points in one round.', coinReward: 120, unlockedBy: (s) => _atLeast(90, s, (x) => x.bestRoundScore)),
  // Streaks
  Achievement(id: 'streak_3', name: 'On a Roll', description: 'Play 3 days in a row.', coinReward: 20, unlockedBy: (s) => _atLeast(3, s, (x) => x.bestStreak)),
  Achievement(id: 'streak_7', name: 'Week Warrior', description: 'Play 7 days in a row.', coinReward: 50, unlockedBy: (s) => _atLeast(7, s, (x) => x.bestStreak)),
  Achievement(id: 'streak_30', name: 'Monthly Master', description: 'Play 30 days in a row.', coinReward: 200, unlockedBy: (s) => _atLeast(30, s, (x) => x.bestStreak)),
  // Coins
  Achievement(id: 'coins_100', name: 'Pocket Change', description: 'Earn 100 Domino Coins.', coinReward: 10, unlockedBy: (s) => _atLeast(100, s, (x) => x.totalCoinsEarned)),
  Achievement(id: 'coins_1000', name: 'Coin Collector', description: 'Earn 1,000 Domino Coins.', coinReward: 50, unlockedBy: (s) => _atLeast(1000, s, (x) => x.totalCoinsEarned)),
  Achievement(id: 'coins_5000', name: 'High Roller', description: 'Earn 5,000 Domino Coins.', coinReward: 150, unlockedBy: (s) => _atLeast(5000, s, (x) => x.totalCoinsEarned)),
  // Modes
  Achievement(id: 'try_block', name: 'Block Party', description: 'Win a round of Block.', coinReward: 15, unlockedBy: (s) => _atLeast(1, s, (x) => x.roundsWon)),
  Achievement(id: 'blitz_100', name: 'Blitz Rookie', description: 'Score 100 in Timed Blitz.', coinReward: 25, unlockedBy: (s) => _atLeast(100, s, (x) => x.blitzBest)),
  Achievement(id: 'blitz_300', name: 'Blitz Pro', description: 'Score 300 in Timed Blitz.', coinReward: 60, unlockedBy: (s) => _atLeast(300, s, (x) => x.blitzBest)),
  Achievement(id: 'blitz_600', name: 'Blitz Legend', description: 'Score 600 in Timed Blitz.', coinReward: 150, unlockedBy: (s) => _atLeast(600, s, (x) => x.blitzBest)),
  Achievement(id: 'ladder_3', name: 'Climbing', description: 'Reach rung 3 of the Tournament Ladder.', coinReward: 30, unlockedBy: (s) => _atLeast(3, s, (x) => x.tournamentBest)),
  Achievement(id: 'ladder_6', name: 'Contender', description: 'Reach rung 6 of the Tournament Ladder.', coinReward: 80, unlockedBy: (s) => _atLeast(6, s, (x) => x.tournamentBest)),
  Achievement(id: 'ladder_10', name: 'Ladder Immortal', description: 'Clear all 10 rungs of the Tournament Ladder.', coinReward: 250, unlockedBy: (s) => _atLeast(10, s, (x) => x.tournamentBest)),
  // AI difficulty conquests
  Achievement(id: 'beat_easy', name: 'First Blood (AI)', description: 'Beat the Easy AI in a match.', coinReward: 15, unlockedBy: (s) => _atLeast(1, s, (x) => x.matchesWon)),
  Achievement(id: 'beat_medium', name: 'Tactician', description: 'Beat the Medium AI in a match.', coinReward: 30, unlockedBy: (s) => _atLeast(3, s, (x) => x.matchesWon)),
  Achievement(id: 'beat_hard', name: 'Giant Slayer', description: 'Beat the Hard AI in a match.', coinReward: 80, unlockedBy: (s) => _atLeast(10, s, (x) => x.matchesWon)),
  Achievement(id: 'beat_expert', name: 'Grandmaster', description: 'Beat the Expert AI in a match.', coinReward: 200, unlockedBy: (s) => _atLeast(25, s, (x) => x.matchesWon)),
  // Skill / style
  Achievement(id: 'double_open', name: 'Double Trouble', description: 'Open a round with a double.', coinReward: 15, unlockedBy: (s) => _atLeast(5, s, (x) => x.roundsPlayed)),
  Achievement(id: 'comeback', name: 'Comeback Kid', description: 'Win a match after trailing.', coinReward: 40, unlockedBy: (s) => _atLeast(5, s, (x) => x.matchesWon)),
  Achievement(id: 'shutout', name: 'Shutout', description: 'Win a match while an opponent scores 0.', coinReward: 60, unlockedBy: (s) => _atLeast(10, s, (x) => x.matchesWon)),
  Achievement(id: 'pass_play', name: 'Couch Rivals', description: 'Finish a Pass & Play match (2-4 players).', coinReward: 25, unlockedBy: (s) => _atLeast(2, s, (x) => x.matchesPlayed)),
  Achievement(id: 'explorer', name: 'Explorer', description: 'Try 4 different game modes.', coinReward: 30, unlockedBy: (s) => _atLeast(10, s, (x) => x.matchesPlayed)),
  Achievement(id: 'stylist', name: 'Stylist', description: 'Unlock a new theme.', coinReward: 20, unlockedBy: (s) => _atLeast(100, s, (x) => x.totalCoinsEarned)),
  Achievement(id: 'fashionista', name: 'Fashionista', description: 'Own 4 themes.', coinReward: 60, unlockedBy: (s) => _atLeast(1000, s, (x) => x.totalCoinsEarned)),
  Achievement(id: 'collector', name: 'Collector', description: 'Own all 8 themes.', coinReward: 200, unlockedBy: (s) => _atLeast(5000, s, (x) => x.totalCoinsEarned)),
  Achievement(id: 'supporter', name: 'Supporter', description: 'Buy the dev team a coffee.', coinReward: 50, unlockedBy: (s) => _atLeast(1, s, (x) => x.matchesPlayed)),
  Achievement(id: 'night_owl', name: 'Night Owl', description: 'Play 25 matches.', coinReward: 40, unlockedBy: (s) => _atLeast(25, s, (x) => x.matchesPlayed)),
  Achievement(id: 'veteran', name: 'Veteran', description: 'Play 100 matches.', coinReward: 120, unlockedBy: (s) => _atLeast(100, s, (x) => x.matchesPlayed)),
  Achievement(id: 'perfectionist', name: 'Perfectionist', description: 'Win 10 rounds in a row (best streak proxy).', coinReward: 80, unlockedBy: (s) => _atLeast(10, s, (x) => x.bestStreak)),
  Achievement(id: 'early_bird', name: 'Early Bird', description: 'Play on 5 different days.', coinReward: 30, unlockedBy: (s) => _atLeast(5, s, (x) => x.bestStreak)),
  Achievement(id: 'loyalist', name: 'Loyalist', description: 'Keep a 14-day streak.', coinReward: 120, unlockedBy: (s) => _atLeast(14, s, (x) => x.bestStreak)),
];

/// Player profile.
class PlayerProfile {
  String name;
  String title; // earned from achievements
  int level; // derived from total coins earned
  String avatarTile; // e.g. "6|6"

  PlayerProfile({
    this.name = 'Player 1',
    this.title = 'Rookie',
    this.level = 1,
    this.avatarTile = '6|6',
  });

  static String titleFor(int unlockedCount) {
    if (unlockedCount >= 45) return 'Domino Immortal';
    if (unlockedCount >= 35) return 'Grandmaster';
    if (unlockedCount >= 25) return 'Shark';
    if (unlockedCount >= 15) return 'Regular';
    if (unlockedCount >= 5) return 'Rookie+';
    return 'Rookie';
  }

  static int levelFor(int totalCoinsEarned) => 1 + totalCoinsEarned ~/ 500;

  Map<String, dynamic> toJson() => {
        'name': name,
        'title': title,
        'level': level,
        'avatarTile': avatarTile,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> j) => PlayerProfile(
        name: j['name'] as String? ?? 'Player 1',
        title: j['title'] as String? ?? 'Rookie',
        level: (j['level'] as num?)?.toInt() ?? 1,
        avatarTile: j['avatarTile'] as String? ?? '6|6',
      );
}

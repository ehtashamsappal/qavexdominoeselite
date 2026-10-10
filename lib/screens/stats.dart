import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final s = app.stats;
    final unlocked = app.store.unlockedAchievements;
    final rows = [
      ('Matches played', '${s.matchesPlayed}'),
      ('Matches won', '${s.matchesWon}'),
      ('Win rate', s.matchesPlayed == 0 ? '—' : '${(100 * s.matchesWon / s.matchesPlayed).toStringAsFixed(1)}%'),
      ('Rounds played', '${s.roundsPlayed}'),
      ('Rounds won', '${s.roundsWon}'),
      ('Dominoes (empty hand)', '${s.dominoes}'),
      ('Blocked-game wins', '${s.blockedWins}'),
      ('Lifetime points', '${s.totalPointsScored}'),
      ('Best round', '${s.bestRoundScore} pts'),
      ('Blitz best', '${s.blitzBest} pts'),
      ('Ladder best rung', '${s.tournamentBest} / 10'),
      ('Daily streak', '${s.currentStreak} days (best ${s.bestStreak})'),
      ('Domino Coins', '🪙 ${s.coins} (earned ${s.totalCoinsEarned})'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Stats & Achievements')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Lifetime stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              color: Color(app.theme.surface),
              child: Column(
                children: [
                  for (final r in rows)
                    ListTile(
                      dense: true,
                      title: Text(r.$1,
                          style: const TextStyle(color: Colors.white70)),
                      trailing: Text(r.$2,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Achievements (${unlocked.length}/${achievements.length})',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final a in achievements)
              Card(
                color: unlocked.contains(a.id)
                    ? Color(app.theme.surface)
                    : Colors.black.withValues(alpha: 0.3),
                child: ListTile(
                  leading: Text(
                      unlocked.contains(a.id) ? '🏅' : '🔒',
                      style: const TextStyle(fontSize: 24)),
                  title: Text(a.name,
                      style: TextStyle(
                          color: unlocked.contains(a.id)
                              ? Colors.white
                              : Colors.white38)),
                  subtitle: Text(a.description,
                      style: TextStyle(
                          color: unlocked.contains(a.id)
                              ? Colors.white70
                              : Colors.white24)),
                  trailing: Text('+${a.coinReward} 🪙',
                      style: const TextStyle(
                          color: Colors.amber, fontSize: 12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

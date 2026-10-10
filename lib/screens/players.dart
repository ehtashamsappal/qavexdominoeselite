import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../services/audio.dart';
import '../models/models.dart';
import '../widgets/domino_tile.dart';
import '../game/engine.dart';

/// Players / Profile screen: identity, level, title, avatar tile picker.
class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});
  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final _avatars = [
    '6|6', '5|5', '1|1', '0|0', '6|5', '6|1', '3|2', '4|4',
  ];

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final p = app.profile;
          final parts = p.avatarTile.split('|');
          final avatar = DominoTile(
              int.parse(parts[0]), int.parse(parts[1]));
          final unlocked = app.store.unlockedAchievements.length;
          final progress =
              (app.stats.totalCoinsEarned % 500) / 500;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                DominoTileWidget(
                  tile: avatar,
                  width: 96,
                  face: Color(app.theme.tileFace),
                  ink: Color(app.theme.tileInk),
                ),
                const SizedBox(height: 12),
                Text(p.name,
                    style: Theme.of(context).textTheme.titleLarge),
                Text('${p.title} · Level ${p.level}',
                    style: TextStyle(color: Color(app.theme.accent))),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white12,
                  color: Color(app.theme.accent),
                ),
                Text(
                    '${app.stats.totalCoinsEarned % 500}/500 coins to level ${p.level + 1}',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Avatar tile',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final a in _avatars)
                      GestureDetector(
                        onTap: () async {
                          app.audio.sfx(SoundBank.sfxClick);
                          p.avatarTile = a;
                          await app.store.saveProfile(p);
                          setState(() {});
                        },
                        child: DominoTileWidget(
                          tile: DominoTile(int.parse(a.split('|')[0]),
                              int.parse(a.split('|')[1])),
                          width: 52,
                          face: Color(app.theme.tileFace),
                          ink: Color(app.theme.tileInk),
                          selected: p.avatarTile == a,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  color: Color(app.theme.surface),
                  child: ListTile(
                    leading: const Icon(Icons.emoji_events,
                        color: Colors.amber),
                    title: const Text('Achievements',
                        style: TextStyle(color: Colors.white)),
                    subtitle: Text('$unlocked / ${achievements.length} unlocked',
                        style:
                            const TextStyle(color: Colors.white70)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.pushNamed(context, '/stats'),
                  ),
                ),
                Card(
                  color: Color(app.theme.surface),
                  child: ListTile(
                    leading: const Icon(Icons.local_fire_department,
                        color: Colors.orange),
                    title: const Text('Daily streak',
                        style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                        '${app.stats.currentStreak} days (best ${app.stats.bestStreak})',
                        style:
                            const TextStyle(color: Colors.white70)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

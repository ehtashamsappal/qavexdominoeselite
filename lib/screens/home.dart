import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../services/audio.dart';
import '../widgets/domino_tile.dart';
import '../game/engine.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final t = app.theme;
    final kids = app.settings.kidsMode;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qavex Dominoes Elite'),
        actions: [
          _CoinPill(app: app),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DominoTileWidget(tile: DominoTile(3, 5), width: 64, face: Color(t.tileFace), ink: Color(t.tileInk)),
                    const SizedBox(width: 12),
                    DominoTileWidget(tile: DominoTile(5, 2), width: 64, face: Color(t.tileFace), ink: Color(t.tileInk)),
                    const SizedBox(width: 12),
                    DominoTileWidget(tile: DominoTile(2, 6), width: 64, face: Color(t.tileFace), ink: Color(t.tileInk)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('Welcome, ${app.profile.name}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge),
              Text('${app.profile.title} · Level ${app.profile.level} · 🔥 ${app.stats.currentStreak}-day streak',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              _MenuButton(
                  label: '▶  Play',
                  color: Color(t.primary),
                  onTap: () {
                    app.audio.sfx(SoundBank.sfxClick);
                    Navigator.pushNamed(context, '/modes');
                  }),
              const SizedBox(height: 12),
              _MenuButton(
                  label: '🏆  Tournament Ladder',
                  color: Color(t.accent),
                  onTap: () {
                    app.audio.sfx(SoundBank.sfxClick);
                    Navigator.pushNamed(context, '/levels', arguments: 'ladder');
                  }),
              const SizedBox(height: 12),
              if (!kids) ...[
                _MenuButton(
                    label: '🛍  Shop',
                    color: const Color(0xFF8B5CF6),
                    onTap: () => Navigator.pushNamed(context, '/shop')),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                      child: _MenuButton(
                          label: '🎨 Themes',
                          color: Colors.blueGrey,
                          onTap: () =>
                              Navigator.pushNamed(context, '/themes'))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _MenuButton(
                          label: '📊 Stats',
                          color: Colors.teal,
                          onTap: () =>
                              Navigator.pushNamed(context, '/stats'))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _MenuButton(
                          label: '👤 Profile',
                          color: Colors.indigo,
                          onTap: () =>
                              Navigator.pushNamed(context, '/players'))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _MenuButton(
                          label: '❓ How to Play',
                          color: Colors.brown,
                          onTap: () => Navigator.pushNamed(context, '/howto'))),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/about'),
                child: const Text('About & Privacy',
                    style: TextStyle(color: Colors.white54)),
              ),
              const SizedBox(height: 8),
              const Text('Offline · No ads · Made by QAVEX',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16)),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }
}

class _CoinPill extends StatelessWidget {
  final AppState app;
  const _CoinPill({required this.app});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.amber.shade700,
          borderRadius: BorderRadius.circular(20)),
      child: Text('🪙 ${app.stats.coins}',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

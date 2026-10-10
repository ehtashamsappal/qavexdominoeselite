import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../services/audio.dart';

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final modes = [
      _Mode('block', '🧱 Block', 'Classic. No boneyard — pass when stuck.',
          Icons.grid_on),
      _Mode('draw', '🎲 Draw', 'Draw from the boneyard when stuck.',
          Icons.casino),
      _Mode('vsai', '🤖 Vs AI', 'Quick match against the computer.',
          Icons.smart_toy),
      _Mode('passplay', '👥 Pass & Play', '2–4 players on one device.',
          Icons.people),
      _Mode('blitz', '⚡ Timed Blitz', '2 minutes. Score as much as you can!',
          Icons.timer),
      _Mode('ladder', '🏆 Tournament Ladder', '10 rungs, rising AI difficulty.',
          Icons.emoji_events),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a Mode')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: modes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final m = modes[i];
          return Card(
            color: Color(app.theme.surface),
            child: ListTile(
              leading: Icon(m.icon, size: 36, color: Color(app.theme.accent)),
              title: Text(m.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(m.blurb,
                  style: const TextStyle(color: Colors.white70)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                app.audio.sfx(SoundBank.sfxClick);
                if (m.id == 'ladder') {
                  Navigator.pushNamed(context, '/levels',
                      arguments: 'ladder');
                } else if (m.id == 'passplay') {
                  Navigator.pushNamed(context, '/levels',
                      arguments: 'passplay');
                } else {
                  Navigator.pushNamed(context, '/levels', arguments: m.id);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _Mode {
  final String id, title, blurb;
  final IconData icon;
  _Mode(this.id, this.title, this.blurb, this.icon);
}

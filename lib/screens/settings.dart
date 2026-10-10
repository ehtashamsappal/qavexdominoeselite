import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../services/audio.dart';
import '../models/models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
        text: AppStateScope.of(context).settings.playerName);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final s = app.settings;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _name,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Player name',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (v) async {
                s.playerName = v.trim().isEmpty ? 'Player 1' : v.trim();
                await app.updateSettings(s);
              },
            ),
            const SizedBox(height: 8),
            _Switch(
                title: '🔊 Sound effects',
                value: s.soundOn,
                onChanged: (v) async {
                  s.soundOn = v;
                  await app.updateSettings(s);
                }),
            _Switch(
                title: '🎵 Music',
                value: s.musicOn,
                onChanged: (v) async {
                  s.musicOn = v;
                  await app.updateSettings(s);
                }),
            _Switch(
                title: '📳 Haptics',
                value: s.hapticsOn,
                onChanged: (v) async {
                  s.hapticsOn = v;
                  await app.updateSettings(s);
                }),
            const Divider(color: Colors.white24),
            const Text('Accessibility',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            _Switch(
                title: '🧒 Kids Mode (bigger tiles, no shop)',
                value: s.kidsMode,
                onChanged: (v) async {
                  s.kidsMode = v;
                  await app.updateSettings(s);
                }),
            _Switch(
                title: '🔆 High contrast',
                value: s.highContrast,
                onChanged: (v) async {
                  s.highContrast = v;
                  await app.updateSettings(s);
                }),
            _Switch(
                title: '🎞 Reduce motion',
                value: s.reduceMotion,
                onChanged: (v) async {
                  s.reduceMotion = v;
                  await app.updateSettings(s);
                }),
            _Switch(
                title: '🔠 Larger text',
                value: s.largeText,
                onChanged: (v) async {
                  s.largeText = v;
                  await app.updateSettings(s);
                }),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Reset all progress',
                  style: TextStyle(color: Colors.red)),
              onTap: () => _confirmReset(app),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(AppState app) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset everything?'),
        content: const Text(
            'This clears stats, coins, achievements and settings.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reset',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && mounted) {
      app.stats = GameStats();
      app.settings = AppSettings(playerName: app.settings.playerName);
      await app.store.saveStats(app.stats);
      await app.updateSettings(app.settings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Progress reset.')));
        setState(() {});
      }
    }
  }
}

class _Switch extends StatelessWidget {
  final String title;
  final bool value;
  final Future<void> Function(bool) onChanged;
  const _Switch(
      {required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      activeThumbColor: Color(app.theme.accent),
      onChanged: (v) {
        app.audio.sfx(SoundBank.sfxClick);
        onChanged(v);
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../services/audio.dart';
import '../models/models.dart';
import '../widgets/domino_tile.dart';
import '../game/engine.dart';

/// Theme gallery: preview all 8 palettes, activate owned ones.
class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Themes')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: dominoThemes.length,
          itemBuilder: (context, i) {
            final t = dominoThemes[i];
            final owned = app.store.ownedThemes.contains(t.id);
            final active = app.settings.themeId == t.id;
            return GestureDetector(
              onTap: owned
                  ? () async {
                      app.audio.sfx(SoundBank.sfxClick);
                      app.settings.themeId = t.id;
                      await app.updateSettings(app.settings);
                    }
                  : () => Navigator.pushNamed(context, '/shop'),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(t.surface),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active
                        ? Color(t.accent)
                        : Colors.white.withValues(alpha: 0.15),
                    width: active ? 3 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DominoTileWidget(
                      tile: DominoTile(6, 4),
                      width: 52,
                      face: Color(t.tileFace),
                      ink: Color(t.tileInk),
                    ),
                    const SizedBox(height: 8),
                    Text(t.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final c in [
                          t.background,
                          t.surface,
                          t.primary,
                          t.accent,
                          t.tileFace,
                          t.tileInk,
                        ])
                          Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white30, width: 0.5),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      active
                          ? '✓ Active'
                          : owned
                              ? 'Tap to use'
                              : '🔒 In shop',
                      style: TextStyle(
                          color: active
                              ? Color(t.accent)
                              : Colors.white60,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

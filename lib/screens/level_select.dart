import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../services/audio.dart';
import '../game/ai.dart';
import '../game/session.dart';
import '../game/engine.dart';

/// Level Select: difficulty + player count, then launches the Game screen.
class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});
  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  AiLevel level = AiLevel.medium;
  int aiCount = 1;
  int players = 2;
  int ladderStart = 1;

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final mode = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'vsai';
    final isLadder = mode == 'ladder';
    final isPassPlay = mode == 'passplay';
    final isBlitz = mode == 'blitz';

    return Scaffold(
      appBar: AppBar(title: Text(_titleFor(mode))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLadder) ...[
              const Text('Start at rung',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (var r = 1; r <= 10; r++)
                    ChoiceChip(
                      label: Text('$r'),
                      selected: ladderStart == r,
                      onSelected: (_) =>
                          setState(() => ladderStart = r),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                  'Rung $ladderStart: ${ladderRungs[ladderStart - 1].ai.label} AI · ${ladderRungs[ladderStart - 1].variant.name}',
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
            ],
            if (!isLadder && !isPassPlay) ...[
              const Text('AI Difficulty',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              RadioGroup<AiLevel>(
                groupValue: level,
                onChanged: (v) => setState(() => level = v!),
                child: Column(
                  children: [
                    for (final lv in AiLevel.values)
                      RadioListTile<AiLevel>(
                        title: Text(lv.label,
                            style:
                                const TextStyle(color: Colors.white)),
                        subtitle: Text(lv.blurb,
                            style:
                                const TextStyle(color: Colors.white60)),
                        value: lv,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (mode == 'vsai') ...[
              const Text('AI Opponents',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  for (var n = 1; n <= 3; n++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('$n'),
                        selected: aiCount == n,
                        onSelected: (_) => setState(() => aiCount = n),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (isPassPlay) ...[
              const Text('Players',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  for (var n = 2; n <= 4; n++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('$n'),
                        selected: players == n,
                        onSelected: (_) => setState(() => players = n),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (isBlitz)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                    'Race the clock: every round you win adds to your Blitz score. Boneyard draws included.',
                    style: TextStyle(color: Colors.white70)),
              ),
            ElevatedButton(
              onPressed: () {
                app.audio.sfx(SoundBank.sfxClick);
                final session = GameSession();
                if (isLadder) {
                  session.startLadder(ladderStart);
                } else if (isPassPlay) {
                  session.startPassAndPlay(
                      variant: DominoVariant.block, players: players);
                } else if (isBlitz) {
                  session.startBlitz(aiLevel: level);
                } else if (mode == 'block') {
                  session.startVsAi(
                      variant: DominoVariant.block,
                      aiLevel: level,
                      aiCount: aiCount);
                } else if (mode == 'draw') {
                  session.startVsAi(
                      variant: DominoVariant.draw,
                      aiLevel: level,
                      aiCount: aiCount);
                } else {
                  session.startVsAi(
                      variant: DominoVariant.block,
                      aiLevel: level,
                      aiCount: aiCount);
                }
                Navigator.pushNamed(context, '/game', arguments: session);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('Start Game', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _titleFor(String mode) => switch (mode) {
        'block' => 'Block — Difficulty',
        'draw' => 'Draw — Difficulty',
        'blitz' => 'Timed Blitz — Difficulty',
        'ladder' => 'Tournament Ladder',
        'passplay' => 'Pass & Play',
        _ => 'Vs AI — Difficulty',
      };
}

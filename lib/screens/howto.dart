import 'package:flutter/material.dart';
import '../state/app_state.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  static const _sections = [
    ('🎯 Goal',
        'Be the first to reach 100 match points. Win rounds to bank points.'),
    ('🧱 Block',
        'Classic dominoes. No boneyard: if you cannot play, you pass. '
        'The round ends when someone empties their hand ("Domino!") or nobody can play (blocked game).'),
    ('🎲 Draw',
        'When you cannot play, draw tiles from the boneyard until you find a playable one. '
        'If the boneyard runs out, you pass.'),
    ('🁫 Starting a round',
        'Each player gets 7 tiles from the double-six set (28 tiles). '
        'The holder of the highest double plays first; otherwise the highest tile opens.'),
    ('➡️ Playing',
        'Match a tile to either open end of the line. Tap a glowing tile in your hand; '
        'if it fits both ends, choose left or right. Doubles are played crosswise but count normally.'),
    ('🏁 Round scoring',
        'Domino (empty hand): you score the total pips left in every opponent\'s hand.\n'
        'Blocked game: the player with the fewest remaining pips wins and scores '
        '(opponents\' pips − their own pips).'),
    ('🏆 Match scoring',
        'Round points accumulate. First to 100 wins the match. '
        'Timed Blitz instead races a 2-minute clock: every round win adds to your Blitz score.'),
    ('🤖 AI levels',
        'Easy plays randomly. Medium plays greedy tactics. Hard looks ahead and counts tiles. '
        'Expert runs a deep time-capped search.'),
    ('🪙 Domino Coins',
        'Earned by playing — 5 per round plus bonuses for points, wins and dominoes. '
        'Spend them on themes in the Shop. Streak bonus: +50 coins every 7th consecutive day.'),
    ('🧒 Kids Mode',
        'Bigger tiles, simplified layout, and the Shop is hidden. '
        'Find it in Settings along with high-contrast, larger-text and reduced-motion options.'),
  ];

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('How to Play')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final s = _sections[i];
          return Card(
            color: Color(app.theme.surface),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.$1,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(s.$2,
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

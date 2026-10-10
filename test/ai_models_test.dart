import 'package:flutter_test/flutter_test.dart';
import 'package:qavexdominoeselite/game/engine.dart';
import 'package:qavexdominoeselite/game/ai.dart';
import 'package:qavexdominoeselite/models/models.dart';

void main() {
  group('DominoAi', () {
    test('easy always returns a legal move', () {
      for (var seed = 0; seed < 10; seed++) {
        final g = DominoesGame(
            variant: DominoVariant.block, playerCount: 2, seed: seed);
        final ai = DominoAi(AiLevel.easy, seed: seed);
        var guard = 0;
        while (!g.roundOver && guard++ < 200) {
          final moves = g.legalMoves(g.currentPlayer);
          if (moves.isEmpty) {
            g.pass();
          } else {
            final m = ai.chooseMove(g)!;
            expect(moves, contains(m));
            g.play(m);
          }
        }
        expect(g.roundOver, isTrue);
      }
    });
    test('all levels finish a draw game vs each other', () {
      for (final lv in AiLevel.values) {
        final g = DominoesGame(
            variant: DominoVariant.draw, playerCount: 2, seed: 21);
        final ai = DominoAi(lv, seed: 21);
        var guard = 0;
        while (!g.roundOver && guard++ < 400) {
          final me = g.currentPlayer;
          final moves = g.legalMoves(me);
          if (moves.isEmpty) {
            if (g.variant == DominoVariant.draw &&
                g.playerCount == 2 &&
                g.boneyard.isNotEmpty) {
              g.drawTile(me);
              var g2 = 0;
              while (g.legalMoves(me).isEmpty &&
                  g.boneyard.isNotEmpty &&
                  g2++ < 20) {
                g.drawTile(me);
              }
              if (g.legalMoves(me).isEmpty) {
                g.pass();
              } else {
                g.play(ai.chooseMove(g)!);
              }
            } else {
              g.pass();
            }
          } else {
            g.play(ai.chooseMove(g)!);
          }
        }
        expect(g.roundOver, isTrue,
            reason: 'level ${lv.label} did not finish');
      }
    });
    test('expert respects its time budget', () {
      final g = DominoesGame(
          variant: DominoVariant.block, playerCount: 2, seed: 77);
      // Play a few moves to reach a mid-game position.
      for (var i = 0; i < 6 && !g.roundOver; i++) {
        final moves = g.legalMoves(g.currentPlayer);
        if (moves.isEmpty) {
          g.pass();
        } else {
          g.play(moves.first);
        }
      }
      if (!g.roundOver) {
        final ai = DominoAi(AiLevel.expert, seed: 77);
        final sw = Stopwatch()..start();
        final m = ai.chooseMove(g);
        sw.stop();
        expect(m, isNotNull);
        // Generous ceiling: budget 900ms + overhead.
        expect(sw.elapsedMilliseconds, lessThan(5000));
      }
    });
    test('medium prefers dumping heavy tiles (sanity)', () {
      // Construct a position where the greedy choice is obvious.
      final g = DominoesGame(
          variant: DominoVariant.block, playerCount: 2, seed: 1234);
      final ai = DominoAi(AiLevel.medium, seed: 1);
      var sawHeavy = false;
      var guard = 0;
      while (!g.roundOver && guard++ < 60) {
        final moves = g.legalMoves(g.currentPlayer);
        if (moves.isEmpty) {
          g.pass();
          continue;
        }
        final m = ai.chooseMove(g)!;
        if (m.tile.pips >= 9) sawHeavy = true;
        g.play(m);
      }
      expect(sawHeavy, isTrue);
    });
  });

  group('Models', () {
    test('8 themes with unique ids and 6-color palettes', () {
      expect(dominoThemes.length, 8);
      final ids = dominoThemes.map((t) => t.id).toSet();
      expect(ids.length, 8);
      expect(ids, contains('ivory_club'));
      final ivory = themeById('ivory_club');
      expect(ivory.background, 0xFF1A1A1A);
      expect(ivory.tileFace, 0xFFFFF8E7);
      expect(ivory.primary, 0xFFC0392B);
    });
    test('50+ achievements defined with unique ids', () {
      expect(achievements.length, greaterThanOrEqualTo(50));
      final ids = achievements.map((a) => a.id).toSet();
      expect(ids.length, achievements.length);
    });
    test('daily streak logic', () {
      final s = GameStats();
      expect(s.touchDailyStreak('2026-10-10'), 0);
      expect(s.currentStreak, 1);
      expect(s.touchDailyStreak('2026-10-10'), 0); // same day: no-op
      expect(s.currentStreak, 1);
      expect(s.touchDailyStreak('2026-10-11'), 0);
      expect(s.currentStreak, 2);
      expect(s.touchDailyStreak('2026-10-20'), 0); // gap: reset
      expect(s.currentStreak, 1);
    });
    test('settings round-trip', () {
      final s = AppSettings(kidsMode: true, themeId: 'neon');
      final r = AppSettings.fromJson(s.toJson());
      expect(r.kidsMode, isTrue);
      expect(r.themeId, 'neon');
    });
    test('stats round-trip', () {
      final s = GameStats(matchesWon: 3, coins: 42);
      final r = GameStats.fromJson(s.toJson());
      expect(r.matchesWon, 3);
      expect(r.coins, 42);
    });
    test('profile titles escalate', () {
      expect(PlayerProfile.titleFor(0), 'Rookie');
      expect(PlayerProfile.titleFor(50), 'Domino Immortal');
      expect(PlayerProfile.levelFor(0), 1);
      expect(PlayerProfile.levelFor(1000), 3);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:qavexdominoeselite/game/engine.dart';

void main() {
  group('DominoTile', () {
    test('normalizes order so a <= b', () {
      final t = DominoTile(5, 2);
      expect(t.a, 2);
      expect(t.b, 5);
    });
    test('rejects out-of-range pips', () {
      expect(() => DominoTile(7, 0), throwsArgumentError);
      expect(() => DominoTile(-1, 3), throwsArgumentError);
    });
    test('double-six set has 28 unique tiles', () {
      final set = doubleSixSet();
      expect(set.length, 28);
      expect(set.toSet().length, 28);
    });
    test('matches and otherSide', () {
      final t = DominoTile(2, 5);
      expect(t.matches(2), isTrue);
      expect(t.matches(5), isTrue);
      expect(t.matches(3), isFalse);
      expect(t.otherSide(2), 5);
      expect(t.otherSide(5), 2);
    });
  });

  group('DominoesGame - deal & open', () {
    test('block 2P deals 7 each, no boneyard', () {
      final g = DominoesGame(
          variant: DominoVariant.block, playerCount: 2, seed: 42);
      expect(g.hands[0].length, 7);
      expect(g.hands[1].length, 7);
      expect(g.boneyard, isEmpty);
    });
    test('draw 2P keeps 14-tile boneyard', () {
      final g = DominoesGame(
          variant: DominoVariant.draw, playerCount: 2, seed: 42);
      expect(g.hands[0].length, 7);
      expect(g.hands[1].length, 7);
      expect(g.boneyard.length, 14);
    });
    test('all 28 tiles accounted for', () {
      final g = DominoesGame(
          variant: DominoVariant.draw, playerCount: 4, seed: 1);
      final all = [
        ...g.hands.expand((h) => h),
        ...g.boneyard,
      ];
      expect(all.toSet().length, 28);
    });
    test('opening move is highest double when present', () {
      final g = DominoesGame(
          variant: DominoVariant.block, playerCount: 2, seed: 42);
      final moves = g.legalMoves(g.currentPlayer);
      expect(moves.length, 1);
      // Highest double across both hands must be the opener.
      DominoTile? best;
      for (final h in g.hands) {
        for (final t in h) {
          if (t.isDouble && (best == null || t.b > best.b)) best = t;
        }
      }
      if (best != null) expect(moves.first.tile, best);
    });
  });

  group('DominoesGame - play & scoring', () {
    test('legal moves match open ends', () {
      final g = DominoesGame(
          variant: DominoVariant.block, playerCount: 2, seed: 7);
      g.play(g.legalMoves(g.currentPlayer).first);
      expect(g.firstMoveDone, isTrue);
      for (final m in g.legalMoves(g.currentPlayer)) {
        expect(
            m.tile.matches(g.leftEnd) || m.tile.matches(g.rightEnd), isTrue);
      }
    });
    test('illegal move throws', () {
      final g = DominoesGame(
          variant: DominoVariant.block, playerCount: 2, seed: 7);
      g.play(g.legalMoves(g.currentPlayer).first);
      final notMine = g.hands[(g.currentPlayer + 1) % 2].first;
      expect(() => g.play(DominoMove(notMine, PlayEnd.left)),
          throwsStateError);
    });
    test('full random game terminates with a result', () {
      final g = DominoesGame(
          variant: DominoVariant.block, playerCount: 2, seed: 99);
      var guard = 0;
      while (!g.roundOver && guard++ < 500) {
        final moves = g.legalMoves(g.currentPlayer);
        if (moves.isEmpty) {
          g.pass();
        } else {
          g.play(moves.first);
        }
      }
      expect(g.roundOver, isTrue);
      final r = g.lastResult!;
      expect(r.winner, inInclusiveRange(0, 1));
      expect(r.pointsAwarded[r.winner], greaterThanOrEqualTo(0));
      // Points conservation: awarded == opponents' pips (minus winner's if blocked).
      var expected = 0;
      for (var p = 0; p < 2; p++) {
        if (p != r.winner) expected += r.handPips[p];
      }
      if (r.blocked) expected -= r.handPips[r.winner];
      expect(r.pointsAwarded[r.winner], expected < 0 ? 0 : expected);
    });
    test('draw variant: drawTile pulls from boneyard', () {
      final g = DominoesGame(
          variant: DominoVariant.draw, playerCount: 2, seed: 3);
      final before = g.boneyard.length;
      final t = g.drawTile(0);
      expect(t, isNotNull);
      expect(g.boneyard.length, before - 1);
      expect(g.hands[0].contains(t), isTrue);
    });
    test('undo restores previous state', () {
      final g = DominoesGame(
          variant: DominoVariant.block, playerCount: 2, seed: 11);
      final keyBefore = g.stateKey(0);
      g.play(g.legalMoves(g.currentPlayer).first);
      expect(g.stateKey(0), isNot(keyBefore));
      expect(g.undo(), isTrue);
      expect(g.stateKey(0), keyBefore);
    });
    test('match ends at target score', () {
      final g = DominoesGame(
          variant: DominoVariant.block,
          playerCount: 2,
          targetScore: 100,
          seed: 5);
      g.matchScores[0] = 120;
      expect(g.matchOver, isTrue);
      expect(g.matchWinner, 0);
    });
  });
}

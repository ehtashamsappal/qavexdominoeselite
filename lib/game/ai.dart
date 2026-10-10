// AI opponents: Easy / Medium / Hard / Expert.
// Pure Dart. Hard and Expert use time-capped heuristic search.

import 'dart:math';
import 'engine.dart';

enum AiLevel { easy, medium, hard, expert }

extension AiLevelX on AiLevel {
  String get label => switch (this) {
        AiLevel.easy => 'Easy',
        AiLevel.medium => 'Medium',
        AiLevel.hard => 'Hard',
        AiLevel.expert => 'Expert',
      };

  /// Milliseconds the AI may think (Hard/Expert search caps).
  int get timeBudgetMs => switch (this) {
        AiLevel.easy => 0,
        AiLevel.medium => 60,
        AiLevel.hard => 350,
        AiLevel.expert => 900,
      };

  String get blurb => switch (this) {
        AiLevel.easy => 'Plays random legal moves. Great for learning.',
        AiLevel.medium => 'Greedy tactics: dumps heavy tiles, keeps options open.',
        AiLevel.hard => 'Looks ahead and counts what is still out.',
        AiLevel.expert => 'Deep time-capped search. Bring your A-game.',
      };
}

class DominoAi {
  final AiLevel level;
  final Random _rng;

  DominoAi(this.level, {int? seed}) : _rng = Random(seed);

  /// Choose a move for the current player. Returns null when the player
  /// must pass (or draw first in Draw variant).
  DominoMove? chooseMove(DominoesGame game) {
    final moves = game.legalMoves(game.currentPlayer);
    if (moves.isEmpty) return null;
    if (moves.length == 1) return moves.first;
    return switch (level) {
      AiLevel.easy => moves[_rng.nextInt(moves.length)],
      AiLevel.medium => _greedy(game, moves),
      AiLevel.hard => _search(game, moves, depth: 2),
      AiLevel.expert => _search(game, moves, depth: 4),
    };
  }

  /// Greedy: maximize immediate heuristic value.
  DominoMove _greedy(DominoesGame game, List<DominoMove> moves) {
    DominoMove? best;
    var bestScore = double.negativeInfinity;
    for (final m in moves) {
      final s = _heuristic(game, m);
      if (s > bestScore) {
        bestScore = s;
        best = m;
      }
    }
    return best!;
  }

  /// Static evaluation of playing [move] right now.
  double _heuristic(DominoesGame game, DominoMove move) {
    final me = game.currentPlayer;
    var score = 0.0;
    // Dump heavy tiles first: pips disposed is good.
    score += move.tile.pips * 2.0;
    // Doubles are flexible later but clunky: slight penalty to hold them.
    if (move.tile.isDouble) score += 1.5;
    // After the move, how many of my remaining tiles stay playable?
    final left = game.leftEnd;
    final right = game.rightEnd;
    int newLeft = left, newRight = right;
    if (!game.firstMoveDone) {
      newLeft = move.tile.a;
      newRight = move.tile.b;
    } else if (move.end == PlayEnd.left) {
      newLeft = move.tile.otherSide(left);
    } else {
      newRight = move.tile.otherSide(right);
    }
    var future = 0;
    var futurePips = 0;
    for (final t in game.hands[me]) {
      if (t == move.tile) continue;
      if (t.matches(newLeft) || t.matches(newRight)) {
        future++;
        futurePips += t.pips;
      }
    }
    score += future * 3.0 + futurePips * 0.4;
    // Prefer leaving ends on values I hold a lot of.
    final counts = List.filled(7, 0);
    for (final t in game.hands[me]) {
      if (t == move.tile) continue;
      counts[t.a]++;
      counts[t.b]++;
    }
    score += (counts[newLeft] + counts[newRight]) * 1.2;
    // Small noise so Medium is not perfectly deterministic.
    score += _rng.nextDouble() * (level == AiLevel.medium ? 2.0 : 0.5);
    return score;
  }

  /// Time-capped negamax-style search over my moves with heuristic
  /// replies for opponents. Falls back to greedy on timeout.
  DominoMove _search(DominoesGame game, List<DominoMove> moves,
      {required int depth}) {
    final deadline =
        DateTime.now().add(Duration(milliseconds: level.timeBudgetMs));
    final me = game.currentPlayer;
    DominoMove? best = _greedy(game, moves);
    var bestValue = double.negativeInfinity;

    // Order moves by greedy value so the best is found early.
    final ordered = List<DominoMove>.of(moves)
      ..sort((x, y) =>
          _heuristic(game, y).compareTo(_heuristic(game, x)));

    for (final m in ordered) {
      if (DateTime.now().isAfter(deadline)) break;
      game.play(m);
      final v = -_searchValue(game, me, depth - 1, deadline,
          double.negativeInfinity, double.infinity);
      game.undo();
      if (v > bestValue) {
        bestValue = v;
        best = m;
      }
    }
    return best!;
  }

  double _searchValue(DominoesGame game, int me, int depth,
      DateTime deadline, double alpha, double beta) {
    if (game.roundOver || depth <= 0 || DateTime.now().isAfter(deadline)) {
      return _evaluate(game, me);
    }
    final moves = game.legalMoves(game.currentPlayer);
    if (moves.isEmpty) {
      // Opponent passes or must draw: treat draw-variant draws as passes in
      // search (boneyard knowledge is hidden anyway).
      if (game.canPass(game.currentPlayer)) {
        game.pass();
        final v = -_searchValue(game, me, depth - 1, deadline, -beta, -alpha);
        game.undo();
        return v;
      }
      return _evaluate(game, me);
    }
    // Opponent replies greedily to keep the tree narrow.
    final reply = _greedy(game, moves);
    game.play(reply);
    final v = -_searchValue(game, me, depth - 1, deadline, -beta, -alpha);
    game.undo();
    return v;
  }

  /// Evaluation from [me]'s perspective: tile-count lead, pip lead,
  /// mobility, and match score.
  double _evaluate(DominoesGame game, int me) {
    if (game.roundOver) {
      final r = game.lastResult!;
      if (r.winner == me) return 1000.0 + r.pointsAwarded[me];
      return -1000.0 - r.pointsAwarded[r.winner];
    }
    var v = 0.0;
    final myTiles = game.hands[me].length;
    var oppTiles = 0;
    var myPips = 0;
    var oppPips = 0;
    for (var p = 0; p < game.playerCount; p++) {
      final n = game.hands[p].length;
      final pips = game.hands[p].fold(0, (s, t) => s + t.pips);
      if (p == me) {
        myPips = pips;
      } else {
        oppTiles += n;
        oppPips += pips;
      }
    }
    final oppAvg = oppTiles / (game.playerCount - 1);
    v += (oppAvg - myTiles) * 12.0; // fewer tiles than opponents: good
    v += (oppPips - myPips) * 0.8; // pip lead: good
    v += game.matchScores[me] * 0.5; // match score matters
    // Mobility: my playable moves now.
    v += game.legalMoves(me).length * 2.0;
    return v;
  }
}

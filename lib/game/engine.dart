// Pure-Dart dominoes engine: tile set, legal plays, variants, scoring.
// No Flutter imports — safe for unit tests and reuse.

/// A single domino tile. Normalized so [a] <= [b].
class DominoTile implements Comparable<DominoTile> {
  final int a;
  final int b;

  DominoTile(int x, int y)
      : a = x <= y ? x : y,
        b = x <= y ? y : x {
    if (x < 0 || x > 6 || y < 0 || y > 6) {
      throw ArgumentError('Domino pips must be 0..6, got ($x,$y)');
    }
  }

  bool get isDouble => a == b;
  int get pips => a + b;

  /// True if this tile can be placed on an end showing [end].
  bool matches(int end) => a == end || b == end;

  /// The value the free side of this tile shows after matching [end].
  int otherSide(int end) {
    if (a == end) return b;
    if (b == end) return a;
    throw StateError('Tile $this does not match end $end');
  }

  @override
  int compareTo(DominoTile other) {
    final c = pips.compareTo(other.pips);
    return c != 0 ? c : b.compareTo(other.b);
  }

  @override
  bool operator ==(Object other) =>
      other is DominoTile && other.a == a && other.b == b;

  @override
  int get hashCode => a * 8 + b;

  @override
  String toString() => '[$a|$b]';

  Map<String, int> toJson() => {'a': a, 'b': b};
  factory DominoTile.fromJson(Map<String, dynamic> j) =>
      DominoTile((j['a'] as num).toInt(), (j['b'] as num).toInt());
}

/// Full double-six set (28 tiles).
List<DominoTile> doubleSixSet() {
  final tiles = <DominoTile>[];
  for (var i = 0; i <= 6; i++) {
    for (var j = i; j <= 6; j++) {
      tiles.add(DominoTile(i, j));
    }
  }
  return tiles;
}

/// Game variant.
enum DominoVariant { block, draw }

/// Which end(s) a play targets.
enum PlayEnd { left, right }

/// A legal move: tile from hand played on one end of the layout.
class DominoMove {
  final DominoTile tile;
  final PlayEnd end;
  const DominoMove(this.tile, this.end);

  @override
  String toString() => 'Play $tile on ${end.name}';
  @override
  bool operator ==(Object other) =>
      other is DominoMove && other.tile == tile && other.end == end;
  @override
  int get hashCode => tile.hashCode * 31 + end.hashCode;
}

/// Result of a finished round.
class RoundResult {
  final int winner; // player index, -1 for draw
  final List<int> pointsAwarded; // per-player match points earned
  final bool blocked;
  final List<int> handPips; // remaining pips per player
  final String summary;
  const RoundResult({
    required this.winner,
    required this.pointsAwarded,
    required this.blocked,
    required this.handPips,
    required this.summary,
  });
}

/// Core game state machine for Block and Draw dominoes.
///
/// Rules implemented:
/// - Double-six set, 2-4 players, 7 tiles each.
/// - Draw variant: 2-player games keep a 14-tile boneyard; pass-and-draw
///   when no legal play (player draws until playable or boneyard empties,
///   then passes).
/// - Block variant: no boneyard; pass when no legal play.
/// - First move of a round: highest double in any hand, else highest tile.
/// - Round ends on domino (empty hand) or when all players pass consecutively
///   (blocked game). Blocked game: lowest remaining pip count wins the round.
/// - Scoring: round winner scores the sum of all opponents' remaining pips.
///   Blocked game: winner scores (opponents' pips − winner's pips).
/// - Match target: first to 100 match points wins the match.
class DominoesGame {
  final DominoVariant variant;
  final int playerCount;
  final int targetScore;

  List<List<DominoTile>> hands = [];
  List<DominoTile> boneyard = [];
  List<DominoTile> layout = []; // tiles in play order
  int leftEnd = -1;
  int rightEnd = -1;
  int currentPlayer = 0;
  int consecutivePasses = 0;
  bool roundOver = false;
  bool firstMoveDone = false;
  List<int> matchScores;
  int roundNumber = 1;
  final List<String> log = [];

  // Snapshot stack for AI search.
  final List<_Snapshot> _history = [];

  DominoesGame({
    required this.variant,
    required this.playerCount,
    this.targetScore = 100,
    int? seed,
  })  : assert(playerCount >= 2 && playerCount <= 4),
        matchScores = List.filled(playerCount, 0) {
    newRound(seed: seed);
  }

  /// Starts (or restarts) a round: shuffle, deal, choose first player.
  void newRound({int? seed}) {
    final deck = doubleSixSet()..shuffleSeeded(_Rng(seed));
    hands = List.generate(playerCount, (_) => <DominoTile>[]);
    boneyard = [];
    layout = [];
    leftEnd = -1;
    rightEnd = -1;
    currentPlayer = 0;
    consecutivePasses = 0;
    roundOver = false;
    firstMoveDone = false;
    _history.clear();
    log.clear();

    // Block: 7 tiles each; undealt tiles sit out (never drawn).
    // Draw 2P: 7 each + 14-tile boneyard. Draw 3-4P: 7 each, no boneyard.
    final dealCount = playerCount * 7;
    for (var i = 0; i < dealCount; i++) {
      hands[i % playerCount].add(deck[i]);
    }
    if (variant == DominoVariant.draw && playerCount == 2) {
      boneyard = deck.sublist(dealCount, dealCount + 14);
    }
    for (final h in hands) {
      h.sort();
    }

    // First player: holder of highest double, else highest tile.
    var best = _firstMoveTile();
    currentPlayer = best.$1;
    log.add('Round $roundNumber starts. Player $currentPlayer opens.');
  }

  /// (playerIndex, tile) of the opening tile.
  (int, DominoTile) _firstMoveTile() {
    DominoTile? bestDouble;
    var bestDoublePlayer = 0;
    DominoTile? bestTile;
    var bestTilePlayer = 0;
    for (var p = 0; p < playerCount; p++) {
      for (final t in hands[p]) {
        if (t.isDouble &&
            (bestDouble == null || t.b > bestDouble.b)) {
          bestDouble = t;
          bestDoublePlayer = p;
        }
        if (bestTile == null || t.compareTo(bestTile) > 0) {
          bestTile = t;
          bestTilePlayer = p;
        }
      }
    }
    if (bestDouble != null) return (bestDoublePlayer, bestDouble);
    return (bestTilePlayer, bestTile!);
  }

  /// All legal moves for [player] in the current position.
  List<DominoMove> legalMoves(int player) {
    final moves = <DominoMove>[];
    if (roundOver) return moves;
    if (!firstMoveDone) {
      if (player != currentPlayer) return moves;
      final (_, tile) = _firstMoveTile();
      if (!hands[player].contains(tile)) return moves;
      return [DominoMove(tile, PlayEnd.right)];
    }
    for (final t in hands[player]) {
      if (t.matches(leftEnd)) moves.add(DominoMove(t, PlayEnd.left));
      // When both ends show the same value, playing on either end is the
      // same logical move — keep a single entry to avoid duplicates.
      if (t.matches(rightEnd) && leftEnd != rightEnd) {
        moves.add(DominoMove(t, PlayEnd.right));
      }
    }
    return moves;
  }

  /// True if [player] can pass (no legal moves and boneyard empty/exhausted).
  bool canPass(int player) =>
      legalMoves(player).isEmpty &&
      (variant == DominoVariant.block ||
          playerCount != 2 ||
          boneyard.isEmpty);

  /// Draw one tile from the boneyard for [player]. Returns the tile or null.
  DominoTile? drawTile(int player) {
    if (variant != DominoVariant.draw || boneyard.isEmpty) return null;
    final t = boneyard.removeLast();
    hands[player].add(t);
    hands[player].sort();
    log.add('Player $player draws.');
    return t;
  }

  /// Applies [move] for the current player. Throws on illegal move.
  void play(DominoMove move) {
    if (roundOver) throw StateError('Round is over');
    final legal = legalMoves(currentPlayer);
    if (!legal.contains(move)) throw StateError('Illegal move: $move');
    _history.add(_snapshot());

    hands[currentPlayer].remove(move.tile);
    if (!firstMoveDone) {
      layout.add(move.tile);
      leftEnd = move.tile.a;
      rightEnd = move.tile.b;
      firstMoveDone = true;
    } else if (move.end == PlayEnd.left) {
      layout.insert(0, move.tile);
      leftEnd = move.tile.otherSide(leftEnd);
    } else {
      layout.add(move.tile);
      rightEnd = move.tile.otherSide(rightEnd);
    }
    consecutivePasses = 0;
    log.add('Player $currentPlayer plays ${move.tile} on ${move.end.name}.');

    if (hands[currentPlayer].isEmpty) {
      _finishRound(dominoWinner: currentPlayer);
      return;
    }
    _advance();
  }

  /// Current player passes (must be legal).
  void pass() {
    if (roundOver) throw StateError('Round is over');
    if (!canPass(currentPlayer)) {
      throw StateError('Player $currentPlayer cannot pass');
    }
    _history.add(_snapshot());
    consecutivePasses++;
    log.add('Player $currentPlayer passes.');
    if (consecutivePasses >= playerCount) {
      _finishRound(dominoWinner: -1);
      return;
    }
    _advance();
  }

  void _advance() {
    currentPlayer = (currentPlayer + 1) % playerCount;
  }

  void _finishRound({required int dominoWinner}) {
    roundOver = true;
    final pips = [for (final h in hands) h.fold(0, (s, t) => s + t.pips)];
    int winner;
    bool blocked = false;
    if (dominoWinner >= 0) {
      winner = dominoWinner;
    } else {
      blocked = true;
      winner = 0;
      for (var p = 1; p < playerCount; p++) {
        if (pips[p] < pips[winner]) winner = p;
      }
    }
    final awarded = List.filled(playerCount, 0);
    var gained = 0;
    for (var p = 0; p < playerCount; p++) {
      if (p != winner) gained += pips[p];
    }
    if (blocked) gained -= pips[winner];
    if (gained < 0) gained = 0;
    awarded[winner] = gained;
    matchScores[winner] += gained;

    final kind = blocked ? 'blocked' : 'domino';
    log.add(
        'Round $roundNumber ends ($kind). Player $winner wins the round, +$gained pts.');
    _lastResult = RoundResult(
      winner: winner,
      pointsAwarded: awarded,
      blocked: blocked,
      handPips: pips,
      summary: blocked
          ? 'Blocked game — Player $winner takes the round (+$gained).'
          : 'Player $winner dominoes! (+$gained)',
    );
  }

  RoundResult? _lastResult;
  RoundResult? get lastResult => _lastResult;

  /// True when some player reached [targetScore].
  bool get matchOver => matchScores.any((s) => s >= targetScore);

  /// Match winner index, or -1 if the match is not over.
  int get matchWinner {
    var best = -1;
    for (var p = 0; p < playerCount; p++) {
      if (matchScores[p] >= targetScore &&
          (best < 0 || matchScores[p] > matchScores[best])) {
        best = p;
      }
    }
    return best;
  }

  /// Undo the last play/pass (used by AI search). Returns false if empty.
  bool undo() {
    if (_history.isEmpty) return false;
    _history.removeLast().restore(this);
    return true;
  }

  int get historyDepth => _history.length;

  _Snapshot _snapshot() => _Snapshot(
        hands: [for (final h in hands) List<DominoTile>.of(h)],
        boneyard: List<DominoTile>.of(boneyard),
        layout: List<DominoTile>.of(layout),
        leftEnd: leftEnd,
        rightEnd: rightEnd,
        currentPlayer: currentPlayer,
        consecutivePasses: consecutivePasses,
        roundOver: roundOver,
        firstMoveDone: firstMoveDone,
        matchScores: List<int>.of(matchScores),
        roundNumber: roundNumber,
        lastResult: _lastResult,
      );

  /// Compact state key for transposition tables.
  String stateKey(int perspective) {
    final sb = StringBuffer()
      ..write(leftEnd)
      ..write(',')
      ..write(rightEnd)
      ..write(',')
      ..write(currentPlayer)
      ..write(',');
    for (var p = 0; p < playerCount; p++) {
      sb.write(hands[(perspective + p) % playerCount].join(';'));
      sb.write('|');
    }
    return sb.toString();
  }
}

class _Snapshot {
  final List<List<DominoTile>> hands;
  final List<DominoTile> boneyard;
  final List<DominoTile> layout;
  final int leftEnd, rightEnd, currentPlayer, consecutivePasses;
  final bool roundOver, firstMoveDone;
  final List<int> matchScores;
  final int roundNumber;
  final RoundResult? lastResult;

  _Snapshot({
    required this.hands,
    required this.boneyard,
    required this.layout,
    required this.leftEnd,
    required this.rightEnd,
    required this.currentPlayer,
    required this.consecutivePasses,
    required this.roundOver,
    required this.firstMoveDone,
    required this.matchScores,
    required this.roundNumber,
    required this.lastResult,
  });

  void restore(DominoesGame g) {
    g.hands = [for (final h in hands) List<DominoTile>.of(h)];
    g.boneyard = List<DominoTile>.of(boneyard);
    g.layout = List<DominoTile>.of(layout);
    g.leftEnd = leftEnd;
    g.rightEnd = rightEnd;
    g.currentPlayer = currentPlayer;
    g.consecutivePasses = consecutivePasses;
    g.roundOver = roundOver;
    g.firstMoveDone = firstMoveDone;
    g.matchScores = List<int>.of(matchScores);
    g.roundNumber = roundNumber;
    g._lastResult = lastResult;
  }
}

/// Deterministic seeded RNG (mulberry32) so tests are reproducible.
class _Rng {
  int _s;
  _Rng(int? seed) : _s = (seed ?? DateTime.now().microsecondsSinceEpoch) & 0xffffffff;
  int nextInt(int max) {
    _s = (_s + 0x6D2B79F5) & 0xffffffff;
    var t = _s;
    t = (t ^ (t >> 15)) * (t | 1) & 0xffffffff;
    t ^= t + ((t ^ (t >> 7)) * (t | 61) & 0xffffffff);
    return ((t ^ (t >> 14)) >> 0) % max;
  }
}

extension _Shuffle<T> on List<T> {
  void shuffleSeeded(_Rng rng) {
    for (var i = length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = this[i];
      this[i] = this[j];
      this[j] = tmp;
    }
  }
}

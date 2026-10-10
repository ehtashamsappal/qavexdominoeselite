// Match orchestration: turns, AI scheduling, Timed Blitz clock,
// Tournament Ladder progression. Bridges the pure-Dart engine to the UI.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'engine.dart';
import 'ai.dart';

enum SessionKind { vsAi, passAndPlay, blitz, ladder }

/// Rung configuration for the Tournament Ladder (10 rungs).
class LadderRung {
  final int rung; // 1..10
  final AiLevel ai;
  final DominoVariant variant;
  const LadderRung(this.rung, this.ai, this.variant);
}

const List<LadderRung> ladderRungs = [
  LadderRung(1, AiLevel.easy, DominoVariant.block),
  LadderRung(2, AiLevel.easy, DominoVariant.draw),
  LadderRung(3, AiLevel.medium, DominoVariant.block),
  LadderRung(4, AiLevel.medium, DominoVariant.draw),
  LadderRung(5, AiLevel.hard, DominoVariant.block),
  LadderRung(6, AiLevel.hard, DominoVariant.draw),
  LadderRung(7, AiLevel.hard, DominoVariant.block),
  LadderRung(8, AiLevel.expert, DominoVariant.draw),
  LadderRung(9, AiLevel.expert, DominoVariant.block),
  LadderRung(10, AiLevel.expert, DominoVariant.draw),
];

class GameSession extends ChangeNotifier {
  late DominoesGame game;
  SessionKind kind = SessionKind.vsAi;
  List<AiLevel?> seatAi = []; // null = human seat
  List<DominoAi> ais = [];
  int ladderRung = 1;
  bool busy = false; // AI thinking / animating

  // Timed Blitz state.
  int blitzSecondsLeft = 0;
  int blitzScore = 0;
  Timer? _blitzTimer;
  static const int blitzDuration = 120;

  // Event hooks wired by the UI layer.
  void Function(RoundResult result)? onRoundEnd;
  void Function(int winner)? onMatchEnd;
  void Function(DominoMove move, int player)? onMovePlayed;
  void Function(int player)? onTurnChanged;

  void startVsAi({
    required DominoVariant variant,
    required AiLevel aiLevel,
    int aiCount = 1, // 1..3 AI opponents
  }) {
    kind = SessionKind.vsAi;
    seatAi = [null, for (var i = 0; i < aiCount; i++) aiLevel];
    _boot(variant: variant, targetScore: 100);
  }

  void startPassAndPlay({
    required DominoVariant variant,
    required int players, // 2..4
    int targetScore = 100,
  }) {
    kind = SessionKind.passAndPlay;
    seatAi = List.filled(players, null);
    _boot(variant: variant, targetScore: targetScore);
  }

  void startBlitz({required AiLevel aiLevel}) {
    kind = SessionKind.blitz;
    seatAi = [null, aiLevel];
    blitzScore = 0;
    blitzSecondsLeft = blitzDuration;
    _boot(variant: DominoVariant.draw, targetScore: 1 << 30);
    _blitzTimer?.cancel();
    _blitzTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      blitzSecondsLeft--;
      if (blitzSecondsLeft <= 0) {
        t.cancel();
        onMatchEnd?.call(game.matchScores[0] >= game.matchScores[1] ? 0 : 1);
      }
      notifyListeners();
    });
  }

  void startLadder(int rung) {
    kind = SessionKind.ladder;
    ladderRung = rung.clamp(1, 10);
    final cfg = ladderRungs[ladderRung - 1];
    seatAi = [null, cfg.ai];
    _boot(variant: cfg.variant, targetScore: 100);
  }

  void _boot({required DominoVariant variant, required int targetScore}) {
    game = DominoesGame(
      variant: variant,
      playerCount: seatAi.length,
      targetScore: targetScore,
    );
    ais = [
      for (final lv in seatAi) lv == null ? DominoAi(AiLevel.easy) : DominoAi(lv)
    ];
    busy = false;
    notifyListeners();
    _maybeAiTurn();
  }

  bool get isHumanTurn => seatAi[game.currentPlayer] == null && !game.roundOver;

  bool get humanMustDraw =>
      isHumanTurn &&
      game.variant == DominoVariant.draw &&
      game.playerCount == 2 &&
      game.legalMoves(game.currentPlayer).isEmpty &&
      game.boneyard.isNotEmpty;

  Future<void> humanPlay(DominoMove move) async {
    if (!isHumanTurn || busy) return;
    busy = true;
    notifyListeners();
    game.play(move);
    onMovePlayed?.call(move, game.currentPlayer == 0 ? game.playerCount - 1 : game.currentPlayer - 1);
    busy = false;
    await _afterAction();
  }

  Future<void> humanDraw() async {
    if (!isHumanTurn || !humanMustDraw) return;
    game.drawTile(game.currentPlayer);
    notifyListeners();
    // Keep drawing automatically? No — let the human tap again.
    if (game.legalMoves(game.currentPlayer).isEmpty &&
        game.boneyard.isEmpty) {
      await humanPass();
    }
  }

  Future<void> humanPass() async {
    if (!isHumanTurn || busy) return;
    if (!game.canPass(game.currentPlayer)) return;
    game.pass();
    await _afterAction();
  }

  Future<void> _afterAction() async {
    if (game.roundOver) {
      await _handleRoundEnd();
      return;
    }
    onTurnChanged?.call(game.currentPlayer);
    notifyListeners();
    await _maybeAiTurn();
  }

  Future<void> _maybeAiTurn() async {
    while (!game.roundOver &&
        seatAi[game.currentPlayer] != null &&
        (kind != SessionKind.blitz || blitzSecondsLeft > 0)) {
      busy = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 550));
      final ai = ais[game.currentPlayer];
      final move = ai.chooseMove(game);
      final who = game.currentPlayer;
      if (move == null) {
        if (game.variant == DominoVariant.draw &&
            game.playerCount == 2 &&
            game.boneyard.isNotEmpty) {
          game.drawTile(who);
          // AI keeps drawing until it can play or must pass.
          var guard = 0;
          while (game.legalMoves(who).isEmpty &&
              game.boneyard.isNotEmpty &&
              guard++ < 20) {
            game.drawTile(who);
          }
          if (game.legalMoves(who).isEmpty) {
            game.pass();
          } else {
            final m2 = ai.chooseMove(game)!;
            game.play(m2);
            onMovePlayed?.call(m2, who);
          }
        } else {
          game.pass();
        }
      } else {
        game.play(move);
        onMovePlayed?.call(move, who);
      }
      busy = false;
      if (game.roundOver) {
        await _handleRoundEnd();
        return;
      }
      onTurnChanged?.call(game.currentPlayer);
      notifyListeners();
    }
    busy = false;
    notifyListeners();
  }

  Future<void> _handleRoundEnd() async {
    final result = game.lastResult!;
    if (kind == SessionKind.blitz) {
      blitzScore += result.pointsAwarded[0];
    }
    notifyListeners();
    onRoundEnd?.call(result);
    if (kind == SessionKind.blitz) {
      if (blitzSecondsLeft > 0) {
        await Future.delayed(const Duration(milliseconds: 900));
        game.newRound();
        game.roundNumber++;
        notifyListeners();
        await _maybeAiTurn();
      }
      return;
    }
    if (game.matchOver) {
      onMatchEnd?.call(game.matchWinner);
    }
  }

  /// Start the next round of a vs-AI / pass-and-play / ladder match.
  Future<void> nextRound() async {
    if (game.matchOver) return;
    game.roundNumber++;
    game.newRound();
    notifyListeners();
    await _maybeAiTurn();
  }

  @override
  void dispose() {
    _blitzTimer?.cancel();
    super.dispose();
  }
}

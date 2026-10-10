import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/app_state.dart';
import '../services/audio.dart';
import '../game/engine.dart';
import '../game/ai.dart';
import '../game/session.dart';
import '../widgets/domino_tile.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameSession session;
  bool _wired = false;
  DominoMove? _pending; // selected tile awaiting end choice
  DominoTile? _selectedTile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _wired = true;
    session = ModalRoute.of(context)!.settings.arguments as GameSession;
    final app = AppStateScope.of(context);
    session.onMovePlayed = (move, player) {
      app.audio.sfx(SoundBank.sfxPlace);
      if (app.settings.hapticsOn) HapticFeedback.lightImpact();
    };
    session.onTurnChanged = (_) {
      if (mounted) setState(() {});
    };
    session.onRoundEnd = (result) => _onRoundEnd(app, result);
    session.onMatchEnd = (winner) => _onMatchEnd(app, winner);
    app.audio.playBgm(SoundBank.bgmGame);
    session.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    session.dispose();
    final ctx = context;
    // Best-effort: restore menu music when leaving.
    try {
      AppStateScope.of(ctx).audio.playBgm(SoundBank.bgmMenu);
    } catch (_) {}
    super.dispose();
  }

  Future<void> _onRoundEnd(AppState app, RoundResult result) async {
    final humanWon = session.kind == SessionKind.passAndPlay
        ? true // everyone is "human" — still award participation coins
        : result.winner == 0;
    final myPoints = session.kind == SessionKind.blitz
        ? result.pointsAwarded[0]
        : (result.winner == 0 ? result.pointsAwarded[0] : 0);
    app.audio.sfx(result.winner == 0
        ? SoundBank.sfxDominoWin
        : SoundBank.sfxWin);
    if (result.blocked) app.audio.sfx(SoundBank.sfxBlock);
    await app.awardForRound(
      won: humanWon && result.winner == 0,
      points: myPoints,
      domino: !result.blocked && result.winner == 0,
      blocked: result.blocked,
    );
    if (session.kind == SessionKind.blitz &&
        app.stats.blitzBest < session.blitzScore) {
      app.stats.blitzBest = session.blitzScore;
      await app.saveStats();
    }
    if (!mounted) return;
    final t = app.theme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Color(t.surface),
        title: Text(result.winner == 0 ? '🎉 Round Won!' : result.summary,
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.summary,
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            for (var p = 0; p < session.game.playerCount; p++)
              Text(
                  '${_playerLabel(p)}: +${result.pointsAwarded[p]} pts (match ${session.game.matchScores[p]})',
                  style: const TextStyle(color: Colors.white)),
            if (app.freshAchievements.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final a in app.freshAchievements)
                Text('🏅 ${a.name} (+${a.coinReward} 🪙)',
                    style: const TextStyle(color: Colors.amber)),
            ],
          ],
        ),
        actions: [
          if (!session.game.matchOver &&
              session.kind != SessionKind.blitz)
            TextButton(
              onPressed: () {
                app.clearFreshAchievements();
                Navigator.pop(context);
                session.nextRound();
              },
              child: const Text('Next Round'),
            ),
          if (session.kind == SessionKind.blitz &&
              session.blitzSecondsLeft > 0)
            TextButton(
              onPressed: () {
                app.clearFreshAchievements();
                Navigator.pop(context);
              },
              child: const Text('Keep Blitzing'),
            ),
        ],
      ),
    );
  }

  Future<void> _onMatchEnd(AppState app, int winner) async {
    final humanWon = winner == 0;
    await app.awardForMatch(won: humanWon);
    if (session.kind == SessionKind.ladder && humanWon) {
      if (session.ladderRung > app.stats.tournamentBest) {
        app.stats.tournamentBest = session.ladderRung;
        await app.saveStats();
      }
    }
    app.audio.sfx(SoundBank.sfxFanfare);
    if (!mounted) return;
    final t = app.theme;
    final ladderDone =
        session.kind == SessionKind.ladder && humanWon && session.ladderRung < 10;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Color(t.surface),
        title: Text(
            session.kind == SessionKind.blitz
                ? '⏱ Blitz Over!'
                : humanWon
                    ? '🏆 Match Won!'
                    : 'Match Over',
            style: const TextStyle(color: Colors.white)),
        content: Text(
          session.kind == SessionKind.blitz
              ? 'Blitz score: ${session.blitzScore} (best ${app.stats.blitzBest})'
              : 'Winner: ${_playerLabel(winner)}\nFinal: ${session.game.matchScores.join(' – ')}',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          if (ladderDone)
            TextButton(
              onPressed: () {
                Navigator.pop(context); // dialog
                Navigator.pop(context); // game
                final next = GameSession()
                  ..startLadder(session.ladderRung + 1);
                Navigator.pushNamed(context, '/game', arguments: next);
              },
              child: const Text('Next Rung ▶'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _playerLabel(int p) {
    if (session.kind == SessionKind.passAndPlay) return 'Player ${p + 1}';
    if (p == 0) return AppStateScope.of(context).settings.playerName;
    final ai = session.seatAi[p];
    return 'AI (${ai?.label ?? "CPU"})';
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final t = app.theme;
    final game = session.game;
    final moves = session.isHumanTurn
        ? game.legalMoves(game.currentPlayer)
        : const <DominoMove>[];
    final playableTiles = moves.map((m) => m.tile).toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForKind()),
        actions: [
          if (session.kind == SessionKind.blitz)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                  child: Text(
                      '⏱ ${session.blitzSecondsLeft}s · ${session.blitzScore} pts',
                      style: const TextStyle(fontWeight: FontWeight.bold))),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
                child: Text('🎯 ${game.targetScore > 100000 ? "∞" : game.targetScore}',
                    style: const TextStyle(color: Colors.white70))),
          ),
        ],
      ),
      body: Column(
        children: [
          _ScoreBar(session: session, labelFor: _playerLabel),
          Expanded(child: _Board(game: game, theme: t)),
          _EndsRow(game: game, theme: t),
          const Divider(height: 1, color: Colors.white24),
          _HandArea(
            session: session,
            playable: playableTiles,
            selected: _selectedTile,
            onTileTap: (tile) => _onTileTap(app, tile, moves),
            theme: t,
          ),
          _ActionRow(
            session: session,
            pending: _pending,
            onChooseEnd: (end) => _onChooseEnd(app, end),
            onCancel: () => setState(() {
              _pending = null;
              _selectedTile = null;
            }),
            onPass: () => session.humanPass(),
            onDraw: () => session.humanDraw(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _titleForKind() => switch (session.kind) {
        SessionKind.vsAi =>
          '${session.game.variant.name.toUpperCase()} vs AI',
        SessionKind.passAndPlay => 'Pass & Play',
        SessionKind.blitz => 'Timed Blitz',
        SessionKind.ladder => 'Ladder — Rung ${session.ladderRung}',
      };

  void _onTileTap(AppState app, DominoTile tile, List<DominoMove> moves) {
    if (!session.isHumanTurn || session.busy) return;
    final options = moves.where((m) => m.tile == tile).toList();
    if (options.isEmpty) {
      app.audio.sfx(SoundBank.sfxError);
      return;
    }
    app.audio.sfx(SoundBank.sfxClick);
    if (options.length == 1) {
      session.humanPlay(options.first);
      setState(() {
        _pending = null;
        _selectedTile = null;
      });
    } else {
      setState(() {
        _pending = options.first;
        _selectedTile = tile;
      });
    }
  }

  void _onChooseEnd(AppState app, PlayEnd end) {
    final tile = _selectedTile;
    if (tile == null) return;
    final game = session.game;
    final move = game
        .legalMoves(game.currentPlayer)
        .firstWhere((m) => m.tile == tile && m.end == end,
            orElse: () => DominoMove(tile, end));
    session.humanPlay(move);
    setState(() {
      _pending = null;
      _selectedTile = null;
    });
  }
}

class _ScoreBar extends StatelessWidget {
  final GameSession session;
  final String Function(int) labelFor;
  const _ScoreBar({required this.session, required this.labelFor});

  @override
  Widget build(BuildContext context) {
    final game = session.game;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: Colors.black.withValues(alpha: 0.25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var p = 0; p < game.playerCount; p++)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(labelFor(p),
                    style: TextStyle(
                        color: game.currentPlayer == p && !game.roundOver
                            ? Colors.amber
                            : Colors.white70,
                        fontWeight: game.currentPlayer == p
                            ? FontWeight.bold
                            : FontWeight.normal)),
                Text('${game.matchScores[p]} pts · ${game.hands[p].length} tiles',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
        ],
      ),
    );
  }
}

class _Board extends StatelessWidget {
  final DominoesGame game;
  final dynamic theme;
  const _Board({required this.game, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (game.layout.isEmpty) {
      return const Center(
          child: Text('Tiles will appear here…',
              style: TextStyle(color: Colors.white38)));
    }
    final face = Color(theme.tileFace as int);
    final ink = Color(theme.tileInk as int);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          for (var i = 0; i < game.layout.length; i++) ...[
            DominoTileWidget(
                tile: game.layout[i],
                width: 52,
                horizontal: false,
                face: face,
                ink: ink),
            if (i < game.layout.length - 1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _EndsRow extends StatelessWidget {
  final DominoesGame game;
  final dynamic theme;
  const _EndsRow({required this.game, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (!game.firstMoveDone) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('Ends:  ${game.leftEnd}  •  ${game.rightEnd}',
          style: TextStyle(
              color: Color(theme.accent as int),
              fontWeight: FontWeight.bold,
              fontSize: 16)),
    );
  }
}

class _HandArea extends StatelessWidget {
  final GameSession session;
  final Set<DominoTile> playable;
  final DominoTile? selected;
  final void Function(DominoTile) onTileTap;
  final dynamic theme;
  const _HandArea({
    required this.session,
    required this.playable,
    required this.selected,
    required this.onTileTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final game = session.game;
    final me = game.currentPlayer;
    final isHuman = session.isHumanTurn;
    // In pass-and-play show current player's hand; otherwise human is seat 0.
    final handIndex =
        session.kind == SessionKind.passAndPlay ? me : 0;
    final face = Color(theme.tileFace as int);
    final ink = Color(theme.tileInk as int);

    if (session.kind != SessionKind.passAndPlay && me != 0) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < game.hands[0].length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: TileBackWidget(
                    width: 36,
                    back: Color(theme.surface as int),
                    trim: Color(theme.accent as int)),
              ),
            const SizedBox(width: 12),
            const Text('AI is thinking…',
                style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    final hand = game.hands[handIndex];
    return Container(
      height: 118,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
              session.kind == SessionKind.passAndPlay
                  ? 'Player ${handIndex + 1} — your tiles (pass the device!)'
                  : isHuman
                      ? 'Your tiles — tap a glowing tile'
                      : 'Waiting…',
              style:
                  const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final tile in hand)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: isHuman ? () => onTileTap(tile) : null,
                      child: DominoTileWidget(
                        tile: tile,
                        width: 56,
                        face: face,
                        ink: ink,
                        dimmed: isHuman && !playable.contains(tile),
                        selected: selected == tile,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final GameSession session;
  final DominoMove? pending;
  final void Function(PlayEnd) onChooseEnd;
  final VoidCallback onCancel;
  final VoidCallback onPass;
  final VoidCallback onDraw;
  const _ActionRow({
    required this.session,
    required this.pending,
    required this.onChooseEnd,
    required this.onCancel,
    required this.onPass,
    required this.onDraw,
  });

  @override
  Widget build(BuildContext context) {
    if (!session.isHumanTurn) {
      return const SizedBox(
          height: 56,
          child: Center(
              child: Text('…', style: TextStyle(color: Colors.white38))));
    }
    if (pending != null) {
      return SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Play on which end?',
                style: TextStyle(color: Colors.white)),
            const SizedBox(width: 12),
            ElevatedButton(
                onPressed: () => onChooseEnd(PlayEnd.left),
                child: Text('◀ ${session.game.leftEnd}')),
            const SizedBox(width: 8),
            ElevatedButton(
                onPressed: () => onChooseEnd(PlayEnd.right),
                child: Text('${session.game.rightEnd} ▶')),
            const SizedBox(width: 8),
            TextButton(onPressed: onCancel, child: const Text('Cancel')),
          ],
        ),
      );
    }
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (session.humanMustDraw)
            ElevatedButton.icon(
              onPressed: onDraw,
              icon: const Icon(Icons.casino),
              label: Text('Draw (${session.game.boneyard.length} left)'),
            ),
          if (session.game.canPass(session.game.currentPlayer)) ...[
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onPass,
              child: const Text('Pass',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../services/audio.dart';
import '../widgets/domino_tile.dart';
import '../game/engine.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    final app = AppStateScope.of(context);
    while (!app.ready) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }
    await app.audio.playBgm(SoundBank.bgmMenu);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final t = app.theme;
    return Scaffold(
      backgroundColor: Color(t.background),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DominoTileWidget(
              tile: DominoTile(6, 6),
              width: 110,
              face: Color(t.tileFace),
              ink: Color(t.tileInk),
            ),
            const SizedBox(height: 24),
            Text('QAVEX DOMINOES',
                style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Color(t.accent),
                    letterSpacing: 2)),
            Text('ELITE',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(t.primary),
                    letterSpacing: 12)),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

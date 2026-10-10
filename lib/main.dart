import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'screens/splash.dart';
import 'screens/home.dart';
import 'screens/mode_select.dart';
import 'screens/level_select.dart';
import 'screens/game.dart';
import 'screens/shop.dart';
import 'screens/settings.dart';
import 'screens/themes.dart';
import 'screens/players.dart';
import 'screens/stats.dart';
import 'screens/howto.dart';
import 'screens/about.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final app = AppState();
  await app.init();
  runApp(AppStateScope(state: app, child: const DominoesApp()));
}

class DominoesApp extends StatelessWidget {
  const DominoesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => MaterialApp(
        title: 'Qavex Dominoes Elite',
        debugShowCheckedModeBanner: false,
        theme: app.materialTheme(),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/home': (_) => const HomeScreen(),
          '/modes': (_) => const ModeSelectScreen(),
          '/levels': (_) => const LevelSelectScreen(),
          '/game': (_) => const GameScreen(),
          '/shop': (_) => const ShopScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/themes': (_) => const ThemesScreen(),
          '/players': (_) => const PlayersScreen(),
          '/stats': (_) => const StatsScreen(),
          '/howto': (_) => const HowToPlayScreen(),
          '/about': (_) => const AboutScreen(),
        },
      ),
    );
  }
}

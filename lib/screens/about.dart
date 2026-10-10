import 'package:flutter/material.dart';
import '../state/app_state.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About & Privacy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text('QAVEX DOMINOES ELITE',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(app.theme.accent))),
            ),
            const SizedBox(height: 4),
            const Center(
                child: Text('Version 1.0.0 · Board · Offline · No ads',
                    style: TextStyle(color: Colors.white60))),
            const SizedBox(height: 20),
            const Text('Developer',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            const Text(
                'QAVEX\nDeveloper: muhammad ehtasham\nhttps://www.qavex.company/\ngames@qavex.company\n+923375621550',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            const Text('Privacy Policy',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            const Text(
              'Qavex Dominoes Elite is fully offline. We collect no personal data, '
              'use no analytics, show no ads, and require no account. All game progress, '
              'settings, stats and achievements are stored only on your device and never '
              'leave it. The optional "Buy Me a Coffee" purchase is processed by the '
              'Google Play / Apple App Store billing system under their own privacy policies; '
              'we receive no payment details. Contact: games@qavex.company.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Text('Credits',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            const Text(
                'Tile art, music and sound effects are generated in-app originals. '
                'Dominoes rules follow standard Block/Draw double-six conventions.',
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

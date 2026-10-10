import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../services/audio.dart';
import '../models/models.dart';

/// Shop: spend Domino Coins on themes + the single "Buy Me a Coffee" IAP.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  static const Map<String, int> themePrices = {
    'midnight': 200,
    'ocean': 200,
    'neon': 350,
    'forest': 350,
    'royal': 500,
    'mono': 150,
    'sunset': 300,
  };

  String? _iapMsg;

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.amber.shade800,
              child: ListTile(
                leading: const Text('🪙', style: TextStyle(fontSize: 32)),
                title: Text('${app.stats.coins} Domino Coins',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: const Text('Earned by playing. No real-money coin packs.',
                    style: TextStyle(color: Colors.white70)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Themes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final entry in themePrices.entries)
              _ThemeRow(
                themeId: entry.key,
                price: entry.value,
                onBought: () => setState(() {}),
              ),
            const SizedBox(height: 16),
            const Text('Support the devs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              color: Color(app.theme.surface),
              child: ListTile(
                leading: const Text('☕', style: TextStyle(fontSize: 32)),
                title: Text(
                    app.iap.product != null
                        ? '${app.iap.product!.title} — ${app.iap.product!.price}'
                        : 'Buy Me a Coffee — \$0.99',
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                    app.store.coffeeBought
                        ? 'Thank you! You already bought us a coffee. ☕'
                        : 'One-time tip. No ads, no subscriptions, ever.',
                    style: const TextStyle(color: Colors.white70)),
                trailing: app.store.coffeeBought
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : ElevatedButton(
                        onPressed: _buyCoffee, child: const Text('Buy')),
              ),
            ),
            if (_iapMsg != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_iapMsg!,
                    style: const TextStyle(color: Colors.white70)),
              ),
            TextButton(
              onPressed: () async {
                await app.iap.restore();
                setState(() => _iapMsg = 'Restore requested.');
              },
              child: const Text('Restore purchases'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _buyCoffee() async {
    final app = AppStateScope.of(context);
    app.audio.sfx(SoundBank.sfxClick);
    final ok = await app.iap.buy();
    setState(() => _iapMsg = ok
        ? 'Opening store…'
        : 'Store unavailable right now. Try again later.');
  }
}

class _ThemeRow extends StatelessWidget {
  final String themeId;
  final int price;
  final VoidCallback onBought;
  const _ThemeRow(
      {required this.themeId, required this.price, required this.onBought});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final theme = themeById(themeId);
    final owned = app.store.ownedThemes.contains(themeId);
    final isActive = app.settings.themeId == themeId;
    final canAfford = app.stats.coins >= price;
    return Card(
      color: Color(app.theme.surface),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(colors: [
              Color(theme.primary),
              Color(theme.accent),
            ]),
          ),
        ),
        title: Text(theme.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
            owned ? (isActive ? 'Active' : 'Owned') : '🪙 $price coins',
            style: const TextStyle(color: Colors.white70)),
        trailing: owned
            ? (isActive
                ? const Icon(Icons.check, color: Colors.green)
                : TextButton(
                    onPressed: () async {
                      app.settings.themeId = themeId;
                      await app.updateSettings(app.settings);
                      onBought();
                    },
                    child: const Text('Use')))
            : ElevatedButton(
                onPressed: canAfford
                    ? () async {
                        app.stats.coins -= price;
                        await app.store.addOwnedTheme(themeId);
                        await app.store.saveStats(app.stats);
                        app.audio.sfx(SoundBank.sfxCoin);
                        onBought();
                      }
                    : null,
                child: const Text('Buy'),
              ),
      ),
    );
  }
}

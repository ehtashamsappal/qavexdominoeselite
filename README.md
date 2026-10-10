# Qavex Dominoes Elite

Classic Block & Draw dominoes — offline, no ads, one optional $0.99 coffee tip.

- **Game ID:** `qavexdominoeselite` · **Package:** `com.qavex.qavexdominoeselite`
- **Category:** Board · **Version:** 1.0.0+1
- **Developer:** QAVEX (muhammad ehtasham) — games@qavex.company ·
  https://www.qavex.company/ · +923375621550

## Features
- Block & Draw variants, double-six set, official scoring (race to 100)
- 6 modes: Block, Draw, Vs AI (1–3 opponents), Pass & Play (2–4P),
  Timed Blitz (120s), Tournament Ladder (10 rungs)
- 4 AI levels: Easy / Medium / Hard / Expert (time-capped heuristic search)
- 12 screens, 8 themes (Ivory Club signature), 54 achievements, daily streaks,
  Domino Coins (play-earned), Kids Mode, accessibility options
- 2 BGM loops + 13 SFX (numpy-generated WAVs in `assets/audio/`)
- Single IAP: "Buy Me a Coffee" $0.99 (`qavexdominoeselitecoffee`)

## Project layout
```
lib/
  game/      engine.dart (pure-Dart rules), ai.dart, session.dart
  models/    models.dart (themes, settings, stats, 54 achievements, profile)
  services/  store.dart (shared_preferences), audio.dart, iap.dart
  screens/   12 screens (splash, home, mode_select, level_select, game,
             shop, settings, themes, players, stats, howto, about)
  widgets/   domino_tile.dart (custom pip painter)
  state/     app_state.dart
  main.dart
assets/      audio/ images/ store_art/   (generated via Pillow/numpy)
store/       STORE_LISTING.txt  SEO_AEO_GEO.txt  PRIVACY_POLICY.txt
test/        engine_test.dart  ai_models_test.dart
```

## Commands
```sh
export PATH=~/sdks/flutter/bin:$PATH
flutter pub get
flutter analyze        # clean
flutter test           # 24/24 pass
```
Builds (`flutter build`, gradle) were intentionally not run for this delivery.

## Signing
Release signing uses `android/app/qavex-dominoes-elite.jks`
(alias `qavexdominoeselite`) with credentials in `android/key.properties`
— both git-ignored (see `.gitignore`).

## Docs
- `DESIGN_BRIEF.md` — concept, identity, systems
- `REVIEW_REPORT.md` — self-review findings & checklist
- `store/` — Play listing, SEO/AEO/GEO pack, privacy policy

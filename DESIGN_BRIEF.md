# DESIGN BRIEF — Qavex Dominoes Elite (qavexdominoeselite)

## Concept
A premium-feeling, fully offline dominoes game for Android. Classic club rules
(Block & Draw, double-six, race to 100) with a modern AI ladder, meta
progression (coins, achievements, streaks, themes), and respectful monetization
(one $0.99 tip, no ads).

## Visual identity
- Signature theme **"Ivory Club"**: ivory tiles #FFF8E7 on jet #1A1A1A felt,
  crimson #C0392B primary, gold #D4AF37 accents, walnut #2A2118 surfaces,
  cream text. Evokes a private dominoes club: ivory, brass, dark wood.
- 7 more themes (Midnight, Ocean, Neon, Forest, Royal, Mono, Sunset), each a
  unique 6-color palette: background, surface, primary, accent, tile face,
  tile ink.
- Tiles are rendered at runtime with a custom pip painter (no sprite sheets),
  so every theme re-skins the whole game instantly.
- Store art generated with Pillow: 1024 icon, splash, 28-tile sheet, 1024×500
  feature graphic, 8 themed screenshots.

## Audio identity
- 2 seamless 8s BGM pad loops (menu: C-major, game: D-minor-ish), numpy
  synthesized, WAV.
- 13 SFX: click, tile place (clack), shuffle, deal, draw, win arpeggio,
  domino-win flourish, blocked-game thud, turn blip, coin ping, error buzz,
  countdown, match fanfare.

## Game design
- Engine is pure Dart (`lib/game/`): tile set, legal-move generation,
  Block/Draw variants, round/match scoring, undo stack for AI search,
  deterministic seeded RNG for tests.
- AI: Easy (random), Medium (greedy heuristic + mobility + suit control),
  Hard (2-ply time-capped search), Expert (4-ply time-capped search ~900ms,
  pip-lead + tile-count + mobility evaluation).
- Modes: Block, Draw, Vs AI (1–3 opponents), Pass & Play (2–4P),
  Timed Blitz (120s, draw variant, cumulative score), Tournament Ladder
  (10 rungs: Easy→Expert, alternating variants).
- Economy: Domino Coins earned per round (5 + points/5 + win/domino bonuses),
  streak bonus +50 every 7th day; spent only on themes. No coin packs.

## UX structure (12 screens)
Splash → Home → Mode Select → Level Select → Game (+ dialogs),
Shop, Settings, Themes, Players/Profile, Stats/Achievements, How to Play,
About/Privacy. Kids Mode hides the Shop and enlarges touch targets via theme
scaling; accessibility toggles: high contrast, larger text, reduced motion,
haptics.

## Technical
- Flutter, SDK 36 / min 24. Deps: shared_preferences, audioplayers,
  in_app_purchase, cupertino_icons.
- Signing: dedicated keystore `android/app/qavex-dominoes-elite.jks`
  (alias `qavexdominoeselite`), credentials in `android/key.properties`
  (git-ignored, as are `*.jks`).
- Build env notes (from QAVEX playbook): GRADLE_USER_HOME under home dir,
  fresh proxy creds per session, curl-only downloads, IPv4 stack for Java,
  Hatch egress CA in JDK cacerts, `-Xmx2G`, daemon off.

## Monetization & privacy
- ONE IAP: "Buy Me a Coffee" $0.99, product id `qavexdominoeselitecoffee`.
- Offline, no ads, no analytics, no accounts; privacy policy in `store/`.

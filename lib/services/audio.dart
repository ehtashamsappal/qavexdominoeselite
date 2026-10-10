// Audio: BGM loops + SFX via audioplayers, backed by bundled WAV assets.
import 'package:audioplayers/audioplayers.dart';

class SoundBank {
  static const bgmMenu = 'audio/bgm_menu.wav';
  static const bgmGame = 'audio/bgm_game.wav';
  static const sfxClick = 'audio/sfx_click.wav';
  static const sfxPlace = 'audio/sfx_place.wav';
  static const sfxShuffle = 'audio/sfx_shuffle.wav';
  static const sfxDeal = 'audio/sfx_deal.wav';
  static const sfxDraw = 'audio/sfx_draw.wav';
  static const sfxWin = 'audio/sfx_win.wav';
  static const sfxDominoWin = 'audio/sfx_domino_win.wav';
  static const sfxBlock = 'audio/sfx_block.wav';
  static const sfxTurn = 'audio/sfx_turn.wav';
  static const sfxCoin = 'audio/sfx_coin.wav';
  static const sfxError = 'audio/sfx_error.wav';
  static const sfxCountdown = 'audio/sfx_countdown.wav';
  static const sfxFanfare = 'audio/sfx_fanfare.wav';
}

class AudioService {
  final AudioPlayer _bgm = AudioPlayer();
  final AudioPlayer _sfx = AudioPlayer();
  bool soundOn = true;
  bool musicOn = true;
  String? _currentBgm;

  Future<void> init({required bool soundOn, required bool musicOn}) async {
    this.soundOn = soundOn;
    this.musicOn = musicOn;
    await _bgm.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playBgm(String asset) async {
    if (!musicOn) return;
    if (_currentBgm == asset) return;
    _currentBgm = asset;
    try {
      await _bgm.play(AssetSource(asset));
    } catch (_) {}
  }

  Future<void> stopBgm() async {
    _currentBgm = null;
    try {
      await _bgm.stop();
    } catch (_) {}
  }

  Future<void> sfx(String asset) async {
    if (!soundOn) return;
    try {
      await _sfx.play(AssetSource(asset));
    } catch (_) {}
  }

  void setSound(bool on) => soundOn = on;

  Future<void> setMusic(bool on) async {
    musicOn = on;
    if (!on) {
      await stopBgm();
    } else if (_currentBgm != null) {
      final a = _currentBgm!;
      _currentBgm = null;
      await playBgm(a);
    }
  }

  Future<void> dispose() async {
    await _bgm.dispose();
    await _sfx.dispose();
  }
}

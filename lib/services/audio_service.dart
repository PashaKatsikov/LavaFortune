import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../core/assets.dart';

/// Small wrapper around audioplayers to centralize music + SFX playback
/// and respect user settings for music/sfx toggles.
class AudioService {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'music');
  final List<AudioPlayer> _sfxPool = List.generate(4, (i) => AudioPlayer(playerId: 'sfx_$i'));
  int _sfxIndex = 0;

  bool musicEnabled = true;
  bool sfxEnabled = true;

  String? _currentMusic;

  Future<void> init() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    for (final p in _sfxPool) {
      await p.setReleaseMode(ReleaseMode.stop);
    }
  }

  Future<void> playMusic(String assetPath) async {
    if (_currentMusic == assetPath) return;
    _currentMusic = assetPath;
    await _startCurrentMusic();
  }

  Future<void> _startCurrentMusic() async {
    final track = _currentMusic;
    if (track == null || !musicEnabled) return;
    try {
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource(track.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('Music playback failed: $e');
    }
  }

  Future<void> stopMusic() async {
    _currentMusic = null;
    await _musicPlayer.stop();
  }

  void setMusicEnabled(bool enabled) {
    musicEnabled = enabled;
    if (enabled) {
      _startCurrentMusic();
    } else {
      _musicPlayer.stop();
    }
  }

  void setSfxEnabled(bool enabled) {
    sfxEnabled = enabled;
  }

  Future<void> playSfx(String assetPath) async {
    if (!sfxEnabled) return;
    try {
      final player = _sfxPool[_sfxIndex];
      _sfxIndex = (_sfxIndex + 1) % _sfxPool.length;
      await player.stop();
      await player.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('SFX playback failed: $e');
    }
  }

  Future<void> click() => playSfx(GameAssets.sfxButtonClick);
}

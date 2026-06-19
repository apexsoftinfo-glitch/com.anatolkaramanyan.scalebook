import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> _playSound(String assetPath) async {
    try {
      // In audioplayers 6.0+, AssetSource expects path relative to assets/ directory
      // i.e., "sounds/newetap.mp3" will resolve to "assets/sounds/newetap.mp3"
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing sound $assetPath: $e');
    }
  }

  Future<void> playNewEtap() async {
    await _playSound('sounds/newetap.mp3');
  }

  Future<void> playNewProject() async {
    await _playSound('sounds/newproject.mp3');
  }

  Future<void> playProjectFin() async {
    await _playSound('sounds/projectfin.mp3');
  }

  Future<void> playDelete() async {
    await _playSound('sounds/delete.mp3');
  }

  Future<void> playNewNote() async {
    await _playSound('sounds/newnotes.mp3');
  }

  void dispose() {
    _player.dispose();
  }
}

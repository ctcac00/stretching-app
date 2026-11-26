import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// What the player needs from the phone; faked in tests. Failures are logged
/// and otherwise ignored: a session works without them.
class SessionDevice {
  Future<AudioPlayer>? _player;

  Future<void> keepAwake(bool on) =>
      _quietly(() => WakelockPlus.toggle(enable: on));

  Future<void> haptic() => _quietly(HapticFeedback.heavyImpact);

  Future<void> sound() => _quietly(() async {
    final player = await (_player ??= _createPlayer());
    await player.stop();
    await player.play(AssetSource('cue.wav'));
  });

  Future<AudioPlayer> _createPlayer() async {
    // Mix with other audio so the cue does not stop the user's music. On iOS
    // this is the "playback" category, which also sounds in silent mode.
    await AudioPlayer.global.setAudioContext(
      AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
    );
    final player = AudioPlayer();
    await player.setReleaseMode(ReleaseMode.stop);
    return player;
  }

  Future<void> dispose() =>
      _quietly(() async => await (await _player)?.dispose());

  Future<void> _quietly(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      debugPrint('Session device: $error');
    }
  }
}

final sessionDeviceProvider = Provider((ref) {
  final device = SessionDevice();
  ref.onDispose(device.dispose);
  return device;
});

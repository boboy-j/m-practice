import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

/// 音频生成与播放工具
class AudioGenerator {
  static const int sampleRate = 44100;
  static const int bitsPerSample = 16;
  static const int channels = 1;

  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _accentPlayer = AudioPlayer();
  final AudioPlayer _tonePlayer = AudioPlayer();
  bool _clickLoaded = false;
  bool _accentLoaded = false;

  AudioGenerator() {
    _clickPlayer.setReleaseMode(ReleaseMode.stop);
    _accentPlayer.setReleaseMode(ReleaseMode.stop);
    _tonePlayer.setReleaseMode(ReleaseMode.stop);
  }

  /// 预加载点击音（在节拍器启动时调用一次）
  Future<void> preloadClicks() async {
    final clickWav = generateClick(frequency: 1500, durationMs: 12);
    final accentWav = generateClick(frequency: 1800, durationMs: 12);
    await _clickPlayer.setSource(BytesSource(clickWav));
    await _accentPlayer.setSource(BytesSource(accentWav));
    _clickLoaded = true;
    _accentLoaded = true;
  }

  Uint8List generateClick({double frequency = 1500, int durationMs = 15}) {
    final numSamples = (sampleRate * durationMs / 1000).round();
    final bytes = BytesBuilder();
    final dataSize = numSamples * channels * (bitsPerSample ~/ 8);
    bytes.add(_wavHeader(dataSize));

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final envelope = max(0, 1.0 - (i / numSamples));
      final sample = (sin(2 * pi * frequency * t) * envelope * 0.8 * 32767).round();
      final clamped = sample.clamp(-32768, 32767);
      bytes.addByte(clamped & 0xFF);
      bytes.addByte((clamped >> 8) & 0xFF);
    }
    return bytes.toBytes();
  }

  Uint8List generateTone(double frequency, {int durationMs = 2000}) {
    final numSamples = (sampleRate * durationMs / 1000).round();
    final bytes = BytesBuilder();
    final dataSize = numSamples * channels * (bitsPerSample ~/ 8);
    bytes.add(_wavHeader(dataSize));

    final harmonics = [
      [1.0, 1.0, 0.0],
      [2.0, 0.55, 0.3],
      [3.0, 0.30, 0.8],
      [4.0, 0.15, 1.5],
      [5.0, 0.08, 2.0],
      [6.0, 0.04, 3.0],
      [7.0, 0.02, 4.0],
    ];
    final effectiveHarmonics = frequency > 1000 ? harmonics.take(3).toList() : harmonics;

    final attackSamples = (sampleRate * 0.008).round();
    final decaySamples = (sampleRate * 0.25).round();
    final sustainLevel = 0.65;
    final releaseStart = numSamples - (sampleRate * 0.15).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      double envelope;
      if (i < attackSamples) {
        envelope = i / attackSamples;
      } else if (i < attackSamples + decaySamples) {
        envelope = 1.0 - (1.0 - sustainLevel) * (i - attackSamples) / decaySamples;
      } else if (i > releaseStart) {
        envelope = sustainLevel * max(0, (numSamples - i) / (numSamples - releaseStart));
      } else {
        envelope = sustainLevel;
      }

      double wave = 0;
      for (final h in effectiveHarmonics) {
        wave += sin(2 * pi * (frequency * h[0] + h[2]) * t + h[0] * 0.1) * h[1];
      }
      wave /= effectiveHarmonics.fold<double>(0, (sum, h) => sum + h[1]);

      final sample = (wave * envelope * 0.7 * 32767).round();
      final clamped = sample.clamp(-32768, 32767);
      bytes.addByte(clamped & 0xFF);
      bytes.addByte((clamped >> 8) & 0xFF);
    }
    return bytes.toBytes();
  }

  /// 节拍器点击（预加载后使用，低延迟）
  void playClick() {
    if (!_clickLoaded) return;
    _clickPlayer.stop();
    _clickPlayer.seek(Duration.zero);
    _clickPlayer.resume();
  }

  void playAccent() {
    if (!_accentLoaded) return;
    _accentPlayer.stop();
    _accentPlayer.seek(Duration.zero);
    _accentPlayer.resume();
  }

  /// 播放预生成 WAV
  Future<void> playPreGenerated(Uint8List wavData) async {
    await _clickPlayer.stop();
    await _clickPlayer.play(BytesSource(wavData));
  }

  /// 播放钢琴标准音
  Future<void> playTone(double frequency) async {
    final wav = generateTone(frequency);
    await _tonePlayer.stop();
    await _tonePlayer.play(BytesSource(wav));
  }

  Future<void> stop() async {
    await _tonePlayer.stop();
  }

  void dispose() {
    _clickPlayer.dispose();
    _accentPlayer.dispose();
    _tonePlayer.dispose();
  }

  Uint8List _wavHeader(int dataSize) {
    final header = BytesBuilder();
    final fileSize = 36 + dataSize;
    header.add('RIFF'.codeUnits);
    header.add(_int32LE(fileSize));
    header.add('WAVE'.codeUnits);
    header.add('fmt '.codeUnits);
    header.add(_int32LE(16));
    header.add(_int16LE(1));
    header.add(_int16LE(channels));
    header.add(_int32LE(sampleRate));
    header.add(_int32LE(sampleRate * channels * (bitsPerSample ~/ 8)));
    header.add(_int16LE(channels * (bitsPerSample ~/ 8)));
    header.add(_int16LE(bitsPerSample));
    header.add('data'.codeUnits);
    header.add(_int32LE(dataSize));
    return header.toBytes();
  }

  Uint8List _int32LE(int value) {
    final bytes = Uint8List(4);
    bytes[0] = value & 0xFF;
    bytes[1] = (value >> 8) & 0xFF;
    bytes[2] = (value >> 16) & 0xFF;
    bytes[3] = (value >> 24) & 0xFF;
    return bytes;
  }

  Uint8List _int16LE(int value) {
    final bytes = Uint8List(2);
    bytes[0] = value & 0xFF;
    bytes[1] = (value >> 8) & 0xFF;
    return bytes;
  }
}

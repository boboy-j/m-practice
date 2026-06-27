import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

/// 音频生成与播放工具 — 钢琴音色合成
class AudioGenerator {
  static const int sampleRate = 44100;
  static const int bitsPerSample = 16;
  static const int channels = 1;

  final AudioPlayer _player = AudioPlayer();

  AudioGenerator() {
    _player.setReleaseMode(ReleaseMode.stop);
  }

  /// 生成节拍器点击音（短促正弦波 + 快速衰减）
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

  /// 生成钢琴音色标准音：
  /// - 多谐波叠加（基频 + 第二~第七泛音，模仿琴弦振动）
  /// - ADSR 包络（快起音 → 衰减 → 延音 → 缓释）
  /// - 高次泛音轻微失谐（模拟钢琴的 in-harmonicity）
  Uint8List generateTone(double frequency, {int durationMs = 2000}) {
    final numSamples = (sampleRate * durationMs / 1000).round();
    final bytes = BytesBuilder();
    final dataSize = numSamples * channels * (bitsPerSample ~/ 8);
    bytes.add(_wavHeader(dataSize));

    // 泛音配置：[倍数, 相对振幅, 失谐偏移(Hz)]
    final harmonics = [
      [1.0, 1.0, 0.0],     // 基频 100%
      [2.0, 0.55, 0.3],    // 第二泛音 55%，轻微失谐
      [3.0, 0.30, 0.8],    // 第三泛音 30%
      [4.0, 0.15, 1.5],    // 第四泛音 15%
      [5.0, 0.08, 2.0],    // 第五泛音 8%
      [6.0, 0.04, 3.0],    // 第六泛音 4%
      [7.0, 0.02, 4.0],    // 第七泛音 2%
    ];

    // 对于高音（>1000Hz），减少高次泛音（模拟真实钢琴）
    final effectiveHarmonics = frequency > 1000
        ? harmonics.take(3).toList()
        : harmonics;

    // ADSR 参数
    final attackSamples = (sampleRate * 0.008).round();   // 8ms 起音
    final decaySamples = (sampleRate * 0.25).round();     // 250ms 衰减
    final sustainLevel = 0.65;                             // 延音水平 65%
    final releaseStart = numSamples - (sampleRate * 0.15).round(); // 最后 150ms 释音

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;

      // ADSR 包络
      double envelope;
      if (i < attackSamples) {
        // Attack: 快速上升
        envelope = i / attackSamples;
      } else if (i < attackSamples + decaySamples) {
        // Decay: 衰减到延音水平
        final decayProgress = (i - attackSamples) / decaySamples;
        envelope = 1.0 - (1.0 - sustainLevel) * decayProgress;
      } else if (i > releaseStart) {
        // Release: 渐弱
        envelope = sustainLevel * max(0, (numSamples - i) / (numSamples - releaseStart));
      } else {
        // Sustain
        envelope = sustainLevel;
      }

      // 叠加所有泛音
      double wave = 0;
      for (final h in effectiveHarmonics) {
        final freq = frequency * h[0] + h[2];
        final amp = h[1];
        // 每个泛音有自己的微小相位偏移，增加自然感
        wave += sin(2 * pi * freq * t + h[0] * 0.1) * amp;
      }

      // 归一化
      wave /= effectiveHarmonics.fold<double>(0, (sum, h) => sum + h[1]);

      final sample = (wave * envelope * 0.7 * 32767).round();
      final clamped = sample.clamp(-32768, 32767);
      bytes.addByte(clamped & 0xFF);
      bytes.addByte((clamped >> 8) & 0xFF);
    }

    return bytes.toBytes();
  }

  /// 播放节拍器点击音
  Future<void> playClick() async {
    final wav = generateClick();
    await _player.play(BytesSource(wav));
  }

  /// 播放预生成的 WAV 数据（低延迟复用）
  Future<void> playPreGenerated(Uint8List wavData) async {
    await _player.stop();
    await _player.play(BytesSource(wavData));
  }

  /// 播放指定频率的标准音（钢琴音色）
  Future<void> playTone(double frequency) async {
    final wav = generateTone(frequency);
    await _player.stop();
    await _player.play(BytesSource(wav));
  }

  /// 停止播放
  Future<void> stop() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
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

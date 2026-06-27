import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'yin_detector.dart';

/// 音高检测服务 — 真实麦克风 + YIN 算法
class PitchDetectorService extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final YinDetector _yin;

  double? _currentFrequency;
  double? _targetFrequency;
  double? _currentCents;
  bool _isListening = false;
  StreamSubscription<RecordState>? _stateSub;
  StreamSubscription<Uint8List>? _audioSub;

  // 用于跨帧连续检测的音频缓冲区
  final List<double> _buffer = [];
  static const int _bufferSize = 4096; // YIN 窗口大小（约 93ms @44100）
  static const int _sampleRate = 44100;

  PitchDetectorService()
      : _yin = YinDetector(
          sampleRate: _sampleRate,
          threshold: 0.15,
          minFreq: 60,
          maxFreq: 2000,
        );

  double? get currentFrequency => _currentFrequency;
  double? get targetFrequency => _targetFrequency;
  double? get currentCents => _currentCents;
  bool get isListening => _isListening;

  String get evaluation {
    if (_currentCents == null) return '等待输入...';
    final c = _currentCents!.abs();
    if (c <= 5) return '完美！';
    if (c <= 15) return '很好';
    if (c <= 30) return '偏低/偏高';
    if (c <= 50) return '偏离较大';
    return '请重新校准';
  }

  /// 设置目标音高
  void setTarget(double frequency) {
    _targetFrequency = frequency;
    _updateCents();
    notifyListeners();
  }

  /// 启动麦克风监听
  Future<void> startListening() async {
    if (_isListening) return;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      debugPrint('麦克风权限未授权');
      return;
    }

    _isListening = true;
    _buffer.clear();

    try {
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
        ),
      );

      _audioSub = stream.listen(
        (data) => _processAudioChunk(data),
        onError: (e) => debugPrint('录音错误: $e'),
      );
    } catch (e) {
      debugPrint('启动录音失败: $e');
      _isListening = false;
    }

    notifyListeners();
  }

  /// 处理 PCM 音频数据块
  /// [data] 16-bit PCM, 小端序
  void _processAudioChunk(Uint8List data) {
    // 将字节转为 double（归一化到 -1.0 ~ 1.0）
    final samples = Float64List(data.length ~/ 2);
    for (int i = 0; i < samples.length; i++) {
      final byteIndex = i * 2;
      final value = (data[byteIndex + 1] << 8) | data[byteIndex];
      samples[i] = value / 32768.0;
    }

    // 添加到缓冲区
    _buffer.addAll(samples);

    // 缓冲区足够大时运行 YIN 检测
    while (_buffer.length >= _bufferSize) {
      final window = _buffer.sublist(0, _bufferSize);
      final pitch = _yin.detectPitch(window);

      if (pitch != null && pitch >= 60 && pitch <= 2000) {
        _currentFrequency = pitch;
        _updateCents();
        notifyListeners();
      }

      // 滑动窗口，步长为一半窗口（约 46ms 更新一次）
      _buffer.removeRange(0, _bufferSize ~/ 2);
    }
  }

  void _updateCents() {
    if (_currentFrequency != null && _targetFrequency != null && _targetFrequency! > 0) {
      _currentCents = 1200 * (_log2(_currentFrequency! / _targetFrequency!));
    }
  }

  /// 停止监听
  Future<void> stopListening() async {
    _isListening = false;
    await _audioSub?.cancel();
    _audioSub = null;
    await _stateSub?.cancel();
    _stateSub = null;
    await _recorder.stop();
    _buffer.clear();
    notifyListeners();
  }

  /// 模拟音高输入（Web / 开发调试用）
  void simulateFrequency(double frequency) {
    _currentFrequency = frequency;
    _updateCents();
    notifyListeners();
  }

  /// 清空当前检测结果
  void clear() {
    _currentFrequency = null;
    _currentCents = null;
    notifyListeners();
  }

  double _log2(double x) {
    if (x <= 0) return 0;
    final ln2 = 0.6931471805599453;
    return x > 0 ? (x.abs() > 0 ? _log(x) / ln2 : 0) : 0;
  }

  double _log(double x) {
    // 使用泰勒级数近似 log
    if (x <= 0) return double.negativeInfinity;
    double result = 0;
    double term = (x - 1) / (x + 1);
    double power = term;
    for (int i = 1; i < 20; i += 2) {
      result += power / i;
      power *= term * term;
    }
    return 2 * result;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
